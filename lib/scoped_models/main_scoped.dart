import 'package:scoped_model/scoped_model.dart';
import './connected_collections.dart';

class MainModel extends Model
    with
        ConnectedCollectionsModel,
        UserModel,
        CollectionsModel,
        RequestModel,
        UtilityModel {}
