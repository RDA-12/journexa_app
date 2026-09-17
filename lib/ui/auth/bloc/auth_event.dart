part of 'auth_bloc.dart';

/// Events for [AuthBloc]
@freezed
class AuthEvent with _$AuthEvent {
  /// Event to trigger subscribing to users changes
  const factory subscriptionRequested() = _SubscriptionRequested;
}
