
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class addSaving extends StatefulWidget {
  @override
  _addSavingState createState() => _addSavingState();
}
class _addSavingState extends State<addSaving> {
  final _formkey = GlobalKey<FormState>();
  void backButton() {
    Navigator.pop(context);
  }
  add(BuildContext context, amount, goal,name, about) async {
    User? user= FirebaseAuth.instance.currentUser;
    if (_formkey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        DateTime now= new DateTime.now();
        await FirebaseFirestore.instance.collection("users")
        .doc(user!.uid)
        .collection("Savings")
            .add({
          'Amount': amount,
          'Goal': goal,
          'SavingName': name,
          'About': about,
          'timeStamp': FieldValue.serverTimestamp(),
          'Date': now.day.toString()+ '/' + now.month.toString() + '/' + now.year.toString(),
          'Time': now.hour.toString() + ':' + (now.minute/10).toString().replaceAll('.', ''),
        }).then((value) async {
          await FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .collection("Savings")
              .doc(value.id)
              .update({'id': value.id});
        });
        FirebaseFirestore.instance.collection("users")
            .doc(user.uid).get().then((value) {
          FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .update({'Savings': (double.parse(value['Savings'])+ double.parse(amount)).toString()});
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Saving ${name} Created")));
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
    }
  }

  TextEditingController amountController = TextEditingController();
  TextEditingController goalController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  bool isLoading = false;
  late firebase_storage.Reference ref;

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: (){
        backButton();
        return Future.value(false);
      },
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.lightBlue[800],
          title: Text("Add Saving"),
        ),
        body: isLoading == false ?
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Amount to Add* ",
                            hintStyle: TextStyle(color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54,
                                  width: 2.0),
                            ),
                            prefix: Padding(
                              padding: EdgeInsets.all(4),
                            ),
                          ),
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          validator: (value)  {
                            if (value!.isEmpty) {
                              return "This field should not be empty";
                            }

                            return null;
                          }

                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Goal Amount',
                            hintStyle: TextStyle(color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54,
                                  width: 2.0),
                            ),
                            prefix: Padding(
                              padding: EdgeInsets.all(4),
                            ),
                          ),
                          controller: goalController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Savings name* ",
                            hintStyle: TextStyle(color: Colors.black54),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54,
                                  width: 2.0),
                            ),
                            prefix: Padding(
                              padding: EdgeInsets.all(4),
                            ),
                          ),
                          controller: nameController,
                          validator: (value)  {
                            if (value!.isEmpty) {
                              return "This field should not be empty";
                            }

                            return null;
                          }

                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 10, left: 10),
                      child: TextFormField(
                        maxLines: 10,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'About Savings',
                          hintStyle: TextStyle(color: Colors.black54),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54,
                                width: 2.0),
                          ),
                          prefix: Padding(
                            padding: EdgeInsets.all(4),
                          ),
                        ),
                        controller: aboutController,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: FlatButton(
                        color: Colors.lightBlue[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onPressed: () async {
                          final String amount = amountController.text.trim();
                          final String goal = goalController.text.trim();
                          final String name = nameController.text.trim();
                          final String about = aboutController.text.trim();
                          add(context,amount,goal,name,about);
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                    ),

                  ]
              ),
            ),
          ),
        )
            : Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!),
        ),),

      ),
    );
  }

}
