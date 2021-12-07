import 'package:ampama/models/collection_category.dart';
import 'package:flutter/material.dart';
import '../widgets/home_fab.dart';
import '../widgets/admin_drawer.dart';
import '../models/admin_drawer.dart';
import '../scoped_models/main_scoped.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utility/static_fields.dart';
import '../pages/requests_list.dart';
import 'package:toast/toast.dart';
import './about.dart';


class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final AdminDrawer adminDrawer = new AdminDrawer();
  void authAction(BuildContext context) {
    //to auth page
    Navigator.pushNamed(context, '/auth');
  }

  @override
  initState() {
    widget.model.userSubject.listen((bool isAuthenticated) {
      if (!isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (Route<dynamic> route) => false);
        Toast.show("Please reauthentication is required", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
    super.initState();
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/bg_o.png'),
    );
  }


  void _buildAboutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              companyName,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(companyDescriptionMsg),
                  SizedBox(height: 15.0),
                  Text('For more information',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.0),
                  FittedBox(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: <Widget>[Icon(Icons.call), Text(contact)],
                    ),
                  ),
                  FittedBox(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.mail),
                          Text(companyEmail)
                        ],
                      )),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.place),
                        Text(location),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'Developed by: Soludim',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'),
              )
            ],
          );
        });
  }

  double imageRadius() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeigth = MediaQuery.of(context).size.height;
    if (deviceWidth > deviceHeigth) {
      //landscape mode
      return deviceHeigth / 3 - 8;
    }
    //portrait mode
    return deviceWidth / 3 - 9;
  }

  @override
  Widget build(BuildContext context) {
    List<DrawerItem> drawerItems = <DrawerItem>[
      DrawerItem(
          title: 'Manage Collection',
          icon: Icons.edit,
          action: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/admin');
          }),
      DrawerItem(
          title: 'Customer\'s Requests',
          icon: Icons.publish,
          action: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        RequestList(widget.model, false)));
          })
    ];

    List<Choice> choices = <Choice>[
      Choice(
          title: 'Profile',
          icon: Icons.person,
          action: () {
            Navigator.pushNamed(context, '/user_profile');
          }),
      Choice(
          title: 'Logout', icon: Icons.exit_to_app, action: widget.model.logout)
    ];

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          drawer: model.user == null
              ? null
              : model.user.email == adminEmail
                  ? adminDrawer.buildSideDrawer(context, drawerItems)
                  : null,
          appBar: AppBar(
            title: FittedBox(child: Text(companyName)),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () => _buildAboutDialog(context),
              ),
              model.user == null
                  ? IconButton(
                      icon: Icon(Icons.person_add),
                      onPressed: () => authAction(context))
                  : PopupMenuButton<Choice>(
                      onSelected: (Choice choice) {
                        choice.action();
                      },
                      itemBuilder: (BuildContext context) {
                        return choices.map((Choice choice) {
                          return PopupMenuItem(
                            value: choice,
                            child: Row(children: <Widget>[
                              Icon(choice.icon),
                              SizedBox(width: 20.0),
                              Text(choice.title)
                            ]),
                          );
                        }).toList();
                      },
                    )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: _buildBackgroundImage(),
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        model.collectionCategory = Category.Men;
                        Navigator.pushNamed(context, '/collections');
                      },
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 20.0,
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/mc.jpg'),
                          radius: imageRadius(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Men\'s Collections',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        model.collectionCategory = Category.Women;
                        Navigator.pushNamed(context, '/collections');
                      },
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 20.0,
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/wc.jpg'),
                          radius: imageRadius(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Women\'s Collections',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    SizedBox(height: 20.0),
                    //Divider(color: Colors.black),
                    //About()
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: HomeFab(model));
    });
  }
}

class Choice {
  String title;
  IconData icon;
  Function action;

  Choice({this.title, this.icon, this.action});
}