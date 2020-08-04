import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/is_licensed_bloc.dart';
import '../common/common.dart';
import 'volume_card.dart';
import 'volume_detail.dart';
import 'volumes_bloc.dart';
import 'volumes_filter_sheet.dart';

export 'volumes_bloc.dart' show VolumesFilter;

void showLibrary(BuildContext context) {
  Navigator.of(context, rootNavigator: true)
      .push<void>(MaterialPageRoute(builder: (context) => _LibraryNavigator()));
}

Future<int> selectVolume(BuildContext context, {VolumesFilter filter, String title}) {
  // final originalContext = context;
  return Navigator.of(context, rootNavigator: true).push<int>(
    MaterialPageRoute(
      builder: (context) => Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute<int>(
          builder: (context) {
            return Theme(
              data: Theme.of(context).copyWith(appBarTheme: appBarThemeWithContext(context)),
              child: Scaffold(
                appBar: MinHeightAppBar(
                  appBar: AppBar(
                    leading: BackButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).maybePop()),
                    title: tec.isNullOrEmpty(title) ? null : TecText(title),
                  ),
                ),
                body: _VolumesView(
                  type: _ViewType.store,
                  filter: filter,
                  onTapVolume: (id) {
                    Navigator.of(context, rootNavigator: true).maybePop<int>(id);
                  },
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _LibraryNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (context) => _LibraryScreen(
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
        create: (context) => IsLicensedBloc(
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

typedef _TappedVolumeFunc = void Function(int volume);

class _VolumesView extends StatelessWidget {
  final _ViewType type;
  final VolumesFilter filter;
  final _TappedVolumeFunc onTapVolume;

  const _VolumesView({
    Key key,
    this.type,
    this.filter,
    this.onTapVolume,
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
        builder: (context, state) => _VolumesList(type: type, onTapVolume: onTapVolume),
      ),
    );
  }
}

class _VolumesList extends StatefulWidget {
  final _ViewType type;
  final _TappedVolumeFunc onTapVolume;

  const _VolumesList({Key key, this.type, this.onTapVolume}) : super(key: key);

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
            child: TecListView<Volume>(
              items: bloc.state.volumes,
              itemBuilder: (context, volume, index, total) => VolumeCard(
                volume: volume,
                padding: 0,
                onTap: widget.onTapVolume != null
                    ? () {
                        widget.onTapVolume(volume.id);
                      }
                    : () {
                        Navigator.of(context).push<void>(
                            MaterialPageRoute(builder: (context) => VolumeDetail(volume: volume)));
                      },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
