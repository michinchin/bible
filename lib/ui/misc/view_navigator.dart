import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_widgets/tec_widgets.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../bible/chapter_view.dart';

class ViewNavigator extends StatelessWidget {
  final ViewState viewState;
  const ViewNavigator({this.viewState});
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'viewNav',
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'viewNav':
            builder = (_) => WindowManager(
                  state: viewState,
                  popOff: () => Navigator.of(context).pop(),
                );
            break;
          case 'viewNav/bibleTranslation':
            builder = (_) => BibleTranslationSelection(
                  popOff: () => Navigator.of(context).pop(),
                );
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute<void>(builder: builder, settings: settings);
      },
    );
  }
}

class BibleTranslationSelection extends StatelessWidget {
  final VoidCallback popOff;
  const BibleTranslationSelection({this.popOff});
  @override
  Widget build(BuildContext context) {
    const bt = [
      'New International Version',
      'New Living Translation',
      'Christian Standard Bible',
      'Amplified Bible',
      'The Message',
      'The Voice',
    ];
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ListView(children: [
            for (final each in bt)
              ListTile(
                title: Text(each),
                onTap: popOff,
              )
          ]),
        ));
  }
}

class WindowManager extends StatelessWidget {
  final ViewState state;
  final VoidCallback popOff;
  const WindowManager({this.state, this.popOff});

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final isMaximized = bloc?.state?.maximizedViewUid != 0;

    return ListView(
      children: [
        if ((bloc?.state?.views?.length ?? 0) > 1)
          _menuItem(context, isMaximized ? FeatherIcons.minimize2 : FeatherIcons.maximize2,
              isMaximized ? 'Restore' : 'Maximize', () {
            popOff();
            bloc?.add(isMaximized
                ? const ViewManagerEvent.restore()
                : ViewManagerEvent.maximize(state.uid));
          }),
        if (((bloc?.countOfInvisibleViews ?? 0) > 1 || isMaximized)) ...[
          _titleDivider(context, isMaximized ? 'Switch' : 'Open'),
          ..._generateOffScreenItems(context, state.uid)
        ],
        _titleDivider(context, 'New'),
        ..._generateAddMenuItems(context, state.uid),
        _menuItem(context, FeatherIcons.bookOpen, 'Translation',
            () => Navigator.of(context).pushNamed('viewNav/bibleTranslation')),
        if ((bloc?.state?.views?.length ?? 0) > 1) ...[
          const Divider(),
          _menuItem(context, Icons.close, 'Close View', () {
            popOff();
            bloc?.add(ViewManagerEvent.remove(state.uid));
          }),
        ]
      ],
    );
  }

  Widget _titleDivider(BuildContext context, String title) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TecText(
            title,
            style: TextStyle(fontSize: 12, color: Theme.of(context).textColor.withOpacity(0.5)),
          ),
          const Expanded(
            child: Divider(
              indent: 10,
            ),
          )
        ],
      );

  Iterable<Widget> _generateOffScreenItems(BuildContext context, int viewUid) {
    final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
    final vm = ViewManager.shared;
    final iconMap = <String, IconData>{
      'Bible': FeatherIcons.book,
      'Note': FeatherIcons.edit,
      'Test View': FeatherIcons.plusSquare
    };

    final items = <Widget>[];
    for (final each in bloc.state.views) {
      if (!bloc.isViewWithUidVisible(each.uid)) {
        var title = vm.titleForType(each.type);
        if (each.type == 'BibleChapter') {
          title = bibleChapterTitleFromState(each);
        }
        items.add(_menuItem(context, iconMap[vm.titleForType(each.type)], '$title', () {
          if (bloc.state.maximizedViewUid == viewUid) {
            bloc?.add(
                ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
            bloc?.add(ViewManagerEvent.maximize(each.uid));
            popOff();
          } else {
            bloc?.add(
                ViewManagerEvent.move(fromPosition: bloc.indexOfView(each.uid), toPosition: 0));
            popOff();
          }
        }));
      }
    }
    return items;
  }

  Iterable<Widget> _generateAddMenuItems(BuildContext context, int viewUid) {
    final vm = ViewManager.shared;
    final iconMap = <String, IconData>{
      'Bible': FeatherIcons.book,
      'Note': FeatherIcons.edit,
      'Test View': FeatherIcons.plusSquare
    };
    return vm.types.map<Widget>(
      (type) => _menuItem(context, iconMap[vm.titleForType(type)], '${vm.titleForType(type)}', () {
        popOff();
        final bloc = context.bloc<ViewManagerBloc>(); // ignore: close_sinks
        final position = bloc?.indexOfView(viewUid) ?? -1;
        bloc?.add(ViewManagerEvent.add(
            type: type, data: '', position: position == -1 ? null : position + 1));
      }),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onPressed) {
    return ListTile(
        onTap: onPressed,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).textColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).textColor.withOpacity(0.5),
          ),
        ),
        title: TecText(
          title,
        ));
  }
}
