import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import './constants.dart';
import './superplayer_controller.dart';

class SuperPlayerView extends StatefulWidget {
  SuperPlayerController controller;
  Function(SuperPlayerController controller) onSuperPlayerViewCreated;

  SuperPlayerView({
    Key key,
    this.controller,
    this.onSuperPlayerViewCreated,
  }) : super(key: key);

  @override
  _SuperPlayerViewState createState() => _SuperPlayerViewState();
}

class _SuperPlayerViewState extends State<SuperPlayerView> {
  void _onPlatformViewCreated(int viewId) {
    if (widget.controller == null) {
      widget.controller = new SuperPlayerController();
    }
    if (widget.controller != null) {
      widget.controller.initWithViewId(viewId);
    }
    if (widget.onSuperPlayerViewCreated != null) {
      widget.onSuperPlayerViewCreated(widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Container();
  }
}
