import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:events_app/models/event_detail.dart';
import 'package:events_app/models/favorite.dart';
import 'package:events_app/shared/authentication.dart';
import 'package:events_app/shared/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class EventScreen extends StatelessWidget {
  final String uid;

  EventScreen(this.uid);

  @override
  Widget build(BuildContext context) {
    Authentication auth = new Authentication();
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                auth.signOut().then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen())));
              })
        ],
      ),
      body: EventList(uid),
    );
  }
}

class EventList extends StatefulWidget {
  final String uid;

  EventList(this.uid);

  @override
  _EventListState createState() => _EventListState(uid);
}

class _EventListState extends State<EventList> {
  final String uid;
  final Firestore db = Firestore.instance;

  List<Favorite> favorites = [];

  List<EventDetail> details = [];

  _EventListState(this.uid);

  @override
  void initState() {
    if (mounted) {
      getDetailsList().then((value) => setState(() {
            details = value;
          }));
    }
    FirestoreHelper.getUserFavorites(uid).then((value) => setState(() {
          favorites = value;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: (details != null) ? details.length : 0,
        itemBuilder: (context, position) {
          String sub =
              'Date  : ${details[position].date}\nTime : ${details[position].startTime} - ${details[position].endTime}';
          Color starColor = (isUserFavorite(details[position].id)
              ? Colors.amber
              : Colors.grey);
          return ListTile(
            trailing: IconButton(
                icon: Icon(Icons.star),
                color: starColor,
                onPressed: () {
                  toggleFavorite(details[position]);
                }),
            title: Text(details[position].description),
            subtitle: Text(sub),
          );
        });
  }

  Future<List<EventDetail>> getDetailsList() async {
    var data = await db.collection('event_details').getDocuments();


    int i = 0;
    if (data != null) {
      details = data.documents
          .map((document) => EventDetail.fromMap(document))
          .toList();
      details.forEach((detail) {
        detail.id = data.documents[i].documentID;
        i++;
      });

    }

    return details;
  }

  void toggleFavorite(EventDetail ed) async {
    if (isUserFavorite(ed.id)) {
      Favorite favorite =
          favorites.firstWhere((Favorite f) => (f.eventId == ed.id));
      String favId = favorite.id;
      await FirestoreHelper.deleteFavorite(favId);
    } else {
      await FirestoreHelper.addFavorite(ed, uid);
    }

    List<Favorite> updateFavorite = await FirestoreHelper.getUserFavorites(widget.uid);

    setState(() {
      favorites = updateFavorite;
    });
  }

  bool isUserFavorite(String eventId) {
    Favorite favorite = favorites
        .firstWhere((Favorite f) => (f.eventId == eventId), orElse: () => null);

    if(favorite == null){
      return false;
    }else {
      return true;
    }
  }
}
