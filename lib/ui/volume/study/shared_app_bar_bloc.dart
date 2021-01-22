import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class SharedAppBarBloc extends Cubit<SharedAppBarState> {
  SharedAppBarBloc({SharedAppBarState state}) : super(state ?? const SharedAppBarState(null, null));
  void updateWith({String title, VoidCallback onTapBack}) =>
      emit(SharedAppBarState(title, onTapBack));
  void update(SharedAppBarState newState) => emit(newState ?? const SharedAppBarState(null, null));
}

@immutable
class SharedAppBarState extends Equatable {
  final String title;
  final VoidCallback onTapBack;

  const SharedAppBarState(this.title, this.onTapBack);

  @override
  List<Object> get props => [title, onTapBack];

  @override
  String toString() => '{'
      ' "title": ${jsonEncode(title)},'
      ' "showBackButton": ${onTapBack == null ? 'false' : 'true'}'
      ' }';
}
