import 'dart:io';
import 'package:ampama/utility/static_fields.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/collection_category.dart';
import '../models/collection.dart';
import '../models/request.dart';
import '../widgets/image.dart';
import '../scoped_models/main_scoped.dart';
import '../widgets/measurements_textfields.dart';
import '../pages/requests_list.dart';

class UploadDesign extends StatefulWidget {
  final MainModel _model;
  UploadDesign(this._model);
  @override
  State<StatefulWidget> createState() {
    return _UploadDesignState();
  }
}

class _UploadDesignState extends State<UploadDesign> {
  @override
  void initState() {
    widget._model.setLoading(false);
    super.initState();
  }

  final Map<String, dynamic> _collectionData = {
    'description': null,
    'image': null,
    'category': null,
    'lastTimeModified': null,
    'shirt': false,
    'trousers': false,
    'dress': false,
    'username': null,
    'userphone': null,
    'userId': null,
    'measurements': null,
    'selectedRequest': null
  };

  final Map<String, dynamic> _updateRequest = {
    'time': null,
    'collectionId': null,
    'comment': null,
    'username': null,
    'userphone': null,
    'userId': null,
    'measurements': null
  };

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool changeCategory = true;
  bool changeCheckbox = true;
  String collectionId;

  Category collectionCategory = Category.Men;
  final MeasurementTextFields measurementTextFields =
      new MeasurementTextFields();
  final TextEditingController _descriptionController =
      new TextEditingController();

  Widget _buildDescriptionField(context, Request request) {
    if (request == null && _descriptionController.text.trim() == '') {
      _descriptionController.text = '';
    } else if (request != null && _descriptionController.text.trim() == '') {
      _descriptionController.text = request.comment;
    } else if (request != null && _descriptionController.text.trim() != '') {
      _descriptionController.text = _descriptionController.text;
    } else if (request == null && _descriptionController.text.trim() != '') {
      _descriptionController.text = _descriptionController.text;
    } else {
      _descriptionController.text = '';
    }
    return Container(
      child: TextFormField(
          maxLines: 5,
          controller: _descriptionController,
          decoration: InputDecoration(
            focusColor: Theme.of(context).primaryColor,
            labelText: 'Design description',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          validator: (String value) {
            if (value.isEmpty || value.trim().length < 10) {
              return 'Attire description should be 10+';
            }
          }),
    );
  }

  Widget _buildmea(context, int type, Request request) {
    if (request != null) {
      return measurementTextFields.allfields(
          type, context, request.measurements);
    }
    return measurementTextFields.allfields(type, context);
  }

  Widget _attireHeading() {
    Widget head = _collectionData['dress'] == true ||
            _collectionData['shirt'] == true ||
            _collectionData['trousers'] == true
        ? Align(
            alignment: Alignment.centerLeft,
            child: Text('Attire Measurements(cm)',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold)),
          )
        : Container();
    return head;
  }

  void _setImage(File image) {
    _collectionData['image'] = image;
  }

