import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage_money/mainScreen.dart';


class addView extends StatefulWidget {
  final String screen, savingId;
   addView(this.screen, this.savingId);
  @override
  _addViewState createState() => _addViewState();
}

class _addViewState extends State<addView> {
  String _amount = "0";
   String _error= "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.indigo[700],
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: Column(
                children: [
                  Spacer(),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      "₹$_amount",
                      style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text("${_error }", style: TextStyle(color: Colors.white)),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.4,
                        children: setKeyboard(),
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all( 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FlatButton(
                              color: Colors.white30,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: widget.screen== 'Balance'?
                              Text("Add to Balance", style: TextStyle(color: Colors.white, fontSize: 20))
                              :Text("Add to Savings", style: TextStyle(color: Colors.white, fontSize: 20)),
                              onPressed: () async {
                                User? user= FirebaseAuth.instance.currentUser;
                                if (_amount == "0") {
                                  setState(() {
                                    _error = "Enter an amount";
                                  });
                                }
                                else{
                                  if(widget.screen== 'Balance') {
                                    addToBalance(_amount);
                                  }
                                  else{
                                    Navigator.pop(context);
                                    await FirebaseFirestore.instance.collection("users")
                                        .doc(user!.uid)
                                        .collection("Savings")
                                        .doc(widget.savingId)
                                        .collection("Changed")
                                        .add({
                                      'Status': 'Added',
                                      'Amount': _amount,
                                      "timeStamp": DateTime.now(),
                                      'Date': DateTime.now().day.toString()+ '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                                      'Time': DateTime.now().hour.toString() + ':' + (DateTime.now().minute/10).toString().replaceAll('.', ''),
                                    });
                                    await FirebaseFirestore.instance.collection("users")
                                    .doc(user.uid)
                                    .collection("Savings")
                                    .doc(widget.savingId)
                                    .get().then((value) {
                                      FirebaseFirestore.instance.collection("users")
                                          .doc(user.uid)
                                          .collection("Savings")
                                          .doc(widget.savingId)
                                          .update({
                                        'Amount': (double.parse(value['Amount'])+ double.parse(_amount)).toString(),
                                      });
                                    });
                                    FirebaseFirestore.instance.collection("users")
                                        .doc(user.uid).get().then((value) {
                                      FirebaseFirestore.instance.collection("users")
                                          .doc(user.uid)
                                          .update({'Savings': (double.parse(value['Savings'])+ double.parse(_amount)).toString()});
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FlatButton(
                            color: Colors.white30,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: widget.screen== 'Balance'?
                            Text("Add to Spent", style: TextStyle(color: Colors.white, fontSize: 20))
                            :Text("Remove ", style: TextStyle(color: Colors.white, fontSize: 20)),
                            onPressed: () async {
                              User? user= FirebaseAuth.instance.currentUser;
                              if (_amount == "0") {
                                setState(() {
                                  _error = "Enter an amount";
                                });
                              }
                              else{
                                if(widget.screen== 'Balance') {
                                  addToSpent(_amount);
                                }
                                else{
                                  Navigator.pop(context);
                                  await FirebaseFirestore.instance.collection("users")
                                      .doc(user!.uid)
                                      .collection("Savings")
                                      .doc(widget.savingId)
                                      .collection("Changed")
                                      .add({
                                    'Status': 'Spent',
                                    'Amount': _amount,
                                    "timeStamp": DateTime.now(),
                                    'Date': DateTime.now().day.toString()+ '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                                    'Time': DateTime.now().hour.toString() + ':' + (DateTime.now().minute/10).toString().replaceAll('.', ''),
                                  });
                                  await FirebaseFirestore.instance.collection("users")
                                      .doc(user.uid)
                                      .collection("Savings")
                                      .doc(widget.savingId)
                                      .get().then((value) {
                                    FirebaseFirestore.instance.collection("users")
                                        .doc(user.uid)
                                        .collection("Savings")
                                        .doc(widget.savingId)
                                        .update({
                                      'Amount': (double.parse(value['Amount'])- double.parse(_amount)).toString(),
                                    });
                                  });
                                  FirebaseFirestore.instance.collection("users")
                                      .doc(user.uid).get().then((value) {
                                    FirebaseFirestore.instance.collection("users")
                                        .doc(user.uid)
                                        .update({'Savings': (double.parse(value['Savings'])- double.parse(_amount)).toString()});
                                  });
                                }
                              }
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberBtn(String number) {
    return FlatButton(
      child: Text(
        "$number",
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      onPressed: () {
        setState(() {
          if (_amount == "0") {
            _amount = "$number";
          } else if (_amount.length == 5) {
            _amount = _amount;
            HapticFeedback.heavyImpact();
          } else {
            _amount += "$number";
          }
        });
      },
    );
  }

  Widget _deleteBtn() {
    return FlatButton(
      child: Text(
        "<",
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      onPressed: () {
        setState(() {
          if (_amount.length <= 1) {
            _amount = "0";
          } else {
            _amount = _amount.substring(0, _amount.length - 1);
          }
        });
      },
    );
  }
  setKeyboard() {
    List<Widget> keyboard = [];

    // numbers 1-9
    List.generate(9, (index) {
      keyboard.add(_numberBtn("${index + 1}"));
    });

    keyboard.add(Text(""));
    keyboard.add(_numberBtn("0"));
    keyboard.add(_deleteBtn());

    return keyboard;
  }
  Future<void> addToBalance(amount) async {
    TextEditingController addedfrom= new TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Money Added from?'),
        content : TextField(
          controller: addedfrom,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => mainscreen()),
                      (route) => false);
              User? user= FirebaseAuth.instance.currentUser;
              await FirebaseFirestore.instance.collection("users")
              .doc(user!.uid)
              .collection("Added")
                  .add({
                "AddedAmount": amount,
                "AddedFrom": addedfrom.text,
                "timeStamp": DateTime.now(),
                'Date': DateTime.now().day.toString()+ '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                'Time': DateTime.now().hour.toString() + ':' + (DateTime.now().minute/10).toString().replaceAll('.', ''),
              }).then((value) {
                FirebaseFirestore.instance.collection("users")
                .doc(user.uid)
                .collection("Added")
                    .doc(value.id)
                    .update({
                  "id": value.id,
                });
              });
              await FirebaseFirestore.instance.collection("users")
                  .doc(user.uid)
                  .get().then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .update({
                  "Balance": (double.parse(value['Balance'])+ double.parse(amount)).toString(),
                });
              });
              },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
  Future<void> addToSpent(amount) async {
    TextEditingController spentfor = new TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Money Spent for?'),
        content : TextField(
          controller: spentfor,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => mainscreen()),
                      (route) => false);
              User? user= FirebaseAuth.instance.currentUser;
             await FirebaseFirestore.instance.collection("users")
             .doc(user!.uid)
             .collection("Spent")
              .add({
               "SpentAmount": amount,
               "SpentFor": spentfor.text,
               "timeStamp": DateTime.now(),
               'Date': DateTime.now().day.toString()+ '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
               'Time': DateTime.now().hour.toString() + ':' + (DateTime.now().minute/10).toString().replaceAll('.', ''),
             }).then((value) {
               FirebaseFirestore.instance.collection("users")
               .doc(user.uid)
               .collection("Spent")
                   .doc(value.id)
                   .update({
                 "id": value.id,
               });
             });
             await FirebaseFirestore.instance.collection("users")
              .doc(user.uid)
              .get().then((value) {
               FirebaseFirestore.instance.collection("users")
                   .doc(user.uid)
                   .update({
                 "Balance": (double.parse(value['Balance'])- double.parse(amount)).toString(),
               });
             });
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}