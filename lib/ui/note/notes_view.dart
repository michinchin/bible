import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/notes/note_bloc.dart';
import '../../blocs/view_manager/view_manager_bloc.dart';
import '../common/common.dart';
import '../menu/view_actions.dart';
import 'note_view.dart';

class ViewableNotes extends Viewable {
  ViewableNotes(String typeName, IconData icon) : super(typeName, icon);

  @override
  Widget builder(BuildContext context, ViewState state, Size size) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MinHeightAppBar(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: defaultActionsBuilder(context, state, size),
        ),
      ),
      body: notesViewBuilder(context, state, size),
    );
  }

  @override
  String menuTitle({BuildContext context, ViewState state}) => 'Notes';

  @override
  Future<ViewData> dataForNewView({BuildContext context, int currentViewId}) =>
      Future.value(const ViewData());
}

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
        cubit: bloc,
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
