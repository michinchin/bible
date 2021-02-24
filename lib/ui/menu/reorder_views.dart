import 'package:bible/blocs/sheet/sheet_manager_bloc.dart';
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

    return BlocBuilder<DragOverlayCubit, DragOverlayDetails>(
        builder: (c, state) => DragTarget<int>(
              onAccept: (_) {
                // why is this code never called
                context.tbloc<DragOverlayCubit>().clear();
                context.tbloc<SheetManagerBloc>().add(SheetEvent.main);
              },
              builder: (context, cd, rd) => Stack(alignment: Alignment.center, children: [
                widget.child,
                if (state.show) ...[
                  // &&_inRect
                  if (state.currentUid != widget.viewUid)
                    DragViewIcon(
                      onAccept: (b) async {
                        // tec.dmPrint(' ${state.uid}');
                        context.tbloc<DragOverlayCubit>().clear();
                        if (b != widget.viewUid) {
                          // ignore: close_sinks
                          final vmBloc = context.viewManager;

                          if (vmBloc == null) {
                            return;
                          }

                          if (vmBloc.state.maximizedViewUid > 0 ||
                              vmBloc.countOfVisibleViews == 1) {
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
                                ..move(
                                    fromPosition: fromPosition,
                                    toPosition: toPosition,
                                    unhide: true);
                            } else {
                              vmBloc.swapPositions(context.viewManager.indexOfView(b),
                                  context.viewManager.indexOfView(widget.viewUid));
                            }
                          }
                        }
                      },
                      leftSide: true,
                      text: 'Place Here',
                      icon: SFSymbols.rectangle_badge_checkmark,
                    ),
                  if (state.currentUid == widget.viewUid)
                    Row(children: [
                      if (oneView) ...[
                        Expanded(
                          child: DragViewIcon(
                            onAccept: (_) {
                              context.tbloc<DragOverlayCubit>().clear();
                              context.viewManager.remove(widget.viewUid);
                            },
                            leftSide: true,
                            text: 'Close',
                            icon: SFSymbols.xmark,
                          ),
                        ),
                        if (!isMaximized) ...[
                          Expanded(
                            child: DragViewIcon(
                              onAccept: (_) {
                                context.tbloc<DragOverlayCubit>().clear();
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
                              context.tbloc<DragOverlayCubit>().clear();
                              context.viewManager.restore();
                            },
                            icon: splitScreenIcon(context),
                            text: 'Split screen',
                          ))
                      ]
                    ]),
                ]
              ]),
            ));
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
    return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        // decoration: cd.isNotEmpty
        //     ? BoxDecoration(
        //         borderRadius: br,
        //         color: Const.tecartaBlue.withOpacity(0.5),
        //         border: Border.all(width: 5, color: Const.tecartaBlue.withOpacity(0.5)))
        //     : const BoxDecoration(color: Colors.transparent),
        child: DragTarget<int>(
            onAccept: onAccept,
            // onLeave: (_) => context.tbloc<DragOverlayCubit>().clear(),
            // onMove: (d) => context.tbloc<DragOverlayCubit>().onMoveWithinIcon(context, d),
            // tec.dmPrint('Moving within object: ${d.offset}'),
            builder: (c, cd, rd) {
              final backgroundColor =
                  cd.isNotEmpty ? Theme.of(context).cardColor : Const.tecartaBlue;
              final iconColor = cd.isNotEmpty ? Const.tecartaBlue : Theme.of(context).cardColor;
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                    )
                  ]);
            }));
  }
}
