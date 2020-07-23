import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/notes/note_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/common.dart';
import 'note_view.dart';

const notesViewTypeName = 'NotesView';

Widget notesViewBuilder(BuildContext context, ViewState viewState, Size size) =>
    NotesView(viewState: viewState);

class NotesView extends StatelessWidget {
  final ViewState viewState;

  const NotesView({Key key, this.viewState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: NoteManagerBloc.shared,
      child: _NotesScreen(),
    );
  }
}

class _NotesScreen extends StatefulWidget {
  @override
  __NotesScreenState createState() => __NotesScreenState();
}

class __NotesScreenState extends State<_NotesScreen> {
  NoteManagerBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.bloc<NoteManagerBloc>()..load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteManagerBloc, NoteManagerState>(
        bloc: bloc,
        builder: (context, state) {
          final notes = state.notes;
          return ListView.separated(
              itemCount: notes.length + 1,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (c, i) {
                if (i == 0) {
                  return ListTile(
                    title: const Text('Add Note'),
                    leading: const Icon(Icons.add),
                    onTap: () => Navigator.of(context).push(
                      TecPageRoute<NoteView>(
                        builder: (c) => noteViewBuilder(c, notes.length),
                      ),
                    ),
                  );
                }
                i--;
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (direction) {
                    bloc.remove(i);
                  },
                  child: ListTile(
                    // first line of note is made to be the title
                    title: Text(notes[i].doc.lookupLine(0).node.toPlainText()),
                    onTap: () => Navigator.of(context).push(TecPageRoute<NoteView>(
                      builder: (c) => noteViewBuilder(c, i),
                    )),
                  ),
                );
              });
        });
  }
}
