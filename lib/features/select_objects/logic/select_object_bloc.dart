import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'select_object_event.dart';
part 'select_object_state.dart';

class SelectObjectBloc extends Bloc<SelectObjectEvent, SelectObjectState> {
  List objects = [
    {
      "name": "Laptop",
      "icon": "laptop",
      "aspectRatio": 0.8,
      "tags": ["laptop", "computer", "electronic device"]
    },
    {"name": "Bottle", "icon": "bottle", "aspectRatio": 0.4,
    "tags":['tableware']
    },
    {
      "name": "Mobile",
      "icon": "mobile",
      "aspectRatio": 0.6,
    },
    {
      "name": "Mouse",
      "icon": "mouse",
      "aspectRatio": 0.75,
    },
  ];

  SelectObjectBloc() : super(SelectObjectInitialState()) {
    on<SelectObjectEvent>((event, emit) {});
    on<SelectObjectSelected>(_handleSelect);
  }

  FutureOr<void> _handleSelect(event, emit) {
    try {
      if (state is SelectObjectSelectedState) {
        if ((state as SelectObjectSelectedState)
            .objects
            .contains(event.objectName)) {
          emit(SelectObjectSelectedState(
              (state as SelectObjectSelectedState).objects
                ..remove(event.objectName)));
        } else {
          emit(SelectObjectSelectedState([event.objectName]));
        }
      } else {
        emit(SelectObjectSelectedState([event.objectName]));
      }
    } catch (e) {
      rethrow;
    }
  }
}
