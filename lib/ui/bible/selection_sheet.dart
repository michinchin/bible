import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/selection/selection_bloc.dart';

class SelectionSheet extends StatelessWidget {
  final colors = [
    Colors.pink,
    Colors.deepOrange,
    Colors.amber,
    Colors.green,
    Colors.cyan,
    Colors.indigo
  ];

  final buttons = <String, IconData>{
    'Copy': Icons.content_copy,
    'Save': Icons.bookmark_border,
    'Margin': Icons.list
  };

  @override
  Widget build(BuildContext context) {
    return _RoundedCornerSheet(
      child: Column(
        children: [
          Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final each in buttons.keys) ...[
                    Expanded(
                      child: _SheetButton(text: each, icon: buttons[each]),
                    ),
                    if (buttons.keys.last != each) const SizedBox(width: 10)
                  ]
                ],
              )),
          const Divider(
            color: Colors.transparent,
          ),
          Expanded(
              child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length + 2,
            itemBuilder: (c, i) {
              if (i == 0) {
                return _ClearHighlightButton(context: context);
              } else if (i == colors.length + 1) {
                return _MoreColorsButton();
              }
              i--;
              return _ColorPickerButton(
                context: context,
                color: colors[i],
              );
            },
            separatorBuilder: (c, i) => const VerticalDivider(
              color: Colors.transparent,
            ),
          ))
        ],
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  final BuildContext context;
  final Color color;
  const _ColorPickerButton({@required this.context, @required this.color})
      : assert(context != null),
        assert(color != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => context.bloc<SelectionBloc>()?.add(SelectionEvent.highlight(
          type: HighlightType.highlight, color: color.value)),
      child: CircleAvatar(
        backgroundColor: color,
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String text;
  final IconData icon;
  const _SheetButton({@required this.text, @required this.icon})
      : assert(text != null),
        assert(icon != null);
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      height: 50,
      child: OutlineButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          label: Text(text),
          icon: Icon(
            icon,
            size: 18,
          ),
          onPressed: () {}),
    );
  }
}

class _ClearHighlightButton extends StatelessWidget {
  final BuildContext context;
  const _ClearHighlightButton({@required this.context})
      : assert(context != null);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        customBorder: const CircleBorder(),
        onTap: () =>
            context.bloc<SelectionBloc>()?.add(const SelectionEvent.highlight(
                  type: HighlightType.clear,
                )),
        child: Container(
          child: const CircleAvatar(
            backgroundColor: Colors.transparent,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 2,
            ),
          ),
        ));
  }
}

class _MoreColorsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Container(
          child: const CircleAvatar(
            child: Icon(
              Icons.add,
              color: Colors.grey,
            ),
            backgroundColor: Colors.transparent,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 2,
            ),
          ),
        ));
  }
}

class _RoundedCornerSheet extends StatelessWidget {
  final Widget child;
  const _RoundedCornerSheet({@required this.child}) : assert(child != null);
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        decoration: ShapeDecoration(
            shadows: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
            color: Theme.of(context).canvasColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)))),
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size.fromHeight(200)),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Container(
                    width: 50,
                    height: 5,
                    decoration: ShapeDecoration(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ),
              ),
              body: SafeArea(child: child)),
        ));
  }
}
