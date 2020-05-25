import 'package:flutter/material.dart';

import '../../blocs/view_manager_bloc.dart';

const testViewType = 'TestView';

Widget testViewBuilder(BuildContext context, ViewState viewState) => TestView(viewState: viewState);

Widget testViewPageableBuilder(BuildContext context, ViewState viewState) => PageableView(
      state: viewState,
      pageBuilder: (context, viewState, index) {
        return (index >= -2 && index <= 2)
            ? TestView(viewState: viewState, pageIndex: index)
            : null;
      },
    );

class TestView extends StatelessWidget {
  final ViewState viewState;
  final int pageIndex;

  const TestView({Key key, @required this.viewState, this.pageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.deepOrange[400],
        borderRadius: const BorderRadius.all(Radius.circular(36)),
        //border: Border.all(),
      ),
      child: Center(
        child: Text(
          pageIndex == null ? 'Test View ${viewState.uid}' : 'page $pageIndex',
          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
