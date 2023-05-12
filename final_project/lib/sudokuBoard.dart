import 'dart:math';

import 'package:final_project/boxChar.dart';
import 'package:final_project/boxInner.dart';
import 'package:final_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:final_project/focusClass.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/strings.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';
import 'package:final_project/leaderboard.dart';

class SudokuBoard extends StatefulWidget {
  const SudokuBoard({Key? key}) : super(key: key);
  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

class _SudokuBoardState extends State<SudokuBoard> {
  //our variable
  List<BoxInner> boxInners = [];
  FocusClass focusClass = FocusClass();
  bool isFinish = false;
  String? tapBoxIndex;
  int? gamesWon;

  @override
  void initState() {
    generateSudoku();
    super.initState();
  }

  Future<void> generateSudoku() async {
    isFinish = false;
    focusClass = new FocusClass();
    tapBoxIndex = null;
    gamesWon = await getScore();
    generatePuzzle();
    checkFinish();
    setState(() {});
  }

  Future<int> getScore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return 0;
    try {
      final uid = currentUser.uid;
      // Get the previous score
      final scoreRef = FirebaseDatabase.instance.ref('leaderboard/$uid');
      final userScoreResult = await scoreRef.child('score').once();
      final score = (userScoreResult.snapshot.value as int?) ?? 0;
      if (score == 0) {
        await scoreRef.set({
          'name': "user",
          'score': score,
        });
      }
      return score;
    } catch (e) {
      // handle error
      if (kDebugMode) {
        print("error: $e");
      }
    }
    return 0;
  }

