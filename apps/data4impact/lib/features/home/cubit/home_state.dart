import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String welcomeMessage;
  final int counter;
  final List<String> items;

  const HomeLoaded({
    this.welcomeMessage = 'Welcome!',
    this.counter = 0,
    this.items = const [],
  });

  @override
  List<Object> get props => [welcomeMessage, counter, items];

  HomeLoaded copyWith({
    String? welcomeMessage,
    int? counter,
    List<String>? items,
  }) {
    return HomeLoaded(
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      counter: counter ?? this.counter,
      items: items ?? this.items,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}