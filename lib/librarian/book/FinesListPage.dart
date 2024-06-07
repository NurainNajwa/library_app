import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinesListPage extends StatelessWidget {
  const FinesListPage({Key? key}) : super(key: key);

  Future<Map<String, double>> _fetchFines() async {
    QuerySnapshot finesSnapshot =
        await FirebaseFirestore.instance.collection('fines').get();

    Map<String, double> userFines = {};

    for (var doc in finesSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String userId = data['userId'];
      double fineAmount = data['fineAmount'];

      if (userFines.containsKey(userId)) {
        userFines[userId] = userFines[userId]! + fineAmount;
      } else {
        userFines[userId] = fineAmount;
      }
    }

    return userFines;
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var userData = userSnapshot.data() as Map<String, dynamic>?;
    return userData?['name'] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines List'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _fetchFines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          Map<String, double> fines = snapshot.data ?? {};

          if (fines.isEmpty) {
            return const Center(child: Text('No fines found'));
          }

          return ListView.builder(
            itemCount: fines.length,
            itemBuilder: (context, index) {
              String userId = fines.keys.elementAt(index);
              double fineAmount = fines[userId]!;

              return FutureBuilder<String>(
                future: _getUserName(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: const Text('Loading...'),
                    );
                  }

                  return ListTile(
                    title: Text(userSnapshot.data ?? 'Unknown User'),
                    subtitle: Text('Fine: MYR $fineAmount'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
