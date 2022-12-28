import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:manage_money/main.dart';
class scheduled extends StatefulWidget {


  @override
  _scheduledState createState() => _scheduledState();
}

class _scheduledState extends State<scheduled> {
  User? user= FirebaseAuth.instance.currentUser;
  bool isLoading= false;
  bool val= false;
  DateTime dateTime= DateTime.now();
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
            title: Text("Scheduled Bills"),
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
                            .collection("Scheduled")
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
                          DateTime dateTime= DateTime.now();
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
                                          color: Colors.lightBlue[700]!, width: 4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("₹" + doc['Amount'] + " to "+ doc['PayTo'],
                                          style: TextStyle(color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: doc['Date']== dateTime.day.toString()+ '/' + dateTime.month.toString() + '/' + dateTime.year.toString()?
                                        Text("LATE "+ doc['Date'],
                                          style: TextStyle(fontSize: 16, color: Colors.redAccent))
                                         : Text("Due "+ doc['Date'],
                                          style: TextStyle(fontSize: 16),
                                        ),
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
                                                    markAsDone(value, doc['Amount'], doc['PayTo'], doc.id);
                                                  }
                                                },
                                              ),
                                            ),
                                            val== false ?
                                            Text("PAID?",
                                              style: TextStyle(fontSize: 12, color: Colors.redAccent),
                                            )
                                                : Text("PAID",
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
                                                  Text('Delete this Bill?'),
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
                                                        .collection("Scheduled")
                                                        .doc(doc.id).delete();
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(content: Text("Deleted Successfully!")));
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
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
                                leading: Icon(Icons.watch_later_outlined, size: 70,),
                                title: Text('No Scheduled bills.'),
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
              amountbill();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.lightBlue[800],
          ) : Container(),
        )
    );
  }
  Future<void> amountbill() async {
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
              namebill(amount.text);
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
  Future<void> namebill(amount) async {
    TextEditingController payTo = new TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Pay To?'),
        content :
        TextField(
          controller: payTo,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
          ),
        ),

        actions: <Widget>[
          FlatButton(
            onPressed: ()  {
              Navigator.pop(context);
              addbill(amount, payTo.text);
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
  Future<void> addbill(amount, payTo) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Text('Schedule'),
        content : SizedBox(
          height: 220,
          //width: double.infinity,
          child: CupertinoDatePicker(
            minimumYear: DateTime.now().year,
            initialDateTime: dateTime,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (dateTime) =>
                setState(() => this.dateTime = dateTime),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              Navigator.pop(context);
              User? user= FirebaseAuth.instance.currentUser;
              await FirebaseFirestore.instance.collection("users")
                  .doc(user!.uid)
                  .collection("Scheduled")
                  .add({
                "Amount": amount,
                "PayTo": payTo,
                "timeStamp": dateTime,
                "num": 0,
                "Clear": false,
                'Date': dateTime.day.toString()+ '/' + dateTime.month.toString() + '/' + dateTime.year.toString(),
                //'Time': dateTime.hour.toString() + ':' + (dateTime.minute/10).toString().replaceAll('.', ''),
              }).then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .collection("Scheduled")
                    .doc(value.id)
                    .update({
                  "id": value.id,
                });
              });
             // showNotification(DateTime.now().microsecond, amount, payTo, DateTime.now());
              shownotification(DateTime.now().microsecond, amount, payTo, dateTime.subtract(Duration(days: 1)));
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
  Future<void> markAsDone(value, amount, payTo, id) async {
    await showDialog(
      context: context,
      builder: (currentContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.redAccent),
            SizedBox(width: 5,),
            Text('Pay ₹ ${amount} to ${payTo}?'),
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
                  .doc(user!.uid).collection("Scheduled")
                  .doc(id).update({
                "num": 1,
                "Clear": true,
              });
              FirebaseFirestore.instance.collection("users")
                  .doc(user.uid).get().then((value) {
                FirebaseFirestore.instance.collection("users")
                    .doc(user.uid)
                    .update({'Balance': (double.parse(value['Balance'])- double.parse(amount)).toString()});
              });
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("₹ ${amount} Paid.")));
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
  Future<void> shownotification(id, amount, payTo, dateTime) async {
   flutterLocalNotificationsPlugin.schedule(
       id,
      '₹ ${amount}',
      'Your bill to ${payTo} is due tomorrow.',
      dateTime,
      NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
              importance: Importance.high,
              color: Colors.indigo[200],
              playSound: true,
              icon: '@mipmap/ic_launcher')));
  }

}
