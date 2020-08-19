import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';

import '../../blocs/downloads/downloads_bloc.dart';
import '../../blocs/is_licensed_bloc.dart';
import '../common/common.dart';
import '../common/tec_scaffold_wrapper.dart';
import 'volume_card.dart';
import 'volume_detail.dart';
import 'volumes_bloc.dart';
import 'volumes_filter_sheet.dart';

export 'volumes_bloc.dart' show VolumesFilter;

void showLibrary(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _TabbedLibraryScreen(
        closeLibrary: () => Navigator.of(context, rootNavigator: true).maybePop(),
      ),
    ),
  );
}

Future<int> selectVolume(
  BuildContext context, {
  String title,
  VolumesFilter filter,
  int selectedVolume,
  bool scrollToSelectedVolume = true,
}) {
  return Navigator.of(context, rootNavigator: true).push<int>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _LibraryScreen(
        title: title,
        filter: filter,
        selectedVolumes: selectedVolume == null ? [] : [selectedVolume],
        scrollToSelectedVolumes: scrollToSelectedVolume,
      ),
    ),
  );
}

Future<List<int>> selectVolumes(
  BuildContext context, {
  String title,
  VolumesFilter filter,
  Iterable<int> selectedVolumes,
  bool scrollToSelectedVolumes = true,
}) {
  return Navigator.of(context, rootNavigator: true).push<List<int>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _LibraryScreen(
        title: title,
        filter: filter,
        selectedVolumes: selectedVolumes ?? [],
        scrollToSelectedVolumes: scrollToSelectedVolumes,
        allowMultipleSelections: true,
      ),
    ),
  );
}

class _LibraryScreen extends StatefulWidget {
  final String title;
  final VolumesFilter filter;
  final Iterable<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool allowMultipleSelections;

  const _LibraryScreen({
    Key key,
    this.title,
    this.filter,
    this.selectedVolumes = const [],
    this.scrollToSelectedVolumes = true,
    this.allowMultipleSelections = false,
  }) : super(key: key);

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<_LibraryScreen> {
  final _selectedVolumes = <int>{};

  @override
  void initState() {
    super.initState();
    if (widget.selectedVolumes != null) _selectedVolumes.addAll(widget.selectedVolumes);
  }

  @override
  Widget build(BuildContext context) {
    return TecScaffoldWrapper(
      child: Scaffold(
        appBar: MinHeightAppBar(
          appBar: AppBar(
            leading:
                CloseButton(onPressed: () => Navigator.of(context, rootNavigator: true).maybePop()),
            title: tec.isNullOrEmpty(widget.title) ? null : Text(widget.title),
            actions: !widget.allowMultipleSelections
                ? null
                : [
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
                  ],
          ),
        ),
        body: _VolumesView(
          type: _ViewType.store,
          filter: widget.filter,
          selectedVolumes: _selectedVolumes,
          scrollToSelectedVolumes: widget.scrollToSelectedVolumes,
          allowMultipleSelections: widget.allowMultipleSelections,
          onTapVolume: widget.allowMultipleSelections
              ? null
              : (id) {
                  Navigator.of(context, rootNavigator: true).maybePop<int>(id);
                },
        ),
      ),
    );
  }
}

class _TabbedLibraryScreen extends StatelessWidget {
  final VoidCallback closeLibrary;

