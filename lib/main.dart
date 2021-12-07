import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/home.dart';
import './pages/auth.dart';
import './pages/manage_collection.dart';
import './scoped_models/main_scoped.dart';
import './pages/collections.dart';
import './models/collection.dart';
import './pages/collection_details.dart';
import './pages/collection_request.dart';
import './pages/upload_design.dart';
import './pages/user_profile.dart';
import './utility/static_fields.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: companyName,
        theme: ThemeData(
            fontFamily: 'Raleway',
            primarySwatch: Colors.deepPurple, accentColor: Color(0xff4f6457)),
        routes: {
          '/': (BuildContext context) => HomePage(_model),
          '/auth': (BuildContext context) => AuthPage(_model),
          '/admin': (BuildContext context) => ManageCollection(_model),
          '/collections': (BuildContext context) => CollectionsPage(_model),
          '/upload_design': (BuildContext context) => UploadDesign(_model),
          '/user_profile': (BuildContext context) => UserProfile(_model)
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'collection') {
            final String collectionId = pathElements[2];
            final Collection collection =
                _model.allCollections.firstWhere((Collection collection) {
              return collection.id == collectionId;
            });
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) =>
                    CollectionDetails(collection));
          }

          if (pathElements[1] == 'collection_request') {
            final String collectionId = pathElements[2];
            final Collection collection =
                _model.allCollections.firstWhere((Collection collection) {
              return collection.id == collectionId;
            });
            return MaterialPageRoute(
                builder: (BuildContext context) =>
                    CollectionRequest(collection));
            // return _isAuthenticated
            //     : MaterialPageRoute(
            //         builder: (BuildContext context) => AuthPage(_model));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => CollectionsPage(_model));
        },
      ),
    );
  }
}