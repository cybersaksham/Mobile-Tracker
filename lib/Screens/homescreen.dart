import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keys
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Booleans
  bool _isLoading = false;
  bool _isFetched = false;

  // Controllers
  TextEditingController _mobController = new TextEditingController();

  // Fetched Data Variables
  String _error;
  Map<String, dynamic> _fetchedData;

  // Fetching Data
  Future<void> _getData() async {
    if (_formKey.currentState.validate()) {
      // Fetching Starts
      setState(() {
        _isLoading = true;
        _isFetched = false;
      });

      // Hiding Keyboard & Snackbar
      SystemChannels.textInput.invokeMethod("TextInput.hide");
      _scaffoldKey.currentState.hideCurrentSnackBar();

      // Saving Form
      _formKey.currentState.save();

      // Fetching Data
      final String url =
          "https://cybersaksham-apis.herokuapp.com/mobile_trace?mob=${_mobController.text}";
      final response = await http.post(url);
      final data = json.decode(response.body);

      // Finding Errors
      _error = data["error"];
      if (_error == null) {
        // Storing Data
        _fetchedData = data["response"] as Map<String, dynamic>;
      } else {
        // Error Condition
        String msg = "Internal server error. Try later.";
        if (_error == "SERVER")
          msg = "Either mobile no is invalid or data is not present.";
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );

        // If Error - remove previous data
        setState(() {
          _isLoading = false;
          _isFetched = false;
        });
        return;
      }

      // Fetching Ends
      setState(() {
        _isLoading = false;
        _isFetched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Text _getValText(
      String txt, {
      Color color = Colors.black,
      FontWeight fWeight = FontWeight.normal,
    }) {
      return Text(
        txt,
        style: GoogleFonts.aBeeZee(
          textStyle: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: fWeight,
          ),
        ),
      );
    }

    Column _getRow(String key, String value) {
      return Column(
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                key,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              value == "* Privacy"
                  ? _getValText(
                      "Restricted",
                      color: Theme.of(context).errorColor,
                      fWeight: FontWeight.bold,
                    )
                  : value == "" || value == null
                      ? _getValText("Not Found")
                      : _getValText(value),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Mobile Tracker"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Mobile No",
                    hintText:
                        "10 digit Indian Mobile No (without country code)",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == "") return "Mobile No cannot be empty.";
                    if (int.tryParse(val) == null)
                      return "Mobile no is invalid";
                    if (val.length != 10) return "Length is not 10";
                    return null;
                  },
                  controller: _mobController,
                ),
              ),
              SizedBox(height: 15),
              _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      onPressed: () => _getData(),
                      child: Text(
                        "Track",
                        style: GoogleFonts.bigShouldersDisplay(
                          textStyle: TextStyle(
                            letterSpacing: 5,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              _isFetched
                  ? Column(
                      children: [
                        SizedBox(height: 15),
                        _getRow(
                          "Mob No",
                          _mobController.text,
                        ),
                        _getRow(
                          "First Network",
                          _fetchedData["first_network"],
                        ),
                        _getRow(
                          "Current Network",
                          _fetchedData["current_network"],
                        ),
                        _getRow(
                          "Last Live",
                          _fetchedData["last_live"] + " ago",
                        ),
                        _getRow(
                          "Last Login",
                          _fetchedData["last_login"],
                        ),
                        _getRow(
                          "Local Time",
                          _fetchedData["local_time"],
                        ),
                        _getRow(
                          "Location",
                          _fetchedData["location"],
                        ),
                        _getRow(
                          "Main Language",
                          _fetchedData["main_language"],
                        ),
                        _getRow(
                          "Owner Name",
                          _fetchedData["owner"],
                        ),
                        _getRow(
                          "Signal",
                          _fetchedData["signal"],
                        ),
                        _getRow(
                          "Status",
                          _fetchedData["status"],
                        ),
                        _getRow(
                          "Telecom Capital",
                          _fetchedData["telecom_capital"],
                        ),
                        _getRow(
                          "Telecom Circle",
                          _fetchedData["telecom_circle"],
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
