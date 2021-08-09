import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../superplayer_controller.dart';

const List<num> _kPlayRateList = [
  2.0,
  1.5,
  1.25,
  1.0,
  0.75,
];

class EndDrawerPlayRate extends StatelessWidget {
  final SuperPlayerController controller;
  final num playRate;
  final ValueChanged<num> onPlayRateChanged;

  const EndDrawerPlayRate({
    Key? key,
    required this.controller,
    required this.playRate,
    required this.onPlayRateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (var item in _kPlayRateList)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Builder(builder: (_) {
                  bool isSelected = playRate == item;
                  return Text(
                    '$item${item == 1 ? ' 正常' : ''}X',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  );
                }),
                onPressed: () {
                  onPlayRateChanged(item);
                },
              ),
            ),
        ],
      ),
    );
  }
}
