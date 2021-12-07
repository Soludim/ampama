import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../widgets/admin_drawer.dart';
import '../models/admin_drawer.dart';
import '../widgets/collections_list.dart';
import '../scoped_models/main_scoped.dart';
import '../utility/static_fields.dart';
import '../pages/requests_list.dart';

class CollectionsPage extends StatefulWidget {
  final MainModel model;

  CollectionsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _CollectionsPageState();
  }
}

class _CollectionsPageState extends State<CollectionsPage> {
  final AdminDrawer adminDrawer = new AdminDrawer();

  List<DrawerItem> drawerItems;

  @override
  void initState() {
    drawerItems = <DrawerItem>[
      DrawerItem(
          title: 'Manage Collection',
          icon: Icons.edit,
          action: () => Navigator.pushReplacementNamed(context, '/admin')),
      DrawerItem(
          title: 'Customers Requests',
          icon: Icons.publish,
          action: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        RequestList(widget.model, false)));
          })
    ];

    widget.model.fetchCollections();
    super.initState();
  }

  Widget _buildCollectionsList() {
    final double middleDeviceHeight = MediaQuery.of(context).size.height/2 - 40;

    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: middleDeviceHeight),
              child: Text('No Collections Found!'))
        ]);
        if (model.displayFavoritesOnly) {
          content = ListView(children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: middleDeviceHeight),
                child: Text('No Collection Liked'))
          ]);
        }
        if (model.displayedCollections.length > 0 && !model.isLoading) {
          content = CollectionsList();
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: model.fetchCollections,
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.model.user == null
          ? null
          : widget.model.user.email == adminEmail
              ? adminDrawer.buildSideDrawer(context, drawerItems)
              : null,
      appBar: AppBar(
        title: Text(companyName),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  if (model.user == null) {
                    Navigator.pushNamed(context, '/auth');
                    return;
                  }
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: _buildCollectionsList(),
    );
  }
}
