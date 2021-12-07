import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import '../models/collection_category.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

import '../models/collection.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/request.dart';

class ConnectedCollectionsModel extends Model {
  List<Collection> _collections = [];
  List<Request> _requests = [];
  String _selCollectionId;
  String _selRequestId;
  User _authenticatedUser;
  bool _isLoading = false;
  Category collectionCategory;
}

class CollectionsModel extends ConnectedCollectionsModel {
  bool _showFavorites = false;

  List<Collection> get allCollections {
    //get all collections without user's own uploaded ones
    return _collections
        .where((Collection collection) => !collection.userOwnDesign)
        .toList();
  }

  List<Collection> get everyCollections {
    return List.from(_collections);
  }

  List<Collection> get displayedCollections {
    if (_showFavorites) {
      return _collections
          .where((Collection collection) => collection.isFavorite)
          .where((Collection collection) => !collection.userOwnDesign)
          .where((Collection collection) =>
              collection.category == collectionCategory)
          .toList();
    }
    return _collections
        .where((Collection collection) =>
            collection.category == collectionCategory)
        .where((Collection collection) => !collection.userOwnDesign)
        .toList();
  }

  int get selectedCollectionIndex {
    return _collections.indexWhere((Collection collection) {
      return collection.id == _selCollectionId;
    });
  }

  String get selectedCollectionId {
    return _selCollectionId;
  }

