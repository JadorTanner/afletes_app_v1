// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class NextPageButton extends StatelessWidget {
  NextPageButton(this.pageController, {this.validator, Key? key})
      : super(key: key);
  PageController pageController;
  var validator;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => pageController.nextPage(
          duration: const Duration(milliseconds: 100), curve: Curves.ease),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 20)),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(0xFFF58633),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Siguiente',
            style: TextStyle(color: Colors.white),
          ),
          Icon(
            Icons.navigate_next,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class PrevPageButton extends StatelessWidget {
  PrevPageButton(this.pageController, {this.validator, Key? key})
      : super(key: key);
  PageController pageController;
  var validator;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => pageController.previousPage(
          duration: const Duration(milliseconds: 100), curve: Curves.ease),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 20)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF101010)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.navigate_before, color: Colors.white),
          Text(
            'Atrás',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
