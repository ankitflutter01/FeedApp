abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpUpdate extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String message;
  SignUpSuccess(this.message);

  List<Object?> get props => [message];
}

class SignUpFailure extends SignUpState {
  final String error;
  SignUpFailure(this.error);

  List<Object?> get props => [error];
}
