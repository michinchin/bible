part of 'view_manager_bloc.dart';

///
/// Signature of a function that creates a key for a given view state.
///
typedef KeyMaker = Key Function(BuildContext context, ViewState state);

///
/// Signature of a function that creates a widget for a given view state.
///
typedef BuilderWithViewState = Widget Function(
    BuildContext context, Key bodyKey, ViewState state, Size size);

///
/// Signature of a function that creates a list of "action" widgets for a given view state.
///
typedef ActionsBuilderWithViewState = List<Widget> Function(
    BuildContext context, Key bodyKey, ViewState state, Size size);

///
/// Signature of a function that creates a widget for a given view state and index.
///
typedef IndexedBuilderWithViewState = Widget Function(
    BuildContext context, ViewState state, Size size, int index);

///
/// Signature of a function that returns a view size value based on constraints.
///
typedef ViewSizeFunc = double Function(BoxConstraints constraints);

///
/// Manages view types.
///
/// Use the [register] function to register a view type. For example:
///
/// ```dart
/// register('MyType', builder: (context, bodyKey, state, size) => Container());
/// ```
///
class ViewManager {
  static final ViewManager shared = ViewManager();

  final _types = <String, _ViewTypeAPI>{};

  ///
  /// Registers a new view type.
  ///
  void register(
    String key, {
    @required String title,
    @required BuilderWithViewState builder,
    BuilderWithViewState titleBuilder,
    ActionsBuilderWithViewState actionsBuilder,
    KeyMaker keyMaker,
    ViewSizeFunc minWidth,
    ViewSizeFunc minHeight,
  }) {
    assert(tec.isNotNullOrEmpty(key) && builder != null);
    assert(!_types.containsKey(key));
    _types[key] = _ViewTypeAPI(
      title,
      builder,
      titleBuilder,
      actionsBuilder,
      keyMaker,
      minWidth,
      minHeight,
    );
  }

  List<String> get types => _types.keys.toList();

  String titleForType(String type) => _types[type]?.title;

  Key _makeKey(BuildContext context, ViewState state) =>
      (_types[state.type]?.keyMaker ?? _defaultKeyMaker)(context, state);

  Widget _buildViewBody(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.builder ?? _defaultBuilder)(context, bodyKey, state, size);

  Widget _buildViewTitle(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.titleBuilder ?? _defaultTitleBuilder)(context, bodyKey, state, size);

  Widget _defaultTitleBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      Text(_types[state.type]?.title ?? state.uid.toString());

  List<Widget> _buildViewActions(BuildContext context, Key bodyKey, ViewState state, Size size) =>
      (_types[state.type]?.actionsBuilder ?? _defaultActionsBuilder)(context, bodyKey, state, size);

  double _minWidthForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minWidth ?? _defaultMinWidth)(constraints);

  double _minHeightForType(String type, BoxConstraints constraints) =>
      (_types[type]?.minHeight ?? _defaultMinHeight)(constraints);
}

//
// PRIVATE STUFF
//

class _ViewTypeAPI {
  final String title;
  final BuilderWithViewState builder;
  final BuilderWithViewState titleBuilder;
  final ActionsBuilderWithViewState actionsBuilder;
  final KeyMaker keyMaker;
  final ViewSizeFunc minWidth;
  final ViewSizeFunc minHeight;

  const _ViewTypeAPI(
    this.title,
    this.builder,
    this.titleBuilder,
    this.actionsBuilder,
    this.keyMaker,
    this.minWidth,
    this.minHeight,
  );
}

const _iPhoneSEHeight = 568.0;
const _minSize = (_iPhoneSEHeight - 20.0) / 2;
const _maxMinWidth = 400.0;

Key _defaultKeyMaker(BuildContext context, ViewState state) => null;

Widget _defaultBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    Container(key: bodyKey);

double _defaultMinWidth(BoxConstraints constraints) => math.max(_minSize,
    math.min(_maxMinWidth, ((constraints ?? _defaultConstraints).maxWidth / 3).roundToDouble()));

double _defaultMinHeight(BoxConstraints constraints) =>
    math.max(_minSize, ((constraints ?? _defaultConstraints).maxHeight / 3).roundToDouble());

const BoxConstraints _defaultConstraints = BoxConstraints(maxWidth: 320, maxHeight: 480);

List<Widget> _defaultActionsBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) {
  return [
    IconButton(
      icon: Icon(_moreIcon(context)),
      tooltip: 'More',
      onPressed: () => showMoreMenu(context, bodyKey, state, size),
    ),
  ];
}

Future<void> showMoreMenu(BuildContext context, Key bodyKey, ViewState state, Size size) {
  return showModalBottomSheet<void>(
    useRootNavigator: false,
    context: context,
    builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // _menuItem(context, Icons.close, 'Close View', () {
          //   Navigator.of(context).maybePop();
          //   context
          //       .bloc<ViewManagerBloc>()
          //       ?.add(ViewManagerEvent.remove(state.uid));
          // }),
          ..._generateAddMenuItems(context, state.uid),
        ],
      );
    },
  );
}

Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
  final vm = ViewManager.shared;
  return vm.types.map<Widget>(
    (type) => _menuItem(context, Icons.add, 'Add ${vm.titleForType(type)}', () {
      Navigator.of(context).maybePop();
      final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
      final position = bloc?.indexOfView(viewUid) ?? -1;
      bloc?.add(ViewManagerEvent.add(
          type: type, data: '', position: position == -1 ? null : position + 1));
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
        Text(
          title,
          style: TextStyle(color: textColor),
        ),
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
//     BuildContext context, Key bodyKey, ViewState state, Size size) {
//   final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
//   return <Widget>[
//     IconButton(
//       icon: const Icon(Icons.border_outer),
//       onPressed: () {
//         bloc?
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
//         bloc?.add(event);
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
//         bloc?.add(event);
//       },
//     ),
//   ];
// }
