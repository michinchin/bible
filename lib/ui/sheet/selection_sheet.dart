import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_volumes/tec_volumes.dart';
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../../models/color_utils.dart';
import '../../models/pref_item.dart';
import '../../models/verses.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../misc/color_picker.dart';

class SelectionSheet extends StatefulWidget {
  final SheetSize sheetSize;
  final ValueNotifier<double> onDragValue;

  // final bool fullyExpanded;
  const SelectionSheet({this.sheetSize, this.onDragValue, Key key}) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> with SingleTickerProviderStateMixin {
  static const buttons = <String, IconData>{
    'Learn': Icons.lightbulb_outline,
    'Explore': FeatherIcons.compass,
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
    // 'Copy': FeatherIcons.copy,
    // 'Note': FeatherIcons.edit2,
    'Audio': FeatherIcons.play,
    'Save': FeatherIcons.bookmark,
    'Print': FeatherIcons.printer,
    'Text': FeatherIcons.messageCircle,
    'Email': FeatherIcons.mail,
    'Facebook': FeatherIcons.facebook,
    'Twitter': FeatherIcons.twitter
  };

  static const medButtons = <String, IconData>{
    'Compare': Icons.compare_arrows,
    'Define': FeatherIcons.bookOpen,
  };

  static const keyButtons = <String, IconData>{
    'Note': FeatherIcons.edit,
    'Share': FeatherIcons.share,
    // 'Learn': Icons.lightbulb_outline,
    // 'Compare': FeatherIcons.compass
  };

  bool _showColorPicker;
  bool _underlineMode;
  bool _editMode;
  int _colorIndex;

  @override
  void initState() {
    _editMode = false;
    _showColorPicker = false;
    _underlineMode = false;
    _colorIndex = 0;
   
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void buttonAction(String type) {
    switch (type) {
      case 'Share':
        _share(context);
        break;
      default:
        break;
    }
  }

  ///
  /// PRIVATE FUNCTIONS
  ///

  // TODO(abby): move to model?
  Future<void> _share(BuildContext c) async {
    final bloc = c.bloc<ViewManagerBloc>(); //ignore: close_sinks
    final views = bloc.visibleViewsWithSelections.toList();
    final refs = <Reference>[];
    for (final v in views) {
      refs.add(tec.as<Reference>(bloc.selectionObjectWithViewUid(v)));
    }
    final first = refs[0];
    final verses = await ChapterVerses.fetch(refForChapter: first);
    await Share.share(ChapterVerses.formatForShare(refs, verses.data));
  }

  void onShowColorPicker() {
    setState(() {
      _showColorPicker = !_showColorPicker;
    });
  }

  void _onEditColors() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  void _onEditColor(int colorIndex) {
    setState(() {
      _showColorPicker = !_showColorPicker;
      _colorIndex = colorIndex;
    });
  }

  void onSwitchToUnderline() {
    setState(() {
      _underlineMode = !_underlineMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrefItemsBloc, PrefItems>(
        bloc: context.bloc<PrefItemsBloc>(),
        builder: (context, state) {
          // only grab custom color pref items
          final prefItems = state?.items?.where((i) => i.book >= 1 && i.book <= 4)?.toList() ?? [];
          final underlineButton = GreyCircleButton(
            icon: _underlineMode ? FeatherIcons.edit3 : FeatherIcons.underline,
            onPressed: onSwitchToUnderline,
          );
          final noColorButton = GreyCircleButton(
            icon: Icons.format_color_reset,
            onPressed: () => context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
                  type: HighlightType.clear,
                )),
          );
          final expandButton = GreyCircleButton(
            icon: Icons.keyboard_arrow_up,
            onPressed: () => context.bloc<SheetManagerBloc>().changeSize(SheetSize.medium),
          );

          final defaultColors = <Color>[
            Color(defaultColorIntForIndex(1)),
            Color(defaultColorIntForIndex(2)),
            Color(defaultColorIntForIndex(3)),
            Color(defaultColorIntForIndex(4)),
          ];

          final customColors = [for (final color in prefItems) Color(color.verse)];

          final smallScreen = MediaQuery.of(context).size.width < 350;
          final miniViewColors = smallScreen ? defaultColors.take(2) : defaultColors;
          int colorChosen;

          final colors = [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Expanded(child: noColorButton),
              Expanded(child: underlineButton),
              for (final color in defaultColors) ...[
                Expanded(
                  child: _ColorPickerButton(
                    isForUnderline: _underlineMode,
                    color: color,
                  ),
                ),
              ],
            ]),
          ];

          final sheetButtons = [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final each in medButtons.keys) ...[
                  Expanded(
                    child: SheetButton(
                      text: each,
                      icon: medButtons[each],
                      onPressed: () => buttonAction(each),
                    ),
                  ),
                  if (buttons.keys.last != each) const SizedBox(width: 10)
                ]
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final each in keyButtons.keys) ...[
                  Expanded(
                    child: SheetButton(
                        text: each, icon: keyButtons[each], onPressed: () => buttonAction(each)),
                  ),
                  if (buttons.keys.last != each) const SizedBox(width: 10)
                ]
              ],
            ),
          ];
          final mediumViewChildren = <Widget>[
            if (_showColorPicker)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ColorPicker(
                          showColorContainer: false,
                          color: Color(prefItems[_colorIndex]?.verse ?? 0xff999999),
                          onColorChanged: (c) {
                            colorChosen = c.value;
                            context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                                type: _underlineMode
                                    ? HighlightType.underline
                                    : HighlightType.highlight,
                                isTrialMode: true,
                                color: colorChosen));
                          }),
                    ),
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      GreyCircleButton(
                          icon: Icons.close,
                          onPressed: () {
                            context
                                .bloc<SelectionStyleBloc>()
                                ?.add(const SelectionStyle(type: HighlightType.clear));
                          }),
                      const Divider(color: Colors.transparent),
                      GreyCircleButton(
                        icon: Icons.done,
                        onPressed: () {
                          context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                              type: _underlineMode
                                  ? HighlightType.underline
                                  : HighlightType.highlight,
                              color: colorChosen));
                          context.bloc<PrefItemsBloc>()?.add(PrefItemEvent.update(
                              prefItem: PrefItem.from(
                                  prefItems[_colorIndex].copyWith(verse: colorChosen))));
                          onShowColorPicker();
                        },
                      ),
                    ],
                  ),
                ],
              )
            else ...[
              ...colors,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (customColors.isNotEmpty)
                    for (var i = 0; i < 4; i++) ...[
                      Expanded(
                        child: _ColorPickerButton(
                          isForUnderline: _underlineMode,
                          editMode: _editMode,
                          onEdit: () => _onEditColor(i),
                          color: customColors[i],
                        ),
                      ),
                    ],
                  Expanded(
                    child: GreyCircleButton(
                      icon: _editMode ? Icons.close : Icons.colorize,
                      onPressed: _onEditColors,
                    ),
                  ),
                ],
              ),
            ]
          ];

          final miniChildren = [
            noColorButton,
            underlineButton,
            for (final color in miniViewColors) ...[
              _ColorPickerButton(
                isForUnderline: _underlineMode,
                color: color,
              ),
            ],
            for (final button in keyButtons.keys) ...[
              GreyCircleButton(
                icon: keyButtons[button],
                onPressed: () => buttonAction(button),
              ),
            ],
            expandButton,
          ];

          Widget _miniView() => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final child in miniChildren)
                      Expanded(
                        child: child,
                      )
                  ]);

          Widget _sheetItems({bool excludeSheetButtons = false}) => Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                runSpacing: 10,
                children: [
                  ...mediumViewChildren,
                  if (!excludeSheetButtons && !_showColorPicker) ...sheetButtons
                ],
              );
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(children: [
              if (widget.sheetSize == SheetSize.mini)
                Expanded(child: _miniView())
              else if (widget.sheetSize == SheetSize.medium) ...[
                _sheetItems(),
              ] else if (widget.sheetSize == SheetSize.full) ...[
                _sheetItems(excludeSheetButtons: true),
                const Divider(color: Colors.transparent),
                Expanded(
                  child: GridView.count(
                      crossAxisCount: 4,
                      padding: const EdgeInsets.only(top: 0),
                      children: [
                        for (final each in buttons.keys) ...[
                          GreyCircleButton(
                            icon: buttons[each],
                            onPressed: () {},
                            title: each,
                          ),
                        ],
                      ]),
                ),
              ]
            ]),
          );
        });
  }
}

