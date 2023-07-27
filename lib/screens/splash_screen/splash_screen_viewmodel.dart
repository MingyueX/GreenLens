import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreenViewModel extends Cubit<SplashScreenState> {
  SplashScreenViewModel() : super(InitialState());

  // TODO: implement loadData
  loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    emit(DataLoading());
    try {
      await Future.delayed(const Duration(seconds: 5));
      emit(DataLoaded());
    } catch (e) {
      emit(DataError(e as Exception));
    }
  }
}

abstract class SplashScreenState {}

class InitialState extends SplashScreenState {}

class DataLoading extends SplashScreenState {}

class DataError extends SplashScreenState {
  final Exception settingsError;

  DataError(this.settingsError);
}

class DataLoaded extends SplashScreenState {}