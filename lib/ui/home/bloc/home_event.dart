part of 'home_bloc.dart';

/// Events for [HomeBloc]
@freezed
class HomeEvent with _$HomeEvent {
  /// Event to trigger subscriptions to all data required by [HomeBloc]
  const factory HomeEvent.subscriptionsRequested() = _SubscriptionsRequested;
}
