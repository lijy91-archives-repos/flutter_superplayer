import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import '../../../flutter_superplayer.dart';

import './end_drawer_play_rate.dart';
import './end_drawer_video_quality.dart';

const _kPlayerControlHeaderBarHeight = 60.0;
const _kPlayerControlFooterBarHeight = 60.0;

const _kEndDrawerTypePlayRate = 'playRate';
const _kEndDrawerTypeVideoQuality = 'videoQuality';

class _TextButton extends StatelessWidget {
  final String text;
  final double? height;
  final Color? color;
  final VoidCallback? onPressed;

  const _TextButton(
    this.text, {
    Key? key,
    this.height = 32,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CupertinoButton(
        padding: EdgeInsets.all(4),
        color: color,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ImageButton extends StatelessWidget {
  final String name;
  final double? size;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onPressed;

  const _ImageButton(
    this.name, {
    Key? key,
    this.size = 32,
    this.padding,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red.withOpacity(0.1),
      width: size,
      height: size,
      child: CupertinoButton(
        padding: padding ?? EdgeInsets.all(0),
        color: color,
        child: Image.asset(
          'images/$name',
          package: 'flutter_superplayer',
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _WidgetVisibleTrigger extends StatefulWidget {
  final bool isVisible;
  final Widget child;
  final ValueChanged<bool> onVisibleChanged;

  const _WidgetVisibleTrigger({
    Key? key,
    required this.isVisible,
    required this.child,
    required this.onVisibleChanged,
  }) : super(key: key);

  @override
  __WidgetVisibleTriggerState createState() => __WidgetVisibleTriggerState();
}

class __WidgetVisibleTriggerState extends State<_WidgetVisibleTrigger> {
  Timer? _widgetVisibleTriggerTimer;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1)).then((value) {
      if (!widget.isVisible) {
        _handleTap();
      }
    });
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (widget.isVisible) {
      _startTimer();
    } else {
      _stopTimer();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _startTimer() {
    _stopTimer();
    _widgetVisibleTriggerTimer = Timer.periodic(
      Duration(seconds: 5),
      (timer) {
        _widgetVisibleTriggerTimer!.cancel();
        _widgetVisibleTriggerTimer = null;

        widget.onVisibleChanged(false);
      },
    );
  }

  void _stopTimer() {
    if (_widgetVisibleTriggerTimer != null) {
      _widgetVisibleTriggerTimer!.cancel();
      _widgetVisibleTriggerTimer = null;
    }
  }

  void _handleTap() {
    _stopTimer();
    widget.onVisibleChanged(!widget.isVisible);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

class SuperPlayerDefaultControlView extends StatefulWidget {
  SuperPlayerController controller;

  SuperPlayerDefaultControlView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _SuperPlayerDefaultControlViewState createState() =>
      _SuperPlayerDefaultControlViewState();
}

class _SuperPlayerDefaultControlViewState
    extends State<SuperPlayerDefaultControlView> with SuperPlayerListener {
  bool _controlViewIsVisible = false;
  String? _activeEndDrawerType;

  bool _isLocked = false;
  int _playState = -1;
  int _playProgressCurrent = 0;
  int _playProgressDuration = 0;
  num _playRate = 1;
  bool _isFullScreen = false;
  SuperPlayerURL? _videoQuality;
  List<SuperPlayerURL> _videoQualityList = [];

  @override
  void initState() {
    widget.controller.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(this);
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return _WidgetVisibleTrigger(
      isVisible: _controlViewIsVisible,
      onVisibleChanged: (newValue) {
        _controlViewIsVisible = newValue;
        widget.controller.notifyListeners(kMethodOnControlViewIsVisibleChange, {
          'isVisible': newValue,
        });
        setState(() {});
      },
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: (!_isLocked && _controlViewIsVisible) ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: Column(
                children: [
                  _PlayerControlHeaderBar(
                    controller: widget.controller,
                  ),
                  Expanded(
                    child: Container(),
                    // child: Center(
                    //   child: Stack(
                    //     children: [
                    //       if (_playState == SuperPlayerConst.PLAYSTATE_LOADING)
                    //         Container(
                    //           width: 44,
                    //           height: 44,
                    //           child: CupertinoTheme(
                    //             data: CupertinoTheme.of(context)
                    //                 .copyWith(brightness: Brightness.dark),
                    //             child: CupertinoActivityIndicator(
                    //               radius: 16,
                    //             ),
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                  ),
                  _PlayerControlFooterBar(
                    controller: widget.controller,
                    playState: _playState,
                    isFullScreen: _isFullScreen,
                    playProgressCurrent: _playProgressCurrent,
                    playProgressDuration: _playProgressDuration,
                    onPlayProgressCurrentChanged: (newValue) {
                      widget.controller.seekTo(newValue);
                      setState(() {
                        _playProgressCurrent = newValue;
                      });
                    },
                    playRate: _playRate,
                    onPressedActionPlayRate: () {
                      setState(() {
                        _activeEndDrawerType = _kEndDrawerTypePlayRate;
                      });
                    },
                    videoQuality: _videoQuality,
                    onPressedActionVideoQuality: () async {
                      SuperPlayerModel model =
                          await widget.controller.getModel();
                      setState(() {
                        _activeEndDrawerType = _kEndDrawerTypeVideoQuality;
                        _videoQualityList = model.multiURLs!;
                      });
                    },
                  ),
                ],
              ),
            ),
            if (_isFullScreen)
              Positioned(
                left: 0,
                top: _kPlayerControlHeaderBarHeight,
                bottom: _kPlayerControlFooterBarHeight,
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _PlayerControlLockButton(
                        isLocked: _isLocked,
                        onLockedChanged: (newValue) {
                          setState(() {
                            _isLocked = newValue;
                            if (!_isLocked) {
                              _controlViewIsVisible = true;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            _PlayerControlVideoRepeatButton(
              controller: widget.controller,
              playState: _playState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _activeEndDrawerType = null;
        });
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              color: Colors.black.withOpacity(0.6),
              child: Stack(
                children: [
                  if (_activeEndDrawerType == _kEndDrawerTypePlayRate)
                    EndDrawerPlayRate(
                      controller: widget.controller,
                      playRate: _playRate,
                      onPlayRateChanged: (newValue) {
                        setState(() {
                          _playRate = newValue;
                          _activeEndDrawerType = null;
                        });
                        print('>>>playRate $_playRate');
                        widget.controller.setPlayRate(_playRate);
                      },
                    ),
                  if (_activeEndDrawerType == _kEndDrawerTypeVideoQuality)
                    EndDrawerVideoQuality(
                      videoQualityList: _videoQualityList,
                      videoQuality: _videoQuality,
                      onVideoQualityChanged: (newValue) async {
                        setState(() {
                          _videoQuality = newValue;
                          _activeEndDrawerType = null;
                        });
                        widget.controller.setVideoQuality(_videoQuality!);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _WidgetVisibleTrigger(
          isVisible: _controlViewIsVisible,
          onVisibleChanged: (newValue) {
            _controlViewIsVisible = newValue;
            setState(() {});
          },
          child: _buildBody(context),
        ),
        if (_activeEndDrawerType != null) _buildEndDrawer(context),
      ],
    );
  }

  @override
  void onClickFloatCloseBtn() {}

  @override
  void onClickSmallReturnBtn() {}

  @override
  void onFullScreenChange(bool isFullScreen) {
    if (_isFullScreen != isFullScreen) {
      setState(() {
        _isFullScreen = isFullScreen;
      });
    }
  }

  @override
  void onPlayProgressChange(int current, int duration) {
    if (_playProgressCurrent != current || _playProgressDuration != duration) {
      setState(() {
        _playProgressCurrent = current;
        _playProgressDuration = duration;
      });
    }
  }

  @override
  void onPlayStateChange(int playState) async {
    if (playState != _playState) {
      SuperPlayerURL? superPlayerURL;
      if (playState == SuperPlayerConst.PLAYSTATE_PLAYING) {
        superPlayerURL = await widget.controller.getVideoQuality();
      }
      setState(() {
        _playState = playState;
        _videoQuality = superPlayerURL;

        if (_playState == SuperPlayerConst.PLAYSTATE_END) {
          _playProgressCurrent = 0;
          _playProgressDuration = 0;
        }
      });
    }
  }

  @override
  void onControlViewIsVisibleChange(bool isVisible) {
    // skip
  }
}

class _PlayerControlHeaderBar extends StatelessWidget {
  final SuperPlayerController controller;

  _PlayerControlHeaderBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kPlayerControlHeaderBarHeight,
      padding: EdgeInsets.only(left: 0, right: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff000000).withOpacity(0.60),
            Color(0xff000000).withOpacity(0.06),
            Color(0xff000000).withOpacity(0),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageButton(
            'superplayer_ic_menu_back.png',
            size: 44,
            onPressed: () async {
              bool isFullScreen = await controller.isFullScreen();
              if (isFullScreen) {
                controller.setFullScreen(false);
              } else {
                controller.notifyListeners(kMethodOnClickSmallReturnBtn);
              }
            },
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}

class _PlayerControlFooterBar extends StatefulWidget {
  final SuperPlayerController controller;
  final int playState;
  final bool isFullScreen;
  final int playProgressCurrent;
  final int playProgressDuration;
  final ValueChanged<int> onPlayProgressCurrentChanged;
  final num playRate;
  final VoidCallback onPressedActionPlayRate;
  final SuperPlayerURL? videoQuality;
  final VoidCallback onPressedActionVideoQuality;

  _PlayerControlFooterBar({
    Key? key,
    required this.controller,
    required this.playState,
    required this.isFullScreen,
    required this.playProgressCurrent,
    required this.onPlayProgressCurrentChanged,
    required this.playProgressDuration,
    required this.playRate,
    required this.onPressedActionPlayRate,
    required this.videoQuality,
    required this.onPressedActionVideoQuality,
  }) : super(key: key);

  @override
  __PlayerControlFooterBarState createState() =>
      __PlayerControlFooterBarState();
}

class __PlayerControlFooterBarState extends State<_PlayerControlFooterBar> {
  bool _seekBarDragging = false;
  int _seekBarValue = 0;

  String _formatTime(num seconds) {
    String stringValue = '00:00';

    if (seconds > 0) {
      final num minutes = seconds ~/ 60;
      final num hours = minutes ~/ 60;

      String h = (hours % 24).toInt().toString().padLeft(2, '0');
      String m = (minutes % 60).toInt().toString().padLeft(2, '0');
      String s = (seconds % 60).toInt().toString().padLeft(2, '0');

      stringValue = '$m:$s';
      if (hours > 0) stringValue = '$h:$stringValue';
    }
    return stringValue;
  }

  String get _formattedSeekBarValue {
    return _formatTime(_seekBarValue);
  }

  String get _formattedCurrent {
    return _formatTime(widget.playProgressCurrent);
  }

  String get _formattedDuration {
    return _formatTime(widget.playProgressDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kPlayerControlFooterBarHeight,
      padding: EdgeInsets.only(left: 0, right: 0),
      decoration: BoxDecoration(
        // color: Colors.green.withOpacity(0.1),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xff000000).withOpacity(0.60),
            Color(0xff000000).withOpacity(0.06),
            Color(0xff000000).withOpacity(0),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PlayerControlVideoOperationButton(
            controller: widget.controller,
            playState: widget.playState,
          ),
          Container(
            width: 52,
            height: 44,
            padding: EdgeInsets.only(left: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_formattedCurrent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 44,
              margin: EdgeInsets.only(left: 0, right: 0),
              child: FlutterSlider(
                values: [widget.playProgressCurrent.toDouble()],
                max: widget.playProgressDuration.toDouble() > 0
                    ? widget.playProgressDuration.toDouble()
                    : 1,
                min: 0,
                disabled: widget.playProgressDuration.toDouble() == 0,
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBarHeight: 2,
                  inactiveTrackBar: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  activeTrackBarHeight: 2,
                  activeTrackBar: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                handlerWidth: 16,
                handlerHeight: 16,
                handler: FlutterSliderHandler(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          offset: Offset(0.0, 2.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                offset: Offset(0.0, 2.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                tooltip: FlutterSliderTooltip(
                  custom: (value) {
                    if (!_seekBarDragging) return Container();
                    return Container(
                      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      child: Center(
                        child: Text(
                          '$_formattedSeekBarValue/$_formattedDuration',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                onDragging: (
                  handlerIndex,
                  lowerValue,
                  upperValue,
                ) {
                  _seekBarDragging = true;
                  _seekBarValue = lowerValue.toInt();
                  setState(() {});
                },
                onDragCompleted: (
                  handlerIndex,
                  lowerValue,
                  upperValue,
                ) {
                  widget.onPlayProgressCurrentChanged(_seekBarValue);
                  // _playProgressCurrent = _seekBarValue;
                  _seekBarDragging = false;
                  _seekBarValue = 0;

                  setState(() {});
                },
              ),
            ),
          ),
          Container(
            width: 52,
            height: 44,
            padding: EdgeInsets.only(right: 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_formattedDuration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (widget.isFullScreen)
            Padding(
              padding: EdgeInsets.only(right: 6),
              child: _PlayerControlActionSetPlayRate(
                playRate: widget.playRate,
                onPressed: widget.onPressedActionPlayRate,
              ),
            ),
          if (widget.isFullScreen)
            Padding(
              padding: EdgeInsets.only(right: 6),
              child: _PlayerControlActionSetVideoQuality(
                videoQuality: widget.videoQuality,
                onPressed: widget.onPressedActionVideoQuality,
              ),
            ),
          _PlayerControlActionEnterFullScreen(
            controller: widget.controller,
          ),
        ],
      ),
    );
  }
}

class _PlayerControlVideoOperationButton extends StatelessWidget {
  final SuperPlayerController controller;
  final int playState;

  const _PlayerControlVideoOperationButton({
    Key? key,
    required this.controller,
    required this.playState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 播放 (未初始化/暂停中)
        if (playState == SuperPlayerConst.PLAYSTATE_NONE ||
            playState == SuperPlayerConst.PLAYSTATE_PAUSE ||
            playState == SuperPlayerConst.PLAYSTATE_END ||
            playState == SuperPlayerConst.PLAYSTATE_FAILED)
          _ImageButton(
            'superplayer_btn_play.png',
            size: 44,
            onPressed: () {
              if (playState == SuperPlayerConst.PLAYSTATE_PAUSE) {
                controller.resume();
              } else {
                controller.play();
              }
            },
          )
        else if (playState == SuperPlayerConst.PLAYSTATE_PLAYING ||
            playState == SuperPlayerConst.PLAYSTATE_LOADING)
          _ImageButton(
            'superplayer_btn_pause.png',
            size: 44,
            onPressed: () {
              controller.pause();
            },
          ),
      ],
    );
  }
}

class _PlayerControlVideoRepeatButton extends StatelessWidget {
  final SuperPlayerController controller;
  final int playState;

  const _PlayerControlVideoRepeatButton({
    Key? key,
    required this.controller,
    required this.playState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 重播
          if (playState == SuperPlayerConst.PLAYSTATE_END)
            _ImageButton(
              'superplayer_btn_repeat.png',
              size: 86,
              color: Colors.black.withOpacity(0.6),
              padding: EdgeInsets.all(10),
              onPressed: () {
                controller.resetPlayer();
                controller.play();
              },
            ),
        ],
      ),
    );
  }
}

class _PlayerControlLockButton extends StatelessWidget {
  final bool isLocked;
  final ValueChanged<bool> onLockedChanged;

  const _PlayerControlLockButton({
    Key? key,
    required this.isLocked,
    required this.onLockedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ImageButton(
      isLocked ? 'superplayer_btn_lock_off.png' : 'superplayer_btn_lock_on.png',
      size: 42,
      color: Colors.transparent,
      onPressed: () {
        onLockedChanged(!isLocked);
      },
    );
  }
}

class _PlayerControlActionSetPlayRate extends StatelessWidget {
  final num playRate;
  final VoidCallback onPressed;

  const _PlayerControlActionSetPlayRate({
    Key? key,
    required this.playRate,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _TextButton(
      '${playRate}X',
      onPressed: onPressed,
    );
  }
}

class _PlayerControlActionSetVideoQuality extends StatelessWidget {
  final SuperPlayerURL? videoQuality;
  final VoidCallback onPressed;

  const _PlayerControlActionSetVideoQuality({
    Key? key,
    required this.videoQuality,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _TextButton(
      videoQuality != null ? videoQuality!.qualityName! : '清晰度',
      onPressed: onPressed,
    );
  }
}

class _PlayerControlActionEnterFullScreen extends StatelessWidget {
  final SuperPlayerController controller;

  const _PlayerControlActionEnterFullScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ImageButton(
      'superplayer_btn_fullscreen_enter.png',
      size: 44,
      onPressed: () async {
        bool isFullScreen = await controller.isFullScreen();
        controller.setFullScreen(!isFullScreen);
      },
    );
  }
}
