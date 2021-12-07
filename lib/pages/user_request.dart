import 'package:ampama/pages/upload_design.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/main_scoped.dart';
import '../models/request.dart';
import '../models/collection.dart';
import '../utility/timeago.dart';
import '../pages/collection_request.dart';
import '../widgets/measurements_textfields.dart';

class UserRequest extends StatefulWidget {
  final bool userOwn;
  final MainModel _model;
  UserRequest(this.userOwn, this._model);

  @override
  State<StatefulWidget> createState() {
    return _UserRequestState();
  }
 }
class _UserRequestState extends State<UserRequest> {
  
  final MeasurementTextFields measurementTextFields =
      new MeasurementTextFields();
  Request selectedRequest;

  @override
  void initState() {
    selectedRequest = widget._model.selectedRequest;
    super.initState();
  }
  
  void _editRequest(MainModel model, BuildContext context) {

    if (!widget.userOwn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CollectionRequest(_getCollection(model));
          },
        ),
      );
    } else {
      model.selectCollection(selectedRequest.collectionId);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return UploadDesign(model);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Customer Request'),
          actions: <Widget>[
            selectedRequest.userId == model.user.id
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editRequest(model, context))
                : Container()
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FadeInImage(
                  image: NetworkImage(_getCollectionImage(model)),
                  height: 350.0,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/trans.png')),
              SizedBox(height: 10.0),
              Text(
                'Comment',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              Text(selectedRequest.comment),
              SizedBox(height: 10.0),
              Text(
                'Measurements(cm)',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              _getCollection(model).dress
                  ? _buildmea(context, 0)
                  : Container(),
              _getCollection(model).shirt
                  ? _buildmea(context, 1)
                  : Container(),
              _getCollection(model).trousers
                  ? _buildmea(context, 2)
                  : Container(),
              Divider(),
              SizedBox(height: 30.0),
              Text('Request\'s Details',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Name: ' + selectedRequest.username),
              Text('Tel: ' + '+233 ' + selectedRequest.userphone),
              Text('Time Requested: ' + timeago(selectedRequest.time))
            ],
          ),
        ),
      );
    });
  }

  Collection _getCollection(MainModel model) {
    Request request = selectedRequest;
    if (request == null) {
      return null;
    }
    for (int i = 0; i < model.everyCollections.length; i++) {
      if (model.everyCollections[i].id == request.collectionId)
        return model.everyCollections[i];
    }
    return null;
  }

  String _getCollectionImage(MainModel model) {
  
    for (int i = 0; i < model.everyCollections.length; i++) {
      if (model.everyCollections[i].id == selectedRequest.collectionId)
        return model.everyCollections[i].image;
    }
    return null;
  }

  Widget _buildmea(BuildContext context, int type) {
    return measurementTextFields.allfields(
        type, context, selectedRequest.measurements, true);
  }
}