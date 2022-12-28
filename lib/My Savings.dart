import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage_money/addSaving.dart';
import 'package:manage_money/mainScreen.dart';
import 'package:manage_money/viewSaving.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';


class MySavings extends StatefulWidget {


  @override
  _MySavingsState createState() => _MySavingsState();
}

class _MySavingsState extends State<MySavings> {
  User? user= FirebaseAuth.instance.currentUser;
  bool isLoading= false;
  bool val= false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
            ),
            title: Text("My Savings"),
          ),
          body: isLoading == false
              ? SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Column(
                  children: [
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
                        padding: const EdgeInsets.all(12.0),
                        child:
                        Column(
                          children: [
                            Text("These Savings are not added to your main Balance:)", style: TextStyle(color: Colors.lightBlue[800], fontSize: 14),),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users')
                            .doc(user!.uid)
                            .collection("Savings")
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
                                    color: Colors.lightBlue[800]!,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("₹" + doc['Amount'],
                                          style: TextStyle(color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: double.parse(doc['Time'].split(':')[0])< 12?
                                        Text(doc['Date'] + " , " + doc['Time'] + " AM", style: TextStyle(color: Colors.white),)
                                            : Text(doc['Date'] + " , " + doc['Time'] + " PM", style: TextStyle(color: Colors.white)),
                                      ),
                                      trailing: Icon(Icons.double_arrow, color: Colors.white,),
                                        onTap: (){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => viewSaving(doc['Amount'], doc['Goal'], doc['SavingName'], doc['About'], doc.id)));
                                        },
                                      onLongPress: (){
                                        deleteSaving(doc.id);
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
                                title: Text('Start a saving to save money'),
                              ),
                            ),
                          );
                        }
                    ),
                  ])
          )
              : Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!),
          )),
          floatingActionButton:  isLoading==false ? FloatingActionButton(
            onPressed:(){

              showAd();
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addSaving()));
            },

            child:Icon(Icons.add),

            backgroundColor: Colors.lightBlue[800],
          ) : Container(),
        )
    );
  }

  showAd() async{
    final InterstitialAd interestitialAd= InterstitialAd();
    if(!interestitialAd.isAvailable){
      await interestitialAd.load(unitId: 'ca-app-pub-4619363086776822/7362815931');
    }
    if(interestitialAd.isAvailable){
      await interestitialAd.show();
    }
  }
  Future<void> deleteSaving(savingId) async {
    await showDialog(
      context: context,
      builder: (currentContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.redAccent),
            SizedBox(width: 5,),
            Text('Delete this Saving?'),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await FirebaseFirestore.instance.collection("users")
              .doc(user!.uid)
              .collection("Savings")
              .doc(savingId).delete();
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Deleted Successfully!")));
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}