import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import './constants.dart';
import './superplayer_control_view.dart';
import './superplayer_controller.dart';

class SuperPlayerView extends StatefulWidget {
  Function(SuperPlayerController controller) onSuperPlayerViewCreated;
  SuperPlayerController controller;
  String controlViewType;

  SuperPlayerView({
    Key key,
    this.onSuperPlayerViewCreated,
    this.controller,
    this.controlViewType = kControlViewTypeDefault,
  }) : super(key: key);

  @override
  _SuperPlayerViewState createState() => _SuperPlayerViewState();
}

class _SuperPlayerViewState extends State<SuperPlayerView> {
  void _onPlatformViewCreated(int viewId) {
    if (widget.controller == null) {
      widget.controller = SuperPlayerController();
    }
    if (widget.controller != null) {
      widget.controller.initWithViewId(viewId);
    }
    if (widget.onSuperPlayerViewCreated != null) {
      widget.onSuperPlayerViewCreated(widget.controller);
    }
  }

  @override
  void didUpdateWidget(covariant SuperPlayerView oldWidget) {
    if (oldWidget.controlViewType != widget.controlViewType) {
      widget.controller.setControlViewType(widget.controlViewType);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = {
      'controlViewType': widget.controlViewType,
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: kSuperPlayerViewViewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Container();
  }
}
