// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Habit {

 String get id; bool get isActive; String get name; String? get description; String get interval; bool get wasNotificated; DateTime get createdAt; DateTime get updatedAt; List<DateTime> get completedDates; String get userId;
/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitCopyWith<Habit> get copyWith => _$HabitCopyWithImpl<Habit>(this as Habit, _$identity);

  /// Serializes this Habit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.wasNotificated, wasNotificated) || other.wasNotificated == wasNotificated)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.completedDates, completedDates)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isActive,name,description,interval,wasNotificated,createdAt,updatedAt,const DeepCollectionEquality().hash(completedDates),userId);

@override
String toString() {
  return 'Habit(id: $id, isActive: $isActive, name: $name, description: $description, interval: $interval, wasNotificated: $wasNotificated, createdAt: $createdAt, updatedAt: $updatedAt, completedDates: $completedDates, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $HabitCopyWith<$Res>  {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) _then) = _$HabitCopyWithImpl;
@useResult
$Res call({
 String id, bool isActive, String name, String? description, String interval, bool wasNotificated, DateTime createdAt, DateTime updatedAt, List<DateTime> completedDates, String userId
});




}
/// @nodoc
class _$HabitCopyWithImpl<$Res>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._self, this._then);

  final Habit _self;
  final $Res Function(Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isActive = null,Object? name = null,Object? description = freezed,Object? interval = null,Object? wasNotificated = null,Object? createdAt = null,Object? updatedAt = null,Object? completedDates = null,Object? userId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String,wasNotificated: null == wasNotificated ? _self.wasNotificated : wasNotificated // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedDates: null == completedDates ? _self.completedDates : completedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Habit].
extension HabitPatterns on Habit {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Habit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Habit value)  $default,){
final _that = this;
switch (_that) {
case _Habit():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Habit value)?  $default,){
final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isActive,  String name,  String? description,  String interval,  bool wasNotificated,  DateTime createdAt,  DateTime updatedAt,  List<DateTime> completedDates,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.isActive,_that.name,_that.description,_that.interval,_that.wasNotificated,_that.createdAt,_that.updatedAt,_that.completedDates,_that.userId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isActive,  String name,  String? description,  String interval,  bool wasNotificated,  DateTime createdAt,  DateTime updatedAt,  List<DateTime> completedDates,  String userId)  $default,) {final _that = this;
switch (_that) {
case _Habit():
return $default(_that.id,_that.isActive,_that.name,_that.description,_that.interval,_that.wasNotificated,_that.createdAt,_that.updatedAt,_that.completedDates,_that.userId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isActive,  String name,  String? description,  String interval,  bool wasNotificated,  DateTime createdAt,  DateTime updatedAt,  List<DateTime> completedDates,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _Habit() when $default != null:
return $default(_that.id,_that.isActive,_that.name,_that.description,_that.interval,_that.wasNotificated,_that.createdAt,_that.updatedAt,_that.completedDates,_that.userId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Habit extends Habit {
  const _Habit({required this.id, this.isActive = true, required this.name, this.description, this.interval = 'daily', this.wasNotificated = false, required this.createdAt, required this.updatedAt, final  List<DateTime> completedDates = const [], required this.userId}): _completedDates = completedDates,super._();
  factory _Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);

@override final  String id;
@override@JsonKey() final  bool isActive;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  String interval;
@override@JsonKey() final  bool wasNotificated;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<DateTime> _completedDates;
@override@JsonKey() List<DateTime> get completedDates {
  if (_completedDates is EqualUnmodifiableListView) return _completedDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedDates);
}

@override final  String userId;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitCopyWith<_Habit> get copyWith => __$HabitCopyWithImpl<_Habit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HabitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Habit&&(identical(other.id, id) || other.id == id)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.wasNotificated, wasNotificated) || other.wasNotificated == wasNotificated)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._completedDates, _completedDates)&&(identical(other.userId, userId) || other.userId == userId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isActive,name,description,interval,wasNotificated,createdAt,updatedAt,const DeepCollectionEquality().hash(_completedDates),userId);

@override
String toString() {
  return 'Habit(id: $id, isActive: $isActive, name: $name, description: $description, interval: $interval, wasNotificated: $wasNotificated, createdAt: $createdAt, updatedAt: $updatedAt, completedDates: $completedDates, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$HabitCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$HabitCopyWith(_Habit value, $Res Function(_Habit) _then) = __$HabitCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isActive, String name, String? description, String interval, bool wasNotificated, DateTime createdAt, DateTime updatedAt, List<DateTime> completedDates, String userId
});




}
/// @nodoc
class __$HabitCopyWithImpl<$Res>
    implements _$HabitCopyWith<$Res> {
  __$HabitCopyWithImpl(this._self, this._then);

  final _Habit _self;
  final $Res Function(_Habit) _then;

/// Create a copy of Habit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isActive = null,Object? name = null,Object? description = freezed,Object? interval = null,Object? wasNotificated = null,Object? createdAt = null,Object? updatedAt = null,Object? completedDates = null,Object? userId = null,}) {
  return _then(_Habit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String,wasNotificated: null == wasNotificated ? _self.wasNotificated : wasNotificated // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedDates: null == completedDates ? _self._completedDates : completedDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
