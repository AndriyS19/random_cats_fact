part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final CatApiResponse catData;

  const HomeLoaded({required this.catData});

  @override
  List<Object?> get props => [catData.fact, catData.imageUrl];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class FactAlreadySaved extends HomeState {}

class FactSaved extends HomeState {}
