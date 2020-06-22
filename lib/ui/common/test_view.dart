import 'package:flutter/material.dart';

import 'package:tec_util/tec_util.dart' as tec;

import '../../blocs/view_manager/view_manager_bloc.dart';

const testViewType = 'TestView';

Widget testViewBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    TestView(key: bodyKey, state: state, size: size);

Widget testViewPageableBuilder(BuildContext context, Key bodyKey, ViewState state, Size size) =>
    PageableView(
      key: bodyKey,
      state: state,
      size: size,
      pageBuilder: (context, state, size, index) {
        return (index >= -2 && index <= 2)
            ? TestView(state: state, size: size, pageIndex: index)
            : null;
      },
      onPageChanged: (context, state, page) {
        tec.dmPrint('View ${state.uid} onPageChanged($page)');
      },
    );

class TestView extends StatelessWidget {
  final ViewState state;
  final Size size;
  final int pageIndex;

  const TestView({
    Key key,
    @required this.state,
    @required this.size,
    this.pageIndex,
  }) : super(key: key);

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
          pageIndex == null ? 'Test View ${state.uid}' : 'page $pageIndex',
          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
