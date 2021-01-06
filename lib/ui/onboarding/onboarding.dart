import 'package:flutter/material.dart';
import 'package:tec_user_account/tec_user_account_ui.dart' as tua;
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../models/app_settings.dart';
import '../../models/const.dart';

Future<void> showOnboarding(BuildContext context) async {
  await Navigator.of(context)
      .push<void>(MaterialPageRoute(builder: (c) => Onboarding(), fullscreenDialog: true));
  await tec.Prefs.shared.setBool(Const.prefShowOnboarding, false);
}

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

final pageTitles = <String>[
  'Welcome To Tecarta Bible',
  'Instantly Search the Extensive Library',
  'Cross-reference any passage',
  'Create Study Projects',
  'Begin Your Bible Journey'
];
final pageDescriptions = <String>[
  'The world\'s most advanced Bible study application.\n\nClick continue to learn more about some of TecartaBible\'s more important features',
  'Instantly search across over 30 translations and over 60 Study titles, make instant comparisons, copy passages, and share results with TecartaBible\'s powerful, exclusive search engine.',
  'With the new Learn feature you can cross reference 100+ premium titles for thousands of articles, concordences, maps, charts, study notes and devotionals with one tap.',
  'Manage your Bible study your way. Create, duplicate, share, and archive study projects, each with their own unique markings, notes, and reference material.',
  'Log in or sign up now for a free Sync account, to maintain your progress and study project state across all devices.'
];
final pageIcons = <IconData>[
  TecIcons.tecartabiblelogo,
  Icons.search,
  Icons.mediation,
  Icons.graphic_eq,
  TecIcons.tecartabiblelogo,
];

class _OnboardingState extends State<Onboarding> {
  double _currentIndex;
  PageController _controller;
  final pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _controller = PageController(initialPage: 0)
      ..addListener(() {
        setState(() {
          _currentIndex = _controller.page;
        });
      });
    const pageCount = 5;
    for (var i = 0; i < pageCount; i++) {
      pages.add(_OnboardingPage(i));
    }
  }

  Widget _indicator(int position, bool isActive) {
    return GestureDetector(
      onTap: () => _controller.animateToPage(position,
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut),
      child: Container(
        height: 10,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    final list = <Widget>[];
    for (var i = 0; i < pages.length; i++) {
      list.add(i == _currentIndex ? _indicator(i, true) : _indicator(i, false));
    }
    return list;
  }

  Widget _textAndButton() {
    final index = _currentIndex.toInt();
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: index == _currentIndex ? 1 : 0,
                    child: Column(
                      children: [
                        const Spacer(),
                        Expanded(
                            child: Icon(
                          pageIcons[index],
                          size: 80,
                          color: Colors.white,
                        )),
                        Expanded(
                          child: TecText(
                            pageTitles[index],
                            autoSize: true,
                            style: Theme.of(context).textTheme.headline2.copyWith(
                                color: Colors.white, fontSize: 50, fontWeight: FontWeight.w200),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: TecText(
                            pageDescriptions[index],
                            autoSize: true,
                            style: Theme.of(context).textTheme.headline2.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w200,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: index != pages.length - 1
                        ? Colors.white.withOpacity(0.3)
                        : Const.tecartaBlue,
                  ),
                  child: FlatButton(
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: const StadiumBorder(),
                      child: Text(
                        index != pages.length - 1 ? 'Continue' : 'Sign In',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: () async {
                        if (index != pages.length - 1) {
                          await _controller.animateToPage(index + 1,
                              curve: Curves.easeIn, duration: const Duration(milliseconds: 250));
                        } else {
                          await tua.showSignInDlg(
                            context: context,
                            account: AppSettings.shared.userAccount,
                            appName: Const.appNameForUA,
                          );
                          if (AppSettings.shared.userAccount.isSignedIn) {
                            Navigator.of(context).pop();
                          }
                        }
                      })),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.bottomCenter, children: [
      PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        itemBuilder: (c, i) => pages[i],
      ),
      _textAndButton()
    ]));
  }
}

class _OnboardingPage extends StatelessWidget {
  final int index;
  const _OnboardingPage(this.index);
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      foregroundDecoration: const BoxDecoration(
        color: Colors.black45,
      ),
      child: Image.asset(
        'assets/images/photo$index.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
