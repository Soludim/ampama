import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/main_scoped.dart';

class UserProfile extends StatefulWidget {
  final MainModel model;
  UserProfile(this.model);

  @override
  State<StatefulWidget> createState() {
    return _UserProfileState();
  }
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();

  @override
  void initState() {
    widget.model.setLoading(false);
    super.initState();
  }
  final Map<String, dynamic> _profileData = {
    'username': null,
    'email': null,
    'phone': null
  };

  Widget _buildUsernameTextField() {
    if (_usernameController.text.trim() == '') {
      _usernameController.text = widget.model.user.username;
    }
    return Padding(
      padding: EdgeInsets.all(5),
      child: TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Username shouldn\'t be empty';
            }
          },
          onSaved: (String value) {
            _profileData['username'] = value;
          }),
    );
  }

  Widget _buildEmailTextField() {
    if (_emailController.text.trim() == '') {
      _emailController.text = widget.model.user.email;
    }
    return Padding(
      padding: EdgeInsets.all(5),
      child: TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'E-mail'),
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                    .hasMatch(value)) {
              return 'Please enter a valid email';
            }
          },
          onSaved: (String value) {
            _profileData['email'] = value;
          }),
    );
  }

  Widget _buildPhoneTextField() {
    if (_phoneController.text.trim() == '') {
      _phoneController.text = widget.model.user.phone;
    }
    return Padding(
      padding: EdgeInsets.all(5),
      child: TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: 'Phone', prefix: Text('+233')),
          validator: (String value) {
            if (value.isEmpty || !RegExp(r"^[0-9]{9}$").hasMatch(value)) {
              return 'Invalid phone number';
            }
          },
          onSaved: (String value) {
            _profileData['phone'] = value;
          }),
    );
  }

  Widget _showUpdateButton(scaffold_state) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Container(
            padding: EdgeInsets.all(5.0),
            alignment: FractionalOffset.bottomRight,
              child: CircularProgressIndicator())
          : Container(
              alignment: FractionalOffset.bottomRight,
              child: FlatButton(
                child: Text('Update'),
                textColor: Theme.of(context).accentColor,
                onPressed: () => _update(model, scaffold_state),
              ),
            );
    });
  }

  void _update(MainModel model, scaffold_state) async {
    String successInfo;
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    if (model.user.username == _usernameController.text.trim() &&
        model.user.email == _emailController.text.trim()&&
        model.user.phone == _phoneController.text.trim()) {
      //nothing was changed
    } else {
      successInfo = await model.updateUserData(
          _profileData['username'], _profileData['phone'], _profileData['email']);
      final snackbar = SnackBar(content: Text(successInfo));
      scaffold_state.currentState.showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffold_state = new GlobalKey<ScaffoldState>();

    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      key: scaffold_state,
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          elevation: 10.0,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildUsernameTextField(),
                SizedBox(height: 10.0),
                _buildEmailTextField(),
                SizedBox(
                  height: 10.0,
                ),
                _buildPhoneTextField(),
                SizedBox(
                  height: 30.0,
                ),
                _showUpdateButton(scaffold_state)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
