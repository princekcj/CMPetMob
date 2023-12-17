import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('scan_count', descending: true)
        .get();
    var tese = querySnapshot.docs;
    print("is there $tese");

    for (var document in tese) {
      // Print each document data
      print("Document data: ${document.data()}");

      // Access specific fields in the document
      var fieldValue = document['scan_count'];
      print("Field value: $fieldValue");
    }

// Assuming you have a variable holding the current user's email
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    List<Map<String, dynamic>> leaderboardData = querySnapshot.docs
        .map((DocumentSnapshot<Map<String, dynamic>> document) {
      final email = document.data()!.containsKey('email') ? document['email'] : 'default@example.com';
      final scanCount = document.data()!.containsKey('scan_count') ? document['scan_count'] : 0;

      // Hide emails for users other than the current user
      final displayedEmail = (currentUserEmail == email) ? email : '********';

      return {
        'userId': document.id,
        'displayName': displayedEmail,
        'scanCount': scanCount,
        // Add more fields as needed
      };
    }).toList();
    return leaderboardData;
  } catch (e) {
    print('Error fetching leaderboard: $e');
    return [];
  }
}

