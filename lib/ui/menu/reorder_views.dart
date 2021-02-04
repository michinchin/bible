import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../models/const.dart';

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
        onAccept: (b) {
          // tec.dmPrint('$b ${state.uid}');
          context.tbloc<DragOverlayCubit>().clear();
          if (b != viewUid) {
            // ignore: close_sinks
            final vmBloc = context.viewManager;

            if (vmBloc == null) {
              return;
            }

            if (vmBloc.state.maximizedViewUid > 0) {
              vmBloc.maximize(b);
            } else {
              vmBloc.move(
                  fromPosition: context.viewManager.indexOfView(b),
                  toPosition: context.viewManager.indexOfView(viewUid),
                  unhide: true);
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
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    if (oneView) ...[
                      DragViewIcon(
                        onAccept: (_) {
                          context.tbloc<DragOverlayCubit>().clear();
                          context.viewManager.remove(viewUid);
                        },
                        icon: Icons.close,
                      ),
                      DragViewIcon(
                          onAccept: (_) => context.viewManager.hide(viewUid),
                          icon: Icons.visibility_off_outlined),
                      if (!isMaximized) ...[
                        DragViewIcon(
                          onAccept: (_) => context.viewManager.maximize(viewUid),
                          icon: Icons.fullscreen,
                        ),
                      ] else
                        DragViewIcon(
                          onAccept: (_) => context.viewManager.restore(),
                          icon: Icons.grid_view,
                        )
                    ]
                  ]),
              ]);
            }));
  }
}

class DragViewIcon extends StatelessWidget {
  final Function(int) onAccept;
  final IconData icon;
  const DragViewIcon({this.onAccept, this.icon});

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
        onAccept: onAccept,
        // onMove: (d) => context.tbloc<DragOverlayCubit>().onMoveWithinIcon(context, d),
        // tec.dmPrint('Moving within object: ${d.offset}'),
        builder: (c, cd, rd) => Card(
              shape: const CircleBorder(),
              elevation: cd.isNotEmpty ? 0 : 10,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: cd.isNotEmpty ? Const.tecartaBlue : Theme.of(context).cardColor,
                child: Icon(
                  icon,
                  color: cd.isNotEmpty ? Colors.white : Const.tecartaBlue,
                ),
              ),
            ));
  }
}
