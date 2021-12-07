import 'dart:async';

import 'package:flutter/material.dart';

import '../models/collection.dart';
import '../models/collection_category.dart';

class CollectionDetails extends StatelessWidget {
  final Collection collection;

  CollectionDetails(this.collection);

  double imageHeight(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeigth = MediaQuery.of(context).size.height;
    if (deviceWidth > deviceHeigth) {
      //landscape mode
      return deviceWidth / 2 - 30;
    }
    //portrait mode
    return deviceHeigth / 2 + 80;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeigth = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
                expandedHeight: imageHeight(context),
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: collection.category == Category.Men
                      ? Text('Men\'s Collection')
                      : Text('Women\'s Collection'),
                  background: Container(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Hero(
                      tag: collection.id,
                      child: FadeInImage(
                        image: NetworkImage(collection.image),
                        height: imageHeight(context),
                        fit: deviceWidth > deviceHeigth ? BoxFit.contain : BoxFit.fill,
                        placeholder: AssetImage('assets/broken_image.png'),
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.grey),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    decoration: BoxDecoration(
                      image: _buildBackgroundImage(),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        collection.description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin: EdgeInsets.all(10.0),
                    child: OutlineButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2.0,
                      ),
                      child: Text('Request this attire'),
                      onPressed: () => Navigator.pushNamed(
                          context, '/collection_request/' + collection.id),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/mm.png'),
    );
  }
}