  Collection get selectedCollection {
    if (selectedCollectionId == null) {
      return null;
    }

    return _collections.firstWhere((Collection collection) {
      return collection.id == _selCollectionId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  Future<String> uploadImage(File image, {String imagePath}) async {
    String imageUrl;
    String filename = basename(image.path);
    StorageReference sf = FirebaseStorage.instance
        .ref()
        .child('collections')
        .child(DateTime.now().toString() + filename);
    await sf.putFile(image).onComplete;
    imageUrl = await sf.getDownloadURL();

    return imageUrl;
  }

  Future<Null> deleteImage(String imagePath) async {
    StorageReference sf =
        FirebaseStorage.instance.ref().child('collections').child(imagePath);
    await sf.delete();
  }

  Future<bool> addCollection(Map<String, dynamic> _formData,
      [bool usersOwnRequest = false]) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(_formData['image']);
    if (uploadData == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    String categoryString;
    if (_formData['category'] == Category.Women) {
      categoryString = 'Women';
    } else {
      categoryString = 'Men';
    }
    final Map<String, dynamic> collectionData = {
      'description': _formData['description'],
      'imageUrl': uploadData,
      'category': categoryString,
      'lastTimeModified': _formData['lastTimeModified'],
      'shirt': _formData['shirt'],
      'dress': _formData['dress'],
      'userOwnDesign': usersOwnRequest,
      'trousers': _formData['trousers']
    };

    try {
      final http.Response response = await http.post(
          'https://ambama.firebaseio.com/collections.json',
          body: json.encode(collectionData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Collection newCollection = Collection(
          id: responseData['name'],
          description: _formData['description'],
          image: uploadData,
          category: _formData['category'],
          lastTimeModified: _formData['lastTimeModified'],
          userOwnDesign: usersOwnRequest,
          dress: _formData['dress'],
          trousers: _formData['trousers'],
          shirt: _formData['shirt']);
      _collections.add(newCollection);
      notifyListeners();

      if (usersOwnRequest) {
        final Map<String, dynamic> _requestForm = {
          'time': null,
          'collectionId': null,
          'comment': null,
          'username': null,
          'userphone': null,
          'userId': null,
          'measurements': null
        };

        _requestForm['time'] = _formData['lastTimeModified'];
        _requestForm['collectionId'] = responseData['name'];
        _requestForm['comment'] = _formData['description'];
        _requestForm['username'] = _formData['username'];
        _requestForm['userphone'] = _formData['userphone'];
        _requestForm['userId'] = _formData['userId'];
        _requestForm['measurements'] = _formData['measurements'];
        return await RequestModel()
            .addRequest(_requestForm, _authenticatedUser);
      } //calling request method

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCollection(Map<String, dynamic> _formData,
      [bool usersOwnRequest = false]) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedCollection.image;
    if (_formData['image'] != null) {
      final uploadData = await uploadImage(_formData['image']);

      if (uploadData == null) {
        return false;
      }

      imageUrl = uploadData;
    }
    String categoryString;
    if (_formData['category'] == Category.Women) {
      categoryString = 'Women';
    } else {
      categoryString = 'Men';
    }

    final Map<String, dynamic> updateData = {
      'description': _formData['description'],
      'imageUrl': imageUrl,
      'category': categoryString,
      'lastTimeModified': _formData['lastTimeModified'],
      'userOwnDesign': usersOwnRequest,
      'shirt': _formData['shirt'],
      'dress': _formData['dress'],
      'trousers': _formData['trousers']
    };

    try {
      await http.put(
          'https://ambama.firebaseio.com/collections/${selectedCollection.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));
      _isLoading = false;
      final Collection updatedCollection = Collection(
          id: selectedCollection.id,
          description: _formData['description'],
          image: imageUrl,
          category: _formData['category'],
          lastTimeModified: _formData['lastTimeModified'],
          dress: selectedCollection.dress,
          userOwnDesign: usersOwnRequest,
          trousers: selectedCollection.trousers,
          shirt: selectedCollection.shirt);
      _collections[selectedCollectionIndex] = updatedCollection;

      notifyListeners();
      return true;
    } catch (error) {
      (error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCollection() {
    _isLoading = true;
    final deletedCollectionId = selectedCollection.id;
    _collections.removeAt(selectedCollectionIndex);
    _selCollectionId = null;
    notifyListeners();
    return http
        .delete(
            'https://ambama.firebaseio.com/collections/$deletedCollectionId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      deleteImage(selectedCollection.image);
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchCollections({onlyForUser = false, clearExisting = false}) {
    _isLoading = true;
    if (clearExisting) {
      _collections = [];
    }

    notifyListeners();

    return http
        .get('https://ambama.firebaseio.com/collections.json')
        .then<Null>((http.Response response) {
      final List<Collection> fetchedCollectionList = [];
      final Map<String, dynamic> collectionListData =
          json.decode(response.body);

      if (collectionListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      collectionListData.forEach((String collectionId, dynamic collectionData) {
        Category category;
        if (collectionData['category'] == 'Women') {
          category = Category.Women;
        } else {
          category = Category.Men;
        }
        final Collection collection = Collection(
            id: collectionId,
            description: collectionData['description'],
            image: collectionData['imageUrl'],
            category: category,
            userOwnDesign: collectionData['userOwnDesign'],
            lastTimeModified: collectionData['lastTimeModified'],
            dress: collectionData['dress'],
            trousers: collectionData['trousers'],
            shirt: collectionData['shirt'],
            isFavorite: collectionData['wishlistUsers'] == null ||
                    _authenticatedUser == null
                ? false
                : (collectionData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedCollectionList.add(collection);
      });
      _collections = fetchedCollectionList;
      _isLoading = false;
      notifyListeners();
      _selCollectionId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleCollectionFavoriteStatus() async {
    final bool isCurrentlyFavorite = selectedCollection.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Collection updatedCollection = Collection(
        id: selectedCollection.id,
        description: selectedCollection.description,
        image: selectedCollection.image,
        lastTimeModified: selectedCollection.lastTimeModified,
        category: selectedCollection.category,
        dress: selectedCollection.dress,
        userOwnDesign: selectedCollection.userOwnDesign,
        trousers: selectedCollection.trousers,
        shirt: selectedCollection.shirt,
        isFavorite: newFavoriteStatus);
    _collections[selectedCollectionIndex] = updatedCollection;
    notifyListeners();
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://ambama.firebaseio.com/collections/${selectedCollection.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://ambama.firebaseio.com/collections/${selectedCollection.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Collection updatedCollection = Collection(
          id: selectedCollection.id,
          description: selectedCollection.description,
          image: selectedCollection.image,
          lastTimeModified: selectedCollection.lastTimeModified,
          category: selectedCollection.category,
          dress: selectedCollection.dress,
          userOwnDesign: selectedCollection.userOwnDesign,
          trousers: selectedCollection.trousers,
          shirt: selectedCollection.shirt,
          isFavorite: !newFavoriteStatus);
      _collections[selectedCollectionIndex] = updatedCollection;
      notifyListeners();
    }
    _selCollectionId = null;
  }

  void selectCollection(String collectionId) {
    _selCollectionId = collectionId;
    if (collectionId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class RequestModel extends ConnectedCollectionsModel {
  List<Request> get allRequests {
    return List.from(_requests);
  }

  int get selectedRequestIndex {
    return _requests.indexWhere((Request request) {
      return request.id == _selRequestId;
    });
  }

  String get selectedRequestId {
    return _selRequestId;
  }

  Request get selectedRequest {
    if (selectedRequestId == null) {
      return null;
    }

    return _requests.firstWhere((Request request) {
      return request.id == _selRequestId;
    }, orElse: () => null);
  }

  void selectRequest(String requestId) {
    _selRequestId = requestId;
    if (requestId != null) {
      notifyListeners();
    }
  }

  Future<bool> addRequest(Map<String, dynamic> _requestForm,
      [authenticatedUser]) async {
    _isLoading = true;
    if (_authenticatedUser == null) _authenticatedUser = authenticatedUser;
    notifyListeners();
    try {
      final http.Response response = await http.post(
          'https://ambama.firebaseio.com/requests.json?auth=${_authenticatedUser.token}',
          body: json.encode(_requestForm));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Request newRequest = Request(
          id: responseData['name'],
          time: _requestForm['time'],
          collectionId: _requestForm['collectionId'],
          comment: _requestForm['comment'],
          userId: _requestForm['userId'],
          username: _requestForm['username'],
          userphone: _requestForm['userphone'],
          measurements: _requestForm['measurements']);
      _requests.add(newRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRequest(Map<String, dynamic> requestData) async {
    _isLoading = true;
    notifyListeners();

    try {
      await http.put(
          'https://ambama.firebaseio.com/requests/${selectedRequest.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(requestData));
      _isLoading = false;
      final Request updatedRequest = Request(
          id: selectedRequest.id,
          time: requestData['time'],
          collectionId: requestData['collectionId'],
          comment: requestData['comment'],
          userId: requestData['userId'],
          username: requestData['username'],
          userphone: requestData['userphone'],
          measurements: requestData['measurements']);
      _requests[selectedRequestIndex] = updatedRequest;
      notifyListeners();
      return true;
    } catch (error) {
      (error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRequest() {
    _isLoading = true;
    final deletedRequestId = selectedRequest.id;
    _requests.removeAt(selectedRequestIndex);
    _selRequestId = null;
    notifyListeners();
    return http
        .delete(
            'https://ambama.firebaseio.com/requests/$deletedRequestId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchRequests({onlyForUser = false, clearExisting = false}) {
    _isLoading = true;
    if (clearExisting) {
      _requests = [];
    }

    notifyListeners();
    return http
        .get(
            'https://ambama.firebaseio.com/requests.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Request> fetchedRequestsList = [];
      final Map<String, dynamic> requestListData = json.decode(response.body);
      if (requestListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      List<Map<String, dynamic>> allMeasurements = [];

      requestListData.forEach((String requestId, dynamic requestData) {
        for (int i = 0; i < requestData['measurements'].length; i++) {
          Map<String, dynamic> measurement = {
            'name': null,
            'type': null,
            'value': null
          };
          measurement['name'] = requestData['measurements'][i]['name'];
          measurement['type'] = requestData['measurements'][i]['type'];
          measurement['value'] = requestData['measurements'][i]['value'];
          allMeasurements.add(measurement);
        }

        final Request request = Request(
            id: requestId,
            time: requestData['time'],
            collectionId: requestData['collectionId'],
            comment: requestData['comment'],
            userId: requestData['userId'],
            username: requestData['username'],
            userphone: requestData['userphone'],
            measurements: allMeasurements);
        fetchedRequestsList.add(request);
      });
      _requests = onlyForUser
          ? fetchedRequestsList.where((Request request) {
              return request.userId == _authenticatedUser.id;
            }).toList()
          : fetchedRequestsList;

      _isLoading = false;
      notifyListeners();
      _selRequestId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }
}

class UserModel extends ConnectedCollectionsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(_formData,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': _formData['email'],
      'password': _formData['password'],
      'returnSecureToken': true
    };

    http.Response response;
   
   ///checking network status
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //connected
      }
    } on SocketException catch(_) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message':'Please check your internet connection!!'};
    }

    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDYq82Em-nAEuVWptZ2E9I2JeaHgm6GJA4',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else if (mode == AuthMode.SignUp) {
      response = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDYq82Em-nAEuVWptZ2E9I2JeaHgm6GJA4',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      //forget password
      response = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyDYq82Em-nAEuVWptZ2E9I2JeaHgm6GJA4',
          body: json.encode({'email': _formData['email'], 'requestType': 'PASSWORD_RESET'}),
          headers: {'Content-Type': 'application/json'});
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';

    if (mode != AuthMode.ForgotPassword &&
        responseData.containsKey('idToken')) {
      bool get_userData_result = await getUserData(_formData, mode,
          responseData); //getting user data from storage or database
      if (!get_userData_result) {
        message = 'Getting user data failed';
        _isLoading = false;
        notifyListeners();
        return {'success': !hasError, 'message': message};
      }

      hasError = false;
      message = 'Authentication succeeded!';

      _authenticatedUser = User(
          id: responseData['localId'],
          email: _formData['email'],
          username: _formData['username'],
          phone: _formData['phone'],
          token: responseData['idToken']);
      if (mode == AuthMode.SignUp)
        storeUserInfotoDb(
            responseData['localId'], _formData['username'], _formData['phone']);

      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);

      setLocalStorage(
          token: responseData['idToken'],
          email: _formData['email'],
          id: responseData['localId'],
          username: _formData['username'],
          phone: _formData['phone'],
          expiresIn: responseData['expiresIn']); //set data in local storage

    } else if (mode == AuthMode.ForgotPassword &&
        responseData.containsKey('email')) {
      hasError = false;
      message = 'Email reset sent successfully';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Incorrect email or password';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Incorrect email or password';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  Future<bool> getUserData(_formData, mode, responseData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mode == AuthMode.Login) {
      if (prefs.getString('username') == null ||
          prefs.getString('phone') == null) {
        //when user already have account but no data is stored on local storage
        http.Response userData = await http.get(
            'https://ambama.firebaseio.com/users/' +
                responseData['localId'] +
                ".json?auth=${responseData['idToken']}");
        if (userData.statusCode == 200) {
          //success in getting data from firebase database
          Map<String, dynamic> map = json.decode(userData.body);
          map.forEach((f, h) {
            if (f == 'username') {
              _formData['username'] = h.toString();
            } else if (f == 'phone') {
              _formData['phone'] = h.toString();
            }
          });
        } else {
          return false;
        }
      } else {
        _formData['username'] = prefs.getString('username');
        _formData['phone'] = prefs.getString('phone');
      }
    }
    return true;
  }

  Future<String> updateUserData(
      String username, String phone, String email) async {
    _isLoading = true;
    notifyListeners();
    String msg = "Update Failed!!!";

    Map<String, String> updateData = {
      'id': _authenticatedUser.id,
      'username': username,
      'phone': phone
    };

    Map<String, dynamic> emailChange = {
      'idToken': _authenticatedUser.token,
      'email': email,
      'returnSecureToken': true
    };
    if (email.trim() != _authenticatedUser.email) {
      http.Response changeEmailResponse = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyDYq82Em-nAEuVWptZ2E9I2JeaHgm6GJA4',
          body: json.encode(emailChange),
          headers: {'Content-Type': 'application/json'});

      Map<String, dynamic> emailResponse =
          json.decode(changeEmailResponse.body);

      if (emailResponse.containsKey('idToken')) {
        http.Response userData = await http.put(
            'https://ambama.firebaseio.com/users/' +
                _authenticatedUser.id +
                ".json?auth=${emailResponse['idToken']}",
            body: json.encode(updateData),
            headers: {
              'Content-Type': 'application/json'
            }); //saved to database successfully

        if (userData.statusCode == 200) {
          setLocalStorage(
              token: emailResponse['idToken'],
              email: email,
              id: emailResponse['localId'],
              phone: phone,
              username: username);

          _authenticatedUser = User(
              id: emailResponse['localId'],
              username: username,
              phone: phone,
              email: email,
              token: emailResponse['idToken']);

          _isLoading = false;
          notifyListeners();
          msg = "Update was successful";
          return msg;
        }
      }
    } else {
      http.Response userData = await http.put(
          'https://ambama.firebaseio.com/users/' +
              _authenticatedUser.id +
              ".json?auth=${_authenticatedUser.token}",
          body: json.encode(updateData),
          headers: {
            'Content-Type': 'application/json'
          }); //saved to database successfully

      if (userData.statusCode == 200) {
        setLocalStorage(
            token: _authenticatedUser.token,
            email: email,
            id: _authenticatedUser.id,
            phone: phone,
            username: username);

        _authenticatedUser = User(
            id: _authenticatedUser.id,
            username: username,
            phone: phone,
            email: email,
            token: _authenticatedUser.token);

        _isLoading = false;
        notifyListeners();
        msg = "Update was successful";
        return msg;
      }
    }

    _isLoading = false;
    notifyListeners();

    return msg;
  }

  void setLocalStorage(
      {String token,
      String email,
      String id,
      String username,
      String phone,
      String expiresIn}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('token', token);
    prefs.setString('userEmail', email);
    prefs.setString('userId', id);
    prefs.setString('username', username);
    prefs.setString('phone', phone);
    if (expiresIn != null) {
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(expiresIn)));
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    }
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final String username = prefs.getString('username');
      final String phone = prefs.getString('phone');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(
          id: userId,
          email: userEmail,
          token: token,
          username: username,
          phone: phone);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      notifyListeners();
    }
  }

  void logout() async {
    _isLoading = false;
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selCollectionId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('username');
    prefs.remove('phone');
    prefs.remove('userId');
    notifyListeners();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }

  void storeUserInfotoDb(String id, String username, String phone) async {
    Map<String, dynamic> userInfo = {
      "id": id,
      "username": username,
      "phone": phone
    };

    await http.post(
        "https://ambama.firebaseio.com/users/" +
            _authenticatedUser.id +
            ".json?auth=${_authenticatedUser.token}",
        body: json.encode(userInfo));
  }
}

class UtilityModel extends ConnectedCollectionsModel {
  bool get isLoading {
    return _isLoading;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
