part of 'wallets_bloc.dart';

/// Events for [WalletsBloc]
@freezed
sealed class WalletsEvent with _$WalletsEvent {
  /// Event to loading wallets
  const factory WalletsEvent.load() = _Load;

  /// event to search for wallets
  ///
  /// It uses debounce transformer to prevent rapid calls
  const factory WalletsEvent.search({String? query}) = _Search;

  /// Event to delete [wallet]
  const factory WalletsEvent.delete(Wallet wallet) = _Delete;

  /// Event to update [wallet] based on provided arguments
  const factory WalletsEvent.update(
    Wallet wallet, {
    String? name,
  }) = _Update;
}
