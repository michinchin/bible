part of 'view_manager_bloc.dart';

///
/// Manages view types.
///
/// Use the [register] function to register a [Viewable] class.
///
class ViewManager {
  static final ViewManager shared = ViewManager();

  final _types = <String, Viewable>{};

  ///
  /// Registers a new view type.
  ///
  void register(Viewable viewable) {
    assert(tec.isNotNullOrEmpty(viewable?.typeName));
    assert(!_types.containsKey(viewable?.typeName));
    _types[viewable?.typeName] = viewable;
  }

  List<String> get types => _types.keys.toList();

  IconData iconWithType(String type) => _types[type]?.icon;

  Future<void> onAddView(BuildContext context, String type, {int currentViewId}) async {
    // await Navigator.of(context).maybePop();
    final vmBloc = context.viewManager; // ignore: close_sinks
    assert(vmBloc != null);
    var position = vmBloc?.indexOfView(currentViewId);
    if (position != null && (!vmBloc.isFull || position < vmBloc.countOfVisibleViews - 1)) {
      position += 1;
    }
    final viewData =
        await _types[type]?.dataForNewView(context: context, currentViewId: currentViewId);
    if (viewData != null) {
      vmBloc?.add(ViewManagerEvent.add(type: type, position: position, data: viewData.toString()));
    }
  }

  void makeVisibleOrAdd(BuildContext context, final String windowType) {
    ViewState lastVisibleView;

    for (final view in context.viewManager.state.views) {
      if (context.viewManager.isViewVisible(view.uid)) {
        lastVisibleView = view;
      }

      if (view.type == windowType) {
        if (!context.viewManager.isViewVisible(view.uid)) {
          if (context.viewManager.state.maximizedViewUid > 0) {
            // maximize the existing window...
            context.viewManager.add(ViewManagerEvent.maximize(view.uid));
          } else {
            // move the window from hidden to last visible one...
            context.viewManager.add(ViewManagerEvent.move(
                fromPosition: context.viewManager.indexOfView(view.uid),
                toPosition: context.viewManager.indexOfView(lastVisibleView.uid)));
          }
        } else {
          TecToast.show(context, 'Window is already visible');
        }

        // this window was already created... now it's visible... return
        return;
      }
    }

    // window not found, add one
    context.viewManager?.add(ViewManagerEvent.add(type: windowType, data: null, position: null));
  }

  String menuTitleWith({String type, BuildContext context, ViewState state}) {
    assert(tec.isNotNullOrEmpty(type) || (tec.isNotNullOrEmpty(state?.type) && context != null));
    final viewType = type ?? state?.type;
    return _types[viewType]?.menuTitle?.call(context: context, state: state);
  }

  Widget _buildScaffold(BuildContext context, ViewState state, Size size) =>
      (_types[state.type]?.builder ?? _defaultScaffoldBuilder)(context, state, size);

  Widget _buildViewBody(BuildContext context, ViewState state, Size size) =>
      _defaultBodyBuilder(context, state, size);

  List<Widget> _buildViewActions(BuildContext context, ViewState state, Size size) =>
      _defaultActionsBuilder(context, state, size);
}

///
/// Viewable
///
abstract class Viewable {
  final String typeName;
  final IconData icon;

  Viewable(this.typeName, this.icon);

  ///
  /// Builds and returns the [Scaffold] for the view.
  ///
  Widget builder(BuildContext context, ViewState state, Size size);

  ///
  /// Returns the menu title for the view. If [context] and [state] are null, returns
  /// the title that should be used for creating new views of this type.
  ///
  String menuTitle({BuildContext context, ViewState state});

  ///
  /// Returns the view data for new views of this type. Can return `null` to just
  /// use defaults. If [context] and [currentViewId] are not null, [currentViewId]
  /// is the id of the view the 'Add <this-type>' menu was selected in.
  ///
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId});
}

//
// PRIVATE STUFF
//

