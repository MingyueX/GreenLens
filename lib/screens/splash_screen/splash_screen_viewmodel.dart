import 'package:chaquopy/chaquopy.dart';
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
      await loadModel();
      final prefs = await SharedPreferences.getInstance();
      final participantID = prefs.getInt("lastFarmer");
      await Future.delayed(const Duration(seconds: 5));
      if (participantID != null) {
        final farmer = await dbService.searchFarmer(participantID);
        if (farmer == null) {
          prefs.remove("lastFarmer");
          emit(DataLoadedNewUser());
        } else {
          final plots = await dbService.searchPlotByFarmerId(participantID);
          emit(DataLoadedExistUser(farmer: farmer!, plots: plots));
        }
      } else {
        emit(DataLoadedNewUser());
      }
    } on StateError catch (e) {
      print(e);
    } on Exception catch (e) {
      emit(DataError(e as Exception));
    }
  }

  Future<void> loadModel() async {
    const code = '''
import model

model.load_model()
  ''';

    final result = await Chaquopy.executeCode(code);
    print(result);
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
