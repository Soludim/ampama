import 'package:flutter/material.dart';
import '../models/admin_drawer.dart';

class AdminDrawer {
  Widget buildSideDrawer(BuildContext context, List<DrawerItem> drawerItems) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          _populateDrawer(drawerItems),
        ],
      ),
    );
  }

  Widget _populateDrawer(List<DrawerItem> drawerItems) {
    return Column(
        children: drawerItems
            .map((item) => Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      onTap: item.action,
                    ),
                    Divider()
                  ],
                ))
            .toList());
  }
}