Widget _defaultScaffoldBuilder(BuildContext context, ViewState state, Size size) => Scaffold(
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: Text(ViewManager.shared.menuTitleWith(context: context, state: state)),
          // leading: widget.state.viewIndex > 0
          //     ? null
          //     : IconButton(
          //         icon: const Icon(Icons.menu),
          //         tooltip: 'Main Menu',
          //         onPressed: () => showMainMenu(context),
          //       ),
          actions: ViewManager.shared._buildViewActions(context, state, size),
        ),
      ),
      body: ViewManager.shared._buildViewBody(context, state, size),
    );

Widget _defaultBodyBuilder(BuildContext context, ViewState state, Size size) => Container();

List<Widget> _defaultActionsBuilder(BuildContext context, ViewState state, Size size) {
  return [
    IconButton(
      icon: Icon(_moreIcon(context)),
      tooltip: 'More',
      onPressed: () => _showMoreMenu(context, state, size),
    ),
  ];
}

Future<void> _showMoreMenu(BuildContext context, ViewState state, Size size) {
  return showTecModalPopup<void>(
    useRootNavigator: false,
    context: context,
    alignment: Alignment.topRight,
    builder: (context) {
      return TecPopupSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _menuItem(context, Icons.close, 'Close View', () {
              Navigator.of(context).maybePop();
              context.viewManager?.add(ViewManagerEvent.remove(state.uid));
            }),
            ..._generateAddMenuItems(context, state.uid),
          ],
        ),
      );
    },
  );
}

Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
  final vm = ViewManager.shared;
  return vm.types.map<Widget>(
    (type) =>
        _menuItem(context, Icons.add, 'Add ${vm.menuTitleWith(context: context, type: type)}', () {
      Navigator.of(context).maybePop();
      final vmBloc = context.viewManager; // ignore: close_sinks
      final position = vmBloc?.indexOfView(viewUid) ?? -1;
      vmBloc?.add(ViewManagerEvent.add(type: type, position: position == -1 ? null : position + 1));
    }),
  );
}

Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
  final textColor = Theme.of(context).textColor;
  const iconSize = 24.0;
  return CupertinoButton(
    padding: EdgeInsets.zero,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon == null)
          const SizedBox(width: iconSize)
        else
          Icon(icon, color: Theme.of(context).textColor, size: iconSize),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: textColor)),
      ],
    ),
    borderRadius: null,
    onPressed: onPressed,
  );
}

IconData _moreIcon(BuildContext context) {
  switch (Theme.of(context).platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return Icons.more_horiz;
    default:
      return Icons.more_vert;
  }
}

// List<Widget> _testActionsForAdjustingSize(
//     BuildContext context, ViewState state, Size size) {
//   final vmBloc = context.viewManager; // ignore: close_sinks
//   return <Widget>[
//     IconButton(
//       icon: const Icon(Icons.border_outer),
//       onPressed: () {
//         vmBloc?
//           ..add(ViewManagerEvent.setWidth(position: widget.state.viewIndex, width: null))
//           ..add(ViewManagerEvent.setHeight(position: widget.state.viewIndex, height: null));
//       },
//     ),
//     IconButton(
//       icon: const Icon(Icons.format_textdirection_l_to_r),
//       onPressed: () {
//         final idealWidth = widget.state.viewState.idealWidth(widget.state.parentConstraints) ??
//             ViewManager.shared
//                 ._minWidthForType(widget.state.viewState.type, widget.state.parentConstraints);
//         final event =
//             ViewManagerEvent.setWidth(position: widget.state.viewIndex, width: idealWidth + 20.0);
//         vmBloc?.add(event);
//       },
//     ),
//     IconButton(
//       icon: const Icon(Icons.format_line_spacing),
//       onPressed: () {
//         final idealHeight = widget.state.viewState.idealHeight(widget.state.parentConstraints) ??
//             ViewManager.shared
//                 ._minHeightForType(widget.state.viewState.type, widget.state.parentConstraints);
//         final event = ViewManagerEvent.setHeight(
//             position: widget.state.viewIndex, height: idealHeight + 20.0);
//         vmBloc?.add(event);
//       },
//     ),
//   ];
// }