  const _TabbedLibraryScreen({Key key, this.closeLibrary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsLicensedBloc>(
      create: (context) =>
          IsLicensedBloc(volumeIds: VolumesRepository.shared.volumeIdsWithType(VolumeType.anyType)),
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
          return TecScaffoldWrapper(
            child: DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                appBar: MinHeightAppBar(
                  appBar: AppBar(
                    leading: CloseButton(onPressed: closeLibrary),
                    // leading: BackButton(onPressed: closeLibrary),
                    title: const Text('Library'),
                    bottom: TabBar(tabs: tabs),
                  ),
                ),
                body: TabBarView(children: tabContents),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ViewType { bibles, purchased, store }

typedef _TappedVolumeFunc = void Function(int volume);

class _VolumesView extends StatelessWidget {
  final _ViewType type;
  final VolumesFilter filter;
  final Set<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool allowMultipleSelections;
  final _TappedVolumeFunc onTapVolume;
  final VoidCallback onDone;

  const _VolumesView({
    Key key,
    this.type,
    this.filter,
    this.selectedVolumes = const {},
    this.scrollToSelectedVolumes = true,
    this.allowMultipleSelections = false,
    this.onTapVolume,
    this.onDone,
  }) : super(key: key);

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
      create: (context) => VolumesBloc(
        key: filter != null ? null : '_library$type',
        kvStore: filter != null ? null : tec.Prefs.shared,
        defaultFilter: filter ?? _filterForType(type),
      )..refresh(),
      child: BlocBuilder<VolumesBloc, VolumesState>(
        builder: (context, state) => _VolumesList(
          type: type,
          selectedVolumes: selectedVolumes,
          scrollToSelectedVolumes: scrollToSelectedVolumes,
          allowMultipleSelections: allowMultipleSelections,
          onTapVolume: onTapVolume,
          onDone: onDone,
        ),
      ),
    );
  }
}

class _VolumesList extends StatefulWidget {
  final _ViewType type;
  final Set<int> selectedVolumes;
  final bool scrollToSelectedVolumes;
  final bool allowMultipleSelections;
  final _TappedVolumeFunc onTapVolume;
  final VoidCallback onDone;

  const _VolumesList({
    Key key,
    this.type,
    this.selectedVolumes,
    this.scrollToSelectedVolumes = true,
    this.allowMultipleSelections = false,
    this.onTapVolume,
    this.onDone,
  }) : super(key: key);

  @override
  _VolumesListState createState() => _VolumesListState();
}

class _VolumesListState extends State<_VolumesList> {
  TextEditingController _textEditingController;
  final _scrollController = ItemScrollController();
  Timer _debounce;
  bool _scrollToVolume;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController()..addListener(_searchListener);
    _scrollToVolume = widget.scrollToSelectedVolumes && widget.selectedVolumes.isNotEmpty;
    if (_scrollToVolume) _scrollToVolumeAfterBuild();
  }

  @override
  void didUpdateWidget(_VolumesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_scrollToVolume) _scrollToVolumeAfterBuild();
  }

  void _scrollToVolumeAfterBuild() {
    if (_scrollToVolume && context.bloc<VolumesBloc>().state.volumes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted && _scrollController.isAttached) {
          final index = context
              .bloc<VolumesBloc>()
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
    _debounce?.cancel();
    _debounce = null;
    super.dispose();
  }

  void _searchListener() {
    if (!mounted) return;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          // tec.dmPrint('search string: ${_textEditingController.text.trim()}');
          context.bloc<VolumesBloc>()?.add(
                context.bloc<VolumesBloc>().state.filter.copyWith(
                      searchFilter: _textEditingController.text.trim(),
                    ),
              );
        }
      },
    );
  }

  void _refresh(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  void _toggle(int id) {
    _refresh(() {
      if (!widget.selectedVolumes.remove(id)) widget.selectedVolumes.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<VolumesBloc>(); // ignore: close_sinks
    final showFilter = (bloc.languages?.length ?? 0) > 1 || (bloc.categories?.length ?? 0) > 1;
    return Column(
      children: [
        TecSearchField(
          textEditingController: _textEditingController,
          onSubmit: (s) => _searchListener(),
          suffixIcon: showFilter
              ? IconButton(
                  tooltip: 'filters',
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => showVolumesFilterSheet(context))
              : null,
        ),
        Expanded(
          child: Scrollbar(
            child: ScrollablePositionedList.builder(
              padding: MediaQuery.of(context)?.padding,
              itemScrollController: _scrollController,
              itemCount: bloc.state.volumes.length,
              itemBuilder: (context, index) {
                final volume = bloc.state.volumes[index];
                return BlocBuilder<DownloadsBloc, DownloadsState>(
                  condition: (previous, current) =>
                      previous.items[volume.id] != current.items[volume.id],
                  builder: (context, downloads) {
                    return VolumeCard(
                      volume: volume,
                      trailing: !widget.allowMultipleSelections
                          ? _buildActionForVolume(context, volume)
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
                          : () => _pushDetailView(context, volume),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _pushDetailView(BuildContext context, Volume volume) {
    Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (context) => VolumeDetail(volume: volume)));
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

  Widget _buildActionForVolume(BuildContext context, Volume volume) {
    final bloc = context.bloc<DownloadsBloc>(); // ignore: close_sinks
    assert(bloc != null);
    if (bloc == null || !bloc.supportsDownloading) return null;

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
          onPressed: () => _pushDetailView(context, volume));
    } else if (item == null ||
        item.status == DownloadStatus.undefined ||
        item.status == DownloadStatus.failed ||
        item.status == DownloadStatus.canceled) {
      // If free, or licensed, allow download.
      if (volume.price == 0.0 || context.bloc<VolumesBloc>().isFullyLicensed(volume.id)) {
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
            onPressed: () => _pushDetailView(context, volume));
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
      return null;
    }
  }
}
