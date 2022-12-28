import 'package:flutter/material.dart';
import 'package:manage_money/auth_services.dart';
import 'package:manage_money/loginscreen.dart';

import 'package:provider/provider.dart';
class ResetPage extends StatefulWidget {
  @override
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  TextEditingController _email = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[700],
      body: isLoading == false
          ? Padding(
        padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
        child: Column(
          children: [

            Container(
              margin: EdgeInsets.only(top: 20),

              child: Text( 'A Password reset email will be sent to you. Please follow it to reset your password.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
              ),

            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(hintText: "Email",
                hintStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                  color: Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    context.read<AuthService>()
                        .resetPassword(
                      email: _email.text.trim(),
                    )
                        .then((value) {
                      if (value == "Email sent") {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => loginscreen()),
                                (route) => false);
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(value)));
                      }
                    });
                  },
                  child: Text("Reset account",
                    style: TextStyle(color: Colors.white),)),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => loginscreen()));
              },
              child: Text("Already have an account? Login ",
                style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      )
          : Center(child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!))),
    );
  }
}
