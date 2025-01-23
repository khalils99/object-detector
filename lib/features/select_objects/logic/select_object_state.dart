part of 'select_object_bloc.dart';

@immutable
sealed class SelectObjectState {}

final class SelectObjectInitialState extends SelectObjectState {}

final class SelectObjectSelectedState extends SelectObjectState {
  final List<String> objects;
  SelectObjectSelectedState(this.objects);
}
