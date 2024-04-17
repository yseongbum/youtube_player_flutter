// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enums/player_state.dart';
import '../utils/youtube_player_controller.dart';

/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget? bufferIndicator;

  /// Creates [PlayPauseButton] widget.
  PlayPauseButton({
    this.controller,
    this.bufferIndicator,
  });

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
    _controller.removeListener(_playPauseListener);
    _controller.addListener(_playPauseListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_playPauseListener);
    _animController.dispose();
    super.dispose();
  }

  void _playPauseListener() => _controller.value.isPlaying
      ? _animController.forward()
      : _animController.reverse();

  void _toggleFullScreen() {
    if (_controller.value.isFullScreen) {
      if(_controller.value.isPlaying){
        _controller.pause();
      }else{
        _controller.play();
      }
      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);  // 풀스크린 모드 해제
      //_controller.pause();
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);  // 풀스크린 모드 활성화
      _controller.play();
    }
    //_controller.toggleFullScreenMode();  // 풀스크린 상태 토글
  }

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (_controller.value.isFullScreen) {
      icon = AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _animController.view,
        color: Colors.white,
        size: 60.0,
      );
    } else {
      icon = Icon(
        Icons.fullscreen,
        color: Colors.white,
        size: 60.0,
      );
    }

    final _playerState = _controller.value.playerState;
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return Visibility(
        visible: _playerState == PlayerState.cued ||
            !_controller.value.isPlaying ||
            _controller.value.isControlsVisible,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: _toggleFullScreen,
            child: icon,
          ),
        ),
      );
    }
    if (_controller.value.hasError) return const SizedBox();
    return widget.bufferIndicator ??
        Container(
          width: 70.0,
          height: 70.0,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
  }
}
