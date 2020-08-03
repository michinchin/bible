import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/is_licensed_bloc.dart';
import '../common/common.dart';
import 'volumes_bloc.dart';

void showLibrary(BuildContext context) {
  Navigator.of(context, rootNavigator: true)
      .push<void>(MaterialPageRoute(builder: (_) => _LibraryNavigator()));
}

class _LibraryNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => _LibraryScreen(
              closeLibrary: () => Navigator.of(context, rootNavigator: true).maybePop()),
          settings: settings),
    );
  }
}

class _LibraryScreen extends StatelessWidget {
  final VoidCallback closeLibrary;

  const _LibraryScreen({Key key, this.closeLibrary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: appBarThemeWithContext(context),
        tabBarTheme: tabBarThemeWithContext(context),
      ),
      child: BlocProvider<IsLicensedBloc>(
        create: (_) => IsLicensedBloc(
            volumeIds: VolumesRepository.shared.volumeIdsWithType(VolumeType.anyType)),
        child: BlocBuilder<IsLicensedBloc, bool>(
          builder: (context, hasLicensedVolumes) {
            final tabs = [
              const Tab(text: 'Bibles'),
              if (hasLicensedVolumes) const Tab(text: 'Purchased'),
              const Tab(text: 'Store'),
            ];
            final tabContents = <Widget>[
              const _VolumesView(type: _ViewType.bibles),
              if (hasLicensedVolumes) const _VolumesView(type: _ViewType.purchased),
              const _VolumesView(type: _ViewType.store)
            ];
            return DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                appBar: MinHeightAppBar(
                  appBar: AppBar(
                    leading: BackButton(onPressed: closeLibrary),
                    title: const Text('Library'),
                    bottom: TabBar(tabs: tabs),
                  ),
                ),
                body: TabBarView(children: tabContents),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ViewType { bibles, purchased, store }

class _VolumesView extends StatefulWidget {
  final _ViewType type;

  const _VolumesView({Key key, this.type}) : super(key: key);

  @override
  _VolumesViewState createState() => _VolumesViewState();
}

class _VolumesViewState extends State<_VolumesView> {
  TextEditingController _searchController;
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_searchListener);
  }

  @override
  void dispose() {
    _searchController?.removeListener(_searchListener);
    _searchController?.dispose();
    _debounce?.cancel();
    _debounce = null;
    super.dispose();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text.trim().isNotEmpty) {
        // TODO
      }
    });
  }

