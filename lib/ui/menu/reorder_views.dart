import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_views/tec_views.dart';
import 'package:tec_util/tec_util.dart' as tec;

///
/// DragOverlay
///
class DragOverlayDetails {
  final bool inRect;
  final bool sameView;
  DragOverlayDetails copyWith({bool inRect, bool sameView}) => DragOverlayDetails(
        inRect: inRect ?? this.inRect,
        sameView: sameView ?? this.sameView,
      );
  DragOverlayDetails({
    this.inRect = false,
    this.sameView = false,
  });
}

class DragOverlayCubit extends Cubit<DragOverlayDetails> {
  DragOverlayCubit() : super(DragOverlayDetails());

  void onMove(
    BuildContext context,
    DragTargetDetails details,
    int currentUid,
  ) {
    // details.data is uid of current draggable view
    // state.uid is the view you are dragging into
    final viewRect = context.viewManager.globalRectOfView(currentUid);
    final viewRectSelf = context.viewManager.globalRectOfView(tec.as<int>(details.data));
    final inRect = viewRect.contains(details.offset) || viewRectSelf.contains(details.offset);
    final sameView = details.data == currentUid;
    // tec.dmPrint('View At ${context.viewManager.indexOfView(currentUid)}: $inRect');
    tec.dmPrint('inRect:$inRect and sameView:$sameView');
    emit(state.copyWith(
      inRect: inRect,
      sameView: sameView,
    ));
  }

  void clear() => emit(state.copyWith(inRect: false, sameView: false));
}
// Future<void> showReorderOverlay(
//   BuildContext context,
//   // int viewUid
// ) async {
//   await Navigator.of(context, rootNavigator: true)
//       .push<void>(TransparentRoute(builder: (c) => ReorderViewsOverlay()));
// }

// class ReorderViewsOverlay extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final vmBloc = context.viewManager;
//     final rowCount = vmBloc.rows;
//     var rows = <Widget>[];
//     for (var i = 0; i < rowCount; i++) {
//       var rowChildren = <Widget>[];
//       for (var j = 0; j < vmBloc.columnsInRow(i); j++) {
//         final uid = vmBloc.viewAt(row: i, column: j).uid;
//         final dataBloc = context.viewManager.dataBlocWithView(uid) as VolumeViewDataBloc;
//         final child =
//             // BlocProvider<VolumeViewDataBloc>.value(
//             // value: context.viewManager.dataBlocWithView(uid) as VolumeViewDataBloc,
//             // child: BlocBuilder<VolumeViewDataBloc, ViewData>(builder: (context, state) {
//             //   return
//             Container(
//           height: dataBloc.vmBloc.rectOfView(uid).rect.height,
//           width: dataBloc.vmBloc.rectOfView(uid).rect.width,
//           // decoration: ShapeDecoration(
//           //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           color: Colors.primaries[i].withOpacity(0.3),
//           // ),
//           // alignment: Alignment.center,
//           // child: TecText(dataBloc.state.asVolumeViewData.bookNameChapterAndAbbr,
//           //     autoSize: true, style: Theme.of(context).textTheme.headline1),
//         );
//         rowChildren.add(Draggable(
//             childWhenDragging: Container(
//               height: dataBloc.vmBloc.rectOfView(uid).rect.height,
//               width: dataBloc.vmBloc.rectOfView(uid).rect.width,
//               decoration: ShapeDecoration(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                 color: Colors.black38,
//               ),
//             ),
//             feedback: child,
//             child: child));
//         // if (j != vmBloc.columnsInRow(i) - 1) {
//         //   rowChildren.add(VerticalDivider(
//         //     color: Colors.white,
//         //     thickness: 5,
//         //   ));
//         // }
//       }
//       rows.add(Expanded(
//           child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: rowChildren,
//       )));
//       // if (i != rowCount - 1) {
//       //   rows.add(const Divider(
//       //     indent: 20,
//       //     endIndent: 20,
//       //     color: Colors.white,
//       //     thickness: 5,
//       //   ));
//       // }
//     }
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: () => Navigator.of(context).pop(),
//       child: Scaffold(
//         backgroundColor: Colors.black38,
//         // appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//         body: SafeArea(
//           bottom: false,
//           child: Container(
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: rows,
//               )),
//         ),
//       ),
//     );
//   }
// }
