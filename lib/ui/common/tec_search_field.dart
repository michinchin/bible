import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TecSearchField extends StatefulWidget {
  final void Function(String) onSubmit;
  final TextEditingController textEditingController;
  final Widget suffixIcon;

  const TecSearchField({
    Key key,
    this.onSubmit,
    this.textEditingController,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _TecSearchFieldState createState() => _TecSearchFieldState();
}

class _TecSearchFieldState extends State<TecSearchField> {
  List<BoxShadow> shadow = const [
    BoxShadow(color: Color(0xffcccccc), offset: Offset(0, 2), blurRadius: 2, spreadRadius: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: AppBar().preferredSize,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
              boxShadow: shadow),
          child: Center(
            child: Stack(
              children: <Widget>[
                TextField(
                  autocorrect: false,
                  controller: widget.textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
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
        ),
      ),
    );
  }
}