  VolumesFilter _filterForType(_ViewType type) {
    switch (type) {
      case _ViewType.bibles:
        return const VolumesFilter(volumeType: VolumeType.bible);
      case _ViewType.purchased:
        return const VolumesFilter(ownershipStatus: OwnershipStatus.owned);
      default:
        return const VolumesFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VolumesBloc>(
      create: (_) => VolumesBloc(
        key: '_library${widget.type}',
        kvStore: tec.Prefs.shared,
        defaultFilter: _filterForType(widget.type),
      )..refresh(),
      child: BlocBuilder<VolumesBloc, VolumesState>(
        builder: (context, state) {
          return Column(
            children: [
              SearchBox(
                searchFieldController: _searchController,
                onSubmit: (s) => _searchListener(),
                suffixIcon: IconButton(
                    tooltip: 'more filter option',
                    icon: const Icon(Icons.filter_list),
                    onPressed: () async => _showFilterSheet(context)),
              ),
              Expanded(
                child: Scrollbar(
                  child: TecListView<Volume>(
                    items: state.volumes,
                    itemBuilder: (context, volume, index, total) =>
                        VolumeCard(volume: volume, padding: 0),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _showFilterSheet(BuildContext context) async {
  final bloc = context.bloc<VolumesBloc>(); // ignore: close_sinks
  await showModalBottomSheet<void>(
    context: context,
    shape: bottomSheetShapeBorder,
    builder: (_) => LibraryFilterSheet(volumesBloc: bloc),
  );
  //await _itemScrollController.scrollTo(index: 0, duration: const Duration(milliseconds: 250));
  //setState(() {});
}

class LibraryFilterSheet extends StatelessWidget {
  final VolumesBloc volumesBloc;

  const LibraryFilterSheet({Key key, this.volumesBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languages = volumesBloc.languages;
    final categories = volumesBloc.categories;
    final textStyle = Theme.of(context).textTheme.headline6;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //ListTile(title: Text('Hello World!')),
          _PopupMenuButton<String>(
            title: TecText('Language', style: textStyle),
            values: languages,
          ),
          const SizedBox(
            height: 16,
          ),
          _PopupMenuButton<int>(
            title: TecText('Category', style: textStyle),
            values: categories,
          ),
        ],
      ),
    );
  }
}

const bottomSheetRadius = Radius.circular(15);
const bottomSheetShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: bottomSheetRadius, topRight: bottomSheetRadius));

class SearchBox extends StatefulWidget {
  final void Function(String) onSubmit;
  final TextEditingController searchFieldController;
  final Widget suffixIcon;

  const SearchBox({
    Key key,
    this.onSubmit,
    this.searchFieldController,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  List<BoxShadow> shadow = const [
    BoxShadow(color: Color(0xffcccccc), offset: Offset(0, 2), blurRadius: 2, spreadRadius: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: AppBar().preferredSize,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
              boxShadow: shadow),
          child: Center(
            child: Stack(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    suffixIcon: widget.searchFieldController.text.isNotEmpty
                        ? IconButton(
                            splashColor: Colors.transparent,
                            icon: const Icon(CupertinoIcons.clear_circled),
                            onPressed: () => setState(() => widget.searchFieldController.clear()),
                          )
                        : null,
                  ),
                ),
                if (widget.searchFieldController.text.isEmpty && widget.suffixIcon != null)
                  Positioned(
                    right: 0,
                    child: widget.suffixIcon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VolumeCard extends StatelessWidget {
  final Volume volume;
  final VoidCallback onTapped;
  final Color color;
  final double elevation;
  final double padding;
  final bool heroAnimated;

  const VolumeCard({
    Key key,
    @required this.volume,
    this.onTapped,
    this.color,
    this.elevation = 0,
    this.padding,
    this.heroAnimated = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => TecCard(
        builder: builder,
        color: color,
        elevation: elevation,
        padding: padding,
        onTap: onTapped ??
            () async {
              //if (volume.type == VolumeType.bible && (volume.isStreamable))

              // navigatorPush(
              //   context,
              //   (_) => VolumeScreen(
              //     volume: volume,
              //     // showReadNow: showReadNow,
              //   ),
              // );
            },
      );

  Widget builder(BuildContext context) {
    final scale = textScaleFactorWith(context, forAbsoluteFontSize: true);
    final padding = (6.0 * scale).roundToDouble();

    final imgWidth = 60.0 * scale;
    final imgHeight = 1.47368 * imgWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: padding * 2, top: padding, bottom: padding),
            child: Semantics(
              container: true,
              label: 'Select to view volume:',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    elevation: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(padding)),
                      child: VolumeImage(
                        key: key,
                        volume: volume,
                        width: imgWidth,
                        height: imgHeight,
                        fit: BoxFit.cover,
                        heroAnimated: heroAnimated,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: padding * 2, top: padding, right: padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TecText.rich(
                            TextSpan(
                              style: cardTitleCompactStyle.copyWith(
                                  color: Theme.of(context).textTheme.bodyText2.color),
                              text: '${volume.name}\n',
                            ),
                          ),
                          TecText(
                            volume.publisher,
                            style: cardSubtitleCompactStyle.copyWith(
                                color: Theme.of(context).textColor),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VolumeImage extends StatelessWidget {
  const VolumeImage({
    Key key,
    @required this.volume,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.heroAnimated = true,
  }) : super(key: key);

  final Volume volume;
  final double width;
  final double height;
  final BoxFit fit;
  final bool heroAnimated;

  @override
  Widget build(BuildContext context) {
    final path = 'https://cf-stream.tecartabible.com/7/covers/${volume.id}.jpg';

    final heroTag = '${volume.hashCode}-${volume.id}';
    Widget img() => CachedNetworkImage(
          width: width,
          height: height,
          fit: fit,
          imageUrl: path,
          errorWidget: (context, url, dynamic error) => Container(width: width, height: height),
        );

    return !heroAnimated ? img() : Hero(tag: heroTag, child: img());
  }
}

class TecTextStyle extends TextStyle {
  const TecTextStyle({
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    double height,
  }) : super(
          inherit: false,
          color: color,
          // fontFamily: 'Avenir',
          fontSize: fontSize,
          fontWeight: fontWeight,
          textBaseline: TextBaseline.alphabetic,
          height: height,
        );
}

const TextStyle cardTitleCompactStyle = TecTextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600, // w700 == Bold
);

final TecTextStyle cardSubtitleCompactStyle = TecTextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400, // w500 == Normal
  color: Colors.grey[500],
);

class UnderlinePSW extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final double lineHeight;
  final Color color;

  const UnderlinePSW({
    Key key,
    @required this.child,
    this.color,
    this.lineHeight = 1.5,
  })  : assert(child != null),
        assert(lineHeight != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final line = Container(
      //width: double.infinity,
      height: lineHeight ?? 1.0,
      color: color ?? Theme.of(context).primaryColor,
    );

    // return Stack(children: [child, Positioned(left: 0, right: 0, bottom: 0, child: line)]);
    return Column(children: [child, line]);
  }

  @override
  Size get preferredSize => Size.fromHeight(child.preferredSize.height + lineHeight);
}

const _defaultMenuItemHeight = 36.0;
const _maxTextScaleFactor = 1.0;

class _PopupMenuButton<T> extends StatelessWidget {
  final Widget title;
  final LinkedHashMap<T, String> values;
  final T currentValue;
  final T defaultValue;
  final String defaultName;
  final void Function(T value) onSelectValue;

  const _PopupMenuButton({
    Key key,
    @required this.title,
    @required this.values,
    this.currentValue,
    this.defaultValue,
    this.defaultName,
    this.onSelectValue,
  })  : assert(title != null),
        assert(values != null),
        assert(defaultValue == null || defaultName != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = values.keys.toList();
    if (defaultValue != null && !keys.contains(defaultValue)) {
      keys.insert(0, defaultValue);
    }
    final items = values.keys
        .map<PopupMenuEntry<String>>(
          (key) => PopupMenuItem<String>(
            height: _defaultMenuItemHeight,
            value: values[key],
            child: TecText(
              values[key],
              maxScaleFactor: _maxTextScaleFactor,
              style: TextStyle(
                fontWeight: key == currentValue ? FontWeight.bold : FontWeight.normal,
                color: key == currentValue
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87),
              ),
            ),
          ),
        )
        .toList();

    return PopupMenuButton<String>(
      child: title,
      offset: const Offset(150, 0),
      onSelected: (value) {
        onSelectValue?.call(values.keys.firstWhere((k) => values[k] == value, orElse: () => null));
      },
      itemBuilder: (context) => items,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}
