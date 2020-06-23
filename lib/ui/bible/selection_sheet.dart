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
        child: Column(
          children: [
            const Divider(
              color: Colors.transparent,
            ),
            Container(
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
            const Divider(
              color: Colors.transparent,
            ),
            Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final each in buttons.keys) ...[
                      Expanded(
                        child: ButtonTheme(
                          height: 50,
                          child: OutlineButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              label: Text(each),
                              icon: Icon(
                                buttons[each],
                                size: 18,
                              ),
                              onPressed: () {}),
                        ),
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
                  return InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context
                          .bloc<SelectionBloc>()
                          ?.add(const SelectionEvent.highlight(
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
                } else if (i == colors.length + 1) {
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
                i--;
                return InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => context.bloc<SelectionBloc>()?.add(
                      SelectionEvent.highlight(
                          type: HighlightType.highlight,
                          color: colors[i].value)),
                  child: CircleAvatar(
                    backgroundColor: colors[i],
                  ),
                );
              },
              separatorBuilder: (c, i) => const VerticalDivider(
                color: Colors.transparent,
              ),
            ))
          ],
        ),
      ),
    );
  }
}