class _ColorPickerButton extends StatelessWidget {
  final bool isForUnderline;
  final Color color;
  final bool deletionMode;
  final VoidCallback onDeletion;
  final bool editMode;
  final VoidCallback onEdit;

  const _ColorPickerButton(
      {@required this.color,
      this.isForUnderline = false,
      this.deletionMode = false,
      this.editMode = false,
      this.onDeletion,
      this.onEdit})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    const width = 15.0;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        if (deletionMode) {
          onDeletion();
        } else if (editMode) {
          onEdit();
        } else {
          context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                type: (isForUnderline) ? HighlightType.underline : HighlightType.highlight,
                color: color.value,
              ));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.transparent,
                  width: 5,
                )),
            child: CircleAvatar(
              backgroundColor: isForUnderline ? Colors.transparent : color,
              radius: width,
              child: isForUnderline
                  ? Container(
                      decoration: ShapeDecoration(
                          color: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                      width: 35,
                      height: width,
                    )
                  : null,
            ),
          ),
          if (deletionMode)
            Icon(
              FeatherIcons.trash,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: width,
            )
          else if (editMode)
            Icon(
              Icons.colorize,
              color: Theme.of(context).textColor.withOpacity(0.5),
              size: width,
            ),
        ],
      ),
    );
  }
}
