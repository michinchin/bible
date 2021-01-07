import 'package:bible/ui/common/common.dart';
import 'package:flutter/material.dart';
import 'package:bible/ui/common/tec_dialog.dart';
import 'package:tec_widgets/tec_widgets.dart';

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
    return Container(
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (c, i) => _HelpPageView(i, _controller),
              ),
            ),
            PageIndicatorList(_controller, _index, 2,
                darkMode: Theme.of(context).brightness == Brightness.dark)
          ],
        ));
  }
}

class _HelpPageView extends StatelessWidget {
  final int index;
  final PageController controller;

  const _HelpPageView(this.index, this.controller);

  @override
  Widget build(BuildContext context) {
    final titles = ['Move Views', 'View Actions'];
    final subtitles = [
      'Hold and drag the title bar to move views around',
      'Hold and drag to remove, hide, or rearrange views.'
    ];
    final imagePaths = ['assets/images/moveView', 'assets/images/viewOp'];

    return Column(
      children: [
        Expanded(
          child: TecText(
            titles[index],
            autoSize: true,
            style:
                Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).textColor),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
            flex: 20,
            child: Image.asset(
              Theme.of(context).brightness == Brightness.light
                  ? '${imagePaths[index]}Light.gif'
                  : '${imagePaths[index]}Dark.gif',
            )),
        const SizedBox(height: 20),
        Expanded(
          child: TecText(
            subtitles[index],
            autoSize: true,
            style: TextStyle(color: Theme.of(context).textColor),
          ),
        ),
        TecDialogButton(
          child: Text(index == titles.length - 1 ? 'Done' : 'Continue'),
          onPressed: () => index == titles.length - 1
              ? Navigator.of(context).maybePop()
              : controller.animateToPage(index + 1,
                  duration: const Duration(milliseconds: 150), curve: Curves.easeIn),
        ),
      ],
    );
  }
}
