import 'package:flutter/material.dart';
import '../scoped_models/main_scoped.dart';
import '../pages/collection_create_edit.dart';
import 'package:scoped_model/scoped_model.dart';

import './collection_create_edit.dart';

class CollectionList extends StatefulWidget {
  final MainModel model;

  CollectionList(this.model);
  @override
  State<StatefulWidget> createState() {
    return _CollectionListState();
  }
}

class _CollectionListState extends State<CollectionList> {
  @override
  void initState() {
    widget.model.fetchCollections(clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectCollection(model.allCollections[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return CollectionCreateEdit(model);
            },
          ),
        ).then((_) {
          model.selectCollection(null);
        });
      },
    );
  }

  Widget _buildPageContent() {
    final double middleDeviceHeight =
        MediaQuery.of(context).size.height / 2 - 40;
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: middleDeviceHeight),
              child: Text('No Collections Found!'))
        ]);
        if (model.allCollections.length > 0 && !model.isLoading) {
          content = ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(model.allCollections[index].id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (DismissDirection direction) async {
                  final bool res = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                            'Are you sure you want to delete this collection ?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          )
                        ],
                      );
                    },
                  );
                  return res;
                },
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.endToStart) {
                    model.selectCollection(model.allCollections[index].id);
                    model.deleteCollection();
                  }
                },
                background: Container(color: Colors.red),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(model.allCollections[index].image),
                      ),
                      title: Text(model.allCollections[index].description
                              .substring(0, 10) +
                          '...'),
                      subtitle:
                          Text(model.allCollections[index].lastTimeModified),
                      trailing: _buildEditButton(context, index, model),
                    ),
                    Divider()
                  ],
                ),
              );
            },
            itemCount: model.allCollections.length,
          );
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => model.fetchCollections(clearExisting: true),
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageContent();
  }
}
