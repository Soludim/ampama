import 'package:flutter/material.dart';
import '../models/auth.dart';

class AuthInputFields  {
    TextEditingController passwordController = new TextEditingController();
    TextEditingController emailControler = new TextEditingController();
  
    Widget showUsernameInput(_formData, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Username',
            icon: Icon(Icons.person, color: Theme.of(context).accentColor)),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Username field shouldn\'t be empty';
          }
        },
        onSaved: (String value) {
          _formData['username'] = value;
        },
      ),
    );
  }

  Widget showEmailInput(_formData, _authMode, context) {
    double paddinTop = _authMode == AuthMode.Login ? 20.0 : 10.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, paddinTop, 0.0, 0.0),
      child: TextFormField(
        controller: emailControler,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Email',
            icon: Icon(Icons.mail, color: Theme.of(context).accentColor)),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Please enter a valid email';
          }
        },
        onSaved: (String value) {
          _formData['email'] = value;
        },
      ),
    );
  }

  Widget showPasswordInput(_formData, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        controller: passwordController,
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Password',
            icon: Icon(Icons.lock, color: Theme.of(context).accentColor)),
        validator: (String value) {
          if (value.isEmpty || value.trim().length < 8) {
            return 'Password shouldn\'t be less than 8 chars';
          }
        },
        onSaved: (String value) {
          _formData['password'] = value;
        },
      ),
    );
  }

  Widget confirmPasswordInput(_formData, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Confirm Password',
            icon: Icon(Icons.compare, color: Theme.of(context).accentColor)),
        validator: (String value) {
          if (value != passwordController.text) {
            return 'Password does not match';
          }
        },
      ),
    );
  }

 Widget showPhoneInput(_formData, context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Phone',
            icon: Icon(Icons.add_call, color: Theme.of(context).accentColor),
            prefix: Text('+233')),
        validator: (String value) {
          if (value.isEmpty || !RegExp(r"^[0-9]{9}$")
                  .hasMatch(value)) {
            return 'invalid phone number';
          }
        },
        onSaved: (String value) {
          _formData['phone'] = value;
        },
      ),
    );
  }
}