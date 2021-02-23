import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:tec_util/tec_util.dart';
import 'package:tec_views/tec_views.dart';

import '../../models/const.dart';
import '../common/common.dart';

///
/// DragOverlay
///
class DragOverlayDetails {
  final bool inRect;
  final bool sameView;

  // final bool inIcon;
  DragOverlayDetails copyWith({
    bool inRect,
    bool sameView,
    // bool inIcon,
  }) =>
      DragOverlayDetails(
        inRect: inRect ?? this.inRect,
        sameView: sameView ?? this.sameView,
        // inIcon: inIcon ?? this.inIcon,
      );

  DragOverlayDetails({
    this.inRect = false,
    this.sameView = false,
    // this.inIcon = false
  });
}

class DragOverlayCubit extends Cubit<DragOverlayDetails> {
  final int uid;

  DragOverlayCubit(this.uid) : super(DragOverlayDetails());

  void onMove(
    BuildContext context,
    DragTargetDetails details,
  ) {
    // details.data is uid of current draggable view
    // state.uid is the view you are dragging into
    final viewRect = context.viewManager.layoutOfView(uid).rect;
    // final viewRectSelf = context.viewManager.globalRectOfView(tec.as<int>(details.data));
    final inRect = viewRect.withinBoundsOf(details.offset);
    final sameView = details.data == uid;

    // tec.dmPrint('View At ${context.viewManager.indexOfView(currentUid)}: $inRect');
    // tec.dmPrint('inRect:$inRect and sameView:$sameƒView');
    // tec.dmPrint('${details.offset} ${viewRect.left}');

    emit(state.copyWith(
      inRect: inRect,
      sameView: sameView,
    ));
  }

  // void onMoveWithinIcon(BuildContext context, DragTargetDetails details) {
  //   final viewRect = context.viewManager.globalRectOfView(tec.as<int>(details.data));
  //   final inIcon = viewRect.contains(details.offset);
  //   tec.dmPrint('in icon: $inIcon');
  //   emit(state.copyWith(inIcon: inIcon));
  // }

  void clear() => emit(state.copyWith(
        inRect: false, sameView: false,
        // inIcon: false
      ));

  void leaveRect() => emit(state.copyWith(sameView: false));
}

extension RectExtension on Rect {
  bool withinBoundsOf(Offset offset) =>
      offset.dx + 500 > left && offset.dx < right && offset.dy > top && offset.dy < bottom;
}

class DragTargetView extends StatelessWidget {
  final Widget child;
  final int viewUid;

