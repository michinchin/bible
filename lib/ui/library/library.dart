import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart' as collection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/downloads/downloads_bloc.dart';
import '../../blocs/is_licensed_bloc.dart';
import '../common/common.dart';
import '../common/tec_navigator.dart';
import 'volume_card.dart';
import 'volume_detail.dart';
import 'volumes_bloc.dart';
import 'volumes_filter_sheet.dart';
import 'volumes_sort_bloc.dart';

export 'volumes_bloc.dart' show VolumesFilter;

///
/// Shows the Library, and if [initialTabPrefix] is provided, the Library
/// is opened to the tab that starts with [initialTabPrefix].
///
void showLibrary(BuildContext context, {String initialTabPrefix}) {
  _showLibrary(context: context, initialTabPrefix: initialTabPrefix);
}

///
/// Shows the Library with the given [title] and returns the ID of the
/// Volume that was selected, or `null` if the Library is closed without
/// a volume having been selected.
///
/// If [selectedVolume] is not null, the Library is opened to the tab that
/// contains the Volume, and if [scrollToSelectedVolume] is `true` (the
/// default), the Volume is auto-scrolled into view.
///
Future<int> selectVolumeInLibrary(
  BuildContext context, {
  String title,
  String initialTabPrefix,
  int selectedVolume,
  bool scrollToSelectedVolume = true,
}) {
  var tabPrefix = initialTabPrefix;
  if (tec.isNullOrEmpty(tabPrefix) && selectedVolume != null) {
    final vp = VolumesRepository.shared;
    tabPrefix = _tweakedName(vp.categoryWithId(vp.categoryWithVolume(selectedVolume))?.name);
  }

  return _showLibrary<int>(
    context: context,
    title: title,
    initialTabPrefix: tabPrefix,
    selectedVolumes: selectedVolume == null ? [] : [selectedVolume],
    scrollToSelectedVolumes: scrollToSelectedVolume,
    whenTappedPopWithVolumeId: true,
  );
}

///
/// Shows the Library with the given [title] and returns the list of the IDs
/// of Volumes that were selected, if any.
///
Future<List<int>> selectVolumesInLibrary(
  BuildContext context, {
  String title,
  String initialTabPrefix,
  Iterable<int> selectedVolumes,
  bool scrollToSelectedVolumes = true,
}) {
  return _showLibrary<List<int>>(
    context: context,
    title: title,
    initialTabPrefix: initialTabPrefix,
    selectedVolumes: selectedVolumes ?? [],
    scrollToSelectedVolumes: scrollToSelectedVolumes,
    allowMultipleSelections: true,
  );
}

///
/// Pushes a `VolumeDetail` view for the given [volume] on the `Navigator` of
/// the current [context].
///
void showDetailViewForVolume(BuildContext context, Volume volume, String heroPrefix) {
  Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (context) => VolumeDetail(volume: volume, heroPrefix: heroPrefix)));
}

///
/// The [title], [filter], and [prefsKey] for a Library tab.
///
@immutable
class LibraryTab {
  final String title;
  final VolumesFilter filter;
  final String prefsKey;

  const LibraryTab({@required this.title, @required this.filter, this.prefsKey})
      : assert(title != null && filter != null);
}

//
// PRIVATE STUFF
//

Future<T> _showLibrary<T extends Object>({
  @required BuildContext context,
  String title,
  String initialTabPrefix,
  Iterable<int> selectedVolumes = const {},
  bool scrollToSelectedVolumes = true,
  bool whenTappedPopWithVolumeId = false,
  bool allowMultipleSelections = false,
}) {
  return showTecDialog<T>(
    context: context,
    useRootNavigator: true,
    padding: EdgeInsets.zero,
    maxWidth: 500,
    maxHeight: math.max(500.0, (MediaQuery.of(context)?.size?.height ?? 700) - 40),
    makeScrollable: false,
    builder: (context) => NavigatorWithHeroController(
      onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (context) => LibraryScaffold(
          title: title,
          initialTabPrefix: initialTabPrefix,
          selectedVolumes: selectedVolumes,
          scrollToSelectedVolumes: scrollToSelectedVolumes,
          whenTappedPopWithVolumeId: whenTappedPopWithVolumeId,
          allowMultipleSelections: allowMultipleSelections,
          heroPrefix: 'popup',
        ),
      ),
    ),
  );
}

