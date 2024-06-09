import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRoom {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('Rooms');

  Future<List<QueryDocumentSnapshot>> searchRooms(String query) async {
    var searchQuery = query.toLowerCase().trim();

    var rooms = await _roomsCollection.get();
    var filteredRooms = rooms.docs.where((doc) {
      var roomType = doc['roomType'].toString().toLowerCase();
      var capacity = doc['capacity'].toString().toLowerCase();
      return roomType.contains(searchQuery) || capacity.contains(searchQuery);
    }).toList();

    return filteredRooms;
  }
}
