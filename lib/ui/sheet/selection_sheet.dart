import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    Widget child() {
      if (widget.sheetSize == SheetSize.mini) {
        return _MiniView();
      } else if (widget.sheetSize == SheetSize.medium) {
        return _MediumFullSheetItems(
          isMediumView: true,
          showColorPicker: showColorPicker,
          onShowColorPicker: onShowColorPicker,
          onSwitchToUnderline: onSwitchToUnderline,
          underlineMode: underlineMode,
        );
      }
      return Container();
    }

    return Padding(padding: const EdgeInsets.only(left: 15, right: 15), child: child());

    // Column(children: [

    //     ] else if (widget.sheetSize == SheetSize.full) ...[
    //       _MediumFullSheetItems(
    //         isMediumView: false,
    //         showColorPicker: showColorPicker,
    //         onShowColorPicker: onShowColorPicker,
    //         onSwitchToUnderline: onSwitchToUnderline,
    //         underlineMode: underlineMode,
    //       ),
    //       const Divider(color: Colors.transparent),
    //       Expanded(
    //         child: GridView.count(
    //             crossAxisCount: 4,
    //             padding: const EdgeInsets.only(top: 0),
    //             children: [
    //               for (final each in SelectionSheetModel.buttons.keys) ...[
    //                 GreyCircleButton(
    //                   icon: SelectionSheetModel.buttons[each],
    //                   onPressed: () {},
    //                   title: each,
    //                 ),
    //               ],
    //             ]),
    //       ),
    //     ]
    //   ]),
    // );
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
        cubit: context.bloc<PrefItemsBloc>(),
        builder: (context, state) {
          final prefItems = state?.items?.where((i) => i.book >= 1 && i.book <= 4)?.toList() ?? [];
          final customColors = [for (final color in prefItems) Color(color.verse)];
          final colors = [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (final color in SelectionSheetModel.defaultColors) ...[
                Expanded(
                  child: _ColorPickerButton(
                    color: color,
                  ),
                ),
              ],
              if (tec.isNotNullOrEmpty(customColors))
                for (var i = 0; i < 4; i++) ...[
                  Expanded(
                    child: _ColorPickerButton(
                      editMode: _editMode || customColors[i] == unsetHighlightColor,
                      onEdit: () => _onEditColor(i),
                      color: customColors[i],
                    ),
                  ),
                ],
              Expanded(
                child: IconButton(
                  icon: Icon(_editMode ? Icons.close : Icons.colorize),
                  onPressed: _onEditColors,
                ),
              ),
            ]),
          ];

          final sheetButtons = [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListTile(
                  dense: true,
                  title: Text(SelectionSheetModel.buttons.keys.first),
                  leading: Icon(SelectionSheetModel.buttons.values.first),
                  subtitle: Text(
                      SelectionSheetModel.buttonSubtitles[SelectionSheetModel.buttons.keys.first]),
                  onTap: () => SelectionSheetModel.buttonAction(
                      context, SelectionSheetModel.buttons.keys.first),
                ),
                SelectionSheetModel.defineButton(context),
                for (final each in SelectionSheetModel.buttons.keys.skip(1)) ...[
                  ListTile(
                      dense: true,
                      title: Text(each),
                      subtitle: Text(SelectionSheetModel.buttonSubtitles[each]),
                      leading: Icon(SelectionSheetModel.buttons[each]),
                      onTap: () => SelectionSheetModel.buttonAction(context, each)),
                  if (SelectionSheetModel.buttons.keys.last != each) const SizedBox(width: 10)
                ]
              ],
            ),
          ];
          final mediumViewChildren = <Widget>[
            if (widget.showColorPicker)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 300,
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
                        SquareSheetButton(
                            icon: Icons.close,
                            onPressed: () {
                              context.bloc<SelectionStyleBloc>()?.add(const SelectionStyle(
                                  type: HighlightType.clear, isTrialMode: true));
                            }),
                        const Divider(color: Colors.transparent),
                        SquareSheetButton(
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
                ),
              )
            else ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final color in SelectionSheetModel.defaultColors) ...[
                        Expanded(
                          child: _ColorPickerButton(
                            isForUnderline: widget.underlineMode,
                            color: color,
                          ),
                        ),
                      ],
                      Expanded(
                        child: SelectionSheetModel.circleUnderlineButton(context,
                            underlineMode: widget.underlineMode,
                            onSwitchToUnderline: widget.onSwitchToUnderline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
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
                        child: CircleButton(
                      icon: Icon(_editMode ? Icons.close : Icons.add, color: Colors.grey, size: 20),
                      onPressed: _onEditColors,
                      color: Colors.transparent,
                      borderColor: Colors.grey.withOpacity(0.5),
                    )),
                  ]),
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
                if (widget.isMediumView && !widget.showColorPicker) ...sheetButtons,
              ]);
        });
  }
}

class _MiniView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final miniChildren = [
      for (final button in SelectionSheetModel.miniButtons.keys) ...[
        SquareSheetButton(
          icon: SelectionSheetModel.miniButtons[button],
          onPressed: () => SelectionSheetModel.buttonAction(context, button),
          title: button,
        ),
      ],
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final child in miniChildren)
              Expanded(
                child: child,
              ),
          ]),
    );
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
    const width = 20.0;

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
            const Icon(
              Icons.colorize,
              color: Colors.white,
              size: width,
            ),
        ],
      ),
    );
  }
}

class CircleButton extends StatelessWidget {
  final Icon icon;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final void Function() onPressed;

  const CircleButton({
    Key key,
    @required this.icon,
    this.padding = const EdgeInsets.all(15.0),
    this.color,
    this.borderColor,
    this.onPressed,
  })  : assert(icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        type: MaterialType.button,
        shape: CircleBorder(side: BorderSide(color: borderColor, width: 3)),
        color: color ?? Theme.of(context).buttonColor,
        child: InkWell(
          splashColor: Theme.of(context).splashColor,
          child: Padding(
            padding: padding,
            child: icon,
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}
