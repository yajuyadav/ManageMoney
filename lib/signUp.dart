import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manage_money/auth_services.dart';
import 'package:manage_money/loginscreen.dart';
import 'package:manage_money/mainScreen.dart';
import 'package:provider/provider.dart';
class signUp extends StatefulWidget {
  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final _formkey= GlobalKey<FormState>();
  moveToScreen(BuildContext context, email, password, name) {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      //start
      context.read<AuthService>().signUp(email, password,).then((value) async{
        if (value== "Signed in") {
          User? user= FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance.collection("users").doc(user!.uid)
              .set({
            'uid' : user.uid,
            'name' : name,
            'photo' : "assets/images/background.jpg",
            'role' : "user",
            'Email': email,
            'Balance': "0.0",
            'Debt': "0.0",
            "Savings": "0.0"
          });
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
      //end
    } }
  bool isLoading=false;
  TextEditingController _controller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
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
                              margin: EdgeInsets.only(top: 60, left: 10),
                              child: Center(
                                child: Text( 'Create new Account',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.lightBlue[800],),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 70, right: 20, left: 20),
                              child: TextFormField(
                                  obscureText: true,
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Your Name',
                                    //labelText: 'Name',
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
                                  controller: namecontroller,
                                  validator: (value){
                                    if(value!.isEmpty) {
                                      return "Name is not entered";
                                    }
                                    return null;
                                  }
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, right: 20, left: 20),
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
                              margin: EdgeInsets.only(top: 10, right: 20, left: 20),
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
                                      return "Passwords doesn't match";
                                    } else if(value.length<8){
                                      return "Password should atleast be 8 characters long";
                                    }
                                    return null;
                                  }
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 7, right: 20, left: 20),
                              child: TextFormField(
                                  obscureText: true,
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    //labelText: 'Confirm Password',
                                    hintStyle: TextStyle(color: Colors.lightBlue[800]),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.lightBlue[800]!, width: 2.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                                    ),
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefix: Padding(
                                      padding: EdgeInsets.all(4),
                                    ),
                                  ),

                                  validator: (value){
                                    if(value != _controller.text) {
                                      return "Passwords doesn't match";
                                    }
                                    return null;
                                  }
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              height: 50,
                              width: 350,
                              child: FlatButton(
                                color: Colors.lightBlue[800],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                                onPressed: () {
                                  final String email= _emailController.text.trim();
                                  final String password= _controller.text.trim();
                                  final String name= namecontroller.text.trim();
                                  // context.read<AuthService>().signUp(email, password);
                                  moveToScreen(context, email, password, name);
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white, fontSize: 20 ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 50, top: 30),
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => loginscreen()));
                                },
                                child: Text("Already have an account? Log In. ",
                                  style: TextStyle(color: Colors.lightBlue[800]),
                                ),
                              ),
                            ),
                          ]
                      )
                  )
              )
          )
              : Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!),
          ), ),
        )
      ],
    );
  }
}