class LibraryScaffold extends StatelessWidget {
  final String title;
  final String initialTabPrefix;
  final Iterable<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool whenTappedPopWithVolumeId;
  final bool allowMultipleSelections;
  final bool showCloseButton;
  final String heroPrefix;

  const LibraryScaffold({
    Key key,
    this.title,
    this.initialTabPrefix,
    this.selectedVolumes = const {},
    this.scrollToSelectedVolumes = true,
    this.whenTappedPopWithVolumeId = false,
    this.allowMultipleSelections = false,
    this.showCloseButton = true,
    this.heroPrefix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsLicensedBloc>(
      create: (context) =>
          IsLicensedBloc(volumeIds: VolumesRepository.shared.volumeIdsWithType(VolumeType.anyType)),
      child: BlocBuilder<IsLicensedBloc, bool>(
        builder: (context, hasLicensedVolumes) {
          // if `hasLicensedVolumes` is null, just return spinner.
          if (hasLicensedVolumes == null) return const Center(child: LoadingIndicator());

          final tabs = _tabs(hasLicensedVolumes: hasLicensedVolumes);
          final initialIndex = tec.isNullOrEmpty(initialTabPrefix)
              ? 0
              : math.max(0, tabs.indexWhere((t) => t.title.startsWith(initialTabPrefix)));
          return _Library(
            tabs: tabs,
            initialTabIndex: initialIndex,
            title: title,
            heroPrefix: heroPrefix,
            selectedVolumes: selectedVolumes,
            scrollToSelectedVolumes: scrollToSelectedVolumes,
            whenTappedPopWithVolumeId: whenTappedPopWithVolumeId,
            allowMultipleSelections: allowMultipleSelections,
            showCloseButton: showCloseButton,
          );
        },
      ),
    );
  }
}

List<LibraryTab> _tabs({bool hasLicensedVolumes}) => [
      if (hasLicensedVolumes)
        const LibraryTab(
            title: 'Purchased',
            filter: VolumesFilter(ownershipStatus: OwnershipStatus.owned),
            prefsKey: 'purchased'),
      for (final id in VolumesRepository.shared.categoryIds()) _tabFromCategory(id),
    ];

LibraryTab _tabFromCategory(int categoryId) {
  final category = VolumesRepository.shared.categoryWithId(categoryId);
  if (category != null) {
    return LibraryTab(
        title: _tweakedName(category.name),
        filter: VolumesFilter(category: categoryId),
        prefsKey: category.name);
  }
  return null;
}

String _tweakedName(String name) {
  switch (name) {
    case 'Bible Translations':
      return 'Bibles';
    default:
      return name;
  }
}

class _Library extends StatefulWidget {
  final List<LibraryTab> tabs;
  final int initialTabIndex;
  final String title;
  final Iterable<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool whenTappedPopWithVolumeId;
  final bool allowMultipleSelections;
  final bool showCloseButton;
  final String heroPrefix;

