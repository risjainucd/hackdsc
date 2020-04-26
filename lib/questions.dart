import 'package:flutter/material.dart';


void main() => runApp(Questions());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Questions(),
    );
  }
}

class Questions extends StatefulWidget {
  @override
  _QuestionState createState() => new _QuestionState();
}
class _QuestionState extends State<Questions> {
  
  bool enabledFever=false;
  bool enabledCough=false;
  bool enabledTired=false;
  bool enabledCorona=false;
  
  @override
  Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Please tell us if you have these symptoms'),
          centerTitle: true,
        ),
        body:new Container(
          padding: EdgeInsets.all(20.0),
          child:new Column(
            
            children: <Widget>[
              new Text(
                'Do you have fever?'
              ),
              new Switch(
                onChanged: (bool val){
                  setState(() {
                    enabledFever=val;
                  });
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent[400],
                value: enabledFever,
              ),
              new Text('Do you have dry cough?'),
              new Switch(
                onChanged: (bool val){
                  setState(() {
                    enabledCough=val;
                  });
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent[400],
                value: enabledCough,
              ),
              new Text('Do you feel tired?'),
              new Switch(
                onChanged: (bool val){
                  setState(() {
                    enabledTired=val;
                  });
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent[400],
                value: enabledTired,
              ),
              new Text('Have you been tested for COVID-19?'),
              new Switch(
                onChanged: (bool val){
                  setState(() {
                    enabledCorona=val;
                  });
                },
                activeColor: Colors.green,
                activeTrackColor: Colors.greenAccent[400],
                value: enabledCorona,
              ),


          ],
          
          )
        )
      );
}
}