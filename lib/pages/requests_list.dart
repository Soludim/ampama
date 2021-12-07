import 'package:flutter/material.dart';
import '../scoped_models/main_scoped.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/request.dart';
import './user_request.dart';
import '../models/collection.dart';
import '../utility/timeago.dart';
import 'package:toast/toast.dart';

class RequestList extends StatefulWidget {
  final MainModel model;
  final bool
      requestsType; //whether all request or only users requests should be displayed

  RequestList(this.model, this.requestsType);
  @override
  State<StatefulWidget> createState() {
    return _RequestListState();
  }
}

class _RequestListState extends State<RequestList> {
  void populateCollection() async {
    if (widget.model.everyCollections.length < 1)
      await widget.model.fetchCollections(clearExisting: true);
  }

  @override
  void initState() {
    widget.model.setLoading(false);
    populateCollection();
    widget.model
        .fetchRequests(clearExisting: true, onlyForUser: widget.requestsType);
    super.initState();
  }

  void _requestPressed(BuildContext context, int index, MainModel model) {
    if (_getCollection(model, model.allRequests[index]) == null) {
        //collection is no more available
         Toast.show("Sorry, this attire does not exist anymore!!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    model.selectRequest(model.allRequests[index].id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return UserRequest(
              _getCollection(model, model.allRequests[index]).userOwnDesign,
              model);
        },
      ),
    );
  }

  Widget _buildRequestsList() {
    final double middleDeviceHeight =
        MediaQuery.of(context).size.height / 2 - 40;

    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: middleDeviceHeight),
              child: Text('No Request Found!'))
        ]);
        if (model.allRequests.length > 0 && !model.isLoading) {
          content = ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: ListTile(
                  onTap: () => _requestPressed(context, index, model),
                  leading: CircleAvatar(
                    backgroundImage:
                        _getCollectionImage(model, model.allRequests[index]) ==
                                null
                            ? null
                            : NetworkImage(_getCollectionImage(
                                model, model.allRequests[index])),
                  ),
                  title: Text(model.allRequests[index].username),
                  subtitle: Text(timeago(model.allRequests[index].time)),
                  trailing: _buildDeleteButton(context, index, model),
                ),
              );
            },
            itemCount: model.allRequests.length,
          );
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => model.fetchRequests(
              clearExisting: true, onlyForUser: widget.requestsType),
          child: content,
        );
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.delete, color: Color(0xffff4f64)),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Are you sure you want to delete this request ?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    model.selectRequest(model.allRequests[index].id);
                    Request request = model.selectedRequest;
                    model.deleteRequest();

                    Collection collection = _getCollection(model, request);
                    if (collection != null) {
                      if (collection.userOwnDesign) {
                        model.selectCollection(request.collectionId);
                        model.deleteCollection();
                        //delete collection added by user
                      }
                    }

                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          widget.model.selectRequest(null);
          widget.model.selectCollection(null);

          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Request List'),
          ),
          body: _buildRequestsList(),
        ));
  }

  String _getCollectionImage(MainModel model, Request request) {
    if (request == null) {
      return null;
    }
    Collection collection = model.everyCollections.firstWhere(
        (Collection collection) => collection.id == request.collectionId,
        orElse: () => null);
    if (collection == null) return null;
    return collection.image;
  }

  Collection _getCollection(MainModel model, Request request) {
    if (request == null) {
      return null;
    }
    for (int i = 0; i < model.everyCollections.length; i++) {
      if (model.everyCollections[i].id == request.collectionId)
        return model.everyCollections[i];
    }
    return null;
  }
}
