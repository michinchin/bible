import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' show TecUtilExtOnBuildContext;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../common/common.dart';
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
    const sheetRadius = Radius.circular(7);
    const borderRadius = BorderRadius.only(topLeft: sheetRadius, topRight: sheetRadius);

    // if we want a sheet with a shadow...
    // decoration: BoxDecoration(
    //   borderRadius: borderRadius,
    //   boxShadow: [
    //     BoxShadow(
    //       color:
    //           (Theme.of(context).brightness == Brightness.dark) ? Colors.white54 : Colors.black26,
    //       blurRadius: 3,
    //       spreadRadius: 0,
    //     ),
    //   ],
    //   shape: BoxShape.rectangle,
    // ),

    return Material(
      borderRadius: borderRadius,
      child: Padding(
        padding: EdgeInsets.only(top: 11, bottom: TecScaffoldWrapper.navigationBarPadding),
        child: child,
      ),
    );
  }
}

///
/// Shared Widgets across different sheets
///
class SheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const SheetButton({@required this.text, @required this.icon, @required this.onPressed})
      : assert(text != null),
        assert(icon != null),
        assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        height: 50,
        child: OutlineButton.icon(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          label: TecText(
            text,
            autoSize: true,
            textScaleFactor: 0.8,
            style: TextStyle(
              color: Theme.of(context).textColor.withOpacity(0.8),
            ),
          ),
          icon: Icon(
            icon,
            size: 18,
            color: Theme.of(context).textColor.withOpacity(0.8),
          ),
          onPressed: onPressed,
        ));
  }
}

class SelectionSheetButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String title;

  const SelectionSheetButton({@required this.icon, @required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    Widget iconButton() =>
        // Padding(
        // padding: const EdgeInsets.all(5),
        // child:
        Icon(
          icon,
          color: Colors.grey,
          size: 20,
          // ),
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
                      color: Theme.of(context).textColor.withOpacity(0.5),
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
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onTap: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(height: 4),
            TecText(
              text,
              autoSize: true,
              textScaleFactor: 0.9,
              style: TextStyle(
                color: Theme.of(context).textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
