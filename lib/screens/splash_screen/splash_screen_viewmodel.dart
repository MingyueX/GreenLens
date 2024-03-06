import 'package:chaquopy/chaquopy.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      final participantID = prefs.getInt("lastFarmer");
      await loadModel();
      if (participantID != null) {
        final farmer = await dbService.searchFarmer(participantID);
        if (farmer == null) {
          prefs.remove("lastFarmer");
          emit(DataLoadedNewUser());
        } else {
          final plots = await dbService.searchValidPlotByFarmerId(participantID);
          emit(DataLoadedExistUser(farmer: farmer!, plots: plots));
        }
      } else {
        emit(DataLoadedNewUser());
      }
    } on StateError catch (e) {
      print(e);
    } on Exception catch (e) {
      print(e);
      emit(DataError(e as Exception));
    }
  }

  Future<void> loadModel1() async {
    const code = '''
import improc_all
improc_all.initialize_model()
print("Model loaded")
  ''';

    final result = await Chaquopy.executeCode(code).timeout(const Duration(minutes: 10));
    print(result);
  }

  Future<void> loadModel() async {
    const MethodChannel channel = MethodChannel('com.example.tree/torch_model');
    try {
      await channel.invokeMethod('initialize_model');
      print("Model loaded");
    } on PlatformException catch (e) {
      print(e);
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

class DataLoadedExistUser extends SplashScreenState {
  final Farmer farmer;
  final List<Plot> plots;

  DataLoadedExistUser({required this.farmer, required this.plots});
}

class DataLoadedNewUser extends SplashScreenState {}