  const _Library({
    Key key,
    @required this.tabs,
    this.initialTabIndex,
    this.title,
    this.selectedVolumes = const {},
    this.scrollToSelectedVolumes = true,
    this.whenTappedPopWithVolumeId = false,
    this.allowMultipleSelections = false,
    this.showCloseButton = true,
    this.heroPrefix,
  })  : assert(tabs != null),
        assert(!whenTappedPopWithVolumeId == false || !allowMultipleSelections),
        super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<_Library> {
  final _selectedVolumes = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.selectedVolumes != null) _selectedVolumes.addAll(widget.selectedVolumes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VolumesSortBloc>(
      create: (_) => VolumesSortBloc(),
      child: widget.tabs.length > 1
          ? DefaultTabController(
              initialIndex: widget.initialTabIndex ?? 0,
              length: widget.tabs.length,
              child: Scaffold(
                backgroundColor: Theme.of(context).backgroundColor,
                appBar: _appBar(
                  showCloseButton: widget.showCloseButton,
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: widget.tabs.map((t) => Tab(text: t.title)).toList(),
                  ),
                ),
                body: TabBarView(children: widget.tabs.map(_widgetFromTab).toList()),
              ),
            )
          : Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              appBar: _appBar(showCloseButton: widget.showCloseButton),
              body: _widgetFromTab(widget.tabs.first),
            ),
    );
  }

  Widget _widgetFromTab(LibraryTab t) => BlocBuilder<VolumesSortBloc, VolumesSort>(
        buildWhen: (previous, current) =>
            previous.sortBy != current.sortBy || current.sortBy == VolumesSortOpt.recent,
        builder: (context, sort) => BlocProvider<VolumesBloc>(
          create: (context) => VolumesBloc(
            key: tec.isNullOrEmpty(t.prefsKey) ? null : '_library_${t.prefsKey}',
            kvStore: tec.isNullOrEmpty(t.prefsKey)
                ? null
                : tec.MemoryKVStore.shared, // tec.Prefs.shared,
            defaultFilter: t.filter,
          )..refresh(),
          child: BlocBuilder<VolumesBloc, VolumesState>(
            builder: (context, state) => _VolumesList(
              heroPrefix: widget.heroPrefix,
              selectedVolumes: _selectedVolumes,
              scrollToSelectedVolumes: widget.scrollToSelectedVolumes,
              allowMultipleSelections: widget.allowMultipleSelections,
              onTapVolume: widget.whenTappedPopWithVolumeId
                  ? (id) {
                      context.tbloc<VolumesSortBloc>().updateWithVolume(id);
                      Navigator.of(context, rootNavigator: true).maybePop<int>(id);
                    }
                  : null,
            ),
          ),
        ),
      );

  PreferredSizeWidget _appBar({PreferredSizeWidget bottom, bool showCloseButton = true}) =>
      MinHeightAppBar(
        appBar: AppBar(
          leading: showCloseButton
              ? CloseButton(onPressed: () => Navigator.of(context, rootNavigator: true).maybePop())
              : null,
          automaticallyImplyLeading: false,
          title: Text(tec.isNullOrEmpty(widget.title) ? 'Library' : widget.title),
          actions: widget.allowMultipleSelections
              ? [
                  CupertinoButton(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      'Done',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .maybePop<List<int>>(_selectedVolumes.toList());
                    },
                  ),
                ]
              : null,
          bottom: bottom,
        ),
      );
}

class _VolumesList extends StatefulWidget {
  final Set<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool allowMultipleSelections;
  final void Function(int volume) onTapVolume;
  final String heroPrefix;

  const _VolumesList({
    Key key,
    this.selectedVolumes,
    this.scrollToSelectedVolumes = true,
    this.allowMultipleSelections = false,
    this.onTapVolume,
    this.heroPrefix,
  }) : super(key: key);

  @override
  _VolumesListState createState() => _VolumesListState();
}

