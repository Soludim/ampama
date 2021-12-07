import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Login', icon: Icons.person_add),
];

class PopUpMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  PopupMenuButton(itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(children: <Widget>[
                       Icon(choice.icon),
                       SizedBox(width: 10.0),
                       Text(choice.title)
                    ],) 
                  );
                }).toList();
            });
  }
}