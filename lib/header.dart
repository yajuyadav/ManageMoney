import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  HomeHeader(this.Amount);
  final String Amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.lightBlue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
      ),

      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("₹${(Amount)}", style: TextStyle(color: Colors.white, fontSize: 65)),
              ),
            ),
            Text("Total Saved", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}