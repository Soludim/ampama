import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../models/collection.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Collection collection;

  ImageInput(this.setImage, this.collection);

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  void _getImage(BuildContext context, ImageSource source) {
   ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
     print('in there');
     retrieveLostData();
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);
      Navigator.pop(context);
    }).catchError((onError){
      print(onError);
      print('in here');
      retrieveLostData();
      Navigator.pop(context);
    });
  }
  
  Future<void> retrieveLostData() async {
    final LostDataResponse response = await ImagePicker.retrieveLostData();
    print(response.type);
    if (response == null){
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    }
  }
  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 100.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // SizedBox(
              //   height: 10.0,
              // ),
              // // FlatButton(
              // //   textColor: Theme.of(context).primaryColor,
              // //   child: Text('Use Camera'),
              // //   onPressed: () {
              // //     _getImage(context, ImageSource.camera);
              // //   },
              // // ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Gallery'),
                onPressed: () {
                  _getImage(context, ImageSource.gallery);
                },
              )
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).accentColor;
    Widget previewImage = Text('Please select an image.');
    if (_imageFile != null) {
      previewImage = Card (elevation: 10.0,child: Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      ),);
    }else if (widget.collection != null) {
      previewImage = Card (elevation: 10.0,child: Image.network(
        widget.collection.image,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.topCenter,
      ),);
    }

    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2.0,
          ),
          onPressed: () {
            _openImagePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: buttonColor,
              ),
              SizedBox(
                width: 5.0,
              ),
              _imageFile != null ?
              Text(
                'Change Image',
                style: TextStyle(color: buttonColor),
              ) : Text(
                'Add Image',
                style: TextStyle(color: buttonColor),
              )
            ],
          ),
        ),
        SizedBox(height: 10.0),
        previewImage
      ],
    );
  }
}