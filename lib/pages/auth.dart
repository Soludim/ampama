import 'package:flutter/material.dart';
import '../models/auth.dart';
import '../widgets/authInputFields.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/main_scoped.dart';

class AuthPage extends StatefulWidget {
  final MainModel _model;
  AuthPage(this._model);

  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    widget._model.setLoading(false);
    super.initState();
  }

  final Map<String, dynamic> _formData = {
    'username': null,
    'email': null,
    'password': null,
    'phone': null
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.Login;

  AuthInputFields _authInputFields = new AuthInputFields();

  @override
  void dispose() {
    _authInputFields.passwordController.dispose();
    _authInputFields.emailControler.dispose();
    super.dispose();
  }

  Widget _showLogo() {
    return Hero(
      tag: 'logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 70.0,
          child: Image.asset('assets/logo.png', height: 400, width: 300),
        ),
      ),
    );
  }

  Widget _showAuthButton(double targetWidth, scaffold_state) {
    String buttonLabel;
    switch (_authMode) {
      case AuthMode.Login:
        buttonLabel = 'Login';
        break;
      case AuthMode.SignUp:
        buttonLabel = 'Sign Up';
        break;
      case AuthMode.ForgotPassword:
        buttonLabel = 'Reset Password';
    }

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Container(
              margin: EdgeInsets.only(top: 45.0),
              child: CircularProgressIndicator())
          : SizedBox(
              width: targetWidth - 30,
              child: Container(
                margin: EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 0.0),
                padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                child: RaisedButton(
                    textColor: Colors.white,
                    onPressed: () =>
                        _submitForm(model.authenticate, scaffold_state),
                    child: Text(buttonLabel),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    color: Theme.of(context).primaryColor),
              ),
            );
    });
  }

  void _submitForm(Function authenticate, scaffold_state) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;
    successInformation = await authenticate(_formData, _authMode);
    
    if (successInformation['success']) {
      _authSuccessAction(scaffold_state);
    } else {
      final snackbar = SnackBar(content: Text(successInformation['message']));
      scaffold_state.currentState.showSnackBar(snackbar);
    }
  }

  void _authSuccessAction(scaffold_state) {
    if (_authMode == AuthMode.Login) {
      Navigator.pop(context);
    } else if (_authMode == AuthMode.SignUp) {
      Navigator.pop(context);
    } else {
      final snackbar = SnackBar(
          content: Text('Password reset sent to ${_formData['email']}'));
      scaffold_state.currentState.showSnackBar(snackbar);
    }
  }

  Widget _showAuthModeStatus() {
    String text = _authMode == AuthMode.Login
        ? 'Dont have an account'
        : 'Have an account? Sign in';
    return FlatButton(
      child: Text(text),
      onPressed: () {
        setState(() {
          _formKey.currentState.reset();
          if (_authMode == AuthMode.Login)
            _authMode = AuthMode.SignUp;
          else
            _authMode = AuthMode.Login;
        });
      },
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/bg_o.png'),
    );
  }

  Widget _showForgotPasswordButton() {
    return FlatButton(
      onPressed: () {
        setState(() {
          _authMode = AuthMode.ForgotPassword;
        });
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _showModeItems(double targetWidth, scaffold_state) {
    Widget modeItems;
    switch (_authMode) {
      case AuthMode.Login:
        modeItems = Column(
          children: <Widget>[
            _showLogo(),
            _authInputFields.showEmailInput(_formData, _authMode, context),
            _authInputFields.showPasswordInput(_formData, context),
            _showAuthButton(targetWidth, scaffold_state),
            _showAuthModeStatus(),
            _showForgotPasswordButton()
          ],
        );
        break;
      case AuthMode.SignUp:
        modeItems = Column(
          children: <Widget>[
            _authInputFields.showUsernameInput(_formData, context),
            _authInputFields.showEmailInput(_formData, _authMode, context),
            _authInputFields.showPhoneInput(_formData, context),
            _authInputFields.showPasswordInput(_formData, context),
            _authInputFields.confirmPasswordInput(_formData, context),
            _showAuthButton(targetWidth, scaffold_state),
            _showAuthModeStatus(),
          ],
        );
        break;
      case AuthMode.ForgotPassword:
        modeItems = Column(
          children: <Widget>[
            _authInputFields.showEmailInput(_formData, _authMode, context),
            Text('An email will be sent allowing you to reset your password'),
            _showAuthButton(targetWidth, scaffold_state),
            FlatButton(
              onPressed: () {
                setState(() {
                  _authMode = AuthMode.Login;
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300),
              ),
            )
          ],
        );
    }
    return modeItems;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    GlobalKey<ScaffoldState> scaffold_state = new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffold_state,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: _buildBackgroundImage(),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: targetWidth,
                  child: Form(
                      key: _formKey,
                      child: _showModeItems(targetWidth, scaffold_state)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
