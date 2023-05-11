// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'firebase_options.dart';

// class LeaderboardRepository {
//   Future<void> signIn(String email, String password) async {
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<void> saveHighScore(String name, int newScore) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     try {
//       final uid = currentUser.uid;
//       //final userName = getUserName();

//       // Get the previous score
//       final scoreRef = FirebaseDatabase.instance.ref('leaderboard/$uid');
//       final userScoreResult = await scoreRef.child('score').once();
//       final score = (userScoreResult.snapshot.value as int?) ?? 0;

//       // Return if it is not the high score
//       if (newScore < score) {
//         return;
//       }

//       await scoreRef.set({
//         'name': "test",
//         'score': newScore,
//       });
//     } catch (e) {
//       // handle error
//     }
//   }

//   Future<Iterable<LeaderboardModel>> getTopHighScores() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     final userId = currentUser?.uid;

//     // Retrieve first 20 data from highest to lowest in firebase
//     final result = await FirebaseDatabase.instance
//         .ref()
//         .child('leaderboard')
//         .orderByChild('score')
//         .limitToLast(20)
//         .once();

//     final leaderboardScores = result.snapshot.children
//         .map(
//           (e) => LeaderboardModel.fromJson(e.value as Map, e.key == userId),
//         )
//         .toList();

//     return leaderboardScores.reversed;
//   }
// }

// class LeaderboardModel {
//   final String name;
//   final int score;

//   LeaderboardModel({
//     required this.name,
//     required this.score,
//   });

//   factory LeaderboardModel.fromJson(Map json, bool isUser) {
//     return LeaderboardModel(
//       name: isUser ? 'You' : json['name'],
//       score: json['score'],
//     );
//   }
// }

// class LeaderboardView extends StatefulWidget {
//   const LeaderboardView({
//     this.isGameOver = true,
//     Key? key,
//   }) : super(key: key);
//   final bool isGameOver;

//   @override
//   State<LeaderboardView> createState() => _LeaderboardViewState();
// }

// class _LeaderboardViewState extends State<LeaderboardView> {
//   final List<LeaderboardModel> _leaderboardScores = [];

//   @override
//   void initState() {
//     super.initState();
//     // We get the leaderboard scores from the repository here
//     getLeaderboardScores();
//   }

//   void getLeaderboardScores() async {
//     final leaderboardScores = await LeaderboardRepository().getTopHighScores();
//     setState(() {
//       _leaderboardScores.addAll(leaderboardScores);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // UI widget goes here
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("Game Over"),
//             const SizedBox(height: 20),
//             Container(
//               height: 500,
//               width: 500,
//               child: SingleChildScrollView(
//                 child: DefaultTextStyle(
//                   style: const TextStyle(color: Colors.white),
//                   child: DataTable(
//                       dataTextStyle: const TextStyle(color: Colors.white),
//                       columns: const [
//                         DataColumn(
//                           label: Text('Rank'),
//                         ),
//                         DataColumn(
//                           label: Text('Name'),
//                         ),
//                         DataColumn(
//                           label: Text('Score'),
//                         ),
//                       ],
//                       rows: List.generate(_leaderboardScores.length, (index) {
//                         final leaderboard = _leaderboardScores[index];
//                         return DataRow(
//                           cells: [
//                             DataCell(Text('${index + 1}')),
//                             DataCell(Text(
//                               leaderboard.name,
//                             )),
//                             DataCell(Text(leaderboard.score.toString())),
//                           ],
//                         );
//                       })),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
