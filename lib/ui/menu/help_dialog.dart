import 'package:bible/ui/common/common.dart';
import 'package:flutter/material.dart';
import 'package:bible/ui/common/tec_dialog.dart';
import 'package:tec_widgets/tec_widgets.dart';
import 'package:video_player/video_player.dart';

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
    return Container(
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
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

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    final titles = ['Move Views', 'View Actions'];
    final subtitles = [
      'Hold and drag the title bar to move views around',
      'Hold and drag to remove, hide, or rearrange views.'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TecText(
            titles[widget.index],
            autoSize: true,
            style:
                Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).textColor),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
            flex: 20,
            child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
        const SizedBox(height: 20),
        Expanded(
          child: TecText(
            subtitles[widget.index],
            autoSize: true,
            style: TextStyle(color: Theme.of(context).textColor),
          ),
        ),
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
