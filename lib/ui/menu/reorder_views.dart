import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';

import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/const.dart';
import '../common/common.dart';

///
/// DragOverlay
///
class DragOverlayDetails {
  final bool show;
  final int currentUid;

  // final bool inIcon;
  DragOverlayDetails copyWith({
    bool show,
    int currentUid,
  }) =>
      DragOverlayDetails(
        show: show ?? this.show,
        currentUid: currentUid ?? this.currentUid,
      );

  DragOverlayDetails({
    this.show = false,
    this.currentUid = 0,
  });
}

class DragOverlayCubit extends Cubit<DragOverlayDetails> {
  DragOverlayCubit() : super(DragOverlayDetails());

  /// clear all drag targets from view
  void clear() => emit(state.copyWith(show: false, currentUid: 0));

  /// show all options of where to drag
  void show(int uid) => emit(state.copyWith(show: true, currentUid: uid));
}

extension RectExtension on Rect {
  bool withinBoundsOf(Offset offset) =>
      offset.dx + 500 > left && offset.dx < right && offset.dy > top && offset.dy < bottom;
}

class DragTargetView extends StatefulWidget {
  final Widget child;
  final int viewUid;

  const DragTargetView({this.child, this.viewUid});

  @override
  _DragTargetViewState createState() => _DragTargetViewState();
}

class _DragTargetViewState extends State<DragTargetView> {
  @override
  Widget build(BuildContext context) {
    final isMaximized = context.viewManager?.state?.maximizedViewUid != 0;
    final oneView = !(context.viewManager.countOfVisibleViews == 1 && !isMaximized);
    void clear(BuildContext context) {
      context.tbloc<DragOverlayCubit>().clear();
    }

    return BlocBuilder<DragOverlayCubit, DragOverlayDetails>(
      builder: (c, state) => Stack(alignment: Alignment.center, children: [
        widget.child,
        if (state.show) ...[
          GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => clear(context),
              child: Container(color: Theme.of(context).backgroundColor.withOpacity(0.8))),
          // &&_inRect
          if (state.currentUid != widget.viewUid)
            DragViewIcon(
              text: 'View Here',
              icon: SFSymbols.rectangle_badge_checkmark,
              onAccept: (uid) async {
                // tec.dmPrint(' ${state.uid}');

                var b = uid;
                if (b == null) {
                  final currentUid = context.tbloc<DragOverlayCubit>().state.currentUid;
                  if (currentUid != 0) {
                    b = currentUid;
                  }
                }
                if (b != widget.viewUid) {
                  // ignore: close_sinks
                  final vmBloc = context.viewManager;

                  if (vmBloc == null) {
                    return;
                  }

                  if (vmBloc.state.maximizedViewUid > 0 || vmBloc.countOfVisibleViews == 1) {
                    if (b & Const.recentFlag == Const.recentFlag) {
                      // need to create the new view...
                      final nextUid = vmBloc.state.nextUid;
                      await ViewManager.shared.onAddView(context, Const.viewTypeVolume,
                          currentViewId: widget.viewUid,
                          options: <String, dynamic>{'volumeId': b ^ Const.recentFlag});

                      vmBloc.maximize(nextUid);
                    } else {
                      vmBloc.maximize(b);
                    }
                  } else {
                    if (b & Const.recentFlag == Const.recentFlag) {
                      final toPosition = vmBloc.indexOfView(widget.viewUid);
                      vmBloc.remove(widget.viewUid);

                      final nextUid = vmBloc.state.nextUid;

                      // need to create the new view...
                      await ViewManager.shared.onAddView(context, Const.viewTypeVolume,
                          options: <String, dynamic>{'volumeId': b ^ Const.recentFlag});

                      final fromPosition = vmBloc.indexOfView(nextUid);

                      vmBloc
                        ..move(fromPosition: fromPosition, toPosition: toPosition, unhide: true);
                    } else {
                      vmBloc.swapPositions(context.viewManager.indexOfView(b),
                          context.viewManager.indexOfView(widget.viewUid));
                    }
                  }
                }
                clear(context);
              },
            ),
          if (state.currentUid == widget.viewUid)
            Row(children: [
              if (oneView) ...[
                Expanded(
                  child: DragViewIcon(
                    onAccept: (_) {
                      clear(context);
                      context.viewManager.remove(widget.viewUid);
                    },
                    text: 'Close',
                    icon: SFSymbols.xmark,
                  ),
                ),
                if (!isMaximized) ...[
                  Expanded(
                    child: DragViewIcon(
                      onAccept: (_) {
                        clear(context);
                        context.viewManager.maximize(widget.viewUid);
                      },
                      icon: SFSymbols.arrow_up_left_arrow_down_right,
                      text: 'Full Screen',
                    ),
                  ),
                ] else
                  Expanded(
                      child: DragViewIcon(
                    onAccept: (_) {
                      clear(context);
                      context.viewManager.restore();
                    },
                    icon: SFSymbols.arrow_down_right_arrow_up_left,
                    text: 'Exit Full Screen',
                  ))
              ]
            ]),
        ]
      ]),
    );
  }
}

class DragViewIcon extends StatelessWidget {
  final Function(int) onAccept;
  final IconData icon;
  final String text;

  const DragViewIcon({this.onAccept, this.icon, this.text = ''});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Const.tecartaBlue;
    return InkWell(
      onTap: () => onAccept(null),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          child: DragTarget<int>(
              onAccept: onAccept,
              // onLeave: (_) => context.tbloc<DragOverlayCubit>().clear(),
              // onMove: (d) => context.tbloc<DragOverlayCubit>().onMoveWithinIcon(context, d),
              // tec.dmPrint('Moving within object: ${d.offset}'),
              builder: (c, cd, rd) {
                final backgroundColor =
                    cd.isNotEmpty ? Const.tecartaBlue : Theme.of(context).backgroundColor;
                final iconColor = cd.isNotEmpty ? Colors.white : Const.tecartaBlue;
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        shape: CircleBorder(
                            side: BorderSide(width: 3, color: Const.tecartaBlue.withOpacity(0.5))),
                        elevation: cd.isNotEmpty ? 0 : 3,
                        child: CircleAvatar(
                          radius: cd.isNotEmpty ? 60 : 40,
                          backgroundColor: backgroundColor,
                          child: Icon(icon, color: iconColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        text,
                        textScaleFactor: 1.5,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                    ]);
              })),
    );
  }
}
