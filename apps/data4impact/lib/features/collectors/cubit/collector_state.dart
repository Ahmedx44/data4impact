import 'package:equatable/equatable.dart';

class CollectorState extends Equatable {
  CollectorState({required this.isLoading});

  final bool isLoading;

  CollectorState copyWith({bool? isLoading}) {
    return CollectorState(isLoading: this.isLoading);
  }

  @override
  List<Object?> get props => [isLoading];
}
