import 'package:final_project/boxChar.dart';

class BoxInner {
  late int index;
  List<BoxNum> boxNums = List<BoxNum>.from([]);

  BoxInner(this.index, this.boxNums);

  setFocus(int index, Direction direction) {
    List<BoxNum> temp;
    if (direction == Direction.Horizontal) {
      temp = boxNums
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp =
          boxNums.where((element) => element.index! % 3 == index % 3).toList();
    }
    temp.forEach((element) {
      element.isFocus = true;
    });
  }

  setExistValue(
      int index, int indexBox, String textInput, Direction direction) {
    List<BoxNum> temp;

    if (direction == Direction.Horizontal) {
      temp = boxNums
          .where((element) => element.index! ~/ 3 == index ~/ 3)
          .toList();
    } else {
      temp =
          boxNums.where((element) => element.index! % 3 == index % 3).toList();
    }

    if (this.index == indexBox) {
      List<BoxNum> boxNumsBox =
          boxNums.where((element) => element.text == textInput).toList();
      if (boxNumsBox.length == 1 && temp.isEmpty) boxNumsBox.clear();
      temp.addAll(boxNumsBox);
    }

    temp.where((element) => element.text == textInput).forEach((element) {
      element.isExist = true;
    });
  }

  clearFocus() {
    boxNums.forEach((element) {
      element.isFocus = false;
    });
  }

  clearExist() {
    boxNums.forEach((element) {
      element.isExist = false;
    });
  }
}

enum Direction { Horizontal, Vertical }
