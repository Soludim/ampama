import 'package:flutter/material.dart';
import '../models/collection_category.dart';

class Collection {

  final String id;
  final String description;
  final String image;
  final bool isFavorite;
  final Category category;
  final String lastTimeModified;
  final bool userOwnDesign;
  final bool dress;
  final bool shirt;
  final bool trousers;


   Collection(
      {@required this.id,
      @required this.description,
      @required this.image,
      @required this.category,
      @required this.lastTimeModified,
      this.isFavorite = false,
      this.userOwnDesign = false,
      @required this.dress,
      @required this.shirt,
      @required this.trousers});
}