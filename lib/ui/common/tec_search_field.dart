import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TecSearchField extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String) onSubmit;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Widget suffixIcon;
  final EdgeInsets padding;

  const TecSearchField({
    Key key,
    this.onSubmit,
    this.textEditingController,
    this.focusNode,
    this.suffixIcon,
    this.padding,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height + 12.0);

  @override
  _TecSearchFieldState createState() => _TecSearchFieldState();
}

class _TecSearchFieldState extends State<TecSearchField> {
  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ?? const EdgeInsets.all(8);
    return Container(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black38
                      : Colors.black12,
                  offset: const Offset(0, 2),
                  blurRadius: 2,
                  spreadRadius: 1),
            ]),
        child: Stack(
          children: <Widget>[
            TextField(
              focusNode: widget.focusNode,
              autocorrect: false,
              controller: widget.textEditingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.textEditingController.text.isNotEmpty
                    ? IconButton(
                        splashColor: Colors.transparent,
                        icon: const Icon(CupertinoIcons.clear_circled),
                        onPressed: () => widget.textEditingController.clear(),
                      )
                    : null,
              ),
            ),
            if (widget.textEditingController.text.isEmpty && widget.suffixIcon != null)
              Positioned(right: 0, child: widget.suffixIcon),
          ],
        ),
      ),
    );
  }
}