  Future<void> incrementScore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      final uid = currentUser.uid;
      // Get the previous score
      final scoreRef = FirebaseDatabase.instance.ref('leaderboard/$uid');
      final userScoreResult = await scoreRef.child('score').once();
      final score = (userScoreResult.snapshot.value as int?) ?? 0;
      int newScore = score + 1;
      if (score == 0) {
        await scoreRef.set({
          'score': newScore,
        });
      }
    } catch (e) {
      // handle error
      if (kDebugMode) {
        print("error: $e");
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ElevatedButton(
          onPressed: () => _signOut(),
          child: const Icon(Icons.logout),
        ),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LeaderboardView()));
                },
                child: const Icon(Icons.leaderboard_outlined),
              ),
              ElevatedButton(
                onPressed: () => generateSudoku(),
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
        title: const Text("SUDOKDO"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                color: Colors.black,
                padding: EdgeInsets.all(5),
                width: double.maxFinite,
                alignment: Alignment.center,
                child: GridView.builder(
                  itemCount: boxInners.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  physics: ScrollPhysics(),
                  itemBuilder: (buildContext, index) {
                    BoxInner boxInner = boxInners[index];
                    return Container(
                      color: Colors.grey,
                      alignment: Alignment.center,
                      child: GridView.builder(
                        itemCount: boxInner.boxNums.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        physics: ScrollPhysics(),
                        itemBuilder: (buildContext, indexNum) {
                          BoxNum boxNum = boxInner.boxNums[indexNum];
                          Color color = Colors.yellow.shade100;
                          Color colorNum = Colors.black;
                          if (isFinish) {
                            color = Colors.green;
                            incrementScore();
                          } else if (boxNum.isFocus && boxNum.text != "")
                            color = Colors.grey.shade400;
                          else if (boxNum.isDefault)
                            color = Colors.grey.shade400;

                          if (tapBoxIndex == "${index}-${indexNum}" &&
                              !isFinish) color = Colors.blue.shade100;

                          if (isFinish)
                            colorNum = Colors.white;
                          else if (boxNum.isExist) colorNum = Colors.red;

                          return Container(
                            color: color,
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: boxNum.isDefault
                                  ? null
                                  : () => setFocus(index, indexNum),
                              child: Text(
                                "${boxNum.text}",
                                style: TextStyle(color: colorNum),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Text(
                "Games Won: $gamesWon",
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: GridView.builder(
                          itemCount: 9,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          physics: ScrollPhysics(),
                          itemBuilder: (buildContext, index) {
                            return ElevatedButton(
                              onPressed: () => setInput(index + 1),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white)),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10),
                          child: ElevatedButton(
                            onPressed: () => setInput(null),
                            child: Container(
                              child: Text(
                                'Clear',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  generatePuzzle() {
    // install sudoku generator pluggins to generate
    boxInners.clear();
    var sudokuGenerator = SudokuGenerator(emptySquares: 40);
    // then populate to get a possible combination
    List<List<List<int>>> completes = partition(sudokuGenerator.newSudokuSolved,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList();
    partition(sudokuGenerator.newSudoku,
            sqrt(sudokuGenerator.newSudoku.length).toInt())
        .toList()
        .asMap()
        .entries
        .forEach(
      (entry) {
        List<int> tempListCompletes =
            completes[entry.key].expand((element) => element).toList();
        List<int> tempList = entry.value.expand((element) => element).toList();

        tempList.asMap().entries.forEach((entryIn) {
          int index =
              entry.key * sqrt(sudokuGenerator.newSudoku.length).toInt() +
                  (entryIn.key % 9).toInt() ~/ 3;

          if (boxInners.where((element) => element.index == index).isEmpty) {
            boxInners.add(BoxInner(index, []));
          }

          BoxInner boxInner =
              boxInners.where((element) => element.index == index).first;

          boxInner.boxNums.add(BoxNum(
            entryIn.value == 0 ? '' : entryIn.value.toString(),
            index: boxInner.boxNums.length,
            isDefault: entryIn.value != 0,
            isCorrect: entryIn.value != 0,
            correctText: tempListCompletes[entryIn.key].toString(),
          ));
        });
      },
    );
    //print(boxInners);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    runApp(const MyApp());
  }

  setFocus(int index, int indexNum) {
    tapBoxIndex = "$index-$indexNum";
    focusClass.setData(index, indexNum);
    showFocusCenterLine();
    setState(() {});
  }

  void showFocusCenterLine() {
    int rowBox = focusClass.indexBox! ~/ 3;
    int colBox = focusClass.indexBox! % 3;
    for (var element in boxInners) {
      element.clearFocus();
    }
    boxInners.where((element) => element.index ~/ 3 == rowBox).forEach(
        (element) =>
            element.setFocus(focusClass.indexChar!, Direction.Vertical));
    boxInners.where((element) => element.index % 3 == colBox).forEach(
        (element) =>
            element.setFocus(focusClass.indexChar!, Direction.Vertical));
  }

  setInput(int? number) {
    if (focusClass.indexBox == null) return;
    if (boxInners[focusClass.indexBox!].boxNums[focusClass.indexChar!].text ==
            number.toString() ||
        number == null) {
      boxInners.forEach((element) {
        element.clearFocus();
        element.clearExist();
      });
      boxInners[focusClass.indexBox!].boxNums[focusClass.indexChar!].setEmpty();
      tapBoxIndex = null;
      isFinish = false;
      showInputOnLine();
    } else {
      boxInners[focusClass.indexBox!]
          .boxNums[focusClass.indexChar!]
          .setText("$number");
      showInputOnLine();
      checkFinish();
    }
    setState(() {});
  }

  void showInputOnLine() {
    int rowBox = focusClass.indexBox! ~/ 3;
    int colBox = focusClass.indexBox! % 3;
    String textInput =
        boxInners[focusClass.indexBox!].boxNums[focusClass.indexChar!].text!;
    for (var element in boxInners) {
      element.clearExist();
    }
    boxInners.where((element) => element.index ~/ 3 == rowBox).forEach(
        (element) => element.setExistValue(focusClass.indexChar!,
            focusClass.indexBox!, textInput, Direction.Horizontal));
    boxInners.where((element) => element.index % 3 == colBox).forEach(
        (element) => element.setExistValue(focusClass.indexChar!,
            focusClass.indexBox!, textInput, Direction.Vertical));
    List<BoxNum> exists = boxInners
        .map((element) => element.boxNums)
        .expand((element) => element)
        .where((element) => element.isExist)
        .toList();
    if (exists.length == 1) exists[0].isExist = false;
  }

  void checkFinish() {
    int totalUnfinish = boxInners
        .map((element) => element.boxNums)
        .expand((element) => element)
        .where((element) => !element.isCorrect)
        .length;
    isFinish = totalUnfinish == 0;
  }
}
