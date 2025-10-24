import 'package:equatable/equatable.dart';

class InboxState extends Equatable{
  final bool isLoading;

  const InboxState({this.isLoading = false});

  InboxState copyWith({
    bool? isLoading=false,
  }) {
    return InboxState(
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override

  List<Object?> get props => [isLoading];

}