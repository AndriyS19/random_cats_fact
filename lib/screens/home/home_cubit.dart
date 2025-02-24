import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:random_cat_facts/api/cat_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial()) {
    loadRandomCatData();
  }

  final CatService _catService = CatService();

  Future<void> loadRandomCatData() async {
    emit(HomeLoading());
    try {
      final data = await _catService.getRandomCatData();
      emit(HomeLoaded(
        fact: data['fact'] as String,
        imageUrl: data['imageUrl'] as String,
      ));
    } catch (e) {
      log(e.toString());
      emit(HomeError(e.toString()));
    }
  }
}
