import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tec_util/tec_util.dart' as tec;
import 'package:tec_widgets/tec_widgets.dart';

import '../../blocs/highlights/highlights_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';
import '../../blocs/sheet/pref_items_bloc.dart';
import '../../models/app_settings.dart';
import '../../models/color_utils.dart';
import '../../models/pref_item.dart';
import '../../ui/sheet/snap_sheet.dart';
import '../misc/color_picker.dart';
import 'selection_sheet_model.dart';

class SelectionSheet extends StatefulWidget {
  const SelectionSheet({Key key}) : super(key: key);

  @override
  _SelectionSheetState createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<SelectionSheet> with SingleTickerProviderStateMixin {
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
        enableDrag: false,
        barrierColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (c) => BlocProvider.value(
              value: context.tbloc<SelectionCmdBloc>(),
              child: _ColorSelectionView(
                prefItems: prefItems,
                colorIndex: colorIndex,
                underlineMode: underlineMode,
              ),
            ));
    if (colorChosen != null) {
      context.tbloc<SelectionCmdBloc>()?.add(SelectionCmd.setStyle(
          underlineMode ? HighlightType.underline : HighlightType.highlight, colorChosen));
      context.tbloc<PrefItemsBloc>()?.add(PrefItemEvent.update(
          prefItem: PrefItem.from(prefItems.itemWithId(colorIndex).copyWith(verse: colorChosen))));
    } else {
      context.tbloc<SelectionCmdBloc>()?.add(const SelectionCmd.cancelTrial());
    }
  }

  @override
  Widget build(BuildContext context) {
    final miniChildren = [
      for (final button in SelectionSheetModel.miniButtons.keys) ...[
        SheetIconButton(
          icon: SelectionSheetModel.miniButtons[button],
          onPressed: () => SelectionSheetModel.buttonAction(context, button),
          text: button,
        ),
      ],
    ];
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dy > 5) {
          SelectionSheetModel.deselect(context);
        }
      },
      child: BlocBuilder<PrefItemsBloc, PrefItems>(
          cubit: context.tbloc<PrefItemsBloc>(),
          builder: (context, state) {
            final prefItems = state?.items
                    ?.where((i) =>
                        i.book >= PrefItemId.customColor1 && i.book <= PrefItemId.customColor4)
                    ?.toList() ??
                []
              ..sort((i1, i2) => i1.book.compareTo(i2.book));
            final customColors = [for (final color in prefItems) Color(color.verse)];
            final colors = [
              SelectionSheetModel.underlineButton(
                  underlineMode: underlineMode, onSwitchToUnderline: _onSwitchToUnderline),
              SelectionSheetModel.noColorButton(context, forUnderline: underlineMode),
              for (final color in SelectionSheetModel.defaultColors) ...[
                _ColorPickerButton(
                  isForUnderline: underlineMode,
                  color: color,
                  editMode: editMode,
                  defaultColors: true,
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

            final size = MediaQuery.of(context).size;
            final landscapePhone = isSmallScreen(context) && (size.width > size.height);
            var numItems = colors.length;

            if (landscapePhone) {
              numItems += miniChildren.length;
            }

            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: numItems,
                        itemBuilder: (c, i) {
                          if (landscapePhone) {
                            if (i == 0) {
                              return Padding(
                                  padding: const EdgeInsets.only(left: 5), child: miniChildren[i]);
                            }
                            if (i < miniChildren.length) {
                              return miniChildren[i];
                            }
                            return colors[i - miniChildren.length];
                          } else {
                            return colors[i];
                          }
                        },
                        separatorBuilder: (c, i) {
                          // don't put a divider after the last element...
                          if (landscapePhone) {
                            if (i < miniChildren.length - 1) {
                              return const VerticalDivider(color: Colors.transparent, width: 25);
                            }
                            if (i == miniChildren.length - 1) {
                              return VerticalDivider(color: Theme.of(context).appBarTheme.textTheme.headline6.color, width: 40);
                            }
                            if (i < numItems - 2) {
                              return const VerticalDivider(color: Colors.transparent, width: 15);
                            }
                            return Container();
                          } else {
                            return (i < colors.length - 2)
                                ? const VerticalDivider(color: Colors.transparent, width: 15)
                                : Container();
                          }
                        },
                      )),
                  if (!landscapePhone)
                    Padding(
                        // bottom padding is handled by TecScaffoldWrapper
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final child in miniChildren)
                                Expanded(
                                  child: child,
                                ),
                            ])),
                ],
              ),
            );
          }),
    );
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
    context.tbloc<SelectionCmdBloc>()?.add(SelectionCmd.tryStyle(
        widget.underlineMode ? HighlightType.underline : HighlightType.highlight,
        widget.prefItems.itemWithId(widget.colorIndex).verse));
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
                  context.tbloc<SelectionCmdBloc>()?.add(SelectionCmd.tryStyle(
                      widget.underlineMode ? HighlightType.underline : HighlightType.highlight,
                      color.value));
                  colorChosen = color.value;
                }),
          ),
          const VerticalDivider(
            color: Colors.transparent,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectionSheetButton(icon: Icons.close, onPressed: () => Navigator.of(context).pop()),
              const Divider(color: Colors.transparent),
              SelectionSheetButton(
                icon: Icons.done,
                onPressed: () {
                  Navigator.of(context).pop(colorChosen);
                },
              ),
              const Divider(color: Colors.transparent),
              SelectionSheetButton(
                  icon: Icons.info_outline,
                  onPressed: () {
                    tecShowSimpleAlertDialog<void>(
                        context: context, content: 'Colors are slightly adjusted for readability');
                  }),
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
  final bool defaultColors;

  const _ColorPickerButton(
      {@required this.color,
      this.isForUnderline = false,
      @required this.onEdit,
      this.editMode = false,
      this.switchToEditMode,
      this.defaultColors = false})
      : assert(color != null);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final formattedColor =
        isDarkMode ? textColorWith(color, isDarkMode: true) : highlightColorWith(color);
    final borderColor = isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.6);
    return InkWell(
      customBorder: const CircleBorder(),
      onLongPress: () {
        if (!editMode && switchToEditMode != null) {
          switchToEditMode();
        }
      },
      onTap: () {
        if (editMode) {
          onEdit();
        } else {
          context.tbloc<SelectionCmdBloc>()?.add(SelectionCmd.setStyle(
                isForUnderline ? HighlightType.underline : HighlightType.highlight,
                color.value,
              ));
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: isForUnderline
                ? null
                : ShapeDecoration(
                    shape: CircleBorder(side: BorderSide(color: borderColor, width: 1))),
            child: CircleAvatar(
              backgroundColor: isForUnderline ? Colors.transparent : formattedColor,
              child: isForUnderline
                  ? Container(
                      decoration: ShapeDecoration(
                          color: formattedColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: borderColor, width: 1))),
                      height: 15,
                    )
                  : null,
            ),
          ),
          if (editMode && !defaultColors)
            Icon(
              Icons.colorize,
              color: Theme.of(context).cardColor,
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
