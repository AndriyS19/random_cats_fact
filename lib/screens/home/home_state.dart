part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [DateTime.now().toIso8601String()];
}

class HomeLoading extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoaded extends HomeState {
  final String fact;
  final String imageUrl;

  const HomeLoaded({required this.fact, required this.imageUrl});

  @override
  List<Object> get props => [fact, imageUrl];
}

class HomeError extends HomeState {
  final String error;

  const HomeError(this.error);

  @override
  List<Object> get props => [error];
}
