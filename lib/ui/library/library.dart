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
import 'volumes_bloc.dart';
import 'volumes_filter_sheet.dart';

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
              itemBuilder: (context, volume, index, total) =>
                  VolumeCard(volume: volume, padding: 0),
            ),
          ),
        ),
      ],
    );
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
