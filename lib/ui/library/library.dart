import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../common/common.dart';
import 'volumes_bloc/volumes_bloc.dart';

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
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: closeLibrary),
            title: const Text('Library'),
            bottom: const TabBar(
              tabs: [Tab(text: 'Bibles'), Tab(text: 'Purchased'), Tab(text: 'Store')],
            ),
          ),
          body: const TabBarView(children: [
            _VolumesView(type: _ViewType.bibles),
            _VolumesView(type: _ViewType.purchased),
            _VolumesView(type: _ViewType.store)
          ]),
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
  VolumesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = VolumesBloc(key: '_library${widget.type}', kvStore: tec.Prefs.shared);
    _foo();
  }

  Future<void> _foo() async {
    final state = await VolumesState.generateFrom(_bloc.state.filter);
    if (mounted) _bloc.add(state);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<VolumesBloc, VolumesState>(
        builder: (context, state) {
          return Scrollbar(
            child: TecListView<Volume>(
              items: state.volumes,
              itemBuilder: (context, volume, index, total) =>
                  VolumeCard(volume: volume, padding: 0),
            ),
          );
        },
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