  Widget _submitButton(MainModel model, scaffold_state) {
    return model.isLoading
        ? Container(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator())
        : Container(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    model.selectedRequestIndex == -1
                        ? Text('Upload Request')
                        : Text('Update Request'),
                    Icon(Icons.file_upload)
                  ],
                ),
                onPressed: () => _uploadMethod(model, scaffold_state)),
          );
  }

  void _uploadMethod(MainModel model, scaffold_state) async {
    if (!_formKey.currentState.validate()) return;

    if (model.user == null) {
      //not authenticated
      Navigator.pushNamed(context, '/auth');
      return;
    }
    _formKey.currentState.save();

    _collectionData['description'] = _descriptionController.text;
    _collectionData['lastTimeModified'] = DateTime.now().toString();
    _collectionData['username'] = model.user.username;
    _collectionData['userphone'] = model.user.phone;
    _collectionData['userId'] = model.user.id;
    _collectionData['selectedRequest'] = model.selectedRequest;
    _collectionData['measurements'] = measurementTextFields.measurements;

    if (model.selectedRequestIndex == -1) {
      model.addCollection(_collectionData, true).then((bool success) {
        createUpdateResult(success, model, scaffold_state);
      });
    } else {
      model.updateCollection(_collectionData, true).then((bool success) {
        if (success) {
          _updateRequest['comment'] = _descriptionController.text;
          _updateRequest['time'] = _collectionData['lastTimeModified'];
          _updateRequest['collectionId'] = collectionId;
          _updateRequest['username'] = model.user.username;
          _updateRequest['userphone'] = model.user.phone;
          _updateRequest['userId'] = model.user.id;
          _updateRequest['measurements'] = measurementTextFields.measurements;
          model.updateRequest(_updateRequest).then((bool succss) {
            createUpdateResult(success, model, scaffold_state);
          });
        }
      });
    }
  }

  void createUpdateResult(bool success, MainModel model, scaffold_state) {
    if (success) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RequestList(model, true)),
          (Route<dynamic> route) {
        return route.settings.name == '/';
      });
    } else {
      final snackbar = SnackBar(content: Text('Uploading Request failed!!!'));
      scaffold_state.currentState.showSnackBar(snackbar);
    }
  }

  Widget _buildRadios(Collection collection) {
    if (collection != null && changeCategory) {
      collectionId = collection.id;
      collectionCategory = collection.category;
      changeCategory = false;
    }

    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Attire Category',
            style: TextStyle(
                fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          title: Text('Men\'s Collection'),
          leading: Radio(
              groupValue: collectionCategory,
              value: Category.Men,
              onChanged: (Category value) {
                setState(() {
                  collectionCategory = value;
                  _collectionData['category'] = value;
                });
              }),
        ),
        ListTile(
          title: Text('Women\'s Collection'),
          leading: Radio(
            groupValue: collectionCategory,
            value: Category.Women,
            onChanged: (Category value) {
              setState(() {
                collectionCategory = value;
                _collectionData['category'] = value;
              });
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffold_state = new GlobalKey<ScaffoldState>();
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        key: scaffold_state,
        appBar: AppBar(title: Text(companyName)),
        body: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
          ),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Upload Your Own Design',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Theme.of(context).accentColor),
                      ),
                      SizedBox(height: 30.0),
                      ImageInput(_setImage, _getCollection(model)),
                      SizedBox(height: 10.0),
                      _buildDescriptionField(context, model.selectedRequest),
                      SizedBox(height: 10.0),
                      _buildRadios(_getCollection(model)),
                      SizedBox(height: 10.0),
                      _buildcheckBoxes(_getCollection(model)),
                      SizedBox(height: 10.0),
                      _attireHeading(),
                      _collectionData['dress']
                          ? _buildmea(context, 0, model.selectedRequest)
                          : Container(),
                      _collectionData['shirt']
                          ? _buildmea(context, 1, model.selectedRequest)
                          : Container(),
                      _collectionData['trousers']
                          ? _buildmea(context, 2, model.selectedRequest)
                          : Container(),
                      SizedBox(height: 10.0),
                      _submitButton(model, scaffold_state)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildcheckBoxes(Collection collection) {
    if (collection != null && changeCheckbox) {
      _collectionData['dress'] = collection.dress;
      _collectionData['shirt'] = collection.shirt;
      _collectionData['trousers'] = collection.trousers;
      changeCheckbox = false;
    }

    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Attire Components',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ),
        CheckboxListTile(
          title: Text('Dress'),
          value: _collectionData['dress'],
          onChanged: (bool value) {
            setState(() {
              _collectionData['dress'] = !_collectionData['dress'];
            });
          },
        ),
        CheckboxListTile(
          title: Text('Shirt'),
          value: _collectionData['shirt'],
          onChanged: (bool value) {
            setState(() {
              _collectionData['shirt'] = !_collectionData['shirt'];
            });
          },
        ),
        CheckboxListTile(
          title: Text('Trousers'),
          value: _collectionData['trousers'],
          onChanged: (bool value) {
            setState(() {
              _collectionData['trousers'] = !_collectionData['trousers'];
            });
          },
        ),
      ],
    );
  }

  Collection _getCollection(MainModel model) {
    Request request = model.selectedRequest;
    if (request == null) {
      return null;
    }
    return model.everyCollections.firstWhere(
        (Collection collection) => collection.id == request.collectionId,
        orElse: () => null);
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
      image: AssetImage('assets/mm.png'),
    );
  }
}
