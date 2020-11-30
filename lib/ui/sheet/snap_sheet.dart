import 'dart:math' as math;

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/const.dart';
import '../home/today.dart';
import '../library/library.dart';
import 'main_sheet.dart';
import 'selection_sheet.dart';

// must have SheetManagerBloc provided
class SnapSheet extends StatefulWidget {
  @override
  _SnapSheetState createState() => _SnapSheetState();
}

class _SnapSheetState extends State<SnapSheet> {
  List<Widget> sheets;

  @override
  void initState() {
    super.initState();
    sheets = [
      const _SheetShadow(key: ValueKey(1), child: MainSheet()),
      const _SheetShadow(key: ValueKey(2), child: SelectionSheet()),
      Container(),
    ];
  }

  static Widget animatedLayoutBuilder(Widget currentChild, List<Widget> previousChildren) {
    return Stack(
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectionBloc, SelectionState>(
      listenWhen: (previous, current) => previous.isTextSelected != current.isTextSelected,
      listener: (context, state) {
        if (state.isTextSelected) {
          context.tbloc<SheetManagerBloc>().add(SheetEvent.selection);
        } else {
          context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
        }
      },
      child: BlocBuilder<SheetManagerBloc, SheetManagerState>(builder: (context, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSwitcher(
            duration: Duration(
                milliseconds:
                    (state.type == SheetType.selection || state.previousType == SheetType.selection)
                        ? 250
                        : 125),
            layoutBuilder: animatedLayoutBuilder,
            transitionBuilder: (child, animation) {
              final offsetAnimation =
                  Tween<Offset>(begin: const Offset(0.0, 1.0), end: const Offset(0.0, 0.0))
                      .animate(animation);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            child: sheets[state.type.index],
          ),
        );
      }),
    );
  }
}

class _SheetShadow extends StatelessWidget {
  final Widget child;

  const _SheetShadow({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = isSmallScreen(context) ? size.width : math.min(size.width, 592.0);

    const sheetRadius = Radius.circular(7);
    const borderRadius = BorderRadius.only(topLeft: sheetRadius, topRight: sheetRadius);

    final decoration = Theme.of(context).brightness == Brightness.dark
        ? null
        : const BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                spreadRadius: 0,
              ),
            ],
            shape: BoxShape.rectangle,
          );

    return Container(
      width: maxWidth,
      decoration: decoration,
      child: Material(
        borderRadius: borderRadius,
        child: Padding(
          padding: EdgeInsets.only(top: 11, bottom: TecScaffoldWrapper.navigationBarPadding),
          child: child,
        ),
      ),
    );
  }
}

enum TecTab { today, library, store, reader }

class _TecTabItem {
  final IconData icon;
  final void Function(BuildContext) onPressed;
  final TecTab tab;

  _TecTabItem(this.tab, this.icon, this.onPressed);

  String get label {
    switch (tab) {
      case TecTab.today:
        return 'Today';
      case TecTab.library:
        return 'Library';
      case TecTab.store:
        return 'Store';
      case TecTab.reader:
        return null;
    }

    return null;
  }
}

class TecTabFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 2,
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      backgroundColor: Const.tecartaBlue,
      child: const Icon(TecIcons.tecartabiblelogo, color: Colors.white, size: 28),
    );
  }
}

class TecTabBar extends StatelessWidget {
  final VoidCallback pressedCallback;

  const TecTabBar({this.pressedCallback});

  @override
  Widget build(BuildContext context) {
    final icons = [
      _TecTabItem(TecTab.today, Icons.today_outlined, showTodayScreen),
      _TecTabItem(TecTab.library, FeatherIcons.book, showLibrary),
      _TecTabItem(TecTab.store, Icons.store_outlined, null),
    ];

    // CupertinoTabBar bob;
    // CupertinoTabView tom;

    return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 65, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final icon in icons)
                  SheetIconButton(
                    icon: icon.icon,
                    text: icon.label,
                    onPressed: () {
                      if (pressedCallback != null) {
                        pressedCallback();
                      }

                      if (icon.onPressed != null) {
                        icon.onPressed(context);
                      }
                    },
                  ),
              ],
            )));
  }
}

class SelectionSheetButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String title;

  const SelectionSheetButton({@required this.icon, @required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    Widget iconButton() => Icon(
          icon,
          color: Theme.of(context).appBarTheme.textTheme.headline6.color,
          size: 20,
        );
    return (title != null)
        ? InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              iconButton(),
              TecText(
                title,
                autoSize: true,
                textAlign: TextAlign.center,
                textScaleFactor: 0.9,
                maxLines: 1,
                style: Theme.of(context).textTheme.caption.copyWith(
                      color: Theme.of(context).textColor.withOpacity(0.6),
                    ),
              ),
            ]))
        : InkWell(onTap: onPressed, customBorder: const CircleBorder(), child: iconButton());
  }
}

class SheetIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const SheetIconButton({this.onPressed, this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        // customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).appBarTheme.textTheme.headline6.color,
            ),
            const SizedBox(height: 4),
            TecText(
              text,
              autoSize: true,
              textScaleFactor: 0.9,
              style: Theme.of(context).appBarTheme.textTheme.button,
            ),
          ],
        ),
      ),
    );
  }
}
