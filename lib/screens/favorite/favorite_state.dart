part of 'favorite_cubit.dart';

abstract class FavoriteFactsState extends Equatable {
  const FavoriteFactsState();

  @override
  List<Object?> get props => [];
}

class SavedFactsInitial extends FavoriteFactsState {}

class SavedFactsLoading extends FavoriteFactsState {}

class SavedFactsLoaded extends FavoriteFactsState {
  final List<CatFactModel> facts;

  const SavedFactsLoaded({required this.facts});

  @override
  List<Object?> get props => [facts];
}

class SavedFactsEmpty extends FavoriteFactsState {
  const SavedFactsEmpty();
}

class SavedFactsError extends FavoriteFactsState {
  final String message;

  const SavedFactsError(this.message);

  @override
  List<Object?> get props => [message];
}
