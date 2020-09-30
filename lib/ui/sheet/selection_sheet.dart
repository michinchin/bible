import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../../models/pref_item.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../misc/color_picker.dart';
import 'main_sheet.dart';
import 'selection_sheet_model.dart';

class SelectionSheet extends StatefulWidget {
  final SheetSize sheetSize;

  // final bool fullyExpanded;
  const SelectionSheet({this.sheetSize, Key key}) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.sheetSize == SheetSize.medium) {
      return Material(child: _MiniView());
    }
    return const MainSheet(sheetSize: SheetSize.mini);

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

class _MiniView extends StatefulWidget {
  @override
  __MiniViewState createState() => __MiniViewState();
}

class __MiniViewState extends State<_MiniView> {
  bool editMode;
  bool underlineMode;

  @override
  void initState() {
    editMode = false;
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
  void _onEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  void _onSwitchToUnderline() {
    setState(() {
      underlineMode = !underlineMode;
    });
  }

  Future<void> onShowColorPicker(
      BuildContext context, List<PrefItem> prefItems, int colorIndex) async {
    final colorChosen = await showModalBottomSheet<int>(
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (c) => BlocProvider.value(
              value: context.bloc<SelectionStyleBloc>(),
              child: _ColorSelectionView(
                prefItems: prefItems,
                colorIndex: colorIndex,
                underlineMode: underlineMode,
              ),
            ));
    if (colorChosen != null) {
      context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
          type: underlineMode ? HighlightType.underline : HighlightType.highlight,
          color: colorChosen));
      context.bloc<PrefItemsBloc>()?.add(PrefItemEvent.update(
          prefItem: PrefItem.from(prefItems.itemWithId(colorIndex).copyWith(verse: colorChosen))));
    } else {
      context
          .bloc<SelectionStyleBloc>()
          ?.add(const SelectionStyle(type: HighlightType.clear, isTrialMode: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final miniChildren = [
      for (final button in SelectionSheetModel.miniButtons.keys) ...[
        SelectionSheetButton(
          icon: SelectionSheetModel.miniButtons[button],
          onPressed: () => SelectionSheetModel.buttonAction(context, button),
          title: button,
        ),
      ],
    ];
    return BlocBuilder<PrefItemsBloc, PrefItems>(
        cubit: context.bloc<PrefItemsBloc>(),
        builder: (context, state) {
          final prefItems = state?.items
                  ?.where(
                      (i) => i.book >= PrefItemId.customColor1 && i.book <= PrefItemId.customColor4)
                  ?.toList() ??
              [];
          final customColors = [for (final color in prefItems) Color(color.verse)];
          final colors = [
            SelectionSheetModel.noColorButton(context),
            SelectionSheetModel.underlineButton(
                underlineMode: underlineMode, onSwitchToUnderline: _onSwitchToUnderline),
            for (final color in SelectionSheetModel.defaultColors) ...[
              _ColorPickerButton(
                isForUnderline: underlineMode,
                color: color,
                onEdit: () => TecToast.show(context, 'Cannot edit default colors'),
              ),
            ],
            if (tec.isNotNullOrEmpty(customColors))
              for (var i = 0; i < customColors.length; i++) ...[
                _ColorPickerButton(
                  editMode: editMode,
                  switchToEditMode: _onEditMode,
                  isForUnderline: underlineMode,
                  color: customColors[i],
                  onEdit: () => onShowColorPicker(context, prefItems, i + 1),
                ),
              ],
            SelectionSheetModel.pickColorButton(editMode: editMode, onEditMode: _onEditMode),
            const SizedBox(width: 5)
          ];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              Container(
                  padding: const EdgeInsets.only(left: 8),
                  height: 40,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    itemBuilder: (c, i) => colors[i],
                    separatorBuilder: (c, i) =>
                        const VerticalDivider(color: Colors.transparent, width: 10),
                  )),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (final child in miniChildren)
                          Expanded(
                            child: child,
                          ),
                        Expanded(
                          child: SelectionSheetModel.defineButton(context),
                        )
                      ])),
            ],
          );
        });
  }
}

class _ColorSelectionView extends StatefulWidget {
  final List<PrefItem> prefItems;
  final int colorIndex;
  final bool underlineMode;
  const _ColorSelectionView({this.prefItems, this.colorIndex, this.underlineMode});

  @override
  __ColorSelectionViewState createState() => __ColorSelectionViewState();
}

class __ColorSelectionViewState extends State<_ColorSelectionView> {
  int colorChosen;
  @override
  void initState() {
    colorChosen = 0xff999999;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        height: 300,
        child: Row(children: [
          Expanded(
            child: ColorPicker(
                showColorContainer: false,
                color: Color(widget.prefItems.itemWithId(widget.colorIndex)?.verse ?? colorChosen),
                onColorChanged: (color) {
                  context.bloc<SelectionStyleBloc>()?.add(SelectionStyle(
                      type:
                          widget.underlineMode ? HighlightType.underline : HighlightType.highlight,
                      isTrialMode: true,
                      color: color.value));
                  colorChosen = color.value;
                }),
          ),
          const VerticalDivider(
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectionSheetButton(
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              const Divider(color: Colors.transparent),
              SelectionSheetButton(
                icon: Icons.done,
                onPressed: () {
                  Navigator.of(context).pop(colorChosen);
                },
              ),
            ],
          )
        ]),
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final bool isForUnderline;
  final Color color;
  final VoidCallback onEdit;
  final bool editMode;
  final VoidCallback switchToEditMode;

  const _ColorPickerButton(
      {@required this.color,
      this.isForUnderline = false,
      @required this.onEdit,
      this.editMode = false,
      this.switchToEditMode})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onLongPress: () {
        if (!editMode && switchToEditMode != null) {
          switchToEditMode();
        }
      },
      onTap: () {
        if (color == unsetHighlightColor || editMode) {
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
            decoration: const ShapeDecoration(shape: CircleBorder()),
            child: CircleAvatar(
              backgroundColor: isForUnderline ? Colors.transparent : color,
              child: isForUnderline
                  ? Container(
                      decoration: ShapeDecoration(
                          color: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      height: 15,
                    )
                  : null,
            ),
          ),
          if (color == unsetHighlightColor || editMode)
            const Icon(
              Icons.colorize,
              color: Colors.white,
              size: 15,
            )
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
    return Material(
      type: MaterialType.button,
      shape: CircleBorder(side: BorderSide(color: borderColor, width: 3)),
      color: color ?? Theme.of(context).buttonColor,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: Theme.of(context).splashColor,
        child: Padding(
          padding: padding,
          child: icon,
        ),
        onTap: onPressed,
      ),
    );
  }
}
