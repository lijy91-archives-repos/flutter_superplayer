import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../superplayer_model.dart';

class EndDrawerVideoQuality extends StatelessWidget {
  final List<SuperPlayerURL> videoQualityList;
  final SuperPlayerURL? videoQuality;
  final ValueChanged<SuperPlayerURL> onVideoQualityChanged;

  const EndDrawerVideoQuality({
    Key? key,
    required this.videoQualityList,
    required this.videoQuality,
    required this.onVideoQualityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (var item in videoQualityList)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 20, right: 20),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Builder(builder: (_) {
                  bool isSelected = videoQuality?.qualityName == item.qualityName;
                  return Text(
                    '${item.qualityName}',
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
                  onVideoQualityChanged(item);
                },
              ),
            ),
        ],
      ),
    );
  }
}
