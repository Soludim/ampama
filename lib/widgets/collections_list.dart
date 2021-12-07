import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './collection_card.dart';
import '../models/collection.dart';
import '../scoped_models/main_scoped.dart';

class CollectionsList extends StatelessWidget {
  Widget _buildProductList(List<Collection> collections) {
    Widget collectionCards;
    if (collections.length > 0) {
      collectionCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            CollectionCard(collections[index]),
        itemCount: collections.length,
      );
    } else {
      collectionCards = Container();
    }
    return collectionCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model) {
      return  _buildProductList(model.displayedCollections);
    },);
  }
}
