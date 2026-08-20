part of 'wallets_bloc.dart';

/// Events for [WalletsBloc]
@freezed
sealed class WalletsEvent with _$WalletsEvent {
  /// Event to loading wallet accounts
  const factory WalletsEvent.load() = _Load;

  /// event to search for wallet accounts
  ///
  /// It uses debounce transformer to prevent rapid calls
  const factory WalletsEvent.search({String? query}) = _Search;

  /// Event to delete [account]
  const factory WalletsEvent.delete(Account account) = _Delete;

  /// Event to update [account] based on provided arguments
  const factory WalletsEvent.update(
    Account account, {
    String? name,
  }) = _Update;
}
