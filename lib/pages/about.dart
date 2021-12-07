import 'package:flutter/material.dart';
import '../utility/static_fields.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            child: Text('For more information',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 5.0),
          Row(
            children: <Widget>[
              Icon(Icons.call, color: Colors.black),
              Text(contact,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ))
            ],
          ),
          Row(
            children: <Widget>[
              Icon(Icons.mail, color: Colors.black),
              Text(companyEmail,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ))
            ],
          ),
          Row(
            children: <Widget>[
              Icon(Icons.place, color: Colors.black),
              Text(location,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}