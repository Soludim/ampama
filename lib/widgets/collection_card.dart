import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../models/collection.dart';
import '../scoped_models/main_scoped.dart';
import '../utility/timeago.dart';

class CollectionCard extends StatelessWidget {
  final Collection collection;

  CollectionCard(this.collection);
  Widget _buildActionButtons(BuildContext context, MainModel model) {
    return ButtonBar(children: <Widget>[
      IconButton(
        icon: Icon(Icons.info),
        color: Colors.grey,
        onPressed: () => _collectionDetails(context, model),
      ),
      IconButton(
        icon: Icon(
            collection.isFavorite ? Icons.favorite : Icons.favorite_border),
        color: Colors.red,
        onPressed: () {
          if (model.user == null) {
            Navigator.pushNamed(context, '/auth');
            return;
          }
          model.selectCollection(collection.id);
          model.toggleCollectionFavoriteStatus();
        },
      ),
    ]);
  }

  void _collectionDetails(BuildContext context, MainModel model) {
    model.selectCollection(collection.id);
    Navigator.pushNamed<bool>(context, '/collection/' + collection.id)
        .then((_) => model.selectCollection(null));
  }

  double imageHeight(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeigth = MediaQuery.of(context).size.height;
    if (deviceWidth > deviceHeigth) {
      //landscape mode
      return deviceWidth / 2 - 100;
    }
    //portrait mode
    return deviceHeigth / 2;
  }

  Widget _buildLastTimeModified(context) {
    String time = timeago(collection.lastTimeModified);
    return Text(
      time,
      textAlign: TextAlign.start,
      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _collectionDetails(context, model),
              child: Hero(
                tag: collection.id,
                child: FadeInImage(
                  image: NetworkImage(collection.image),
                  height: imageHeight(context),
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/trans.png'),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 5.0),
                  alignment: FractionalOffset.centerLeft,
                  child: _buildLastTimeModified(context),
                ),
                Container(
                  alignment: FractionalOffset.centerRight,
                  child: _buildActionButtons(context, model),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
