import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_app/common/theme_helper.dart';
import 'package:music_app/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgate_password_page.dart';
import 'registration_page.dart';
import 'widgets/header_widget.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}): super(key:key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = true;
  void validation(){
    if(usernameController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the username");
    }
    else if(passwordController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please enter the password");
    }else
    {
      LoginPage();
    }

  }
  double _headerHeight = 250;
  Key _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true, Icons.login_rounded), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),// This will be the login form
                  child: Column(
                    children: [
                      Text(
                        'Hello',
                        style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Signin into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextField(
                                  controller: usernameController,
                                  decoration: ThemeHelper().textInputDecoration('User Name', 'Enter your user name'),
                                ),
                                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              SizedBox(height: 30.0),
                              Container(
                                // ignore: sort_child_properties_last
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: _passwordVisible,
                                  decoration: ThemeHelper().textInputDecoration('Password', 'Enter your password'),
                                  ),
                                decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                             SizedBox(height: 15.0),
                              Container(
                                margin: EdgeInsets.fromLTRB(10,0,10,20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push( context, MaterialPageRoute( builder: (context) => ForgotPasswordPage()), );
                                  },
                                  child: Text( "Forgot your password?", style: TextStyle( color: Colors.blue, ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  validation();
                                },
                                child: Container(
                                  decoration: ThemeHelper().buttonBoxDecoration(context),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                      child: Text('Sign In'.toUpperCase(),
                                        style: TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),),
                                    ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(10,20,10,20),
                                //child: Text('Don\'t have an account? Create'),
                                child: Text.rich(
                                    TextSpan(
                                        children: [
                                          TextSpan(text: "Don't have an account? "),
                                          TextSpan(
                                            text: 'Create',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                                              },
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                                          ),
                                        ]
                                    )
                                ),
                              ),
                            ],
                          )
                      ),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );

  }

  Future<void> LoginPage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await http.post(
      Uri.parse("https://api-rdms.sooritechnology.com.np/api/login"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: (json.encode(
          {
            "username": usernameController.text,
            "password": passwordController.text
          })),
    );
    log(response.body);
    // log("This is the response form backend"+response.body);
    log("This is the response code"+response.statusCode.toString());

    if (response.statusCode == 200) {
      prefs.setString("access_token", jsonDecode(response.body)['tokens']['access_token']);
      prefs.setString("name", jsonDecode(response.body)['username']);
      usernameController.clear();
      passwordController.clear();
      Fluttertoast.showToast(msg: "Success");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomeScreen()));


    } else if(response.statusCode==401){
      usernameController.clear();
      passwordController.clear();
      Fluttertoast.showToast(msg: "${json.decode(response.body)}");
    }

  }

}
