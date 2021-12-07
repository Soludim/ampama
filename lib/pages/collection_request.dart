import '../scoped_models/main_scoped.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter/material.dart';

import '../models/collection.dart';
import '../models/request.dart';
import '../widgets/measurements_textfields.dart';
import '../pages/requests_list.dart';

class CollectionRequest extends StatefulWidget {
  final Collection collection;
  CollectionRequest(this.collection);

  @override
  State<StatefulWidget> createState() {
    return _CollectionRequestState();
  }
}

class _CollectionRequestState extends State<CollectionRequest> {
  @override
  void dispose() {
    _commentController.dispose();
    _commentNode.dispose();
    super.dispose();
  }

  final Map<String, dynamic> _requestForm = {
    'time': null,
    'collectionId': null,
    'comment': null,
    'username': null,
    'userphone': null,
    'userId': null,
    'measurements': null
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final MeasurementTextFields measurementTextFields =
      new MeasurementTextFields();
  final TextEditingController _commentController = new TextEditingController();
  final FocusNode _commentNode = new FocusNode();

  Widget _buildCommentTextField(context, Request request) {
    if (request == null && _commentController.text.trim() == '') {
      _commentController.text = '';
    } else if (request != null && _commentController.text.trim() == '') {
      _commentController.text = request.comment;
    } else if (request != null && _commentController.text.trim() != '') {
      _commentController.text = _commentController.text;
    } else if (request == null && _commentController.text.trim() != '') {
      _commentController.text = _commentController.text;
    } else {
      _commentController.text = '';
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: TextFormField(
          maxLines: 3,
          focusNode: _commentNode,
          controller: _commentController,
          decoration: InputDecoration(
            focusColor: Theme.of(context).primaryColor,
            labelText: 'Add additional comment',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0))),
          ),
          validator: (String value) {
            if (value.isEmpty) {
              FocusScope.of(context).requestFocus(_commentNode);
              return 'Please add comment';
            }
          }),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(10.0),
              child: CircularProgressIndicator())
          : Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(10.0),
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () => _requestMethod(
                  model.addRequest,
                  model.updateRequest,
                  model.selectRequest,
                  model,
                  model.selectedRequestIndex,
                ),
                color: Theme.of(context).primaryColor,
                child: Text(model.selectedRequest == null
                    ? 'Put Request'
                    : 'Update Request'),
              ),
            );
    });
  }

  void _requestMethod(Function addRequest, Function updateRequest,
      Function setSelectedRequest, model,
      [int selectedRequestIndex]) async{
    if (!_formKey.currentState.validate()) {
      final snackbar = SnackBar(content: Text('Please complete form'));
      _scaffoldState.currentState.showSnackBar(snackbar);
      return;
    }

    _formKey.currentState.save();
    if (model.user == null) {
      //not authenticated
      Navigator.pushNamed(context, '/auth');
      return;
    }
    _requestForm['comment'] = _commentController.text;
    _requestForm['time'] = DateTime.now().toString();
    _requestForm['collectionId'] = widget.collection.id;
    _requestForm['username'] = model.user.username;
    _requestForm['userphone'] = model.user.phone;
    _requestForm['userId'] = model.user.id;
    _requestForm['measurements'] = measurementTextFields.measurements;

    if (selectedRequestIndex == -1) {
      addRequest(_requestForm).then((bool success) {
        createUpdateResult(success, setSelectedRequest, model);
      });
    } else {
      updateRequest(_requestForm).then((bool success) {
        createUpdateResult(success, setSelectedRequest, model);
      });
    }
  }

  void createUpdateResult(bool success, Function setSelectedRequest, model) {
    if (success) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RequestList(model, true)),
          (Route<dynamic> route) {
        return route.settings.name == '/';
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Something went wrong'),
              content: Text('Please try again!'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Okay'),
                )
              ],
            );
          });
    }
  }

  Widget _buildmea(context, int type, Request request) {
    if (request != null) {
      return measurementTextFields.allfields(
          type, context, request.measurements);
    }
    return measurementTextFields.allfields(type, context);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedRequest);
      return model.selectedRequestIndex == -1
          ? Scaffold(
              key: _scaffoldState,
              appBar: AppBar(
                title: Text('Request Collection'),
              ),
              body: pageContent)
          : Scaffold(
              key: _scaffoldState,
              appBar: AppBar(
                title: Text('Edit Request'),
              ),
              body: pageContent,
            );
    });
  }

  Widget _buildPageContent(BuildContext context, Request request) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              margin: EdgeInsets.all(10.0),
              elevation: 3.0,
              child: Hero(
                tag: widget.collection.id,
                child: FadeInImage(
                    image: NetworkImage(widget.collection.image),
                    height: 350.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/trans.png')),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                widget.collection.description,
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
            Form(
              key: _formKey,
              child: Column(children: <Widget>[
                _buildCommentTextField(context, request),
                SizedBox(height: 10.0),
                Text('Please provide your measurements(cm)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                widget.collection.dress
                    ? _buildmea(context, 0, request)
                    : Container(),
                widget.collection.shirt
                    ? _buildmea(context, 1, request)
                    : Container(),
                widget.collection.trousers
                    ? _buildmea(context, 2, request)
                    : Container(),
                _buildSubmitButton()
              ]),
            )
          ],
        ),
      ),
    );
  }
}