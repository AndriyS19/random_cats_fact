import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_cat_facts/model/cat_fact_model.dart';

import 'package:random_cat_facts/utils/db_helper.dart';

part 'favorite_state.dart';

class FavoriteFactsCubit extends Cubit<FavoriteFactsState> {
  FavoriteFactsCubit() : super(SavedFactsInitial()) {
    loadSavedFacts();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> loadSavedFacts() async {
    emit(SavedFactsLoading());
    try {
      final facts = await _dbHelper.getSavedCatFacts();
      if (facts.isEmpty) {
        emit(const SavedFactsEmpty());
      } else {
        emit(SavedFactsLoaded(facts: facts));
      }
    } catch (e) {
      log(e.toString());
      emit(SavedFactsError(e.toString()));
    }
  }

  Future<void> deleteFact(int id) async {
    try {
      await _dbHelper.deleteCatFact(id);
      await loadSavedFacts();
    } catch (e) {
      log(e.toString());
      emit(SavedFactsError(e.toString()));
    }
  }
}
