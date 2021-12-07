import 'package:flutter/material.dart';
import '../pages/collection_create_edit.dart';
import '../pages/collection_list.dart';
import '../scoped_models/main_scoped.dart';

class ManageCollection extends StatelessWidget {

  final MainModel model;
  ManageCollection(this.model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage Collections'),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          bottom: TabBar(
            tabs: <Widget>[
                   Tab(
                icon: Icon(Icons.list),
                text: 'My Collections',
              ),
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Collection',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[CollectionList(model), CollectionCreateEdit(model)],
        ),
      ),
    );
  }
}