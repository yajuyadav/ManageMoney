import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage_money/mainScreen.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';


class MyDebts extends StatefulWidget {


  @override
  _MyDebtsState createState() => _MyDebtsState();
}

class _MyDebtsState extends State<MyDebts> {
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
            title: Text("My Debts"),
          ),
          body: isLoading == false
              ? SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users')
                            .doc(user!.uid)
                            .collection("Debts")
                            .orderBy('num', descending: false)
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
                                 val= doc['Clear'];
                                  return Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.lightBlue[800]!, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("₹" + doc['Amount']+ " Owed To " + doc['OwedTo'],
                                          style: TextStyle(color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: double.parse(doc['Time'].split(':')[0])< 12?
                                        Text(doc['Date'] + " , " + doc['Time'] + " AM")
                                            : Text(doc['Date'] + " , " + doc['Time'] + " PM"),
                                      ),
                                      trailing:  Padding(
                                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 34.0,
                                              width: 34.0,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: val== true? Colors.lightBlue[800]! :Colors.redAccent, width: 3
                                                  ),
                                                  borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Checkbox(
                                                checkColor: Colors.lightBlue[800],
                                                activeColor: Colors.white,
                                                side: BorderSide(color: Colors.white),
                                                value: val,
                                                onChanged: (value) {
                                                  if(value== true){
                                                    markAsDone(value, doc['Amount'], doc['OwedTo'], doc.id);
                                                  }
                                                },
                                              ),
                                            ),
                                            val== false ?
                                              Text("CLEAR DEBT?",
                                                style: TextStyle(fontSize: 12, color: Colors.redAccent),
                                              )
                                                : Text("CLEARED DEBT",
                                              style: TextStyle(fontSize: 12, color: Colors.lightBlue[800]),
                                            )
                                          ],
                                        ),
                                      ),
                                      onLongPress: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (currentContext) => AlertDialog(
                                          insetPadding: EdgeInsets.symmetric(vertical: 10),
                                          title: Row(
                                            children: [
                                              Icon(Icons.warning_amber_outlined, color: Colors.redAccent),
                                              SizedBox(width: 5,),
                                              Text('Delete this Debt?'),
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
                                                    .collection("Debts")
                                                    .doc(doc.id).delete();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(content: Text("Deleted Successfully!")));
                                              },
                                              child: Text('Yes'),
                                            ),
                                          ],
                                        ),
                                        );
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
                                leading: Icon(Icons.pending_actions, size: 70,),
                                title: Text('No Debts added yet'),
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
     amountdebt();
    },
    child: Icon(Icons.add),
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
  Future<void> amountdebt() async {
    TextEditingController amount = new TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Amount?'),
        content :
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Amount'
              ),
            ),

        actions: <Widget>[
          FlatButton(
            onPressed: ()  {
              Navigator.pop(context);
             addDebt(amount.text);
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
  Future<void> addDebt(amount) async {
    TextEditingController owedTo = new TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Owed To?'),
        content :
            TextField(
              controller: owedTo,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Owed To'
              ),
            ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.pop(context);
              User? user= FirebaseAuth.instance.currentUser;
              await FirebaseFirestore.instance.collection("users")
                  .doc(user!.uid)
                  .collection("Debts")
                  .add({
                "Amount": amount,
                "OwedTo": owedTo.text,
                "timeStamp": DateTime.now(),
                "num": 0,
                "Clear": false,
                'Date': DateTime.now().day.toString()+ '/' + DateTime.now().month.toString() + '/' + DateTime.now().year.toString(),
                'Time': DateTime.now().hour.toString() + ':' + (DateTime.now().minute/10).toString().replaceAll('.', ''),
              }).then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .collection("Debts")
                    .doc(value.id)
                    .update({
                  "id": value.id,
                });
              });
              FirebaseFirestore.instance.collection("users")
              .doc(user.uid).get().then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .update({'Debt': (double.parse(value['Debt'])+ double.parse(amount)).toString()});
              });
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
  Future<void> markAsDone(value, amount, owedTo, id) async {
    await showDialog(
      context: context,
      builder: (currentContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.redAccent),
            SizedBox(width: 5,),
            Text('Pay ₹ ${amount} to ${owedTo}?'),
          ],
        ),
        content: Text('Amount will be deducted from your main balance.'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                isLoading=true;
              });
              User? user= FirebaseAuth.instance.currentUser;
              setState(()  {
                this.val= value;
              });
              await FirebaseFirestore.instance.collection("users")
              .doc(user!.uid).collection("Debts")
              .doc(id).update({
                "num": 1,
                "Clear": true,
              });
              FirebaseFirestore.instance.collection("users")
                  .doc(user.uid).get().then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .update({'Debt': (double.parse(value['Debt'])- double.parse(amount)).toString()});
              });
              FirebaseFirestore.instance.collection("users")
                  .doc(user.uid).get().then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .update({'Balance': (double.parse(value['Balance'])- double.parse(amount)).toString()});
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("₹ ${amount} Debt Cleared")));
              setState(() {
                isLoading=false;
              });
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}