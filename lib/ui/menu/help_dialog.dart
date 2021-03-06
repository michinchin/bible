import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:video_player/video_player.dart';

import '../../models/const.dart';
import '../common/common.dart';
import '../common/tec_dialog.dart';

void showViewHelpDialog(BuildContext context) =>
    showTecDialog<void>(context: context, makeScrollable: false, builder: (c) => _ViewHelpDialog());

class _ViewHelpDialog extends StatefulWidget {
  @override
  __ViewHelpDialogState createState() => __ViewHelpDialogState();
}

class __ViewHelpDialogState extends State<_ViewHelpDialog> {
  PageController _controller;
  int _index;

  @override
  void initState() {
    super.initState();
    _index = 0;
    _controller = PageController()
      ..addListener(() {
        setState(() {
          _index = _controller.page.toInt();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final imagePaths = ['assets/images/moveView', 'assets/images/viewOp'];
    return SizedBox(
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: imagePaths.length,
                itemBuilder: (c, i) => _HelpPageView(
                    i,
                    _controller,
                    Theme.of(context).brightness == Brightness.light
                        ? '${imagePaths[i]}Light.mp4'
                        : '${imagePaths[i]}Dark.mp4'),
              ),
            ),
            PageIndicatorList(_controller, _index, 2,
                darkMode: Theme.of(context).brightness == Brightness.dark)
          ],
        ));
  }
}

class _HelpPageView extends StatefulWidget {
  final int index;
  final PageController controller;
  final String videoPath;

  const _HelpPageView(this.index, this.controller, this.videoPath);

  @override
  __HelpPageViewState createState() => __HelpPageViewState();
}

class __HelpPageViewState extends State<_HelpPageView> {
  VideoPlayerController _controller;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _timer.cancel();
      });
    });
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })
      ..setPlaybackSpeed(2.0)
      ..setLooping(true)
      ..play();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Move Views\n(hold and drag title bar to move)',
      'Close, hide, and make full screen'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!kIsWeb && _controller.value.isInitialized)
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                  opacity: _timer.isActive ? 0.3 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
              AnimatedOpacity(
                  opacity: _timer.isActive ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        titles[widget.index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(color: Const.tecartaBlue),
                      ))),
            ],
          )),
        TecDialogButton(
          child: Text(widget.index == titles.length - 1 ? 'Done' : 'Continue'),
          onPressed: () => widget.index == titles.length - 1
              ? Navigator.of(context).maybePop()
              : widget.controller.animateToPage(widget.index + 1,
                  duration: const Duration(milliseconds: 150), curve: Curves.easeIn),
        ),
      ],
    );
  }
}
