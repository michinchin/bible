import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../library/volumes_bloc.dart';

Future<List<List<int>>> showFilter(BuildContext context,
        {VolumesFilter filter, Iterable<int> selectedVolumes, Iterable<int> selectedBooks}) =>
    showModalBottomSheet<List<List<int>>>(
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        enableDrag: false,
        builder: (c) => SizedBox(
            height: 3 * MediaQuery.of(c).size.height / 4, child: _SearchFilterView(filter)));

class _SearchFilterView extends StatefulWidget {
  final VolumesFilter filter;
  const _SearchFilterView(this.filter);

  @override
  __SearchFilterViewState createState() => __SearchFilterViewState();
}

class __SearchFilterViewState extends State<_SearchFilterView> {
  Set<int> _selectedVolumes;
  Set<int> _selectedBooks;

  String _currFilter = 'Book';

  void _changeFilter(String s) {
    setState(() {
      _currFilter = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TecScaffoldWrapper(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            DropdownButton<String>(
                value: _currFilter,
                items: <String>[
                  'Book',
                  'Translation',
                ].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _changeFilter),
          ],
        ),
        body: _currFilter == 'Book'
            ? Container()
            : _VolumeFilter(widget.filter, _selectedVolumes?.toList() ?? []),
      ),
    );
  }
}

class _VolumeFilter extends StatefulWidget {
  final VolumesFilter filter;
  final List<int> selectedVolumes;
  const _VolumeFilter(this.filter, this.selectedVolumes);

  @override
  __VolumeFilterState createState() => __VolumeFilterState();
}

class __VolumeFilterState extends State<_VolumeFilter> {
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
    return BlocProvider<VolumesBloc>(
        create: (context) => VolumesBloc(
              defaultFilter: widget.filter,
            )..refresh(),
        child: BlocBuilder<VolumesBloc, VolumesState>(
            builder: (context, state) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    spacing: 5,
                    children: [
                      for (final v in state.volumes)
                        ButtonTheme(
                            minWidth: 50,
                            child: FlatButton(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                color: widget.selectedVolumes.contains(v.id)
                                    ? Colors.blue
                                    : Colors.grey[300],
                                onPressed: () => _toggle(v.id),
                                child: Text(
                                  v.abbreviation,
                                  style: TextStyle(
                                      color: widget.selectedVolumes.contains(v.id)
                                          ? Colors.white
                                          : Theme.of(context).textColor.withOpacity(0.8)),
                                )))
                    ],
                  ),
                )));
  }
}

class _BookFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