  const DragTargetView({this.child, this.viewUid});

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
        onLeave: (uid) {
          // tec.dmPrint(b);
          if (uid != viewUid) {
            context.tbloc<DragOverlayCubit>().clear();
          }
        },
        onAccept: (b) async {
          // tec.dmPrint('$b ${state.uid}');
          context.tbloc<DragOverlayCubit>().clear();
          if (b != viewUid) {
            // ignore: close_sinks
            final vmBloc = context.viewManager;

            if (vmBloc == null) {
              return;
            }

            if (vmBloc.state.maximizedViewUid > 0) {
              if (b & Const.recentFlag == Const.recentFlag) {
                // need to create the new view...
                final nextUid = vmBloc.state.nextUid;
                await ViewManager.shared.onAddView(context, Const.viewTypeVolume,
                    currentViewId: viewUid,
                    options: <String, dynamic>{'volumeId': b ^ Const.recentFlag});

                vmBloc.maximize(nextUid);
              } else {
                vmBloc.maximize(b);
              }
            } else {
              if (b & Const.recentFlag == Const.recentFlag) {
                final toPosition = vmBloc.indexOfView(viewUid);
                vmBloc.remove(viewUid);

                final nextUid = vmBloc.state.nextUid;

                // need to create the new view...
                await ViewManager.shared.onAddView(context, Const.viewTypeVolume,
                    options: <String, dynamic>{'volumeId': b ^ Const.recentFlag});

                final fromPosition = vmBloc.indexOfView(nextUid);

                vmBloc..move(fromPosition: fromPosition, toPosition: toPosition, unhide: true);
              } else {
                vmBloc.swapPositions(
                    context.viewManager.indexOfView(b), context.viewManager.indexOfView(viewUid));
              }
            }
          }
        },
        onMove: (details) => context.tbloc<DragOverlayCubit>().onMove(context, details),
        builder: (c, cd, rd) =>
            BlocBuilder<DragOverlayCubit, DragOverlayDetails>(builder: (context, state) {
              final isMaximized = context.viewManager?.state?.maximizedViewUid != 0;
              final oneView = !(context.viewManager.countOfVisibleViews == 1 && !isMaximized);
              return Stack(alignment: Alignment.center, children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    foregroundDecoration: (state.inRect && !state.sameView)
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Const.tecartaBlue.withOpacity(0.5),
                            border: Border.all(width: 5, color: Const.tecartaBlue.withOpacity(0.5)))
                        : const BoxDecoration(color: Colors.transparent),
                    child: child),
                if (state.sameView && state.inRect)
                  Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (oneView) ...[
                      Expanded(
                        child: DragViewIcon(
                          onAccept: (_) {
                            context.tbloc<DragOverlayCubit>().clear();
                            context.viewManager.remove(viewUid);
                          },
                          leftSide: true,
                          text: 'Close',
                          icon: SFSymbols.xmark,
                        ),
                      ),
                      if (!isMaximized) ...[
                        Expanded(
                          child: DragViewIcon(
                            onAccept: (_) => context.viewManager.maximize(viewUid),
                            icon: SFSymbols.arrow_up_left_arrow_down_right,
                            text: 'Full Screen',
                          ),
                        ),
                      ] else
                        Expanded(
                            child: DragViewIcon(
                          onAccept: (_) => context.viewManager.restore(),
                          icon: splitScreenIcon(context),
                          text: 'Split screen',
                        ))
                    ]
                  ]),
              ]);
            }));
  }
}

class DragViewIcon extends StatelessWidget {
  final Function(int) onAccept;
  final IconData icon;
  final String text;
  final bool leftSide;

  const DragViewIcon({this.onAccept, this.icon, this.leftSide = false, this.text = ''});

  @override
  Widget build(BuildContext context) {
    const borderRadius = 50.0;
    final br = BorderRadius.only(
      topLeft: Radius.circular(leftSide ? borderRadius : 0),
      bottomLeft: Radius.circular(leftSide ? borderRadius : 0),
      topRight: Radius.circular(leftSide ? 0 : borderRadius),
      bottomRight: Radius.circular(leftSide ? 0 : borderRadius),
    );
    return DragTarget<int>(
        onAccept: onAccept,
        onLeave: (_) => context.tbloc<DragOverlayCubit>().clear(),
        // onMove: (d) => context.tbloc<DragOverlayCubit>().onMoveWithinIcon(context, d),
        // tec.dmPrint('Moving within object: ${d.offset}'),
        builder: (c, cd, rd) {
          final backgroundColor = cd.isNotEmpty ? Theme.of(context).cardColor : Const.tecartaBlue;
          final iconColor = cd.isNotEmpty ? Const.tecartaBlue : Theme.of(context).cardColor;
          return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.center,
              decoration: cd.isNotEmpty
                  ? BoxDecoration(
                      borderRadius: br,
                      color: Const.tecartaBlue.withOpacity(0.5),
                      border: Border.all(width: 5, color: Const.tecartaBlue.withOpacity(0.5)))
                  : const BoxDecoration(color: Colors.transparent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: const CircleBorder(),
                    elevation: cd.isNotEmpty ? 0 : 10,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: backgroundColor,
                      child: Icon(icon, color: iconColor),
                    ),
                  ),
                  Chip(
                    backgroundColor: backgroundColor,
                    label: Text(
                      text,
                      style: TextStyle(color: iconColor),
                    ),
                  ),
                ],
              ));
        });
  }
}
