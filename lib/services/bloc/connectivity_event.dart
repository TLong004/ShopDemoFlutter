part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {

  @override
  List<Object> get props => [];
}

final class ConnectivityChanged extends ConnectivityEvent {
  final List<ConnectivityResult> result;
  ConnectivityChanged(this.result);

  @override
  List<Object> get props => [result];
}

