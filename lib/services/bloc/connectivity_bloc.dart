import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  Connectivity _connectivity = Connectivity();
  StreamSubscription? _streamSubscription;
  ConnectivityBloc() : super(const ConnectivityState(ConnectivityStatus.connected)) {
    on<ConnectivityChanged>((event, emit) {
      if (event.result.contains(ConnectivityResult.none)){
        if (state.status != ConnectivityStatus.disconnected) { // Chỉ emit nếu trạng thái thực sự thay đổi
          print('DEBUG: ConnectivityBloc emitting Disconnected state.');
          emit(const ConnectivityState(ConnectivityStatus.disconnected));
        }
      } else {
        if (state.status != ConnectivityStatus.connected) { // Chỉ emit nếu trạng thái thực sự thay đổi
          print('DEBUG: ConnectivityBloc emitting Connected state.');
          emit(const ConnectivityState(ConnectivityStatus.connected));
        }
      }
    });
    _streamSubscription = _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result));
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
