import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Represent single user
@freezed
sealed class User with _$User {
  const factory({
    /// User' unique ID
    required String id,

    /// User' name
    required String name,

    /// User' email
    String? email,

    /// Photo url
    String? photoUrl,
  }) = _User;
}
