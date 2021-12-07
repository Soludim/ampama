import 'dart:io';

import 'package:flutter/material.dart';
import '../models/collection.dart';
import '../widgets/image.dart';
import '../models/collection_category.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/main_scoped.dart';

class CollectionCreateEdit extends StatefulWidget {
  final MainModel _model;
  CollectionCreateEdit(this._model);
  @override
  State<StatefulWidget> createState() {
    return _CollectionCreateEditState();
  }
}

class _CollectionCreateEditState extends State<CollectionCreateEdit> {

  @override
  void initState() {
    widget._model.setLoading(false);
    super.initState();
  }
  final Map<String, dynamic> _formData = {
    'description': null,
    'image': null,
    'category': null,
    'lastTimeModified': null,
    'shirt': false,
    'trousers': false,
    'dress': false
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool changeCategory = true;
  bool changeCheckbox = true;
  TextEditingController _descriptionTextController =
      new TextEditingController();

  Category collectionCategory = Category.Men;

  @override
  void dispose() {
    _descriptionTextController.dispose();
    super.dispose();
  }

Widget buildDescriptionTextField(collection) {
    if (collection == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (collection != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = collection.description;
    } else if (collection != null &&
        _descriptionTextController.text.trim() != '') {
      _descriptionTextController.text = _descriptionTextController.text;
    } else if (collection == null &&
        _descriptionTextController.text.trim() != '') {
      _descriptionTextController.text = _descriptionTextController.text;
    } else {
      _descriptionTextController.text = '';
    }

    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Attire Description'),
      controller: _descriptionTextController,
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 10) {
          return 'Description is required and should be 10+ characters long.';
        }
      },
    );
  }

  Widget buildcheckBoxes(Collection collection) {
    if (collection != null && changeCheckbox) {
      _formData['dress'] = collection.dress;
      _formData['shirt'] = collection.shirt;
      _formData['trousers'] = collection.trousers;
      changeCheckbox = false;
    }

    return Column(children: <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Attire Components',
            style: TextStyle(
                fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
      CheckboxListTile(
        title: Text('Dress'),
        value: _formData['dress'],
        onChanged: (bool value) {
          setState(() {
            _formData['dress'] = !_formData['dress'];
          });
        },
      ),
      CheckboxListTile(
        title: Text('Shirt'),
        value: _formData['shirt'],
        onChanged: (bool value) {
          setState(() {
            _formData['shirt'] = !_formData['shirt'];
          });
        },
      ),
      CheckboxListTile(
        title: Text('Trousers'),
        value: _formData['trousers'],
        onChanged: (bool value) {
          setState(() {
            _formData['trousers'] = !_formData['trousers'];
          });
        },
      ),
    ]);
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('Save'),
              textColor: Colors.white,
              color: Colors.deepPurple,
              onPressed: () => _submitForm(
                  model.addCollection,
                  model.updateCollection,
                  model.selectCollection,
                  model.selectedCollectionIndex),
            );
    });
  }

  void _submitForm(Function addCollection, Function updateCollection,
      Function setSelectedCollection,
      [int selectedCollectionIndex]) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedCollectionIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    _formData['description'] = _descriptionTextController.text;
    _formData['lastTimeModified'] = DateTime.now().toString();
    if (selectedCollectionIndex == -1) {
      addCollection(_formData).then((bool success) {
        createUpdateResult(success, setSelectedCollection);
      });
    } else {
      updateCollection(_formData).then((bool success) {
        createUpdateResult(success, setSelectedCollection);
      });
    }
  }

  void createUpdateResult(bool success, Function setSelectedCollection) {
    if (success) {
      Navigator.pushReplacementNamed(context, '/admin')
          .then((_) => setSelectedCollection(null));
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

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _buildPageContent(BuildContext context, Collection collection) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    if (collection != null && changeCategory) {
      collectionCategory = collection.category;
      changeCategory = false;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              buildDescriptionTextField(collection),
              SizedBox(height: 10.0),
              Text('Attire Category',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              ListTile(
                title: Text('Men\'s Collection'),
                leading: Radio(
                    groupValue: collectionCategory,
                    value: Category.Men,
                    onChanged: (Category value) {
                      setState(() {
                        collectionCategory = value;
                        _formData['category'] = value;
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
                      _formData['category'] = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 20.0),
              buildcheckBoxes(collection),
              SizedBox(height: 10.0),
              ImageInput(_setImage, collection),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedCollection);
        return model.selectedCollectionIndex == -1
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Collection'),
                ),
                body: pageContent,
              );
      },
    );
  }
}