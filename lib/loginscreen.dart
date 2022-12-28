import 'package:flutter/material.dart';
import 'package:manage_money/ResetPage.dart';
import 'package:manage_money/auth_services.dart';
import 'package:manage_money/mainScreen.dart';
import 'package:manage_money/signUp.dart';
import 'package:provider/provider.dart';
class loginscreen extends StatefulWidget {
  @override
  _loginscreenState createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {

  final _formkey= GlobalKey<FormState>();

  moveToScreen(BuildContext context, email, password) {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      context.read<AuthService>().login(email, password, ).then((value) async{
        if (value== "Logged In") {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => mainscreen()),
                  (route) => false);
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value!)));
        }
      });
    }
  }
  bool isLoading=false;
  TextEditingController _controller = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset("assets/images/background.jpg"),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: isLoading==false?
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                  child: Form(
                      key: _formkey,
                      child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 180, right: 20, left: 10),
                              child: TextFormField(
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                  decoration: InputDecoration(
                                    hintText: 'Enter E-mail',
                                    //labelText: 'E-mail',
                                    hintStyle: TextStyle(color: Colors.lightBlue[800]),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.lightBlue[800]!, width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    labelStyle: TextStyle(color: Colors.lightBlue[800]),
                                    prefix: Padding(
                                      padding: EdgeInsets.all(4),
                                    ),
                                  ),
                                  controller: _emailController,
                                  validator: (value){
                                    if(value!.isEmpty) {
                                      return "E-mail is not entered";
                                    }
                                    return null;
                                  }
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, right: 20, left: 10),
                              child: TextFormField(
                                  obscureText: true,
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Password',
                                    //labelText: 'Password',
                                    hintStyle: TextStyle(color: Colors.lightBlue[800]),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.lightBlue[800]!, width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    labelStyle: TextStyle(color: Colors.lightBlue[800]),
                                    prefix: Padding(
                                      padding: EdgeInsets.all(4),
                                    ),
                                  ),
                                  controller: _controller,
                                  validator: (value){
                                    if(value!.isEmpty) {
                                      return "Password is not entered";
                                    }
                                    return null;
                                  }
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 50, top: 20),
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => ResetPage()));
                                },
                                child: Text("Forgot Password?",
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 50,
                              width: 500,
                              child: FlatButton(
                                color: Colors.lightBlue[800],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                onPressed: () {
                                  final String password= _controller.text.trim();
                                  final String email= _emailController.text.trim();

                                  moveToScreen(context, email, password);
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.white, fontSize: 20 ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                              width: double.infinity,

                                 child: Center(
                                   child: Text("OR",
                                    style: TextStyle(color: Colors.lightBlue[800], fontSize: 20),
                                ),
                                 ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 50,
                              width: 200,
                              child: FlatButton(
                                color: Colors.white30,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                onPressed: () {
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => signUp()));
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.lightBlue[800], fontSize: 20 ),
                                ),
                              ),
                            ),
                        ]
                      )
                  )
              )
          )
              : Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[400]!),
          ), ),
        )
      ],
    );
  }
}
