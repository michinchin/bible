import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:zefyr/zefyr.dart';

import '../../blocs/notes/note_bloc.dart';
import '../../blocs/sheet/sheet_manager_bloc.dart';
import '../common/common.dart';
import 'tec_image_delegate.dart';

const noteViewType = 'NoteView';

Widget noteViewBuilder(BuildContext context, int id) => NoteView(id);

class NoteView extends StatelessWidget {
  final int id;
  const NoteView(this.id);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NoteBloc(id),
      child: const _NoteScreen(),
    );
  }
}

class _NoteScreen extends StatefulWidget {
  const _NoteScreen();
  @override
  __NoteScreenState createState() => __NoteScreenState();
}

class __NoteScreenState extends State<_NoteScreen> {
  FocusNode _focusNode;
  ZefyrController _controller;

  NoteBloc bloc() => context.bloc<NoteBloc>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    KeyboardVisibility.onChange.listen(
      (visible) {
        if (visible) {
          context?.bloc<SheetManagerBloc>()?.collapse(context);
        }
      },
    );
    bloc().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, Note>(
        bloc: bloc(),
        builder: (context, state) {
          final doc = state.doc;
          _controller = ZefyrController(doc);
          return Scaffold(
              appBar: MinHeightAppBar(
                appBar: AppBar(
                  title: const Text('Edit Note'),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        bloc().save();
                      },
                    )
                  ],
                ),
              ),
              body: SafeArea(
                child: ZefyrScaffold(
                  child: ZefyrEditor(
                    padding: const EdgeInsets.all(16),
                    controller: _controller,
                    focusNode: _focusNode,
                    imageDelegate: TecImageDelegate(),
                  ),
                ),
              ));
        });
  }
}
