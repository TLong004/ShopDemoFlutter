part of 'connectivity_bloc.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;
  const ConnectivityState(this.status);

  @override
  List<Object> get props => [status];
}