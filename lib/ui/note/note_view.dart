import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';

import '../../blocs/notes/note_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';

const noteViewTypeName = 'NoteView';

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
              appBar: ManagedViewAppBar(
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
                    imageDelegate: NoteImageDelegate(),
                  ),
                ),
              ));
        });
  }
}

class NoteImageDelegate implements ZefyrImageDelegate<ImageSource> {
  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;

  @override
  Future<String> pickImage(ImageSource source) async {
    final file = await ImagePicker().getImage(source: source);
    if (file == null) return null;
    return file.path;
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    final file = File.fromUri(Uri.parse(key));

    /// Create standard [FileImage] provider. If [key] was an HTTP link
    /// we could use [NetworkImage] instead.
    final image = FileImage(file);
    return Image(image: image);
  }
}
