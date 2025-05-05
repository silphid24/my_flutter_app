import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/data/repositories/auth_repository_impl.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final DummyUser user;

  LoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class LoggedOut extends AuthEvent {}

class GoogleLoginRequested extends AuthEvent {}

class EmailLoginRequested extends AuthEvent {
  final String email;
  final String password;

  EmailLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  SignUpRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final DummyUser user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<DummyUser?>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<EmailLoginRequested>(_onEmailLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);

    _authStateSubscription = _authRepository.authStateChanges().listen((user) {
      if (user != null) {
        add(LoggedIn(user));
      } else {
        add(LoggedOut());
      }
    });
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _authRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(Authenticated(event.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('Google 로그인에 실패했습니다. 다시 시도해주세요.'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('오류가 발생했습니다: $e'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onEmailLoginRequested(
    EmailLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'));
        emit(Unauthenticated());
      }
    } catch (e) {
      String errorMessage = '로그인에 실패했습니다.';

      if (e.toString().contains('이메일과 비밀번호를 입력해주세요')) {
        errorMessage = '이메일과 비밀번호를 입력해주세요.';
      } else if (e.toString().contains('사용자가 없습니다')) {
        errorMessage = '해당 이메일로 등록된 사용자가 없습니다.';
      } else if (e.toString().contains('비밀번호가 올바르지 않습니다')) {
        errorMessage = '비밀번호가 올바르지 않습니다.';
      }

      emit(AuthError(errorMessage));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.createUserWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(AuthError('회원가입에 실패했습니다. 다시 시도해주세요.'));
        emit(Unauthenticated());
      }
    } catch (e) {
      String errorMessage = '회원가입에 실패했습니다.';

      if (e.toString().contains('이메일 또는 비밀번호가 올바르지 않습니다')) {
        errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
      } else if (e.toString().contains('이미 등록된 이메일')) {
        errorMessage = '이미 등록된 이메일입니다.';
      }

      emit(AuthError(errorMessage));
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
