part of 'select_object_bloc.dart';

@immutable
sealed class SelectObjectEvent {}

class SelectObjectInitial extends SelectObjectEvent {}

class SelectObjectSelected extends SelectObjectEvent {
  final String objectName;
  SelectObjectSelected(this.objectName);
}

