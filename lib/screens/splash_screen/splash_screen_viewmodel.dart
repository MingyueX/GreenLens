import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/models.dart';
import '../../services/storage/db_service.dart';

class SplashScreenViewModel extends Cubit<SplashScreenState> {
  SplashScreenViewModel() : super(InitialState());

  final dbService = DatabaseService();

  // TODO: implement loadData
  loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    emit(DataLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      final plots = await dbService.searchPlotByClusterId(1);
      print(plots[0].toString());
      final plots2 = await dbService.searchPlotByFarmerId(1);
      print(plots2[0].toString());
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