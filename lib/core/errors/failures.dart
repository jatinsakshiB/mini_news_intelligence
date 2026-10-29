import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message =
        'No internet connection. Please check your network and try again.',
    super.code,
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message =
        'We could not reach the news service right now. Please try again shortly.',
    super.code,
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message =
        'Daily news feed request limit reached. You can still read all your saved offline articles.',
    super.code,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Could not access local storage.',
    super.code,
  });
}

class GeneralFailure extends Failure {
  const GeneralFailure({
    super.message = 'Something went wrong. Please try again.',
    super.code,
  });
}
