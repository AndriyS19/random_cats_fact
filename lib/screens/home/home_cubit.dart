import 'dart:io';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:random_cat_facts/api/cat_service.dart';
import 'package:random_cat_facts/model/cat_fact_model.dart';
import 'package:random_cat_facts/utils/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial()) {
    loadRandomCatData();
  }

  final CatService _catService = CatService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Cache for the current image file
  File? _currentCachedImageFile;

  bool _isCurrentFactSaved = false;
  bool get isCurrentFactSaved => _isCurrentFactSaved;

  Future<void> loadRandomCatData() async {
    if (isClosed) return;
    emit(HomeLoading());

    try {
      await _deleteCachedImage();

      _isCurrentFactSaved = false;

      if (isClosed) return;
      final data = await _catService.getRandomCatData();

      if (isClosed) return;
      _currentCachedImageFile = await _downloadAndCacheImage(data.imageUrl);

      if (isClosed) return;
      emit(HomeLoaded(catData: data));
    } catch (e) {
      log(e.toString());
      if (!isClosed) emit(HomeError(e.toString()));
    }
  }

  Future<bool> isFactAlreadySaved(String factText) async {
    final existingFact = await _dbHelper.getCatFactByText(factText);
    return existingFact != null;
  }

  Future<void> saveCatFact(CatApiResponse catData) async {
    try {
      final existingFact = await _dbHelper.getCatFactByText(catData.fact);
      if (existingFact != null) {
        emit(FactAlreadySaved());
        if (!isClosed) emit(HomeLoaded(catData: catData));
        return;
      }

      if (_currentCachedImageFile == null || !await _currentCachedImageFile!.exists()) {
        throw Exception('No cached image available');
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'cat_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final permanentPath = path.join(directory.path, fileName);

      final permanentFile = await _currentCachedImageFile!.copy(permanentPath);

      log('Image saved permanently: ${permanentFile.path}');

      final catFact = CatFactModel(
        fact: catData.fact,
        imageUrl: permanentFile.path,
        savedAt: DateTime.now().toIso8601String(),
      );

      await _dbHelper.saveCatFact(catFact);

      _isCurrentFactSaved = true;

      emit(FactSaved());
      if (!isClosed) emit(HomeLoaded(catData: catData));
    } catch (e) {
      log('Error saving fact: $e');
      if (!isClosed) emit(HomeError('Failed to save fact: $e'));
    }
  }

  Future<File?> _downloadAndCacheImage(String imageUrl) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'temp_cat_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = path.join(directory.path, fileName);

      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Accept': 'image/*',
        },
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes, flush: true);
        log('Image cached successfully: ${file.path}, size: ${response.bodyBytes.length} bytes');
        return file;
      } else {
        log('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      log('Error downloading image: $e');
    }
    return null;
  }

  Future<void> _deleteCachedImage() async {
    try {
      if (_currentCachedImageFile != null && await _currentCachedImageFile!.exists()) {
        await _currentCachedImageFile!.delete();
        log('Deleted cached image');
      }
      _currentCachedImageFile = null;
    } catch (e) {
      log('Error deleting cached image: $e');
    }
  }

  String? get currentCachedImagePath => _currentCachedImageFile?.path;

  @override
  Future<void> close() {
    _deleteCachedImage();
    return super.close();
  }
}