class _VolumesListState extends State<_VolumesList> {
  TextEditingController _textEditingController;
  FocusNode _focusNode;
  final _scrollController = ItemScrollController();
  Timer _debounceTimer;
  bool _scrollToVolume;
  bool _searchFieldHasFocus = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController()..addListener(_searchListener);
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _scrollToVolume = widget.scrollToSelectedVolumes && widget.selectedVolumes.isNotEmpty;
    if (_scrollToVolume) _scrollToVolumeAfterBuild();
  }

  @override
  void didUpdateWidget(_VolumesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_scrollToVolume) _scrollToVolumeAfterBuild();
  }

  void _scrollToVolumeAfterBuild() {
    if (_scrollToVolume &&
        context.tbloc<VolumesBloc>().state.volumes.isNotEmpty &&
        context.tbloc<VolumesSortBloc>().state.sortBy == VolumesSortOpt.name) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted && _scrollController.isAttached) {
          final index = context
              .tbloc<VolumesBloc>()
              .state
              .volumes
              .indexWhere((v) => widget.selectedVolumes.contains(v.id));
          if (index >= 0) {
            _scrollToVolume = false;
            _scrollController.jumpTo(index: index);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _textEditingController?.removeListener(_searchListener);
    _textEditingController?.dispose();
    _textEditingController = null;

    _focusNode?.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _focusNode = null;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    super.dispose();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounceTimer?.isActive ?? false) _debounceTimer.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          // tec.dmPrint('search string: ${_textEditingController.text.trim()}');
          context.tbloc<VolumesBloc>()?.add(
                context.tbloc<VolumesBloc>().state.filter.copyWith(
                      searchFilter: _textEditingController.text.trim(),
                    ),
              );
        }
      },
    );
  }

  void _focusNodeListener() {
    if (!mounted) return;
    final hasFocus = (_focusNode?.hasFocus ?? false);
    if (_searchFieldHasFocus != hasFocus) {
      if (!hasFocus) _textEditingController?.clear();
      setState(() => _searchFieldHasFocus = hasFocus);
    }
  }

  void _refresh([VoidCallback fn]) {
    if (mounted) setState(fn ?? () {});
  }

  void _toggle(int id) {
    _refresh(() {
      if (!widget.selectedVolumes.remove(id)) widget.selectedVolumes.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.tbloc<VolumesBloc>(); // ignore: close_sinks
    final showFilter =
        (bloc.languages?.length ?? 0) > 1 /* || (bloc.categories?.length ?? 0) > 1 */;

    var volumes = bloc.state.volumes;
    if (context.tbloc<VolumesSortBloc>().state.sortBy == VolumesSortOpt.recent) {
      final sortBloc = context.tbloc<VolumesSortBloc>();
      volumes = List.of(volumes);
      // Using mergeSort because it is stable (i.e. equal elements remain in the same order).
      collection.mergeSort<Volume>(volumes, compare: (a, b) => sortBloc.compare(a.id, b.id));
    }

    final textScaleFactor = textScaleFactorWith(context);
    final padding = (12.0 * textScaleFactor).roundToDouble();
    final showSearch = _searchFieldHasFocus;
    final barTextColor = Theme.of(context).appBarTheme.textTheme.headline6.color;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: showSearch ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: TecSearchField(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, 8),
              textEditingController: _textEditingController,
              focusNode: _focusNode,
              onSubmit: (s) => _searchListener(),
            ),
            secondChild: Row(
              children: [
                // SizedBox(width: padding, height: topBarHeight),
                IconButton(
                    tooltip: 'search',
                    icon: const Icon(Icons.search),
                    onPressed: () => _focusNode.requestFocus()),
                Theme(
                  data: Theme.of(context).copyWith(accentColor: barTextColor),
                  child: TecPopupMenuButton<int>(
                    title: '',
                    values: {0: 'Title ↓', 1: 'Recent ↓'} as LinkedHashMap<int, String>,
                    currentValue: context.tbloc<VolumesSortBloc>().state.sortBy.index,
                    defaultValue: 0,
                    defaultName: 'Any',
                    onSelectValue: (value) {
                      context.tbloc<VolumesSortBloc>().updateSortBy(VolumesSortOpt.values[value]);
                    },
                  ),
                ),
                Expanded(child: Container()),
                if (showFilter)
                  IconButton(
                      tooltip: 'filters',
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => showVolumesFilterSheet(context)),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ScrollablePositionedList.builder(
                padding: MediaQuery.of(context)?.padding,
                itemScrollController: _scrollController,
                itemCount: volumes.length,
                itemBuilder: (context, index) {
                  final volume = volumes[index];
                  return BlocBuilder<DownloadsBloc, DownloadsState>(
                    buildWhen: (previous, current) =>
                        previous.items[volume.id] != current.items[volume.id],
                    builder: (context, downloads) {
                      return VolumeCard(
                        isCompact: widget.onTapVolume != null || widget.allowMultipleSelections,
                        volume: volume,
                        heroPrefix: widget.heroPrefix,
                        trailing: !widget.allowMultipleSelections
                            ? _VolumeActionButton(volume: volume, heroPrefix: widget.heroPrefix)
                            : Checkbox(
                                value: widget.selectedVolumes.contains(volume.id),
                                onChanged: (checked) => _toggle(volume.id),
                              ),
                        onTap: widget.onTapVolume != null || widget.allowMultipleSelections
                            ? () {
                                if (widget.allowMultipleSelections) {
                                  _toggle(volume.id);
                                } else {
                                  widget.onTapVolume(volume.id);
                                }
                              }
                            : () => showDetailViewForVolume(context, volume, widget.heroPrefix),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeActionButton extends StatelessWidget {
  final Volume volume;
  final String heroPrefix;

  const _VolumeActionButton({Key key, this.volume, this.heroPrefix}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.tbloc<DownloadsBloc>(); // ignore: close_sinks
    assert(bloc != null);
    if (bloc == null || !bloc.supportsDownloading) return Container();

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final item = bloc.state.items[volume.id];
    final color = Theme.of(context).accentColor;

    Widget _progressCircle() => Positioned(
        left: 8,
        right: 8,
        top: 8,
        bottom: 8,
        child: CircularProgressIndicator(
          backgroundColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
          value: item?.progress ?? 0.0,
        ));

    if (VolumesRepository.shared.isLocalVolume(volume.id) ||
        (item != null && item.status == DownloadStatus.complete)) {
      return IconButton(
          icon: const Icon(Icons.check_circle),
          iconSize: 32,
          color: Colors.green,
          onPressed: () => showDetailViewForVolume(context, volume, heroPrefix));
    } else if (item == null ||
        item.status == DownloadStatus.undefined ||
        item.status == DownloadStatus.failed ||
        item.status == DownloadStatus.canceled) {
      // If free, or licensed, allow download.
      if (volume.price == 0.0 || context.tbloc<VolumesBloc>().isFullyLicensed(volume.id)) {
        return IconButton(
            icon: const Icon(Icons.cloud_download),
            iconSize: 32,
            color: color,
            onPressed: () =>
                _onActionTap(bloc, item ?? DownloadItem(volumeId: volume.id, url: '')));
      } else {
        return IconButton(
            icon: Icon(platformAwareMoreIcon(context)),
            iconSize: 32,
            color: color,
            onPressed: () => showDetailViewForVolume(context, volume, heroPrefix));
      }
    } else if (item.status == DownloadStatus.running) {
      return Stack(
        children: [
          _progressCircle(),
          IconButton(
              icon: const Icon(Icons.pause), //.cancel),
              color: color,
              onPressed: () => _onActionTap(bloc, item)),
        ],
      );
    } else if (item.status == DownloadStatus.paused) {
      return Stack(
        children: [
          _progressCircle(),
          IconButton(
              icon: const Icon(Icons.play_arrow),
              color: color,
              onPressed: () => _onActionTap(bloc, item)),
        ],
      );
    } else if (item.status == DownloadStatus.canceled) {
      return const Text('Canceled', style: TextStyle(color: Colors.red));
    } else if (item.status == DownloadStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Failed', style: TextStyle(color: Colors.red)),
          IconButton(
              icon: const Icon(Icons.refresh),
              color: color,
              onPressed: () => _onActionTap(bloc, item)),
        ],
      );
    } else {
      return Container();
    }
  }

  void _onActionTap(DownloadsBloc bloc, DownloadItem item) {
    assert(item != null);
    if (item.status == DownloadStatus.undefined ||
        item.status == DownloadStatus.failed ||
        item.status == DownloadStatus.canceled) {
      bloc?.requestDownload(item.volumeId);
    } else if (item.status == DownloadStatus.running) {
      bloc?.pauseDownload(item.volumeId);
    } else if (item.status == DownloadStatus.paused) {
      bloc?.resumeDownload(item.volumeId);
      // } else if (item.status == DownloadStatus.complete) {
      //   bloc?.delete(item);
      // } else if (item.status == DownloadStatus.failed) {
      //   bloc?.retryDownload(item);
    }
  }
}
