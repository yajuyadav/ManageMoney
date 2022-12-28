import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage_money/add_view.dart';
import 'package:manage_money/header.dart';
import 'package:manage_money/mainScreen.dart';


class viewSaving extends StatefulWidget {
  final String amount, goal, name, about, id;
  viewSaving(this.amount, this.goal, this.name, this.about, this.id);
  @override
  _viewSavingState createState() => _viewSavingState();
}

class _viewSavingState extends State<viewSaving> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;
  bool val = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          bottomNavigationBar: Container(
            height: 70,
            width: double.infinity,
            //margin: EdgeInsets.symmetric(horizontal: 10),
            child: isLoading==false? _buildButton() : Container(),
          ),
          body: isLoading== false?
              SizedBox(
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                child: Column(
                  children: [
                    HomeHeader(widget.amount),
                    Container(
                      margin: EdgeInsets.all(10,),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.lightBlue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(16))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child:
                        Column(
                          children: [
                            Text("${widget.name}", style: TextStyle(color: Colors.lightBlue[800], fontSize: 40),),
                            SizedBox(height: 10,),
                            Text("${widget.about}", style: TextStyle(color: Colors.lightBlue[800], fontSize: 20),),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10,),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                          ),
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: double.parse(widget.amount)<double.parse(widget.goal)?
                        Text("You need to save ₹ ${double.parse(widget.goal)- double.parse(widget.amount)} more.", style: TextStyle(color: Colors.white, fontSize: 20),)
                            :Text("GOAL COMPLETED!!!!", style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users')
                            .doc(user!.uid)
                            .collection("Savings")
                        .doc(widget.id)
                        .collection("Changed")
                            .orderBy('Date', descending: true)
                            .snapshots(),
                        builder:
                            (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!)));
                          }
                          return snapshot.data!.size>0?
                          Expanded(
                            child: SingleChildScrollView(
                              child: ListView(
                                shrinkWrap: true,
                                physics: new ClampingScrollPhysics(),
                                children: snapshot.data!.docs.map((doc)
                                {
                                  return Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.lightBlue, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("${doc['Status']}: "+ "₹" + doc['Amount'],
                                          style: TextStyle(color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: double.parse(doc['Time'].split(':')[0])< 12?
                                        Text(doc['Date'] + " , " + doc['Time'] + " AM")
                                            : Text(doc['Date'] + " , " + doc['Time'] + " PM"),
                                      ),
                                      onTap: (){

                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          )
                              :Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 80,
                              child: ListTile(
                                tileColor: Colors.black12,
                                leading: Icon(Icons.monetization_on_outlined, size: 70,),
                                title: Text('No History of this Saving.'),
                              ),
                            ),
                          );
                        }
                    ),
                  ],
                ),
              ):  Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!),
          ),),
          floatingActionButton:  isLoading==false ? FloatingActionButton(
            onPressed:(){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addView("Saving", widget.id)));
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.lightBlue[800],
          ) : Container(),
        ),
    );
  }
  Widget _buildButton() {
    bool isLoading=false;
    return isLoading==false?
    Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text("Goal ₹${widget.goal}", style: TextStyle(color: Colors.white, fontSize: 40),)),
      ),
           )
        :Center(child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[300]!),
    ), );
  }
}