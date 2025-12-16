import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String password,
    @Default(false) bool guestMode,
    required String name,
    @Default(false) bool isSynced,
    required DateTime createdTime,
    required DateTime updatedTime,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
