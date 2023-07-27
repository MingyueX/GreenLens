import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlotCollectViewModel extends Cubit<PlotCollectState> {
  PlotCollectViewModel(super.initialState);
}

class PlotCollectState {
  List<Widget> plotCards;
  PlotCollectState(this.plotCards);
}