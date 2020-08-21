import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tec_widgets/tec_widgets.dart';
import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/pref_item.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../misc/color_picker.dart';
import 'selection_sheet_model.dart';

class SelectionSheet extends StatefulWidget {
  final SheetSize sheetSize;

  // final bool fullyExpanded;
  const SelectionSheet({this.sheetSize, Key key}) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> with SingleTickerProviderStateMixin {
  bool showColorPicker;
  bool underlineMode;

  @override
  void initState() {
    showColorPicker = false;
    underlineMode = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  /// CHANGE MODES FOR SHEET
  ///

  void onShowColorPicker() {
    setState(() {
      showColorPicker = !showColorPicker;
    });
  }

  void onSwitchToUnderline() {
    setState(() {
      underlineMode = !underlineMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(children: [
        if (widget.sheetSize == SheetSize.mini)
          Expanded(
              child: _MiniView(
            underlineMode: underlineMode,
            onSwitchToUnderline: onSwitchToUnderline,
          ))
        else if (widget.sheetSize == SheetSize.medium) ...[
          _MediumFullSheetItems(
            isMediumView: true,
            showColorPicker: showColorPicker,
            onShowColorPicker: onShowColorPicker,
            onSwitchToUnderline: onSwitchToUnderline,
            underlineMode: underlineMode,
          ),
        ] else if (widget.sheetSize == SheetSize.full) ...[
          _MediumFullSheetItems(
            isMediumView: false,
            showColorPicker: showColorPicker,
            onShowColorPicker: onShowColorPicker,
            onSwitchToUnderline: onSwitchToUnderline,
            underlineMode: underlineMode,
          ),
          const Divider(color: Colors.transparent),
          Expanded(
            child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.only(top: 0),
                children: [
                  for (final each in SelectionSheetModel.buttons.keys) ...[
                    GreyCircleButton(
                      icon: SelectionSheetModel.buttons[each],
                      onPressed: () {},
                      title: each,
                    ),
                  ],
                ]),
          ),
        ]
      ]),
    );
  }
}

class _MediumFullSheetItems extends StatefulWidget {
  final bool isMediumView;
  final bool showColorPicker;
  final bool underlineMode;

  final VoidCallback onSwitchToUnderline;
  final VoidCallback onShowColorPicker;

  const _MediumFullSheetItems({
    @required this.isMediumView,
    @required this.showColorPicker,
    @required this.underlineMode,
    @required this.onShowColorPicker,
    @required this.onSwitchToUnderline,
  });

  @override
  __MediumFullSheetItemsState createState() => __MediumFullSheetItemsState();
}

class __MediumFullSheetItemsState extends State<_MediumFullSheetItems> {
  int _colorChosen;
  int _colorIndex;
  bool _editMode;

  @override
  void initState() {
    super.initState();
    _colorChosen = 0xff999999;
    _colorIndex = 0;
    _editMode = false;
  }

  void _setColor(int color) {
    setState(() {
      _colorChosen = color;
    });
  }

  void _onEditColor(int colorIndex) {
    widget.onShowColorPicker();
    setState(() {
      _colorIndex = colorIndex;
    });
  }

  void _onEditColors() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrefItemsBloc, PrefItems>(
        bloc: context.bloc<PrefItemsBloc>(),
        builder: (context, state) {
          final prefItems = state?.items?.where((i) => i.book >= 1 && i.book <= 4)?.toList() ?? [];
          final customColors = [for (final color in prefItems) Color(color.verse)];
          final colors = [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Expanded(child: SelectionSheetModel.noColorButton(context)),
              Expanded(
                  child: SelectionSheetModel.underlineButton(
                      underlineMode: widget.underlineMode,
                      onSwitchToUnderline: widget.onSwitchToUnderline)),
              for (final color in SelectionSheetModel.defaultColors) ...[
                Expanded(
                  child: _ColorPickerButton(
                    isForUnderline: widget.underlineMode,
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
                Expanded(
                  child: SheetButton(
                    text: SelectionSheetModel.medButtons.keys.first,
                    icon: SelectionSheetModel.medButtons.values.first,
                    onPressed: () => SelectionSheetModel.buttonAction(
                        context, SelectionSheetModel.medButtons.keys.first),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectionSheetModel.defineButton(context),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final each in SelectionSheetModel.keyButtons.keys) ...[
                  Expanded(
                    child: SheetButton(
                        text: each,
                        icon: SelectionSheetModel.keyButtons[each],
                        onPressed: () => SelectionSheetModel.buttonAction(context, each)),
                  ),
                  if (SelectionSheetModel.keyButtons.keys.last != each) const SizedBox(width: 10)
                ]
              ],
            ),
          ];
          final mediumViewChildren = <Widget>[
            if (widget.showColorPicker)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 200,
                      child: ColorPicker(
                          showColorContainer: false,
                          color: Color(prefItems[_colorIndex]?.verse ?? _colorChosen),
                          onColorChanged: (c) {
                            context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                                type: widget.underlineMode
                                    ? HighlightType.underline
                                    : HighlightType.highlight,
                                isTrialMode: true,
                                color: c.value));
                            _setColor(c.value);
                          }),
                    ),
                  ),
                  const VerticalDivider(),
                  Column(
                    children: [
                      GreyCircleButton(
                          icon: Icons.close,
                          onPressed: () {
                            context.bloc<SelectionStyleBloc>()?.add(
                                const SelectionStyle(type: HighlightType.clear, isTrialMode: true));
                          }),
                      const Divider(color: Colors.transparent),
                      GreyCircleButton(
                        icon: Icons.done,
                        onPressed: () {
                          context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                              type: widget.underlineMode
                                  ? HighlightType.underline
                                  : HighlightType.highlight,
                              color: _colorChosen));
                          context.bloc<PrefItemsBloc>()?.add(PrefItemEvent.update(
                              prefItem: PrefItem.from(
                                  prefItems[_colorIndex].copyWith(verse: _colorChosen))));
                          widget.onShowColorPicker();
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
                  if (tec.isNotNullOrEmpty(customColors))
                    for (var i = 0; i < 4; i++) ...[
                      Expanded(
                        child: _ColorPickerButton(
                          isForUnderline: widget.underlineMode,
                          editMode: _editMode || customColors[i] == unsetHighlightColor,
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
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 10,
            children: [
              ...mediumViewChildren,
              if (widget.isMediumView && !widget.showColorPicker) ...sheetButtons
            ],
          );
        });
  }
}

class _MiniView extends StatelessWidget {
  final bool underlineMode;
  final VoidCallback onSwitchToUnderline;
  const _MiniView({@required this.underlineMode, @required this.onSwitchToUnderline});
  @override
  Widget build(BuildContext context) {
    final smallScreen = MediaQuery.of(context).size.width < 350;
    final miniViewColors =
        smallScreen ? SelectionSheetModel.defaultColors.take(2) : SelectionSheetModel.defaultColors;

    final miniChildren = [
      SelectionSheetModel.noColorButton(context),
      SelectionSheetModel.underlineButton(
          underlineMode: underlineMode, onSwitchToUnderline: onSwitchToUnderline),
      for (final color in miniViewColors) ...[
        _ColorPickerButton(
          isForUnderline: underlineMode,
          color: color,
        ),
      ],
      for (final button in SelectionSheetModel.keyButtons.keys) ...[
        GreyCircleButton(
          icon: SelectionSheetModel.keyButtons[button],
          onPressed: () => SelectionSheetModel.buttonAction(context, button),
        ),
      ],
      SelectionSheetModel.expandButton(context),
    ];
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final child in miniChildren)
            Expanded(
              child: child,
            )
        ]);
  }
}

class _ColorPickerButton extends StatelessWidget {
  final bool isForUnderline;
  final Color color;
  final bool editMode;
  final VoidCallback onEdit;

  const _ColorPickerButton(
      {@required this.color, this.isForUnderline = false, this.editMode = false, this.onEdit})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    const width = 15.0;

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        if (editMode) {
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
          if (editMode)
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
