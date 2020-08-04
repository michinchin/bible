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

class _VolumesView extends StatelessWidget {
  final _ViewType type;

  const _VolumesView({Key key, this.type}) : super(key: key);

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
        key: '_library$type',
        kvStore: tec.Prefs.shared,
        defaultFilter: _filterForType(type),
      )..refresh(),
      child: BlocBuilder<VolumesBloc, VolumesState>(
        builder: (context, state) => _VolumesList(type: type),
      ),
    );
  }
}

class _VolumesList extends StatefulWidget {
  final _ViewType type;

  const _VolumesList({Key key, this.type}) : super(key: key);

  @override
  _VolumesListState createState() => _VolumesListState();
}

class _VolumesListState extends State<_VolumesList> {
  TextEditingController _textEditingController;
  Timer _debounce;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController()..addListener(_searchListener);
  }

  @override
  void dispose() {
    _textEditingController?.removeListener(_searchListener);
    _textEditingController?.dispose();
    _debounce?.cancel();
    _debounce = null;
    super.dispose();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        tec.dmPrint('search string: ${_textEditingController.text.trim()}');
        context.bloc<VolumesBloc>()?.add(
              context.bloc<VolumesBloc>().state.filter.copyWith(
                    searchFilter: _textEditingController.text.trim(),
                  ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<VolumesBloc>(); // ignore: close_sinks
    final showFilter = (bloc.languages?.length ?? 0) > 1 || (bloc.categories?.length ?? 0) > 1;
    return Column(
      children: [
        SearchBox(
          textEditingController: _textEditingController,
          onSubmit: (s) => _searchListener(),
          suffixIcon: showFilter
              ? IconButton(
                  tooltip: 'filters',
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterSheet(context))
              : null,
        ),
        Expanded(
          child: Scrollbar(
            child: TecListView<Volume>(
              items: bloc.state.volumes,
              itemBuilder: (context, volume, index, total) =>
                  VolumeCard(volume: volume, padding: 0),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showFilterSheet(BuildContext context) async {
  final bloc = context.bloc<VolumesBloc>(); // ignore: close_sinks
  await showModalBottomSheet<void>(
    context: context,
    shape: bottomSheetShapeBorder,
    builder: (_) => BlocBuilder<VolumesBloc, VolumesState>(
      bloc: bloc,
      builder: (context, state) => LibraryFilterSheet(volumesBloc: bloc),
    ),
  );
}

class LibraryFilterSheet extends StatelessWidget {
  final VolumesBloc volumesBloc;

  const LibraryFilterSheet({Key key, this.volumesBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = textScaleFactorWith(context);
    final padding = 8 * textScaleFactor;
    final languages = volumesBloc.languages;
    final categories = volumesBloc.categories;
    final language = volumesBloc.state.filter.language;
    final category = volumesBloc.state.filter.category;

    const animationDuration = Duration(milliseconds: 300);
    final buttonHeight = 16 + (20 * textScaleFactor).roundToDouble();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: TecText(
                'Filter By',
                textScaleFactor: textScaleFactor,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            AnimatedContainer(
              duration: animationDuration,
              height: languages.length > 1 ? buttonHeight : 0,
              child: TecPopupMenuButton<String>(
                title: 'Language',
                values: languages,
                currentValue: language,
                defaultValue: '',
                defaultName: 'Any',
                onSelectValue: (value) {
                  volumesBloc.add(volumesBloc.state.filter.copyWith(language: value));
                },
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: categories.length > 1 ? buttonHeight : 0,
              child: TecPopupMenuButton<int>(
                title: 'Category',
                values: categories,
                currentValue: category,
                defaultValue: 0,
                defaultName: 'Any',
                onSelectValue: (value) {
                  volumesBloc.add(volumesBloc.state.filter.copyWith(category: value));
                },
              ),
            ),
            AnimatedContainer(
              duration: animationDuration,
              height: volumesBloc.state.filter != volumesBloc.defaultFilter ? buttonHeight : 0,
              child: TecTextButton(
                title: 'Clear Filters',
                onTap: () => volumesBloc.add(volumesBloc.defaultFilter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const bottomSheetRadius = Radius.circular(15);
const bottomSheetShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: bottomSheetRadius, topRight: bottomSheetRadius));

class SearchBox extends StatefulWidget {
  final void Function(String) onSubmit;
  final TextEditingController textEditingController;
  final Widget suffixIcon;

  const SearchBox({
    Key key,
    this.onSubmit,
    this.textEditingController,
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
                  autocorrect: false,
                  controller: widget.textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    suffixIcon: widget.textEditingController.text.isNotEmpty
                        ? IconButton(
                            splashColor: Colors.transparent,
                            icon: const Icon(CupertinoIcons.clear_circled),
                            onPressed: () => widget.textEditingController.clear(),
                          )
                        : null,
                  ),
                ),
                if (widget.textEditingController.text.isEmpty && widget.suffixIcon != null)
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
    final textScaleFactor = textScaleFactorWith(context);
    final padding = (6.0 * textScaleFactor).roundToDouble();

    final imgWidth = 60.0 * textScaleFactor;
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
                          TecText(
                            '${volume.name}\n',
                            textScaleFactor: textScaleFactor,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          TecText(
                            volume.publisher,
                            textScaleFactor: textScaleFactor,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).textColor,
                            ),
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

class TecPopupMenuButton<T> extends StatelessWidget {
  final String title;
  final LinkedHashMap<T, String> values;
  final T currentValue;
  final T defaultValue;
  final String defaultName;
  final void Function(T value) onSelectValue;

  const TecPopupMenuButton({
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
    final textScaleFactor = textScaleFactorWith(context);
    final entryHeight = (32.0 * textScaleFactor).roundToDouble();

    final keys = values.keys.toList();
    if (defaultValue != null && !keys.contains(defaultValue)) {
      keys.insert(0, defaultValue);
    }
    final items = keys
        .map<PopupMenuEntry<String>>(
          (key) => PopupMenuItem<String>(
            height: entryHeight,
            value: values[key] ?? defaultName,
            child: TecText(
              values[key] ?? defaultName,
              textScaleFactor: textScaleFactor,
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

    final currentName = currentValue == null ? null : values[currentValue] ?? defaultName;
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: TecText.rich(
          TextSpan(
            children: [
              TextSpan(text: title.endsWith(': ') ? title : '$title: '),
              if (tec.isNotNullOrEmpty(currentName))
                TextSpan(
                  text: currentName,
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
            ],
          ),
          textScaleFactor: textScaleFactor,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      offset: const Offset(150, 0),
      onSelected: (string) {
        final value = values.keys.firstWhere(
          (k) => values[k] == string,
          orElse: () => defaultValue,
        );
        onSelectValue?.call(value);
      },
      itemBuilder: (context) => items,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}

class TecTextButton extends StatelessWidget {
  final String title;
  final String tooltip;
  final void Function() onTap;

  const TecTextButton({Key key, this.title, this.tooltip, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: TecText(
            title,
            textScaleFactor: textScaleFactorWith(context),
            style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),
          ),
        ),
      ),
    );
  }
}
