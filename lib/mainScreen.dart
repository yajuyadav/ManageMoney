import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manage_money/My%20Savings.dart';
import 'package:manage_money/MyDebts.dart';
import 'package:manage_money/add_view.dart';
import 'package:manage_money/auth_services.dart';
import 'package:manage_money/loginscreen.dart';
import 'package:manage_money/scheduled.dart';
import 'package:provider/provider.dart';

class mainscreen extends StatefulWidget {
  @override
  _mainscreenState createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {

  final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(DateTime
      .parse('2021-08-05 16:49:42.044')
      .millisecondsSinceEpoch);
  bool isLoading = false;
  String text = "";
  final style = TextStyle(fontSize: 20);
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
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
          title: Text("Manage Money"),
          bottom:
          TabBar(
            indicatorColor: Colors.white,
            labelStyle: style,
            tabs: [
              Tab(text: 'Balance',),
              Tab(text: 'Spent',),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Added(),
            Spent()
          ],

        ),
        drawer: Drawer(
          child: Material(
              color: Colors.indigo[700],
              child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users')
                          .doc(user!.uid)
                          .snapshots(),
                      builder:
                          (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors
                                  .lightBlue[800]!)));
                        }
                        DocumentSnapshot doc = snapshot.data!;
                        return Column(
                          children: [
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.person_sharp, size: 25,
                                color: Colors.white,),
                              title: Text(
                                doc['name'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.mail_outlined, size: 25,
                                color: Colors.white,),
                              title: Text(
                                doc['Email'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Divider(color: Colors.white),
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.pending_actions, size: 25,
                                color: Colors.white,),
                              title: Text(
                                'My Debts',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyDebts()));
                              },
                            ),
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.monetization_on_outlined,
                                size: 25, color: Colors.white,),
                              title: Text(
                                'My Savings',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MySavings()));
                              },
                            ),
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.schedule_outlined, size: 25,
                                color: Colors.white,),
                              title: Text(
                                'Scheduled Bills',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => scheduled()));
                              },
                            ),
                            ListTile(
                              tileColor: Colors.indigo[700],
                              leading: Icon(Icons.logout, size: 25,
                                color: Colors.white,),
                              title: Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                logout();
                              },
                            ),
                          ],
                        );
                      })
              )
          ),
        ),
      ),
    );
  }
  Future<void> logout() async {
    await showDialog(
      context: context,
      builder: (currentContext) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 10),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.lightBlue[800]),
            SizedBox(width: 5,),
            Text('Log Out?'),
          ],
        ),
        content: Text('Are you sure you want to Logout?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();

              context.read<AuthService>().signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => loginscreen()),
                      (route) => false);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
  class Added extends StatefulWidget {
  @override
  _AddedState createState() => _AddedState();
  }
  class _AddedState extends State<Added> {
    User? user = FirebaseAuth.instance.currentUser;
  bool isLoading= false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading == false
        ? SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
            children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
        StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
            .doc(user!.uid)
            .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors
                            .lightBlue[800]!)));
                  }
        DocumentSnapshot doc= snapshot.data!;
        print(doc);
        return Container(
        margin: EdgeInsets.all(10),
        height: 150,
        width: 160,
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        ),
        border: Border.all(
        color: Colors.white,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                children: <Widget>[
                Text("₹", style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold),),
                Flexible( child: Text(doc['Balance'], style: TextStyle(color: Colors.white, fontSize: 28),)),
                ],
                ),
                ),
        );
        }),
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => addView("Balance", "aabbcc")));
                              },
                              child: Container(
                                margin: EdgeInsets.all(10,),
                                height: 150,

                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Icon(
                                    Icons.add, size: 120, color: Colors.white,
                                  )
                                ),
                              ),
                            ),
                          ],
                        ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users')
                      .doc(user!.uid)
                      .collection("Added")
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
                      ListView(
                        shrinkWrap: true,
                        physics: new ClampingScrollPhysics(),
                        children: snapshot.data!.docs.map((doc)
                        {
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
                                child: Text("Added: "+ "₹" + doc['AddedAmount'],
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
                              trailing: Text(
                                doc["AddedFrom"], style: TextStyle(color: Colors.lightBlue[800], fontSize: 26),
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: (){

                              },
                            ),
                          );
                        }).toList(),
                      )
                        :Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 80,
                        child: ListTile(
                          tileColor: Colors.black12,
                          leading: Icon(Icons.monetization_on_outlined, size: 70,),
                          title: Text('No Balance to Show yet.'),
                        ),
                      ),
                    );
                  }
              ),
            ]),
        )
            : Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[800]!),
        )),
    );
  }}
class Spent extends StatefulWidget {
  @override
  _SpentState createState() => _SpentState();
}

class _SpentState extends State<Spent> {
  bool isLoading= false;
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
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
                    .collection("Spent")
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
                                      color: Colors.lightBlue[800]!, width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text("Spent: "+ "₹" + doc['SpentAmount'],
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
                                  trailing: Text(
                                    doc["SpentFor"], style: TextStyle(color: Colors.lightBlue[800], fontSize: 26),
                                    overflow: TextOverflow.ellipsis,
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
                            leading: Icon(Icons.watch_later_outlined, size: 70,),
                            title: Text('No Spent history to show.'),
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
    );
  }}

