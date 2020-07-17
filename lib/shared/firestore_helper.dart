import '../models/event_detail.dart';
import '../models/favorite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final Firestore db = Firestore.instance;

  static Future addFavorite(EventDetail eventDetail, String uid) {
    Favorite fav = Favorite(null, uid, eventDetail.id);
    var result = db
        .collection('favorites')
        .add(fav.toMap())
        .then((value) => print(value))
        .catchError((err) => print(err));
    return result;
  }

  static Future deleteFavorite(String favId) async {
    await db.collection('favorites').document(favId).delete();
  }

  static Future<List<Favorite>> getUserFavorites(String uid) async{
    List<Favorite> favs;
    QuerySnapshot docs = await db.collection('favorites').where('userId', isEqualTo:uid).getDocuments();

    if(docs != null){
      favs = docs.documents.map((data) => Favorite.map(data)).toList();
    }

    return favs;
  }
}
