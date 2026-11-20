// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Me {

 String get userId; String get role; String get preferredLanguage; String? get advocateCode; String? get advocateName; String? get displayName; String? get email; String? get googleEmail; String? get identityVerification; String? get verificationMethod; String? get linkedAt; String? get mobile; String? get createdAt;
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeCopyWith<Me> get copyWith => _$MeCopyWithImpl<Me>(this as Me, _$identity);

  /// Serializes this Me to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Me;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Me&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.preferredLanguage, _this.preferredLanguage) || other.preferredLanguage == _this.preferredLanguage)&&(identical(other.advocateCode, _this.advocateCode) || other.advocateCode == _this.advocateCode)&&(identical(other.advocateName, _this.advocateName) || other.advocateName == _this.advocateName)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.googleEmail, _this.googleEmail) || other.googleEmail == _this.googleEmail)&&(identical(other.identityVerification, _this.identityVerification) || other.identityVerification == _this.identityVerification)&&(identical(other.verificationMethod, _this.verificationMethod) || other.verificationMethod == _this.verificationMethod)&&(identical(other.linkedAt, _this.linkedAt) || other.linkedAt == _this.linkedAt)&&(identical(other.mobile, _this.mobile) || other.mobile == _this.mobile)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Me;
  return Object.hash(runtimeType,_this.userId,_this.role,_this.preferredLanguage,_this.advocateCode,_this.advocateName,_this.displayName,_this.email,_this.googleEmail,_this.identityVerification,_this.verificationMethod,_this.linkedAt,_this.mobile,_this.createdAt);
}

@override
String toString() {
  final _this = this as Me;
  return 'Me(userId: ${_this.userId}, role: ${_this.role}, preferredLanguage: ${_this.preferredLanguage}, advocateCode: ${_this.advocateCode}, advocateName: ${_this.advocateName}, displayName: ${_this.displayName}, email: ${_this.email}, googleEmail: ${_this.googleEmail}, identityVerification: ${_this.identityVerification}, verificationMethod: ${_this.verificationMethod}, linkedAt: ${_this.linkedAt}, mobile: ${_this.mobile}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MeCopyWith<$Res>  {
  factory $MeCopyWith(Me value, $Res Function(Me) _then) = _$MeCopyWithImpl;
@useResult
$Res call({
 String userId, String role, String preferredLanguage, String? advocateCode, String? advocateName, String? displayName, String? email, String? googleEmail, String? identityVerification, String? verificationMethod, String? linkedAt, String? mobile, String? createdAt
});




}
/// @nodoc
class _$MeCopyWithImpl<$Res>
    implements $MeCopyWith<$Res> {
  _$MeCopyWithImpl(this._self, this._then);

  final Me _self;
  final $Res Function(Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? role = null,Object? preferredLanguage = null,Object? advocateCode = freezed,Object? advocateName = freezed,Object? displayName = freezed,Object? email = freezed,Object? googleEmail = freezed,Object? identityVerification = freezed,Object? verificationMethod = freezed,Object? linkedAt = freezed,Object? mobile = freezed,Object? createdAt = freezed,}) {
  return _then(Me(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,advocateCode: freezed == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String?,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,googleEmail: freezed == googleEmail ? _self.googleEmail : googleEmail // ignore: cast_nullable_to_non_nullable
as String?,identityVerification: freezed == identityVerification ? _self.identityVerification : identityVerification // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,linkedAt: freezed == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Me].
extension MePatterns on Me {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Me value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Me value)  $default,){
final _that = this;
switch (_that) {
case _Me():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Me value)?  $default,){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String role,  String preferredLanguage,  String? advocateCode,  String? advocateName,  String? displayName,  String? email,  String? googleEmail,  String? identityVerification,  String? verificationMethod,  String? linkedAt,  String? mobile,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.userId,_that.role,_that.preferredLanguage,_that.advocateCode,_that.advocateName,_that.displayName,_that.email,_that.googleEmail,_that.identityVerification,_that.verificationMethod,_that.linkedAt,_that.mobile,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String role,  String preferredLanguage,  String? advocateCode,  String? advocateName,  String? displayName,  String? email,  String? googleEmail,  String? identityVerification,  String? verificationMethod,  String? linkedAt,  String? mobile,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Me():
return $default(_that.userId,_that.role,_that.preferredLanguage,_that.advocateCode,_that.advocateName,_that.displayName,_that.email,_that.googleEmail,_that.identityVerification,_that.verificationMethod,_that.linkedAt,_that.mobile,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String role,  String preferredLanguage,  String? advocateCode,  String? advocateName,  String? displayName,  String? email,  String? googleEmail,  String? identityVerification,  String? verificationMethod,  String? linkedAt,  String? mobile,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.userId,_that.role,_that.preferredLanguage,_that.advocateCode,_that.advocateName,_that.displayName,_that.email,_that.googleEmail,_that.identityVerification,_that.verificationMethod,_that.linkedAt,_that.mobile,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Me implements Me {
  const _Me({required this.userId, required this.role, this.preferredLanguage = 'en', this.advocateCode, this.advocateName, this.displayName, this.email, this.googleEmail, this.identityVerification, this.verificationMethod, this.linkedAt, this.mobile, this.createdAt});
  factory _Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

@override final  String userId;
@override final  String role;
@override@JsonKey() final  String preferredLanguage;
@override final  String? advocateCode;
@override final  String? advocateName;
@override final  String? displayName;
@override final  String? email;
@override final  String? googleEmail;
@override final  String? identityVerification;
@override final  String? verificationMethod;
@override final  String? linkedAt;
@override final  String? mobile;
@override final  String? createdAt;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeCopyWith<_Me> get copyWith => __$MeCopyWithImpl<_Me>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Me&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.advocateCode, advocateCode) || other.advocateCode == advocateCode)&&(identical(other.advocateName, advocateName) || other.advocateName == advocateName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.googleEmail, googleEmail) || other.googleEmail == googleEmail)&&(identical(other.identityVerification, identityVerification) || other.identityVerification == identityVerification)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.linkedAt, linkedAt) || other.linkedAt == linkedAt)&&(identical(other.mobile, mobile) || other.mobile == mobile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,role,preferredLanguage,advocateCode,advocateName,displayName,email,googleEmail,identityVerification,verificationMethod,linkedAt,mobile,createdAt);
}

@override
String toString() {
    return 'Me(userId: $userId, role: $role, preferredLanguage: $preferredLanguage, advocateCode: $advocateCode, advocateName: $advocateName, displayName: $displayName, email: $email, googleEmail: $googleEmail, identityVerification: $identityVerification, verificationMethod: $verificationMethod, linkedAt: $linkedAt, mobile: $mobile, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MeCopyWith<$Res> implements $MeCopyWith<$Res> {
  factory _$MeCopyWith(_Me value, $Res Function(_Me) _then) = __$MeCopyWithImpl;
@override @useResult
$Res call({
 String userId, String role, String preferredLanguage, String? advocateCode, String? advocateName, String? displayName, String? email, String? googleEmail, String? identityVerification, String? verificationMethod, String? linkedAt, String? mobile, String? createdAt
});




}
/// @nodoc
class __$MeCopyWithImpl<$Res>
    implements _$MeCopyWith<$Res> {
  __$MeCopyWithImpl(this._self, this._then);

  final _Me _self;
  final $Res Function(_Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? role = null,Object? preferredLanguage = null,Object? advocateCode = freezed,Object? advocateName = freezed,Object? displayName = freezed,Object? email = freezed,Object? googleEmail = freezed,Object? identityVerification = freezed,Object? verificationMethod = freezed,Object? linkedAt = freezed,Object? mobile = freezed,Object? createdAt = freezed,}) {
  return _then(_Me(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,preferredLanguage: null == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String,advocateCode: freezed == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String?,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,googleEmail: freezed == googleEmail ? _self.googleEmail : googleEmail // ignore: cast_nullable_to_non_nullable
as String?,identityVerification: freezed == identityVerification ? _self.identityVerification : identityVerification // ignore: cast_nullable_to_non_nullable
as String?,verificationMethod: freezed == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as String?,linkedAt: freezed == linkedAt ? _self.linkedAt : linkedAt // ignore: cast_nullable_to_non_nullable
as String?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GoogleSignInResult {

 String get status; String? get accessToken; String? get refreshToken; int? get expiresIn; String? get sessionId; String? get linkToken; int? get linkExpiresIn; String? get googleEmail;
/// Create a copy of GoogleSignInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoogleSignInResultCopyWith<GoogleSignInResult> get copyWith => _$GoogleSignInResultCopyWithImpl<GoogleSignInResult>(this as GoogleSignInResult, _$identity);

  /// Serializes this GoogleSignInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoogleSignInResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoogleSignInResult&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.accessToken, _this.accessToken) || other.accessToken == _this.accessToken)&&(identical(other.refreshToken, _this.refreshToken) || other.refreshToken == _this.refreshToken)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn)&&(identical(other.sessionId, _this.sessionId) || other.sessionId == _this.sessionId)&&(identical(other.linkToken, _this.linkToken) || other.linkToken == _this.linkToken)&&(identical(other.linkExpiresIn, _this.linkExpiresIn) || other.linkExpiresIn == _this.linkExpiresIn)&&(identical(other.googleEmail, _this.googleEmail) || other.googleEmail == _this.googleEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoogleSignInResult;
  return Object.hash(runtimeType,_this.status,_this.accessToken,_this.refreshToken,_this.expiresIn,_this.sessionId,_this.linkToken,_this.linkExpiresIn,_this.googleEmail);
}

@override
String toString() {
  final _this = this as GoogleSignInResult;
  return 'GoogleSignInResult(status: ${_this.status}, accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, expiresIn: ${_this.expiresIn}, sessionId: ${_this.sessionId}, linkToken: ${_this.linkToken}, linkExpiresIn: ${_this.linkExpiresIn}, googleEmail: ${_this.googleEmail})';
}


}

/// @nodoc
abstract mixin class $GoogleSignInResultCopyWith<$Res>  {
  factory $GoogleSignInResultCopyWith(GoogleSignInResult value, $Res Function(GoogleSignInResult) _then) = _$GoogleSignInResultCopyWithImpl;
@useResult
$Res call({
 String status, String? accessToken, String? refreshToken, int? expiresIn, String? sessionId, String? linkToken, int? linkExpiresIn, String? googleEmail
});




}
/// @nodoc
class _$GoogleSignInResultCopyWithImpl<$Res>
    implements $GoogleSignInResultCopyWith<$Res> {
  _$GoogleSignInResultCopyWithImpl(this._self, this._then);

  final GoogleSignInResult _self;
  final $Res Function(GoogleSignInResult) _then;

/// Create a copy of GoogleSignInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,Object? sessionId = freezed,Object? linkToken = freezed,Object? linkExpiresIn = freezed,Object? googleEmail = freezed,}) {
  return _then(GoogleSignInResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,linkToken: freezed == linkToken ? _self.linkToken : linkToken // ignore: cast_nullable_to_non_nullable
as String?,linkExpiresIn: freezed == linkExpiresIn ? _self.linkExpiresIn : linkExpiresIn // ignore: cast_nullable_to_non_nullable
as int?,googleEmail: freezed == googleEmail ? _self.googleEmail : googleEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GoogleSignInResult].
extension GoogleSignInResultPatterns on GoogleSignInResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoogleSignInResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoogleSignInResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoogleSignInResult value)  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoogleSignInResult value)?  $default,){
final _that = this;
switch (_that) {
case _GoogleSignInResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? sessionId,  String? linkToken,  int? linkExpiresIn,  String? googleEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoogleSignInResult() when $default != null:
return $default(_that.status,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.sessionId,_that.linkToken,_that.linkExpiresIn,_that.googleEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? sessionId,  String? linkToken,  int? linkExpiresIn,  String? googleEmail)  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInResult():
return $default(_that.status,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.sessionId,_that.linkToken,_that.linkExpiresIn,_that.googleEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? sessionId,  String? linkToken,  int? linkExpiresIn,  String? googleEmail)?  $default,) {final _that = this;
switch (_that) {
case _GoogleSignInResult() when $default != null:
return $default(_that.status,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.sessionId,_that.linkToken,_that.linkExpiresIn,_that.googleEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoogleSignInResult implements GoogleSignInResult {
  const _GoogleSignInResult({required this.status, this.accessToken, this.refreshToken, this.expiresIn, this.sessionId, this.linkToken, this.linkExpiresIn, this.googleEmail});
  factory _GoogleSignInResult.fromJson(Map<String, dynamic> json) => _$GoogleSignInResultFromJson(json);

@override final  String status;
@override final  String? accessToken;
@override final  String? refreshToken;
@override final  int? expiresIn;
@override final  String? sessionId;
@override final  String? linkToken;
@override final  int? linkExpiresIn;
@override final  String? googleEmail;

/// Create a copy of GoogleSignInResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoogleSignInResultCopyWith<_GoogleSignInResult> get copyWith => __$GoogleSignInResultCopyWithImpl<_GoogleSignInResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoogleSignInResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoogleSignInResult&&(identical(other.status, status) || other.status == status)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.linkToken, linkToken) || other.linkToken == linkToken)&&(identical(other.linkExpiresIn, linkExpiresIn) || other.linkExpiresIn == linkExpiresIn)&&(identical(other.googleEmail, googleEmail) || other.googleEmail == googleEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,accessToken,refreshToken,expiresIn,sessionId,linkToken,linkExpiresIn,googleEmail);
}

@override
String toString() {
    return 'GoogleSignInResult(status: $status, accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, sessionId: $sessionId, linkToken: $linkToken, linkExpiresIn: $linkExpiresIn, googleEmail: $googleEmail)';
}


}

/// @nodoc
abstract mixin class _$GoogleSignInResultCopyWith<$Res> implements $GoogleSignInResultCopyWith<$Res> {
  factory _$GoogleSignInResultCopyWith(_GoogleSignInResult value, $Res Function(_GoogleSignInResult) _then) = __$GoogleSignInResultCopyWithImpl;
@override @useResult
$Res call({
 String status, String? accessToken, String? refreshToken, int? expiresIn, String? sessionId, String? linkToken, int? linkExpiresIn, String? googleEmail
});




}
/// @nodoc
class __$GoogleSignInResultCopyWithImpl<$Res>
    implements _$GoogleSignInResultCopyWith<$Res> {
  __$GoogleSignInResultCopyWithImpl(this._self, this._then);

  final _GoogleSignInResult _self;
  final $Res Function(_GoogleSignInResult) _then;

/// Create a copy of GoogleSignInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,Object? sessionId = freezed,Object? linkToken = freezed,Object? linkExpiresIn = freezed,Object? googleEmail = freezed,}) {
  return _then(_GoogleSignInResult(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,linkToken: freezed == linkToken ? _self.linkToken : linkToken // ignore: cast_nullable_to_non_nullable
as String?,linkExpiresIn: freezed == linkExpiresIn ? _self.linkExpiresIn : linkExpiresIn // ignore: cast_nullable_to_non_nullable
as int?,googleEmail: freezed == googleEmail ? _self.googleEmail : googleEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdvocateListing {

 String get itemNo; String get courtNo; String get listType; String get rawCase; String? get caseNumber; String? get caseId; String? get application; String? get applicationDescription; String? get petitioner; String? get respondent; List<String> get petitionerAdvocates; List<String> get respondentAdvocates; String? get district; String? get stage;
/// Create a copy of AdvocateListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvocateListingCopyWith<AdvocateListing> get copyWith => _$AdvocateListingCopyWithImpl<AdvocateListing>(this as AdvocateListing, _$identity);

  /// Serializes this AdvocateListing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdvocateListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvocateListing&&(identical(other.itemNo, _this.itemNo) || other.itemNo == _this.itemNo)&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.listType, _this.listType) || other.listType == _this.listType)&&(identical(other.rawCase, _this.rawCase) || other.rawCase == _this.rawCase)&&(identical(other.caseNumber, _this.caseNumber) || other.caseNumber == _this.caseNumber)&&(identical(other.caseId, _this.caseId) || other.caseId == _this.caseId)&&(identical(other.application, _this.application) || other.application == _this.application)&&(identical(other.applicationDescription, _this.applicationDescription) || other.applicationDescription == _this.applicationDescription)&&(identical(other.petitioner, _this.petitioner) || other.petitioner == _this.petitioner)&&(identical(other.respondent, _this.respondent) || other.respondent == _this.respondent)&&const DeepCollectionEquality().equals(other.petitionerAdvocates, _this.petitionerAdvocates)&&const DeepCollectionEquality().equals(other.respondentAdvocates, _this.respondentAdvocates)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.stage, _this.stage) || other.stage == _this.stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdvocateListing;
  return Object.hash(runtimeType,_this.itemNo,_this.courtNo,_this.listType,_this.rawCase,_this.caseNumber,_this.caseId,_this.application,_this.applicationDescription,_this.petitioner,_this.respondent,const DeepCollectionEquality().hash(_this.petitionerAdvocates),const DeepCollectionEquality().hash(_this.respondentAdvocates),_this.district,_this.stage);
}

@override
String toString() {
  final _this = this as AdvocateListing;
  return 'AdvocateListing(itemNo: ${_this.itemNo}, courtNo: ${_this.courtNo}, listType: ${_this.listType}, rawCase: ${_this.rawCase}, caseNumber: ${_this.caseNumber}, caseId: ${_this.caseId}, application: ${_this.application}, applicationDescription: ${_this.applicationDescription}, petitioner: ${_this.petitioner}, respondent: ${_this.respondent}, petitionerAdvocates: ${_this.petitionerAdvocates}, respondentAdvocates: ${_this.respondentAdvocates}, district: ${_this.district}, stage: ${_this.stage})';
}


}

/// @nodoc
abstract mixin class $AdvocateListingCopyWith<$Res>  {
  factory $AdvocateListingCopyWith(AdvocateListing value, $Res Function(AdvocateListing) _then) = _$AdvocateListingCopyWithImpl;
@useResult
$Res call({
 String itemNo, String courtNo, String listType, String rawCase, String? caseNumber, String? caseId, String? application, String? applicationDescription, String? petitioner, String? respondent, List<String> petitionerAdvocates, List<String> respondentAdvocates, String? district, String? stage
});




}
/// @nodoc
class _$AdvocateListingCopyWithImpl<$Res>
    implements $AdvocateListingCopyWith<$Res> {
  _$AdvocateListingCopyWithImpl(this._self, this._then);

  final AdvocateListing _self;
  final $Res Function(AdvocateListing) _then;

/// Create a copy of AdvocateListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemNo = null,Object? courtNo = null,Object? listType = null,Object? rawCase = null,Object? caseNumber = freezed,Object? caseId = freezed,Object? application = freezed,Object? applicationDescription = freezed,Object? petitioner = freezed,Object? respondent = freezed,Object? petitionerAdvocates = null,Object? respondentAdvocates = null,Object? district = freezed,Object? stage = freezed,}) {
  return _then(AdvocateListing(
itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,rawCase: null == rawCase ? _self.rawCase : rawCase // ignore: cast_nullable_to_non_nullable
as String,caseNumber: freezed == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String?,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as String?,applicationDescription: freezed == applicationDescription ? _self.applicationDescription : applicationDescription // ignore: cast_nullable_to_non_nullable
as String?,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,petitionerAdvocates: null == petitionerAdvocates ? _self.petitionerAdvocates : petitionerAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,respondentAdvocates: null == respondentAdvocates ? _self.respondentAdvocates : respondentAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdvocateListing].
extension AdvocateListingPatterns on AdvocateListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvocateListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvocateListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvocateListing value)  $default,){
final _that = this;
switch (_that) {
case _AdvocateListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvocateListing value)?  $default,){
final _that = this;
switch (_that) {
case _AdvocateListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemNo,  String courtNo,  String listType,  String rawCase,  String? caseNumber,  String? caseId,  String? application,  String? applicationDescription,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? stage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvocateListing() when $default != null:
return $default(_that.itemNo,_that.courtNo,_that.listType,_that.rawCase,_that.caseNumber,_that.caseId,_that.application,_that.applicationDescription,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.stage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemNo,  String courtNo,  String listType,  String rawCase,  String? caseNumber,  String? caseId,  String? application,  String? applicationDescription,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? stage)  $default,) {final _that = this;
switch (_that) {
case _AdvocateListing():
return $default(_that.itemNo,_that.courtNo,_that.listType,_that.rawCase,_that.caseNumber,_that.caseId,_that.application,_that.applicationDescription,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.stage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemNo,  String courtNo,  String listType,  String rawCase,  String? caseNumber,  String? caseId,  String? application,  String? applicationDescription,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? stage)?  $default,) {final _that = this;
switch (_that) {
case _AdvocateListing() when $default != null:
return $default(_that.itemNo,_that.courtNo,_that.listType,_that.rawCase,_that.caseNumber,_that.caseId,_that.application,_that.applicationDescription,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.stage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdvocateListing implements AdvocateListing {
  const _AdvocateListing({required this.itemNo, required this.courtNo, required this.listType, required this.rawCase, this.caseNumber, this.caseId, this.application, this.applicationDescription, this.petitioner, this.respondent,  List<String> petitionerAdvocates = const [],  List<String> respondentAdvocates = const [], this.district, this.stage}): _petitionerAdvocates = petitionerAdvocates,_respondentAdvocates = respondentAdvocates;
  factory _AdvocateListing.fromJson(Map<String, dynamic> json) => _$AdvocateListingFromJson(json);

@override final  String itemNo;
@override final  String courtNo;
@override final  String listType;
@override final  String rawCase;
@override final  String? caseNumber;
@override final  String? caseId;
@override final  String? application;
@override final  String? applicationDescription;
@override final  String? petitioner;
@override final  String? respondent;
 final  List<String> _petitionerAdvocates;
@override@JsonKey() List<String> get petitionerAdvocates {
  if (_petitionerAdvocates is EqualUnmodifiableListView) return _petitionerAdvocates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_petitionerAdvocates);
}

 final  List<String> _respondentAdvocates;
@override@JsonKey() List<String> get respondentAdvocates {
  if (_respondentAdvocates is EqualUnmodifiableListView) return _respondentAdvocates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_respondentAdvocates);
}

@override final  String? district;
@override final  String? stage;

/// Create a copy of AdvocateListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvocateListingCopyWith<_AdvocateListing> get copyWith => __$AdvocateListingCopyWithImpl<_AdvocateListing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdvocateListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvocateListing&&(identical(other.itemNo, itemNo) || other.itemNo == itemNo)&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.listType, listType) || other.listType == listType)&&(identical(other.rawCase, rawCase) || other.rawCase == rawCase)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.application, application) || other.application == application)&&(identical(other.applicationDescription, applicationDescription) || other.applicationDescription == applicationDescription)&&(identical(other.petitioner, petitioner) || other.petitioner == petitioner)&&(identical(other.respondent, respondent) || other.respondent == respondent)&&const DeepCollectionEquality().equals(other.petitionerAdvocates, _petitionerAdvocates)&&const DeepCollectionEquality().equals(other.respondentAdvocates, _respondentAdvocates)&&(identical(other.district, district) || other.district == district)&&(identical(other.stage, stage) || other.stage == stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,itemNo,courtNo,listType,rawCase,caseNumber,caseId,application,applicationDescription,petitioner,respondent,const DeepCollectionEquality().hash(_petitionerAdvocates),const DeepCollectionEquality().hash(_respondentAdvocates),district,stage);
}

@override
String toString() {
    return 'AdvocateListing(itemNo: $itemNo, courtNo: $courtNo, listType: $listType, rawCase: $rawCase, caseNumber: $caseNumber, caseId: $caseId, application: $application, applicationDescription: $applicationDescription, petitioner: $petitioner, respondent: $respondent, petitionerAdvocates: $petitionerAdvocates, respondentAdvocates: $respondentAdvocates, district: $district, stage: $stage)';
}


}

/// @nodoc
abstract mixin class _$AdvocateListingCopyWith<$Res> implements $AdvocateListingCopyWith<$Res> {
  factory _$AdvocateListingCopyWith(_AdvocateListing value, $Res Function(_AdvocateListing) _then) = __$AdvocateListingCopyWithImpl;
@override @useResult
$Res call({
 String itemNo, String courtNo, String listType, String rawCase, String? caseNumber, String? caseId, String? application, String? applicationDescription, String? petitioner, String? respondent, List<String> petitionerAdvocates, List<String> respondentAdvocates, String? district, String? stage
});




}
/// @nodoc
class __$AdvocateListingCopyWithImpl<$Res>
    implements _$AdvocateListingCopyWith<$Res> {
  __$AdvocateListingCopyWithImpl(this._self, this._then);

  final _AdvocateListing _self;
  final $Res Function(_AdvocateListing) _then;

/// Create a copy of AdvocateListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemNo = null,Object? courtNo = null,Object? listType = null,Object? rawCase = null,Object? caseNumber = freezed,Object? caseId = freezed,Object? application = freezed,Object? applicationDescription = freezed,Object? petitioner = freezed,Object? respondent = freezed,Object? petitionerAdvocates = null,Object? respondentAdvocates = null,Object? district = freezed,Object? stage = freezed,}) {
  return _then(_AdvocateListing(
itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,rawCase: null == rawCase ? _self.rawCase : rawCase // ignore: cast_nullable_to_non_nullable
as String,caseNumber: freezed == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String?,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as String?,applicationDescription: freezed == applicationDescription ? _self.applicationDescription : applicationDescription // ignore: cast_nullable_to_non_nullable
as String?,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,petitionerAdvocates: null == petitionerAdvocates ? _self._petitionerAdvocates : petitionerAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,respondentAdvocates: null == respondentAdvocates ? _self._respondentAdvocates : respondentAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdvocateCourtGroup {

 String get courtNo; List<AdvocateListing> get cases;
/// Create a copy of AdvocateCourtGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvocateCourtGroupCopyWith<AdvocateCourtGroup> get copyWith => _$AdvocateCourtGroupCopyWithImpl<AdvocateCourtGroup>(this as AdvocateCourtGroup, _$identity);

  /// Serializes this AdvocateCourtGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdvocateCourtGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvocateCourtGroup&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&const DeepCollectionEquality().equals(other.cases, _this.cases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdvocateCourtGroup;
  return Object.hash(runtimeType,_this.courtNo,const DeepCollectionEquality().hash(_this.cases));
}

@override
String toString() {
  final _this = this as AdvocateCourtGroup;
  return 'AdvocateCourtGroup(courtNo: ${_this.courtNo}, cases: ${_this.cases})';
}


}

/// @nodoc
abstract mixin class $AdvocateCourtGroupCopyWith<$Res>  {
  factory $AdvocateCourtGroupCopyWith(AdvocateCourtGroup value, $Res Function(AdvocateCourtGroup) _then) = _$AdvocateCourtGroupCopyWithImpl;
@useResult
$Res call({
 String courtNo, List<AdvocateListing> cases
});




}
/// @nodoc
class _$AdvocateCourtGroupCopyWithImpl<$Res>
    implements $AdvocateCourtGroupCopyWith<$Res> {
  _$AdvocateCourtGroupCopyWithImpl(this._self, this._then);

  final AdvocateCourtGroup _self;
  final $Res Function(AdvocateCourtGroup) _then;

/// Create a copy of AdvocateCourtGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtNo = null,Object? cases = null,}) {
  return _then(AdvocateCourtGroup(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,cases: null == cases ? _self.cases : cases // ignore: cast_nullable_to_non_nullable
as List<AdvocateListing>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdvocateCourtGroup].
extension AdvocateCourtGroupPatterns on AdvocateCourtGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvocateCourtGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvocateCourtGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvocateCourtGroup value)  $default,){
final _that = this;
switch (_that) {
case _AdvocateCourtGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvocateCourtGroup value)?  $default,){
final _that = this;
switch (_that) {
case _AdvocateCourtGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courtNo,  List<AdvocateListing> cases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvocateCourtGroup() when $default != null:
return $default(_that.courtNo,_that.cases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courtNo,  List<AdvocateListing> cases)  $default,) {final _that = this;
switch (_that) {
case _AdvocateCourtGroup():
return $default(_that.courtNo,_that.cases);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courtNo,  List<AdvocateListing> cases)?  $default,) {final _that = this;
switch (_that) {
case _AdvocateCourtGroup() when $default != null:
return $default(_that.courtNo,_that.cases);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdvocateCourtGroup implements AdvocateCourtGroup {
  const _AdvocateCourtGroup({required this.courtNo,  List<AdvocateListing> cases = const []}): _cases = cases;
  factory _AdvocateCourtGroup.fromJson(Map<String, dynamic> json) => _$AdvocateCourtGroupFromJson(json);

@override final  String courtNo;
 final  List<AdvocateListing> _cases;
@override@JsonKey() List<AdvocateListing> get cases {
  if (_cases is EqualUnmodifiableListView) return _cases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cases);
}


/// Create a copy of AdvocateCourtGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvocateCourtGroupCopyWith<_AdvocateCourtGroup> get copyWith => __$AdvocateCourtGroupCopyWithImpl<_AdvocateCourtGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdvocateCourtGroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvocateCourtGroup&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&const DeepCollectionEquality().equals(other.cases, _cases));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,courtNo,const DeepCollectionEquality().hash(_cases));
}

@override
String toString() {
    return 'AdvocateCourtGroup(courtNo: $courtNo, cases: $cases)';
}


}

/// @nodoc
abstract mixin class _$AdvocateCourtGroupCopyWith<$Res> implements $AdvocateCourtGroupCopyWith<$Res> {
  factory _$AdvocateCourtGroupCopyWith(_AdvocateCourtGroup value, $Res Function(_AdvocateCourtGroup) _then) = __$AdvocateCourtGroupCopyWithImpl;
@override @useResult
$Res call({
 String courtNo, List<AdvocateListing> cases
});




}
/// @nodoc
class __$AdvocateCourtGroupCopyWithImpl<$Res>
    implements _$AdvocateCourtGroupCopyWith<$Res> {
  __$AdvocateCourtGroupCopyWithImpl(this._self, this._then);

  final _AdvocateCourtGroup _self;
  final $Res Function(_AdvocateCourtGroup) _then;

/// Create a copy of AdvocateCourtGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtNo = null,Object? cases = null,}) {
  return _then(_AdvocateCourtGroup(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,cases: null == cases ? _self._cases : cases // ignore: cast_nullable_to_non_nullable
as List<AdvocateListing>,
  ));
}


}


/// @nodoc
mixin _$AdvocateCauseList {

 String get advocateCode; String? get advocateName; String get listDate; bool get dateOfferedBySource; List<String> get availableDates; int get totalCases; List<AdvocateCourtGroup> get courts; String? get fetchedAt; bool get stale; String? get source;
/// Create a copy of AdvocateCauseList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvocateCauseListCopyWith<AdvocateCauseList> get copyWith => _$AdvocateCauseListCopyWithImpl<AdvocateCauseList>(this as AdvocateCauseList, _$identity);

  /// Serializes this AdvocateCauseList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdvocateCauseList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvocateCauseList&&(identical(other.advocateCode, _this.advocateCode) || other.advocateCode == _this.advocateCode)&&(identical(other.advocateName, _this.advocateName) || other.advocateName == _this.advocateName)&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&(identical(other.dateOfferedBySource, _this.dateOfferedBySource) || other.dateOfferedBySource == _this.dateOfferedBySource)&&const DeepCollectionEquality().equals(other.availableDates, _this.availableDates)&&(identical(other.totalCases, _this.totalCases) || other.totalCases == _this.totalCases)&&const DeepCollectionEquality().equals(other.courts, _this.courts)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&(identical(other.source, _this.source) || other.source == _this.source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdvocateCauseList;
  return Object.hash(runtimeType,_this.advocateCode,_this.advocateName,_this.listDate,_this.dateOfferedBySource,const DeepCollectionEquality().hash(_this.availableDates),_this.totalCases,const DeepCollectionEquality().hash(_this.courts),_this.fetchedAt,_this.stale,_this.source);
}

@override
String toString() {
  final _this = this as AdvocateCauseList;
  return 'AdvocateCauseList(advocateCode: ${_this.advocateCode}, advocateName: ${_this.advocateName}, listDate: ${_this.listDate}, dateOfferedBySource: ${_this.dateOfferedBySource}, availableDates: ${_this.availableDates}, totalCases: ${_this.totalCases}, courts: ${_this.courts}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $AdvocateCauseListCopyWith<$Res>  {
  factory $AdvocateCauseListCopyWith(AdvocateCauseList value, $Res Function(AdvocateCauseList) _then) = _$AdvocateCauseListCopyWithImpl;
@useResult
$Res call({
 String advocateCode, String? advocateName, String listDate, bool dateOfferedBySource, List<String> availableDates, int totalCases, List<AdvocateCourtGroup> courts, String? fetchedAt, bool stale, String? source
});




}
/// @nodoc
class _$AdvocateCauseListCopyWithImpl<$Res>
    implements $AdvocateCauseListCopyWith<$Res> {
  _$AdvocateCauseListCopyWithImpl(this._self, this._then);

  final AdvocateCauseList _self;
  final $Res Function(AdvocateCauseList) _then;

/// Create a copy of AdvocateCauseList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? advocateCode = null,Object? advocateName = freezed,Object? listDate = null,Object? dateOfferedBySource = null,Object? availableDates = null,Object? totalCases = null,Object? courts = null,Object? fetchedAt = freezed,Object? stale = null,Object? source = freezed,}) {
  return _then(AdvocateCauseList(
advocateCode: null == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,dateOfferedBySource: null == dateOfferedBySource ? _self.dateOfferedBySource : dateOfferedBySource // ignore: cast_nullable_to_non_nullable
as bool,availableDates: null == availableDates ? _self.availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<String>,totalCases: null == totalCases ? _self.totalCases : totalCases // ignore: cast_nullable_to_non_nullable
as int,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<AdvocateCourtGroup>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdvocateCauseList].
extension AdvocateCauseListPatterns on AdvocateCauseList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvocateCauseList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvocateCauseList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvocateCauseList value)  $default,){
final _that = this;
switch (_that) {
case _AdvocateCauseList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvocateCauseList value)?  $default,){
final _that = this;
switch (_that) {
case _AdvocateCauseList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String advocateCode,  String? advocateName,  String listDate,  bool dateOfferedBySource,  List<String> availableDates,  int totalCases,  List<AdvocateCourtGroup> courts,  String? fetchedAt,  bool stale,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvocateCauseList() when $default != null:
return $default(_that.advocateCode,_that.advocateName,_that.listDate,_that.dateOfferedBySource,_that.availableDates,_that.totalCases,_that.courts,_that.fetchedAt,_that.stale,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String advocateCode,  String? advocateName,  String listDate,  bool dateOfferedBySource,  List<String> availableDates,  int totalCases,  List<AdvocateCourtGroup> courts,  String? fetchedAt,  bool stale,  String? source)  $default,) {final _that = this;
switch (_that) {
case _AdvocateCauseList():
return $default(_that.advocateCode,_that.advocateName,_that.listDate,_that.dateOfferedBySource,_that.availableDates,_that.totalCases,_that.courts,_that.fetchedAt,_that.stale,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String advocateCode,  String? advocateName,  String listDate,  bool dateOfferedBySource,  List<String> availableDates,  int totalCases,  List<AdvocateCourtGroup> courts,  String? fetchedAt,  bool stale,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _AdvocateCauseList() when $default != null:
return $default(_that.advocateCode,_that.advocateName,_that.listDate,_that.dateOfferedBySource,_that.availableDates,_that.totalCases,_that.courts,_that.fetchedAt,_that.stale,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdvocateCauseList implements AdvocateCauseList {
  const _AdvocateCauseList({required this.advocateCode, this.advocateName, required this.listDate, this.dateOfferedBySource = true,  List<String> availableDates = const [], required this.totalCases,  List<AdvocateCourtGroup> courts = const [], this.fetchedAt, this.stale = false, this.source}): _availableDates = availableDates,_courts = courts;
  factory _AdvocateCauseList.fromJson(Map<String, dynamic> json) => _$AdvocateCauseListFromJson(json);

@override final  String advocateCode;
@override final  String? advocateName;
@override final  String listDate;
@override@JsonKey() final  bool dateOfferedBySource;
 final  List<String> _availableDates;
@override@JsonKey() List<String> get availableDates {
  if (_availableDates is EqualUnmodifiableListView) return _availableDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDates);
}

@override final  int totalCases;
 final  List<AdvocateCourtGroup> _courts;
@override@JsonKey() List<AdvocateCourtGroup> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

@override final  String? fetchedAt;
@override@JsonKey() final  bool stale;
@override final  String? source;

/// Create a copy of AdvocateCauseList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvocateCauseListCopyWith<_AdvocateCauseList> get copyWith => __$AdvocateCauseListCopyWithImpl<_AdvocateCauseList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdvocateCauseListToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvocateCauseList&&(identical(other.advocateCode, advocateCode) || other.advocateCode == advocateCode)&&(identical(other.advocateName, advocateName) || other.advocateName == advocateName)&&(identical(other.listDate, listDate) || other.listDate == listDate)&&(identical(other.dateOfferedBySource, dateOfferedBySource) || other.dateOfferedBySource == dateOfferedBySource)&&const DeepCollectionEquality().equals(other.availableDates, _availableDates)&&(identical(other.totalCases, totalCases) || other.totalCases == totalCases)&&const DeepCollectionEquality().equals(other.courts, _courts)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,advocateCode,advocateName,listDate,dateOfferedBySource,const DeepCollectionEquality().hash(_availableDates),totalCases,const DeepCollectionEquality().hash(_courts),fetchedAt,stale,source);
}

@override
String toString() {
    return 'AdvocateCauseList(advocateCode: $advocateCode, advocateName: $advocateName, listDate: $listDate, dateOfferedBySource: $dateOfferedBySource, availableDates: $availableDates, totalCases: $totalCases, courts: $courts, fetchedAt: $fetchedAt, stale: $stale, source: $source)';
}


}

/// @nodoc
abstract mixin class _$AdvocateCauseListCopyWith<$Res> implements $AdvocateCauseListCopyWith<$Res> {
  factory _$AdvocateCauseListCopyWith(_AdvocateCauseList value, $Res Function(_AdvocateCauseList) _then) = __$AdvocateCauseListCopyWithImpl;
@override @useResult
$Res call({
 String advocateCode, String? advocateName, String listDate, bool dateOfferedBySource, List<String> availableDates, int totalCases, List<AdvocateCourtGroup> courts, String? fetchedAt, bool stale, String? source
});




}
/// @nodoc
class __$AdvocateCauseListCopyWithImpl<$Res>
    implements _$AdvocateCauseListCopyWith<$Res> {
  __$AdvocateCauseListCopyWithImpl(this._self, this._then);

  final _AdvocateCauseList _self;
  final $Res Function(_AdvocateCauseList) _then;

/// Create a copy of AdvocateCauseList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? advocateCode = null,Object? advocateName = freezed,Object? listDate = null,Object? dateOfferedBySource = null,Object? availableDates = null,Object? totalCases = null,Object? courts = null,Object? fetchedAt = freezed,Object? stale = null,Object? source = freezed,}) {
  return _then(_AdvocateCauseList(
advocateCode: null == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,dateOfferedBySource: null == dateOfferedBySource ? _self.dateOfferedBySource : dateOfferedBySource // ignore: cast_nullable_to_non_nullable
as bool,availableDates: null == availableDates ? _self._availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<String>,totalCases: null == totalCases ? _self.totalCases : totalCases // ignore: cast_nullable_to_non_nullable
as int,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<AdvocateCourtGroup>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListDates {

 String get listType; List<String> get dates; String? get fetchedAt; bool get stale;
/// Create a copy of ListDates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListDatesCopyWith<ListDates> get copyWith => _$ListDatesCopyWithImpl<ListDates>(this as ListDates, _$identity);

  /// Serializes this ListDates to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListDates;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListDates&&(identical(other.listType, _this.listType) || other.listType == _this.listType)&&const DeepCollectionEquality().equals(other.dates, _this.dates)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListDates;
  return Object.hash(runtimeType,_this.listType,const DeepCollectionEquality().hash(_this.dates),_this.fetchedAt,_this.stale);
}

@override
String toString() {
  final _this = this as ListDates;
  return 'ListDates(listType: ${_this.listType}, dates: ${_this.dates}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale})';
}


}

/// @nodoc
abstract mixin class $ListDatesCopyWith<$Res>  {
  factory $ListDatesCopyWith(ListDates value, $Res Function(ListDates) _then) = _$ListDatesCopyWithImpl;
@useResult
$Res call({
 String listType, List<String> dates, String? fetchedAt, bool stale
});




}
/// @nodoc
class _$ListDatesCopyWithImpl<$Res>
    implements $ListDatesCopyWith<$Res> {
  _$ListDatesCopyWithImpl(this._self, this._then);

  final ListDates _self;
  final $Res Function(ListDates) _then;

/// Create a copy of ListDates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listType = null,Object? dates = null,Object? fetchedAt = freezed,Object? stale = null,}) {
  return _then(ListDates(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,dates: null == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as List<String>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ListDates].
extension ListDatesPatterns on ListDates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListDates value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListDates() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListDates value)  $default,){
final _that = this;
switch (_that) {
case _ListDates():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListDates value)?  $default,){
final _that = this;
switch (_that) {
case _ListDates() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listType,  List<String> dates,  String? fetchedAt,  bool stale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListDates() when $default != null:
return $default(_that.listType,_that.dates,_that.fetchedAt,_that.stale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listType,  List<String> dates,  String? fetchedAt,  bool stale)  $default,) {final _that = this;
switch (_that) {
case _ListDates():
return $default(_that.listType,_that.dates,_that.fetchedAt,_that.stale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listType,  List<String> dates,  String? fetchedAt,  bool stale)?  $default,) {final _that = this;
switch (_that) {
case _ListDates() when $default != null:
return $default(_that.listType,_that.dates,_that.fetchedAt,_that.stale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListDates implements ListDates {
  const _ListDates({required this.listType,  List<String> dates = const [], this.fetchedAt, this.stale = false}): _dates = dates;
  factory _ListDates.fromJson(Map<String, dynamic> json) => _$ListDatesFromJson(json);

@override final  String listType;
 final  List<String> _dates;
@override@JsonKey() List<String> get dates {
  if (_dates is EqualUnmodifiableListView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dates);
}

@override final  String? fetchedAt;
@override@JsonKey() final  bool stale;

/// Create a copy of ListDates
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListDatesCopyWith<_ListDates> get copyWith => __$ListDatesCopyWithImpl<_ListDates>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListDatesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListDates&&(identical(other.listType, listType) || other.listType == listType)&&const DeepCollectionEquality().equals(other.dates, _dates)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listType,const DeepCollectionEquality().hash(_dates),fetchedAt,stale);
}

@override
String toString() {
    return 'ListDates(listType: $listType, dates: $dates, fetchedAt: $fetchedAt, stale: $stale)';
}


}

/// @nodoc
abstract mixin class _$ListDatesCopyWith<$Res> implements $ListDatesCopyWith<$Res> {
  factory _$ListDatesCopyWith(_ListDates value, $Res Function(_ListDates) _then) = __$ListDatesCopyWithImpl;
@override @useResult
$Res call({
 String listType, List<String> dates, String? fetchedAt, bool stale
});




}
/// @nodoc
class __$ListDatesCopyWithImpl<$Res>
    implements _$ListDatesCopyWith<$Res> {
  __$ListDatesCopyWithImpl(this._self, this._then);

  final _ListDates _self;
  final $Res Function(_ListDates) _then;

/// Create a copy of ListDates
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listType = null,Object? dates = null,Object? fetchedAt = freezed,Object? stale = null,}) {
  return _then(_ListDates(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,dates: null == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as List<String>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CourtSummary {

 String get courtNo; String get courtName; int? get caseCount; String? get bench; String? get syncedAt;
/// Create a copy of CourtSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtSummaryCopyWith<CourtSummary> get copyWith => _$CourtSummaryCopyWithImpl<CourtSummary>(this as CourtSummary, _$identity);

  /// Serializes this CourtSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CourtSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtSummary&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.courtName, _this.courtName) || other.courtName == _this.courtName)&&(identical(other.caseCount, _this.caseCount) || other.caseCount == _this.caseCount)&&(identical(other.bench, _this.bench) || other.bench == _this.bench)&&(identical(other.syncedAt, _this.syncedAt) || other.syncedAt == _this.syncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CourtSummary;
  return Object.hash(runtimeType,_this.courtNo,_this.courtName,_this.caseCount,_this.bench,_this.syncedAt);
}

@override
String toString() {
  final _this = this as CourtSummary;
  return 'CourtSummary(courtNo: ${_this.courtNo}, courtName: ${_this.courtName}, caseCount: ${_this.caseCount}, bench: ${_this.bench}, syncedAt: ${_this.syncedAt})';
}


}

/// @nodoc
abstract mixin class $CourtSummaryCopyWith<$Res>  {
  factory $CourtSummaryCopyWith(CourtSummary value, $Res Function(CourtSummary) _then) = _$CourtSummaryCopyWithImpl;
@useResult
$Res call({
 String courtNo, String courtName, int? caseCount, String? bench, String? syncedAt
});




}
/// @nodoc
class _$CourtSummaryCopyWithImpl<$Res>
    implements $CourtSummaryCopyWith<$Res> {
  _$CourtSummaryCopyWithImpl(this._self, this._then);

  final CourtSummary _self;
  final $Res Function(CourtSummary) _then;

/// Create a copy of CourtSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtNo = null,Object? courtName = null,Object? caseCount = freezed,Object? bench = freezed,Object? syncedAt = freezed,}) {
  return _then(CourtSummary(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,caseCount: freezed == caseCount ? _self.caseCount : caseCount // ignore: cast_nullable_to_non_nullable
as int?,bench: freezed == bench ? _self.bench : bench // ignore: cast_nullable_to_non_nullable
as String?,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CourtSummary].
extension CourtSummaryPatterns on CourtSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourtSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourtSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourtSummary value)  $default,){
final _that = this;
switch (_that) {
case _CourtSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourtSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CourtSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courtNo,  String courtName,  int? caseCount,  String? bench,  String? syncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourtSummary() when $default != null:
return $default(_that.courtNo,_that.courtName,_that.caseCount,_that.bench,_that.syncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courtNo,  String courtName,  int? caseCount,  String? bench,  String? syncedAt)  $default,) {final _that = this;
switch (_that) {
case _CourtSummary():
return $default(_that.courtNo,_that.courtName,_that.caseCount,_that.bench,_that.syncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courtNo,  String courtName,  int? caseCount,  String? bench,  String? syncedAt)?  $default,) {final _that = this;
switch (_that) {
case _CourtSummary() when $default != null:
return $default(_that.courtNo,_that.courtName,_that.caseCount,_that.bench,_that.syncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourtSummary implements CourtSummary {
  const _CourtSummary({required this.courtNo, required this.courtName, this.caseCount, this.bench, this.syncedAt});
  factory _CourtSummary.fromJson(Map<String, dynamic> json) => _$CourtSummaryFromJson(json);

@override final  String courtNo;
@override final  String courtName;
@override final  int? caseCount;
@override final  String? bench;
@override final  String? syncedAt;

/// Create a copy of CourtSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtSummaryCopyWith<_CourtSummary> get copyWith => __$CourtSummaryCopyWithImpl<_CourtSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourtSummary&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.caseCount, caseCount) || other.caseCount == caseCount)&&(identical(other.bench, bench) || other.bench == bench)&&(identical(other.syncedAt, syncedAt) || other.syncedAt == syncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,courtNo,courtName,caseCount,bench,syncedAt);
}

@override
String toString() {
    return 'CourtSummary(courtNo: $courtNo, courtName: $courtName, caseCount: $caseCount, bench: $bench, syncedAt: $syncedAt)';
}


}

/// @nodoc
abstract mixin class _$CourtSummaryCopyWith<$Res> implements $CourtSummaryCopyWith<$Res> {
  factory _$CourtSummaryCopyWith(_CourtSummary value, $Res Function(_CourtSummary) _then) = __$CourtSummaryCopyWithImpl;
@override @useResult
$Res call({
 String courtNo, String courtName, int? caseCount, String? bench, String? syncedAt
});




}
/// @nodoc
class __$CourtSummaryCopyWithImpl<$Res>
    implements _$CourtSummaryCopyWith<$Res> {
  __$CourtSummaryCopyWithImpl(this._self, this._then);

  final _CourtSummary _self;
  final $Res Function(_CourtSummary) _then;

/// Create a copy of CourtSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtNo = null,Object? courtName = null,Object? caseCount = freezed,Object? bench = freezed,Object? syncedAt = freezed,}) {
  return _then(_CourtSummary(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,caseCount: freezed == caseCount ? _self.caseCount : caseCount // ignore: cast_nullable_to_non_nullable
as int?,bench: freezed == bench ? _self.bench : bench // ignore: cast_nullable_to_non_nullable
as String?,syncedAt: freezed == syncedAt ? _self.syncedAt : syncedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CourtsResponse {

 String get listType; String get listDate; List<CourtSummary> get courts; String? get fetchedAt; bool get stale;
/// Create a copy of CourtsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtsResponseCopyWith<CourtsResponse> get copyWith => _$CourtsResponseCopyWithImpl<CourtsResponse>(this as CourtsResponse, _$identity);

  /// Serializes this CourtsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CourtsResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtsResponse&&(identical(other.listType, _this.listType) || other.listType == _this.listType)&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&const DeepCollectionEquality().equals(other.courts, _this.courts)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CourtsResponse;
  return Object.hash(runtimeType,_this.listType,_this.listDate,const DeepCollectionEquality().hash(_this.courts),_this.fetchedAt,_this.stale);
}

@override
String toString() {
  final _this = this as CourtsResponse;
  return 'CourtsResponse(listType: ${_this.listType}, listDate: ${_this.listDate}, courts: ${_this.courts}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale})';
}


}

/// @nodoc
abstract mixin class $CourtsResponseCopyWith<$Res>  {
  factory $CourtsResponseCopyWith(CourtsResponse value, $Res Function(CourtsResponse) _then) = _$CourtsResponseCopyWithImpl;
@useResult
$Res call({
 String listType, String listDate, List<CourtSummary> courts, String? fetchedAt, bool stale
});




}
/// @nodoc
class _$CourtsResponseCopyWithImpl<$Res>
    implements $CourtsResponseCopyWith<$Res> {
  _$CourtsResponseCopyWithImpl(this._self, this._then);

  final CourtsResponse _self;
  final $Res Function(CourtsResponse) _then;

/// Create a copy of CourtsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listType = null,Object? listDate = null,Object? courts = null,Object? fetchedAt = freezed,Object? stale = null,}) {
  return _then(CourtsResponse(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<CourtSummary>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CourtsResponse].
extension CourtsResponsePatterns on CourtsResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourtsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourtsResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourtsResponse value)  $default,){
final _that = this;
switch (_that) {
case _CourtsResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourtsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CourtsResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listType,  String listDate,  List<CourtSummary> courts,  String? fetchedAt,  bool stale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourtsResponse() when $default != null:
return $default(_that.listType,_that.listDate,_that.courts,_that.fetchedAt,_that.stale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listType,  String listDate,  List<CourtSummary> courts,  String? fetchedAt,  bool stale)  $default,) {final _that = this;
switch (_that) {
case _CourtsResponse():
return $default(_that.listType,_that.listDate,_that.courts,_that.fetchedAt,_that.stale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listType,  String listDate,  List<CourtSummary> courts,  String? fetchedAt,  bool stale)?  $default,) {final _that = this;
switch (_that) {
case _CourtsResponse() when $default != null:
return $default(_that.listType,_that.listDate,_that.courts,_that.fetchedAt,_that.stale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourtsResponse implements CourtsResponse {
  const _CourtsResponse({required this.listType, required this.listDate,  List<CourtSummary> courts = const [], this.fetchedAt, this.stale = false}): _courts = courts;
  factory _CourtsResponse.fromJson(Map<String, dynamic> json) => _$CourtsResponseFromJson(json);

@override final  String listType;
@override final  String listDate;
 final  List<CourtSummary> _courts;
@override@JsonKey() List<CourtSummary> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

@override final  String? fetchedAt;
@override@JsonKey() final  bool stale;

/// Create a copy of CourtsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtsResponseCopyWith<_CourtsResponse> get copyWith => __$CourtsResponseCopyWithImpl<_CourtsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourtsResponse&&(identical(other.listType, listType) || other.listType == listType)&&(identical(other.listDate, listDate) || other.listDate == listDate)&&const DeepCollectionEquality().equals(other.courts, _courts)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listType,listDate,const DeepCollectionEquality().hash(_courts),fetchedAt,stale);
}

@override
String toString() {
    return 'CourtsResponse(listType: $listType, listDate: $listDate, courts: $courts, fetchedAt: $fetchedAt, stale: $stale)';
}


}

/// @nodoc
abstract mixin class _$CourtsResponseCopyWith<$Res> implements $CourtsResponseCopyWith<$Res> {
  factory _$CourtsResponseCopyWith(_CourtsResponse value, $Res Function(_CourtsResponse) _then) = __$CourtsResponseCopyWithImpl;
@override @useResult
$Res call({
 String listType, String listDate, List<CourtSummary> courts, String? fetchedAt, bool stale
});




}
/// @nodoc
class __$CourtsResponseCopyWithImpl<$Res>
    implements _$CourtsResponseCopyWith<$Res> {
  __$CourtsResponseCopyWithImpl(this._self, this._then);

  final _CourtsResponse _self;
  final $Res Function(_CourtsResponse) _then;

/// Create a copy of CourtsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listType = null,Object? listDate = null,Object? courts = null,Object? fetchedAt = freezed,Object? stale = null,}) {
  return _then(_CourtsResponse(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<CourtSummary>,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ApplicationRef {

 String get number; String? get description;
/// Create a copy of ApplicationRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApplicationRefCopyWith<ApplicationRef> get copyWith => _$ApplicationRefCopyWithImpl<ApplicationRef>(this as ApplicationRef, _$identity);

  /// Serializes this ApplicationRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApplicationRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApplicationRef&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApplicationRef;
  return Object.hash(runtimeType,_this.number,_this.description);
}

@override
String toString() {
  final _this = this as ApplicationRef;
  return 'ApplicationRef(number: ${_this.number}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ApplicationRefCopyWith<$Res>  {
  factory $ApplicationRefCopyWith(ApplicationRef value, $Res Function(ApplicationRef) _then) = _$ApplicationRefCopyWithImpl;
@useResult
$Res call({
 String number, String? description
});




}
/// @nodoc
class _$ApplicationRefCopyWithImpl<$Res>
    implements $ApplicationRefCopyWith<$Res> {
  _$ApplicationRefCopyWithImpl(this._self, this._then);

  final ApplicationRef _self;
  final $Res Function(ApplicationRef) _then;

/// Create a copy of ApplicationRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? number = null,Object? description = freezed,}) {
  return _then(ApplicationRef(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApplicationRef].
extension ApplicationRefPatterns on ApplicationRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApplicationRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApplicationRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApplicationRef value)  $default,){
final _that = this;
switch (_that) {
case _ApplicationRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApplicationRef value)?  $default,){
final _that = this;
switch (_that) {
case _ApplicationRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String number,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApplicationRef() when $default != null:
return $default(_that.number,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String number,  String? description)  $default,) {final _that = this;
switch (_that) {
case _ApplicationRef():
return $default(_that.number,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String number,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _ApplicationRef() when $default != null:
return $default(_that.number,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApplicationRef implements ApplicationRef {
  const _ApplicationRef({required this.number, this.description});
  factory _ApplicationRef.fromJson(Map<String, dynamic> json) => _$ApplicationRefFromJson(json);

@override final  String number;
@override final  String? description;

/// Create a copy of ApplicationRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApplicationRefCopyWith<_ApplicationRef> get copyWith => __$ApplicationRefCopyWithImpl<_ApplicationRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApplicationRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApplicationRef&&(identical(other.number, number) || other.number == number)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,number,description);
}

@override
String toString() {
    return 'ApplicationRef(number: $number, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ApplicationRefCopyWith<$Res> implements $ApplicationRefCopyWith<$Res> {
  factory _$ApplicationRefCopyWith(_ApplicationRef value, $Res Function(_ApplicationRef) _then) = __$ApplicationRefCopyWithImpl;
@override @useResult
$Res call({
 String number, String? description
});




}
/// @nodoc
class __$ApplicationRefCopyWithImpl<$Res>
    implements _$ApplicationRefCopyWith<$Res> {
  __$ApplicationRefCopyWithImpl(this._self, this._then);

  final _ApplicationRef _self;
  final $Res Function(_ApplicationRef) _then;

/// Create a copy of ApplicationRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? number = null,Object? description = freezed,}) {
  return _then(_ApplicationRef(
number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListingItem {

 int get sequence; String get itemNo; String? get caseId; String get caseNumber; List<ApplicationRef> get applications; String? get petitioner; String? get respondent; List<String> get petitionerAdvocates; List<String> get respondentAdvocates; String? get district; String? get listSection; String? get stage; String? get remarks; PdfCheck? get pdfCheck; List<int>? get pdfPages;
/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingItemCopyWith<ListingItem> get copyWith => _$ListingItemCopyWithImpl<ListingItem>(this as ListingItem, _$identity);

  /// Serializes this ListingItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListingItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingItem&&(identical(other.sequence, _this.sequence) || other.sequence == _this.sequence)&&(identical(other.itemNo, _this.itemNo) || other.itemNo == _this.itemNo)&&(identical(other.caseId, _this.caseId) || other.caseId == _this.caseId)&&(identical(other.caseNumber, _this.caseNumber) || other.caseNumber == _this.caseNumber)&&const DeepCollectionEquality().equals(other.applications, _this.applications)&&(identical(other.petitioner, _this.petitioner) || other.petitioner == _this.petitioner)&&(identical(other.respondent, _this.respondent) || other.respondent == _this.respondent)&&const DeepCollectionEquality().equals(other.petitionerAdvocates, _this.petitionerAdvocates)&&const DeepCollectionEquality().equals(other.respondentAdvocates, _this.respondentAdvocates)&&(identical(other.district, _this.district) || other.district == _this.district)&&(identical(other.listSection, _this.listSection) || other.listSection == _this.listSection)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.remarks, _this.remarks) || other.remarks == _this.remarks)&&(identical(other.pdfCheck, _this.pdfCheck) || other.pdfCheck == _this.pdfCheck)&&const DeepCollectionEquality().equals(other.pdfPages, _this.pdfPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListingItem;
  return Object.hash(runtimeType,_this.sequence,_this.itemNo,_this.caseId,_this.caseNumber,const DeepCollectionEquality().hash(_this.applications),_this.petitioner,_this.respondent,const DeepCollectionEquality().hash(_this.petitionerAdvocates),const DeepCollectionEquality().hash(_this.respondentAdvocates),_this.district,_this.listSection,_this.stage,_this.remarks,_this.pdfCheck,const DeepCollectionEquality().hash(_this.pdfPages));
}

@override
String toString() {
  final _this = this as ListingItem;
  return 'ListingItem(sequence: ${_this.sequence}, itemNo: ${_this.itemNo}, caseId: ${_this.caseId}, caseNumber: ${_this.caseNumber}, applications: ${_this.applications}, petitioner: ${_this.petitioner}, respondent: ${_this.respondent}, petitionerAdvocates: ${_this.petitionerAdvocates}, respondentAdvocates: ${_this.respondentAdvocates}, district: ${_this.district}, listSection: ${_this.listSection}, stage: ${_this.stage}, remarks: ${_this.remarks}, pdfCheck: ${_this.pdfCheck}, pdfPages: ${_this.pdfPages})';
}


}

/// @nodoc
abstract mixin class $ListingItemCopyWith<$Res>  {
  factory $ListingItemCopyWith(ListingItem value, $Res Function(ListingItem) _then) = _$ListingItemCopyWithImpl;
@useResult
$Res call({
 int sequence, String itemNo, String? caseId, String caseNumber, List<ApplicationRef> applications, String? petitioner, String? respondent, List<String> petitionerAdvocates, List<String> respondentAdvocates, String? district, String? listSection, String? stage, String? remarks, PdfCheck? pdfCheck, List<int>? pdfPages
});


$PdfCheckCopyWith<$Res>? get pdfCheck;

}
/// @nodoc
class _$ListingItemCopyWithImpl<$Res>
    implements $ListingItemCopyWith<$Res> {
  _$ListingItemCopyWithImpl(this._self, this._then);

  final ListingItem _self;
  final $Res Function(ListingItem) _then;

/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sequence = null,Object? itemNo = null,Object? caseId = freezed,Object? caseNumber = null,Object? applications = null,Object? petitioner = freezed,Object? respondent = freezed,Object? petitionerAdvocates = null,Object? respondentAdvocates = null,Object? district = freezed,Object? listSection = freezed,Object? stage = freezed,Object? remarks = freezed,Object? pdfCheck = freezed,Object? pdfPages = freezed,}) {
  return _then(ListingItem(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,applications: null == applications ? _self.applications : applications // ignore: cast_nullable_to_non_nullable
as List<ApplicationRef>,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,petitionerAdvocates: null == petitionerAdvocates ? _self.petitionerAdvocates : petitionerAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,respondentAdvocates: null == respondentAdvocates ? _self.respondentAdvocates : respondentAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,listSection: freezed == listSection ? _self.listSection : listSection // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,pdfCheck: freezed == pdfCheck ? _self.pdfCheck : pdfCheck // ignore: cast_nullable_to_non_nullable
as PdfCheck?,pdfPages: freezed == pdfPages ? _self.pdfPages : pdfPages // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}
/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfCheckCopyWith<$Res>? get pdfCheck {
    if (_self.pdfCheck == null) {
    return null;
  }

  return $PdfCheckCopyWith<$Res>(_self.pdfCheck!, (value) {
    return _then(_self.copyWith(pdfCheck: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListingItem].
extension ListingItemPatterns on ListingItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingItem value)  $default,){
final _that = this;
switch (_that) {
case _ListingItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingItem value)?  $default,){
final _that = this;
switch (_that) {
case _ListingItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sequence,  String itemNo,  String? caseId,  String caseNumber,  List<ApplicationRef> applications,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? listSection,  String? stage,  String? remarks,  PdfCheck? pdfCheck,  List<int>? pdfPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingItem() when $default != null:
return $default(_that.sequence,_that.itemNo,_that.caseId,_that.caseNumber,_that.applications,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.listSection,_that.stage,_that.remarks,_that.pdfCheck,_that.pdfPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sequence,  String itemNo,  String? caseId,  String caseNumber,  List<ApplicationRef> applications,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? listSection,  String? stage,  String? remarks,  PdfCheck? pdfCheck,  List<int>? pdfPages)  $default,) {final _that = this;
switch (_that) {
case _ListingItem():
return $default(_that.sequence,_that.itemNo,_that.caseId,_that.caseNumber,_that.applications,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.listSection,_that.stage,_that.remarks,_that.pdfCheck,_that.pdfPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sequence,  String itemNo,  String? caseId,  String caseNumber,  List<ApplicationRef> applications,  String? petitioner,  String? respondent,  List<String> petitionerAdvocates,  List<String> respondentAdvocates,  String? district,  String? listSection,  String? stage,  String? remarks,  PdfCheck? pdfCheck,  List<int>? pdfPages)?  $default,) {final _that = this;
switch (_that) {
case _ListingItem() when $default != null:
return $default(_that.sequence,_that.itemNo,_that.caseId,_that.caseNumber,_that.applications,_that.petitioner,_that.respondent,_that.petitionerAdvocates,_that.respondentAdvocates,_that.district,_that.listSection,_that.stage,_that.remarks,_that.pdfCheck,_that.pdfPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingItem implements ListingItem {
  const _ListingItem({required this.sequence, required this.itemNo, this.caseId, required this.caseNumber,  List<ApplicationRef> applications = const [], this.petitioner, this.respondent,  List<String> petitionerAdvocates = const [],  List<String> respondentAdvocates = const [], this.district, this.listSection, this.stage, this.remarks, this.pdfCheck,  List<int>? pdfPages}): _applications = applications,_petitionerAdvocates = petitionerAdvocates,_respondentAdvocates = respondentAdvocates,_pdfPages = pdfPages;
  factory _ListingItem.fromJson(Map<String, dynamic> json) => _$ListingItemFromJson(json);

@override final  int sequence;
@override final  String itemNo;
@override final  String? caseId;
@override final  String caseNumber;
 final  List<ApplicationRef> _applications;
@override@JsonKey() List<ApplicationRef> get applications {
  if (_applications is EqualUnmodifiableListView) return _applications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_applications);
}

@override final  String? petitioner;
@override final  String? respondent;
 final  List<String> _petitionerAdvocates;
@override@JsonKey() List<String> get petitionerAdvocates {
  if (_petitionerAdvocates is EqualUnmodifiableListView) return _petitionerAdvocates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_petitionerAdvocates);
}

 final  List<String> _respondentAdvocates;
@override@JsonKey() List<String> get respondentAdvocates {
  if (_respondentAdvocates is EqualUnmodifiableListView) return _respondentAdvocates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_respondentAdvocates);
}

@override final  String? district;
@override final  String? listSection;
@override final  String? stage;
@override final  String? remarks;
@override final  PdfCheck? pdfCheck;
 final  List<int>? _pdfPages;
@override List<int>? get pdfPages {
  final value = _pdfPages;
  if (value == null) return null;
  if (_pdfPages is EqualUnmodifiableListView) return _pdfPages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingItemCopyWith<_ListingItem> get copyWith => __$ListingItemCopyWithImpl<_ListingItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingItem&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.itemNo, itemNo) || other.itemNo == itemNo)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&const DeepCollectionEquality().equals(other.applications, _applications)&&(identical(other.petitioner, petitioner) || other.petitioner == petitioner)&&(identical(other.respondent, respondent) || other.respondent == respondent)&&const DeepCollectionEquality().equals(other.petitionerAdvocates, _petitionerAdvocates)&&const DeepCollectionEquality().equals(other.respondentAdvocates, _respondentAdvocates)&&(identical(other.district, district) || other.district == district)&&(identical(other.listSection, listSection) || other.listSection == listSection)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.pdfCheck, pdfCheck) || other.pdfCheck == pdfCheck)&&const DeepCollectionEquality().equals(other.pdfPages, _pdfPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,sequence,itemNo,caseId,caseNumber,const DeepCollectionEquality().hash(_applications),petitioner,respondent,const DeepCollectionEquality().hash(_petitionerAdvocates),const DeepCollectionEquality().hash(_respondentAdvocates),district,listSection,stage,remarks,pdfCheck,const DeepCollectionEquality().hash(_pdfPages));
}

@override
String toString() {
    return 'ListingItem(sequence: $sequence, itemNo: $itemNo, caseId: $caseId, caseNumber: $caseNumber, applications: $applications, petitioner: $petitioner, respondent: $respondent, petitionerAdvocates: $petitionerAdvocates, respondentAdvocates: $respondentAdvocates, district: $district, listSection: $listSection, stage: $stage, remarks: $remarks, pdfCheck: $pdfCheck, pdfPages: $pdfPages)';
}


}

/// @nodoc
abstract mixin class _$ListingItemCopyWith<$Res> implements $ListingItemCopyWith<$Res> {
  factory _$ListingItemCopyWith(_ListingItem value, $Res Function(_ListingItem) _then) = __$ListingItemCopyWithImpl;
@override @useResult
$Res call({
 int sequence, String itemNo, String? caseId, String caseNumber, List<ApplicationRef> applications, String? petitioner, String? respondent, List<String> petitionerAdvocates, List<String> respondentAdvocates, String? district, String? listSection, String? stage, String? remarks, PdfCheck? pdfCheck, List<int>? pdfPages
});


@override $PdfCheckCopyWith<$Res>? get pdfCheck;

}
/// @nodoc
class __$ListingItemCopyWithImpl<$Res>
    implements _$ListingItemCopyWith<$Res> {
  __$ListingItemCopyWithImpl(this._self, this._then);

  final _ListingItem _self;
  final $Res Function(_ListingItem) _then;

/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sequence = null,Object? itemNo = null,Object? caseId = freezed,Object? caseNumber = null,Object? applications = null,Object? petitioner = freezed,Object? respondent = freezed,Object? petitionerAdvocates = null,Object? respondentAdvocates = null,Object? district = freezed,Object? listSection = freezed,Object? stage = freezed,Object? remarks = freezed,Object? pdfCheck = freezed,Object? pdfPages = freezed,}) {
  return _then(_ListingItem(
sequence: null == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as int,itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,applications: null == applications ? _self._applications : applications // ignore: cast_nullable_to_non_nullable
as List<ApplicationRef>,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,petitionerAdvocates: null == petitionerAdvocates ? _self._petitionerAdvocates : petitionerAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,respondentAdvocates: null == respondentAdvocates ? _self._respondentAdvocates : respondentAdvocates // ignore: cast_nullable_to_non_nullable
as List<String>,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,listSection: freezed == listSection ? _self.listSection : listSection // ignore: cast_nullable_to_non_nullable
as String?,stage: freezed == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String?,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,pdfCheck: freezed == pdfCheck ? _self.pdfCheck : pdfCheck // ignore: cast_nullable_to_non_nullable
as PdfCheck?,pdfPages: freezed == pdfPages ? _self._pdfPages : pdfPages // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

/// Create a copy of ListingItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfCheckCopyWith<$Res>? get pdfCheck {
    if (_self.pdfCheck == null) {
    return null;
  }

  return $PdfCheckCopyWith<$Res>(_self.pdfCheck!, (value) {
    return _then(_self.copyWith(pdfCheck: value));
  });
}
}


/// @nodoc
mixin _$CourtListing {

 String get listType; String get listDate; String get courtNo; String? get bench; List<String> get headings; String get status; int get totalCases; String? get fetchedAt; bool get stale; String? get source; List<ListingItem> get items; String get itemsSource; String? get fallbackReason; PdfVerification? get pdfVerification;
/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtListingCopyWith<CourtListing> get copyWith => _$CourtListingCopyWithImpl<CourtListing>(this as CourtListing, _$identity);

  /// Serializes this CourtListing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CourtListing;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtListing&&(identical(other.listType, _this.listType) || other.listType == _this.listType)&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.bench, _this.bench) || other.bench == _this.bench)&&const DeepCollectionEquality().equals(other.headings, _this.headings)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalCases, _this.totalCases) || other.totalCases == _this.totalCases)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.itemsSource, _this.itemsSource) || other.itemsSource == _this.itemsSource)&&(identical(other.fallbackReason, _this.fallbackReason) || other.fallbackReason == _this.fallbackReason)&&(identical(other.pdfVerification, _this.pdfVerification) || other.pdfVerification == _this.pdfVerification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CourtListing;
  return Object.hash(runtimeType,_this.listType,_this.listDate,_this.courtNo,_this.bench,const DeepCollectionEquality().hash(_this.headings),_this.status,_this.totalCases,_this.fetchedAt,_this.stale,_this.source,const DeepCollectionEquality().hash(_this.items),_this.itemsSource,_this.fallbackReason,_this.pdfVerification);
}

@override
String toString() {
  final _this = this as CourtListing;
  return 'CourtListing(listType: ${_this.listType}, listDate: ${_this.listDate}, courtNo: ${_this.courtNo}, bench: ${_this.bench}, headings: ${_this.headings}, status: ${_this.status}, totalCases: ${_this.totalCases}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale}, source: ${_this.source}, items: ${_this.items}, itemsSource: ${_this.itemsSource}, fallbackReason: ${_this.fallbackReason}, pdfVerification: ${_this.pdfVerification})';
}


}

/// @nodoc
abstract mixin class $CourtListingCopyWith<$Res>  {
  factory $CourtListingCopyWith(CourtListing value, $Res Function(CourtListing) _then) = _$CourtListingCopyWithImpl;
@useResult
$Res call({
 String listType, String listDate, String courtNo, String? bench, List<String> headings, String status, int totalCases, String? fetchedAt, bool stale, String? source, List<ListingItem> items, String itemsSource, String? fallbackReason, PdfVerification? pdfVerification
});


$PdfVerificationCopyWith<$Res>? get pdfVerification;

}
/// @nodoc
class _$CourtListingCopyWithImpl<$Res>
    implements $CourtListingCopyWith<$Res> {
  _$CourtListingCopyWithImpl(this._self, this._then);

  final CourtListing _self;
  final $Res Function(CourtListing) _then;

/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listType = null,Object? listDate = null,Object? courtNo = null,Object? bench = freezed,Object? headings = null,Object? status = null,Object? totalCases = null,Object? fetchedAt = freezed,Object? stale = null,Object? source = freezed,Object? items = null,Object? itemsSource = null,Object? fallbackReason = freezed,Object? pdfVerification = freezed,}) {
  return _then(CourtListing(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,bench: freezed == bench ? _self.bench : bench // ignore: cast_nullable_to_non_nullable
as String?,headings: null == headings ? _self.headings : headings // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCases: null == totalCases ? _self.totalCases : totalCases // ignore: cast_nullable_to_non_nullable
as int,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ListingItem>,itemsSource: null == itemsSource ? _self.itemsSource : itemsSource // ignore: cast_nullable_to_non_nullable
as String,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,pdfVerification: freezed == pdfVerification ? _self.pdfVerification : pdfVerification // ignore: cast_nullable_to_non_nullable
as PdfVerification?,
  ));
}
/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfVerificationCopyWith<$Res>? get pdfVerification {
    if (_self.pdfVerification == null) {
    return null;
  }

  return $PdfVerificationCopyWith<$Res>(_self.pdfVerification!, (value) {
    return _then(_self.copyWith(pdfVerification: value));
  });
}
}


/// Adds pattern-matching-related methods to [CourtListing].
extension CourtListingPatterns on CourtListing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourtListing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourtListing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourtListing value)  $default,){
final _that = this;
switch (_that) {
case _CourtListing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourtListing value)?  $default,){
final _that = this;
switch (_that) {
case _CourtListing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listType,  String listDate,  String courtNo,  String? bench,  List<String> headings,  String status,  int totalCases,  String? fetchedAt,  bool stale,  String? source,  List<ListingItem> items,  String itemsSource,  String? fallbackReason,  PdfVerification? pdfVerification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourtListing() when $default != null:
return $default(_that.listType,_that.listDate,_that.courtNo,_that.bench,_that.headings,_that.status,_that.totalCases,_that.fetchedAt,_that.stale,_that.source,_that.items,_that.itemsSource,_that.fallbackReason,_that.pdfVerification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listType,  String listDate,  String courtNo,  String? bench,  List<String> headings,  String status,  int totalCases,  String? fetchedAt,  bool stale,  String? source,  List<ListingItem> items,  String itemsSource,  String? fallbackReason,  PdfVerification? pdfVerification)  $default,) {final _that = this;
switch (_that) {
case _CourtListing():
return $default(_that.listType,_that.listDate,_that.courtNo,_that.bench,_that.headings,_that.status,_that.totalCases,_that.fetchedAt,_that.stale,_that.source,_that.items,_that.itemsSource,_that.fallbackReason,_that.pdfVerification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listType,  String listDate,  String courtNo,  String? bench,  List<String> headings,  String status,  int totalCases,  String? fetchedAt,  bool stale,  String? source,  List<ListingItem> items,  String itemsSource,  String? fallbackReason,  PdfVerification? pdfVerification)?  $default,) {final _that = this;
switch (_that) {
case _CourtListing() when $default != null:
return $default(_that.listType,_that.listDate,_that.courtNo,_that.bench,_that.headings,_that.status,_that.totalCases,_that.fetchedAt,_that.stale,_that.source,_that.items,_that.itemsSource,_that.fallbackReason,_that.pdfVerification);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourtListing implements CourtListing {
  const _CourtListing({required this.listType, required this.listDate, required this.courtNo, this.bench,  List<String> headings = const [], required this.status, required this.totalCases, this.fetchedAt, this.stale = false, this.source,  List<ListingItem> items = const [], this.itemsSource = 'online_list', this.fallbackReason, this.pdfVerification}): _headings = headings,_items = items;
  factory _CourtListing.fromJson(Map<String, dynamic> json) => _$CourtListingFromJson(json);

@override final  String listType;
@override final  String listDate;
@override final  String courtNo;
@override final  String? bench;
 final  List<String> _headings;
@override@JsonKey() List<String> get headings {
  if (_headings is EqualUnmodifiableListView) return _headings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headings);
}

@override final  String status;
@override final  int totalCases;
@override final  String? fetchedAt;
@override@JsonKey() final  bool stale;
@override final  String? source;
 final  List<ListingItem> _items;
@override@JsonKey() List<ListingItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String itemsSource;
@override final  String? fallbackReason;
@override final  PdfVerification? pdfVerification;

/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtListingCopyWith<_CourtListing> get copyWith => __$CourtListingCopyWithImpl<_CourtListing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtListingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourtListing&&(identical(other.listType, listType) || other.listType == listType)&&(identical(other.listDate, listDate) || other.listDate == listDate)&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.bench, bench) || other.bench == bench)&&const DeepCollectionEquality().equals(other.headings, _headings)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalCases, totalCases) || other.totalCases == totalCases)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.itemsSource, itemsSource) || other.itemsSource == itemsSource)&&(identical(other.fallbackReason, fallbackReason) || other.fallbackReason == fallbackReason)&&(identical(other.pdfVerification, pdfVerification) || other.pdfVerification == pdfVerification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listType,listDate,courtNo,bench,const DeepCollectionEquality().hash(_headings),status,totalCases,fetchedAt,stale,source,const DeepCollectionEquality().hash(_items),itemsSource,fallbackReason,pdfVerification);
}

@override
String toString() {
    return 'CourtListing(listType: $listType, listDate: $listDate, courtNo: $courtNo, bench: $bench, headings: $headings, status: $status, totalCases: $totalCases, fetchedAt: $fetchedAt, stale: $stale, source: $source, items: $items, itemsSource: $itemsSource, fallbackReason: $fallbackReason, pdfVerification: $pdfVerification)';
}


}

/// @nodoc
abstract mixin class _$CourtListingCopyWith<$Res> implements $CourtListingCopyWith<$Res> {
  factory _$CourtListingCopyWith(_CourtListing value, $Res Function(_CourtListing) _then) = __$CourtListingCopyWithImpl;
@override @useResult
$Res call({
 String listType, String listDate, String courtNo, String? bench, List<String> headings, String status, int totalCases, String? fetchedAt, bool stale, String? source, List<ListingItem> items, String itemsSource, String? fallbackReason, PdfVerification? pdfVerification
});


@override $PdfVerificationCopyWith<$Res>? get pdfVerification;

}
/// @nodoc
class __$CourtListingCopyWithImpl<$Res>
    implements _$CourtListingCopyWith<$Res> {
  __$CourtListingCopyWithImpl(this._self, this._then);

  final _CourtListing _self;
  final $Res Function(_CourtListing) _then;

/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listType = null,Object? listDate = null,Object? courtNo = null,Object? bench = freezed,Object? headings = null,Object? status = null,Object? totalCases = null,Object? fetchedAt = freezed,Object? stale = null,Object? source = freezed,Object? items = null,Object? itemsSource = null,Object? fallbackReason = freezed,Object? pdfVerification = freezed,}) {
  return _then(_CourtListing(
listType: null == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String,listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,bench: freezed == bench ? _self.bench : bench // ignore: cast_nullable_to_non_nullable
as String?,headings: null == headings ? _self._headings : headings // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalCases: null == totalCases ? _self.totalCases : totalCases // ignore: cast_nullable_to_non_nullable
as int,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ListingItem>,itemsSource: null == itemsSource ? _self.itemsSource : itemsSource // ignore: cast_nullable_to_non_nullable
as String,fallbackReason: freezed == fallbackReason ? _self.fallbackReason : fallbackReason // ignore: cast_nullable_to_non_nullable
as String?,pdfVerification: freezed == pdfVerification ? _self.pdfVerification : pdfVerification // ignore: cast_nullable_to_non_nullable
as PdfVerification?,
  ));
}

/// Create a copy of CourtListing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PdfVerificationCopyWith<$Res>? get pdfVerification {
    if (_self.pdfVerification == null) {
    return null;
  }

  return $PdfVerificationCopyWith<$Res>(_self.pdfVerification!, (value) {
    return _then(_self.copyWith(pdfVerification: value));
  });
}
}


/// @nodoc
mixin _$PdfCheck {

 String get status; List<String> get fields;
/// Create a copy of PdfCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfCheckCopyWith<PdfCheck> get copyWith => _$PdfCheckCopyWithImpl<PdfCheck>(this as PdfCheck, _$identity);

  /// Serializes this PdfCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PdfCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfCheck&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PdfCheck;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as PdfCheck;
  return 'PdfCheck(status: ${_this.status}, fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $PdfCheckCopyWith<$Res>  {
  factory $PdfCheckCopyWith(PdfCheck value, $Res Function(PdfCheck) _then) = _$PdfCheckCopyWithImpl;
@useResult
$Res call({
 String status, List<String> fields
});




}
/// @nodoc
class _$PdfCheckCopyWithImpl<$Res>
    implements $PdfCheckCopyWith<$Res> {
  _$PdfCheckCopyWithImpl(this._self, this._then);

  final PdfCheck _self;
  final $Res Function(PdfCheck) _then;

/// Create a copy of PdfCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? fields = null,}) {
  return _then(PdfCheck(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfCheck].
extension PdfCheckPatterns on PdfCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfCheck value)  $default,){
final _that = this;
switch (_that) {
case _PdfCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfCheck value)?  $default,){
final _that = this;
switch (_that) {
case _PdfCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  List<String> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfCheck() when $default != null:
return $default(_that.status,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  List<String> fields)  $default,) {final _that = this;
switch (_that) {
case _PdfCheck():
return $default(_that.status,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  List<String> fields)?  $default,) {final _that = this;
switch (_that) {
case _PdfCheck() when $default != null:
return $default(_that.status,_that.fields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfCheck implements PdfCheck {
  const _PdfCheck({required this.status,  List<String> fields = const []}): _fields = fields;
  factory _PdfCheck.fromJson(Map<String, dynamic> json) => _$PdfCheckFromJson(json);

@override final  String status;
 final  List<String> _fields;
@override@JsonKey() List<String> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of PdfCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfCheckCopyWith<_PdfCheck> get copyWith => __$PdfCheckCopyWithImpl<_PdfCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfCheck&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.fields, _fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'PdfCheck(status: $status, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$PdfCheckCopyWith<$Res> implements $PdfCheckCopyWith<$Res> {
  factory _$PdfCheckCopyWith(_PdfCheck value, $Res Function(_PdfCheck) _then) = __$PdfCheckCopyWithImpl;
@override @useResult
$Res call({
 String status, List<String> fields
});




}
/// @nodoc
class __$PdfCheckCopyWithImpl<$Res>
    implements _$PdfCheckCopyWith<$Res> {
  __$PdfCheckCopyWithImpl(this._self, this._then);

  final _PdfCheck _self;
  final $Res Function(_PdfCheck) _then;

/// Create a copy of PdfCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? fields = null,}) {
  return _then(_PdfCheck(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$PdfVerification {

 String get status; String? get source; String? get sourceUrl; String? get checkedAt; int get matched; int get differs; int get notInPdf; int get pdfOnly; List<ListingItem> get pdfOnlyItems; String? get errorCode;
/// Create a copy of PdfVerification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PdfVerificationCopyWith<PdfVerification> get copyWith => _$PdfVerificationCopyWithImpl<PdfVerification>(this as PdfVerification, _$identity);

  /// Serializes this PdfVerification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PdfVerification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PdfVerification&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.matched, _this.matched) || other.matched == _this.matched)&&(identical(other.differs, _this.differs) || other.differs == _this.differs)&&(identical(other.notInPdf, _this.notInPdf) || other.notInPdf == _this.notInPdf)&&(identical(other.pdfOnly, _this.pdfOnly) || other.pdfOnly == _this.pdfOnly)&&const DeepCollectionEquality().equals(other.pdfOnlyItems, _this.pdfOnlyItems)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PdfVerification;
  return Object.hash(runtimeType,_this.status,_this.source,_this.sourceUrl,_this.checkedAt,_this.matched,_this.differs,_this.notInPdf,_this.pdfOnly,const DeepCollectionEquality().hash(_this.pdfOnlyItems),_this.errorCode);
}

@override
String toString() {
  final _this = this as PdfVerification;
  return 'PdfVerification(status: ${_this.status}, source: ${_this.source}, sourceUrl: ${_this.sourceUrl}, checkedAt: ${_this.checkedAt}, matched: ${_this.matched}, differs: ${_this.differs}, notInPdf: ${_this.notInPdf}, pdfOnly: ${_this.pdfOnly}, pdfOnlyItems: ${_this.pdfOnlyItems}, errorCode: ${_this.errorCode})';
}


}

/// @nodoc
abstract mixin class $PdfVerificationCopyWith<$Res>  {
  factory $PdfVerificationCopyWith(PdfVerification value, $Res Function(PdfVerification) _then) = _$PdfVerificationCopyWithImpl;
@useResult
$Res call({
 String status, String? source, String? sourceUrl, String? checkedAt, int matched, int differs, int notInPdf, int pdfOnly, List<ListingItem> pdfOnlyItems, String? errorCode
});




}
/// @nodoc
class _$PdfVerificationCopyWithImpl<$Res>
    implements $PdfVerificationCopyWith<$Res> {
  _$PdfVerificationCopyWithImpl(this._self, this._then);

  final PdfVerification _self;
  final $Res Function(PdfVerification) _then;

/// Create a copy of PdfVerification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? source = freezed,Object? sourceUrl = freezed,Object? checkedAt = freezed,Object? matched = null,Object? differs = null,Object? notInPdf = null,Object? pdfOnly = null,Object? pdfOnlyItems = null,Object? errorCode = freezed,}) {
  return _then(PdfVerification(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as String?,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,differs: null == differs ? _self.differs : differs // ignore: cast_nullable_to_non_nullable
as int,notInPdf: null == notInPdf ? _self.notInPdf : notInPdf // ignore: cast_nullable_to_non_nullable
as int,pdfOnly: null == pdfOnly ? _self.pdfOnly : pdfOnly // ignore: cast_nullable_to_non_nullable
as int,pdfOnlyItems: null == pdfOnlyItems ? _self.pdfOnlyItems : pdfOnlyItems // ignore: cast_nullable_to_non_nullable
as List<ListingItem>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PdfVerification].
extension PdfVerificationPatterns on PdfVerification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PdfVerification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PdfVerification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PdfVerification value)  $default,){
final _that = this;
switch (_that) {
case _PdfVerification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PdfVerification value)?  $default,){
final _that = this;
switch (_that) {
case _PdfVerification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  String? source,  String? sourceUrl,  String? checkedAt,  int matched,  int differs,  int notInPdf,  int pdfOnly,  List<ListingItem> pdfOnlyItems,  String? errorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PdfVerification() when $default != null:
return $default(_that.status,_that.source,_that.sourceUrl,_that.checkedAt,_that.matched,_that.differs,_that.notInPdf,_that.pdfOnly,_that.pdfOnlyItems,_that.errorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  String? source,  String? sourceUrl,  String? checkedAt,  int matched,  int differs,  int notInPdf,  int pdfOnly,  List<ListingItem> pdfOnlyItems,  String? errorCode)  $default,) {final _that = this;
switch (_that) {
case _PdfVerification():
return $default(_that.status,_that.source,_that.sourceUrl,_that.checkedAt,_that.matched,_that.differs,_that.notInPdf,_that.pdfOnly,_that.pdfOnlyItems,_that.errorCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  String? source,  String? sourceUrl,  String? checkedAt,  int matched,  int differs,  int notInPdf,  int pdfOnly,  List<ListingItem> pdfOnlyItems,  String? errorCode)?  $default,) {final _that = this;
switch (_that) {
case _PdfVerification() when $default != null:
return $default(_that.status,_that.source,_that.sourceUrl,_that.checkedAt,_that.matched,_that.differs,_that.notInPdf,_that.pdfOnly,_that.pdfOnlyItems,_that.errorCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PdfVerification implements PdfVerification {
  const _PdfVerification({required this.status, this.source, this.sourceUrl, this.checkedAt, this.matched = 0, this.differs = 0, this.notInPdf = 0, this.pdfOnly = 0,  List<ListingItem> pdfOnlyItems = const [], this.errorCode}): _pdfOnlyItems = pdfOnlyItems;
  factory _PdfVerification.fromJson(Map<String, dynamic> json) => _$PdfVerificationFromJson(json);

@override final  String status;
@override final  String? source;
@override final  String? sourceUrl;
@override final  String? checkedAt;
@override@JsonKey() final  int matched;
@override@JsonKey() final  int differs;
@override@JsonKey() final  int notInPdf;
@override@JsonKey() final  int pdfOnly;
 final  List<ListingItem> _pdfOnlyItems;
@override@JsonKey() List<ListingItem> get pdfOnlyItems {
  if (_pdfOnlyItems is EqualUnmodifiableListView) return _pdfOnlyItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pdfOnlyItems);
}

@override final  String? errorCode;

/// Create a copy of PdfVerification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PdfVerificationCopyWith<_PdfVerification> get copyWith => __$PdfVerificationCopyWithImpl<_PdfVerification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PdfVerificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PdfVerification&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.differs, differs) || other.differs == differs)&&(identical(other.notInPdf, notInPdf) || other.notInPdf == notInPdf)&&(identical(other.pdfOnly, pdfOnly) || other.pdfOnly == pdfOnly)&&const DeepCollectionEquality().equals(other.pdfOnlyItems, _pdfOnlyItems)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,source,sourceUrl,checkedAt,matched,differs,notInPdf,pdfOnly,const DeepCollectionEquality().hash(_pdfOnlyItems),errorCode);
}

@override
String toString() {
    return 'PdfVerification(status: $status, source: $source, sourceUrl: $sourceUrl, checkedAt: $checkedAt, matched: $matched, differs: $differs, notInPdf: $notInPdf, pdfOnly: $pdfOnly, pdfOnlyItems: $pdfOnlyItems, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class _$PdfVerificationCopyWith<$Res> implements $PdfVerificationCopyWith<$Res> {
  factory _$PdfVerificationCopyWith(_PdfVerification value, $Res Function(_PdfVerification) _then) = __$PdfVerificationCopyWithImpl;
@override @useResult
$Res call({
 String status, String? source, String? sourceUrl, String? checkedAt, int matched, int differs, int notInPdf, int pdfOnly, List<ListingItem> pdfOnlyItems, String? errorCode
});




}
/// @nodoc
class __$PdfVerificationCopyWithImpl<$Res>
    implements _$PdfVerificationCopyWith<$Res> {
  __$PdfVerificationCopyWithImpl(this._self, this._then);

  final _PdfVerification _self;
  final $Res Function(_PdfVerification) _then;

/// Create a copy of PdfVerification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? source = freezed,Object? sourceUrl = freezed,Object? checkedAt = freezed,Object? matched = null,Object? differs = null,Object? notInPdf = null,Object? pdfOnly = null,Object? pdfOnlyItems = null,Object? errorCode = freezed,}) {
  return _then(_PdfVerification(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as String?,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,differs: null == differs ? _self.differs : differs // ignore: cast_nullable_to_non_nullable
as int,notInPdf: null == notInPdf ? _self.notInPdf : notInPdf // ignore: cast_nullable_to_non_nullable
as int,pdfOnly: null == pdfOnly ? _self.pdfOnly : pdfOnly // ignore: cast_nullable_to_non_nullable
as int,pdfOnlyItems: null == pdfOnlyItems ? _self._pdfOnlyItems : pdfOnlyItems // ignore: cast_nullable_to_non_nullable
as List<ListingItem>,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PassedOverEntry {

 String get itemNo; String get listPrefix; String? get listType; String get status; String get firstSeenAt; String get lastSeenAt; String? get removedAt;@JsonKey(name: 'case') ListingItem? get listing;
/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassedOverEntryCopyWith<PassedOverEntry> get copyWith => _$PassedOverEntryCopyWithImpl<PassedOverEntry>(this as PassedOverEntry, _$identity);

  /// Serializes this PassedOverEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PassedOverEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassedOverEntry&&(identical(other.itemNo, _this.itemNo) || other.itemNo == _this.itemNo)&&(identical(other.listPrefix, _this.listPrefix) || other.listPrefix == _this.listPrefix)&&(identical(other.listType, _this.listType) || other.listType == _this.listType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.firstSeenAt, _this.firstSeenAt) || other.firstSeenAt == _this.firstSeenAt)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.removedAt, _this.removedAt) || other.removedAt == _this.removedAt)&&(identical(other.listing, _this.listing) || other.listing == _this.listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PassedOverEntry;
  return Object.hash(runtimeType,_this.itemNo,_this.listPrefix,_this.listType,_this.status,_this.firstSeenAt,_this.lastSeenAt,_this.removedAt,_this.listing);
}

@override
String toString() {
  final _this = this as PassedOverEntry;
  return 'PassedOverEntry(itemNo: ${_this.itemNo}, listPrefix: ${_this.listPrefix}, listType: ${_this.listType}, status: ${_this.status}, firstSeenAt: ${_this.firstSeenAt}, lastSeenAt: ${_this.lastSeenAt}, removedAt: ${_this.removedAt}, listing: ${_this.listing})';
}


}

/// @nodoc
abstract mixin class $PassedOverEntryCopyWith<$Res>  {
  factory $PassedOverEntryCopyWith(PassedOverEntry value, $Res Function(PassedOverEntry) _then) = _$PassedOverEntryCopyWithImpl;
@useResult
$Res call({
 String itemNo, String listPrefix, String? listType, String status, String firstSeenAt, String lastSeenAt, String? removedAt,@JsonKey(name: 'case') ListingItem? listing
});


$ListingItemCopyWith<$Res>? get listing;

}
/// @nodoc
class _$PassedOverEntryCopyWithImpl<$Res>
    implements $PassedOverEntryCopyWith<$Res> {
  _$PassedOverEntryCopyWithImpl(this._self, this._then);

  final PassedOverEntry _self;
  final $Res Function(PassedOverEntry) _then;

/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemNo = null,Object? listPrefix = null,Object? listType = freezed,Object? status = null,Object? firstSeenAt = null,Object? lastSeenAt = null,Object? removedAt = freezed,Object? listing = freezed,}) {
  return _then(PassedOverEntry(
itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,listPrefix: null == listPrefix ? _self.listPrefix : listPrefix // ignore: cast_nullable_to_non_nullable
as String,listType: freezed == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: null == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as String,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as String?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ListingItem?,
  ));
}
/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingItemCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingItemCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}


/// Adds pattern-matching-related methods to [PassedOverEntry].
extension PassedOverEntryPatterns on PassedOverEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassedOverEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassedOverEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassedOverEntry value)  $default,){
final _that = this;
switch (_that) {
case _PassedOverEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassedOverEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PassedOverEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemNo,  String listPrefix,  String? listType,  String status,  String firstSeenAt,  String lastSeenAt,  String? removedAt, @JsonKey(name: 'case')  ListingItem? listing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassedOverEntry() when $default != null:
return $default(_that.itemNo,_that.listPrefix,_that.listType,_that.status,_that.firstSeenAt,_that.lastSeenAt,_that.removedAt,_that.listing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemNo,  String listPrefix,  String? listType,  String status,  String firstSeenAt,  String lastSeenAt,  String? removedAt, @JsonKey(name: 'case')  ListingItem? listing)  $default,) {final _that = this;
switch (_that) {
case _PassedOverEntry():
return $default(_that.itemNo,_that.listPrefix,_that.listType,_that.status,_that.firstSeenAt,_that.lastSeenAt,_that.removedAt,_that.listing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemNo,  String listPrefix,  String? listType,  String status,  String firstSeenAt,  String lastSeenAt,  String? removedAt, @JsonKey(name: 'case')  ListingItem? listing)?  $default,) {final _that = this;
switch (_that) {
case _PassedOverEntry() when $default != null:
return $default(_that.itemNo,_that.listPrefix,_that.listType,_that.status,_that.firstSeenAt,_that.lastSeenAt,_that.removedAt,_that.listing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassedOverEntry implements PassedOverEntry {
  const _PassedOverEntry({required this.itemNo, required this.listPrefix, this.listType, required this.status, required this.firstSeenAt, required this.lastSeenAt, this.removedAt, @JsonKey(name: 'case') this.listing});
  factory _PassedOverEntry.fromJson(Map<String, dynamic> json) => _$PassedOverEntryFromJson(json);

@override final  String itemNo;
@override final  String listPrefix;
@override final  String? listType;
@override final  String status;
@override final  String firstSeenAt;
@override final  String lastSeenAt;
@override final  String? removedAt;
@override@JsonKey(name: 'case') final  ListingItem? listing;

/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassedOverEntryCopyWith<_PassedOverEntry> get copyWith => __$PassedOverEntryCopyWithImpl<_PassedOverEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassedOverEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassedOverEntry&&(identical(other.itemNo, itemNo) || other.itemNo == itemNo)&&(identical(other.listPrefix, listPrefix) || other.listPrefix == listPrefix)&&(identical(other.listType, listType) || other.listType == listType)&&(identical(other.status, status) || other.status == status)&&(identical(other.firstSeenAt, firstSeenAt) || other.firstSeenAt == firstSeenAt)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.removedAt, removedAt) || other.removedAt == removedAt)&&(identical(other.listing, listing) || other.listing == listing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,itemNo,listPrefix,listType,status,firstSeenAt,lastSeenAt,removedAt,listing);
}

@override
String toString() {
    return 'PassedOverEntry(itemNo: $itemNo, listPrefix: $listPrefix, listType: $listType, status: $status, firstSeenAt: $firstSeenAt, lastSeenAt: $lastSeenAt, removedAt: $removedAt, listing: $listing)';
}


}

/// @nodoc
abstract mixin class _$PassedOverEntryCopyWith<$Res> implements $PassedOverEntryCopyWith<$Res> {
  factory _$PassedOverEntryCopyWith(_PassedOverEntry value, $Res Function(_PassedOverEntry) _then) = __$PassedOverEntryCopyWithImpl;
@override @useResult
$Res call({
 String itemNo, String listPrefix, String? listType, String status, String firstSeenAt, String lastSeenAt, String? removedAt,@JsonKey(name: 'case') ListingItem? listing
});


@override $ListingItemCopyWith<$Res>? get listing;

}
/// @nodoc
class __$PassedOverEntryCopyWithImpl<$Res>
    implements _$PassedOverEntryCopyWith<$Res> {
  __$PassedOverEntryCopyWithImpl(this._self, this._then);

  final _PassedOverEntry _self;
  final $Res Function(_PassedOverEntry) _then;

/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemNo = null,Object? listPrefix = null,Object? listType = freezed,Object? status = null,Object? firstSeenAt = null,Object? lastSeenAt = null,Object? removedAt = freezed,Object? listing = freezed,}) {
  return _then(_PassedOverEntry(
itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,listPrefix: null == listPrefix ? _self.listPrefix : listPrefix // ignore: cast_nullable_to_non_nullable
as String,listType: freezed == listType ? _self.listType : listType // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,firstSeenAt: null == firstSeenAt ? _self.firstSeenAt : firstSeenAt // ignore: cast_nullable_to_non_nullable
as String,lastSeenAt: null == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as String,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as String?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as ListingItem?,
  ));
}

/// Create a copy of PassedOverEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingItemCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingItemCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}
}


/// @nodoc
mixin _$PassedOverCourt {

 String get courtNo; String? get coram; String? get currentItem; int get pending; List<PassedOverEntry> get items;
/// Create a copy of PassedOverCourt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassedOverCourtCopyWith<PassedOverCourt> get copyWith => _$PassedOverCourtCopyWithImpl<PassedOverCourt>(this as PassedOverCourt, _$identity);

  /// Serializes this PassedOverCourt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PassedOverCourt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassedOverCourt&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.coram, _this.coram) || other.coram == _this.coram)&&(identical(other.currentItem, _this.currentItem) || other.currentItem == _this.currentItem)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PassedOverCourt;
  return Object.hash(runtimeType,_this.courtNo,_this.coram,_this.currentItem,_this.pending,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as PassedOverCourt;
  return 'PassedOverCourt(courtNo: ${_this.courtNo}, coram: ${_this.coram}, currentItem: ${_this.currentItem}, pending: ${_this.pending}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $PassedOverCourtCopyWith<$Res>  {
  factory $PassedOverCourtCopyWith(PassedOverCourt value, $Res Function(PassedOverCourt) _then) = _$PassedOverCourtCopyWithImpl;
@useResult
$Res call({
 String courtNo, String? coram, String? currentItem, int pending, List<PassedOverEntry> items
});




}
/// @nodoc
class _$PassedOverCourtCopyWithImpl<$Res>
    implements $PassedOverCourtCopyWith<$Res> {
  _$PassedOverCourtCopyWithImpl(this._self, this._then);

  final PassedOverCourt _self;
  final $Res Function(PassedOverCourt) _then;

/// Create a copy of PassedOverCourt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtNo = null,Object? coram = freezed,Object? currentItem = freezed,Object? pending = null,Object? items = null,}) {
  return _then(PassedOverCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as String?,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PassedOverEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [PassedOverCourt].
extension PassedOverCourtPatterns on PassedOverCourt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassedOverCourt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassedOverCourt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassedOverCourt value)  $default,){
final _that = this;
switch (_that) {
case _PassedOverCourt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassedOverCourt value)?  $default,){
final _that = this;
switch (_that) {
case _PassedOverCourt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courtNo,  String? coram,  String? currentItem,  int pending,  List<PassedOverEntry> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassedOverCourt() when $default != null:
return $default(_that.courtNo,_that.coram,_that.currentItem,_that.pending,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courtNo,  String? coram,  String? currentItem,  int pending,  List<PassedOverEntry> items)  $default,) {final _that = this;
switch (_that) {
case _PassedOverCourt():
return $default(_that.courtNo,_that.coram,_that.currentItem,_that.pending,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courtNo,  String? coram,  String? currentItem,  int pending,  List<PassedOverEntry> items)?  $default,) {final _that = this;
switch (_that) {
case _PassedOverCourt() when $default != null:
return $default(_that.courtNo,_that.coram,_that.currentItem,_that.pending,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassedOverCourt implements PassedOverCourt {
  const _PassedOverCourt({required this.courtNo, this.coram, this.currentItem, this.pending = 0,  List<PassedOverEntry> items = const []}): _items = items;
  factory _PassedOverCourt.fromJson(Map<String, dynamic> json) => _$PassedOverCourtFromJson(json);

@override final  String courtNo;
@override final  String? coram;
@override final  String? currentItem;
@override@JsonKey() final  int pending;
 final  List<PassedOverEntry> _items;
@override@JsonKey() List<PassedOverEntry> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of PassedOverCourt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassedOverCourtCopyWith<_PassedOverCourt> get copyWith => __$PassedOverCourtCopyWithImpl<_PassedOverCourt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassedOverCourtToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassedOverCourt&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.coram, coram) || other.coram == coram)&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.pending, pending) || other.pending == pending)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,courtNo,coram,currentItem,pending,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'PassedOverCourt(courtNo: $courtNo, coram: $coram, currentItem: $currentItem, pending: $pending, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PassedOverCourtCopyWith<$Res> implements $PassedOverCourtCopyWith<$Res> {
  factory _$PassedOverCourtCopyWith(_PassedOverCourt value, $Res Function(_PassedOverCourt) _then) = __$PassedOverCourtCopyWithImpl;
@override @useResult
$Res call({
 String courtNo, String? coram, String? currentItem, int pending, List<PassedOverEntry> items
});




}
/// @nodoc
class __$PassedOverCourtCopyWithImpl<$Res>
    implements _$PassedOverCourtCopyWith<$Res> {
  __$PassedOverCourtCopyWithImpl(this._self, this._then);

  final _PassedOverCourt _self;
  final $Res Function(_PassedOverCourt) _then;

/// Create a copy of PassedOverCourt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtNo = null,Object? coram = freezed,Object? currentItem = freezed,Object? pending = null,Object? items = null,}) {
  return _then(_PassedOverCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as String?,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PassedOverEntry>,
  ));
}


}


/// @nodoc
mixin _$PassedOverList {

 String get listDate; bool get isToday; String? get source; String? get observedFrom; String? get boardFetchedAt; bool? get boardStale; List<String> get availableDates; int get total; int get pending; List<PassedOverCourt> get courts; String? get note;
/// Create a copy of PassedOverList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassedOverListCopyWith<PassedOverList> get copyWith => _$PassedOverListCopyWithImpl<PassedOverList>(this as PassedOverList, _$identity);

  /// Serializes this PassedOverList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PassedOverList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassedOverList&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&(identical(other.isToday, _this.isToday) || other.isToday == _this.isToday)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.observedFrom, _this.observedFrom) || other.observedFrom == _this.observedFrom)&&(identical(other.boardFetchedAt, _this.boardFetchedAt) || other.boardFetchedAt == _this.boardFetchedAt)&&(identical(other.boardStale, _this.boardStale) || other.boardStale == _this.boardStale)&&const DeepCollectionEquality().equals(other.availableDates, _this.availableDates)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&const DeepCollectionEquality().equals(other.courts, _this.courts)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PassedOverList;
  return Object.hash(runtimeType,_this.listDate,_this.isToday,_this.source,_this.observedFrom,_this.boardFetchedAt,_this.boardStale,const DeepCollectionEquality().hash(_this.availableDates),_this.total,_this.pending,const DeepCollectionEquality().hash(_this.courts),_this.note);
}

@override
String toString() {
  final _this = this as PassedOverList;
  return 'PassedOverList(listDate: ${_this.listDate}, isToday: ${_this.isToday}, source: ${_this.source}, observedFrom: ${_this.observedFrom}, boardFetchedAt: ${_this.boardFetchedAt}, boardStale: ${_this.boardStale}, availableDates: ${_this.availableDates}, total: ${_this.total}, pending: ${_this.pending}, courts: ${_this.courts}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $PassedOverListCopyWith<$Res>  {
  factory $PassedOverListCopyWith(PassedOverList value, $Res Function(PassedOverList) _then) = _$PassedOverListCopyWithImpl;
@useResult
$Res call({
 String listDate, bool isToday, String? source, String? observedFrom, String? boardFetchedAt, bool? boardStale, List<String> availableDates, int total, int pending, List<PassedOverCourt> courts, String? note
});




}
/// @nodoc
class _$PassedOverListCopyWithImpl<$Res>
    implements $PassedOverListCopyWith<$Res> {
  _$PassedOverListCopyWithImpl(this._self, this._then);

  final PassedOverList _self;
  final $Res Function(PassedOverList) _then;

/// Create a copy of PassedOverList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listDate = null,Object? isToday = null,Object? source = freezed,Object? observedFrom = freezed,Object? boardFetchedAt = freezed,Object? boardStale = freezed,Object? availableDates = null,Object? total = null,Object? pending = null,Object? courts = null,Object? note = freezed,}) {
  return _then(PassedOverList(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,observedFrom: freezed == observedFrom ? _self.observedFrom : observedFrom // ignore: cast_nullable_to_non_nullable
as String?,boardFetchedAt: freezed == boardFetchedAt ? _self.boardFetchedAt : boardFetchedAt // ignore: cast_nullable_to_non_nullable
as String?,boardStale: freezed == boardStale ? _self.boardStale : boardStale // ignore: cast_nullable_to_non_nullable
as bool?,availableDates: null == availableDates ? _self.availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<String>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<PassedOverCourt>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassedOverList].
extension PassedOverListPatterns on PassedOverList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassedOverList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassedOverList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassedOverList value)  $default,){
final _that = this;
switch (_that) {
case _PassedOverList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassedOverList value)?  $default,){
final _that = this;
switch (_that) {
case _PassedOverList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listDate,  bool isToday,  String? source,  String? observedFrom,  String? boardFetchedAt,  bool? boardStale,  List<String> availableDates,  int total,  int pending,  List<PassedOverCourt> courts,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassedOverList() when $default != null:
return $default(_that.listDate,_that.isToday,_that.source,_that.observedFrom,_that.boardFetchedAt,_that.boardStale,_that.availableDates,_that.total,_that.pending,_that.courts,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listDate,  bool isToday,  String? source,  String? observedFrom,  String? boardFetchedAt,  bool? boardStale,  List<String> availableDates,  int total,  int pending,  List<PassedOverCourt> courts,  String? note)  $default,) {final _that = this;
switch (_that) {
case _PassedOverList():
return $default(_that.listDate,_that.isToday,_that.source,_that.observedFrom,_that.boardFetchedAt,_that.boardStale,_that.availableDates,_that.total,_that.pending,_that.courts,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listDate,  bool isToday,  String? source,  String? observedFrom,  String? boardFetchedAt,  bool? boardStale,  List<String> availableDates,  int total,  int pending,  List<PassedOverCourt> courts,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _PassedOverList() when $default != null:
return $default(_that.listDate,_that.isToday,_that.source,_that.observedFrom,_that.boardFetchedAt,_that.boardStale,_that.availableDates,_that.total,_that.pending,_that.courts,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassedOverList implements PassedOverList {
  const _PassedOverList({required this.listDate, this.isToday = false, this.source, this.observedFrom, this.boardFetchedAt, this.boardStale,  List<String> availableDates = const [], this.total = 0, this.pending = 0,  List<PassedOverCourt> courts = const [], this.note}): _availableDates = availableDates,_courts = courts;
  factory _PassedOverList.fromJson(Map<String, dynamic> json) => _$PassedOverListFromJson(json);

@override final  String listDate;
@override@JsonKey() final  bool isToday;
@override final  String? source;
@override final  String? observedFrom;
@override final  String? boardFetchedAt;
@override final  bool? boardStale;
 final  List<String> _availableDates;
@override@JsonKey() List<String> get availableDates {
  if (_availableDates is EqualUnmodifiableListView) return _availableDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDates);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int pending;
 final  List<PassedOverCourt> _courts;
@override@JsonKey() List<PassedOverCourt> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

@override final  String? note;

/// Create a copy of PassedOverList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassedOverListCopyWith<_PassedOverList> get copyWith => __$PassedOverListCopyWithImpl<_PassedOverList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassedOverListToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassedOverList&&(identical(other.listDate, listDate) || other.listDate == listDate)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.source, source) || other.source == source)&&(identical(other.observedFrom, observedFrom) || other.observedFrom == observedFrom)&&(identical(other.boardFetchedAt, boardFetchedAt) || other.boardFetchedAt == boardFetchedAt)&&(identical(other.boardStale, boardStale) || other.boardStale == boardStale)&&const DeepCollectionEquality().equals(other.availableDates, _availableDates)&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&const DeepCollectionEquality().equals(other.courts, _courts)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listDate,isToday,source,observedFrom,boardFetchedAt,boardStale,const DeepCollectionEquality().hash(_availableDates),total,pending,const DeepCollectionEquality().hash(_courts),note);
}

@override
String toString() {
    return 'PassedOverList(listDate: $listDate, isToday: $isToday, source: $source, observedFrom: $observedFrom, boardFetchedAt: $boardFetchedAt, boardStale: $boardStale, availableDates: $availableDates, total: $total, pending: $pending, courts: $courts, note: $note)';
}


}

/// @nodoc
abstract mixin class _$PassedOverListCopyWith<$Res> implements $PassedOverListCopyWith<$Res> {
  factory _$PassedOverListCopyWith(_PassedOverList value, $Res Function(_PassedOverList) _then) = __$PassedOverListCopyWithImpl;
@override @useResult
$Res call({
 String listDate, bool isToday, String? source, String? observedFrom, String? boardFetchedAt, bool? boardStale, List<String> availableDates, int total, int pending, List<PassedOverCourt> courts, String? note
});




}
/// @nodoc
class __$PassedOverListCopyWithImpl<$Res>
    implements _$PassedOverListCopyWith<$Res> {
  __$PassedOverListCopyWithImpl(this._self, this._then);

  final _PassedOverList _self;
  final $Res Function(_PassedOverList) _then;

/// Create a copy of PassedOverList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listDate = null,Object? isToday = null,Object? source = freezed,Object? observedFrom = freezed,Object? boardFetchedAt = freezed,Object? boardStale = freezed,Object? availableDates = null,Object? total = null,Object? pending = null,Object? courts = null,Object? note = freezed,}) {
  return _then(_PassedOverList(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,observedFrom: freezed == observedFrom ? _self.observedFrom : observedFrom // ignore: cast_nullable_to_non_nullable
as String?,boardFetchedAt: freezed == boardFetchedAt ? _self.boardFetchedAt : boardFetchedAt // ignore: cast_nullable_to_non_nullable
as String?,boardStale: freezed == boardStale ? _self.boardStale : boardStale // ignore: cast_nullable_to_non_nullable
as bool?,availableDates: null == availableDates ? _self._availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<String>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<PassedOverCourt>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PublicationCourt {

 String get courtNo; String? get benchCode; String? get coram; String get status; String? get uploadedAt; bool get hasPdf;
/// Create a copy of PublicationCourt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicationCourtCopyWith<PublicationCourt> get copyWith => _$PublicationCourtCopyWithImpl<PublicationCourt>(this as PublicationCourt, _$identity);

  /// Serializes this PublicationCourt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PublicationCourt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicationCourt&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.benchCode, _this.benchCode) || other.benchCode == _this.benchCode)&&(identical(other.coram, _this.coram) || other.coram == _this.coram)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.uploadedAt, _this.uploadedAt) || other.uploadedAt == _this.uploadedAt)&&(identical(other.hasPdf, _this.hasPdf) || other.hasPdf == _this.hasPdf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PublicationCourt;
  return Object.hash(runtimeType,_this.courtNo,_this.benchCode,_this.coram,_this.status,_this.uploadedAt,_this.hasPdf);
}

@override
String toString() {
  final _this = this as PublicationCourt;
  return 'PublicationCourt(courtNo: ${_this.courtNo}, benchCode: ${_this.benchCode}, coram: ${_this.coram}, status: ${_this.status}, uploadedAt: ${_this.uploadedAt}, hasPdf: ${_this.hasPdf})';
}


}

/// @nodoc
abstract mixin class $PublicationCourtCopyWith<$Res>  {
  factory $PublicationCourtCopyWith(PublicationCourt value, $Res Function(PublicationCourt) _then) = _$PublicationCourtCopyWithImpl;
@useResult
$Res call({
 String courtNo, String? benchCode, String? coram, String status, String? uploadedAt, bool hasPdf
});




}
/// @nodoc
class _$PublicationCourtCopyWithImpl<$Res>
    implements $PublicationCourtCopyWith<$Res> {
  _$PublicationCourtCopyWithImpl(this._self, this._then);

  final PublicationCourt _self;
  final $Res Function(PublicationCourt) _then;

/// Create a copy of PublicationCourt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtNo = null,Object? benchCode = freezed,Object? coram = freezed,Object? status = null,Object? uploadedAt = freezed,Object? hasPdf = null,}) {
  return _then(PublicationCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,benchCode: freezed == benchCode ? _self.benchCode : benchCode // ignore: cast_nullable_to_non_nullable
as String?,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String?,hasPdf: null == hasPdf ? _self.hasPdf : hasPdf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicationCourt].
extension PublicationCourtPatterns on PublicationCourt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicationCourt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicationCourt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicationCourt value)  $default,){
final _that = this;
switch (_that) {
case _PublicationCourt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicationCourt value)?  $default,){
final _that = this;
switch (_that) {
case _PublicationCourt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courtNo,  String? benchCode,  String? coram,  String status,  String? uploadedAt,  bool hasPdf)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicationCourt() when $default != null:
return $default(_that.courtNo,_that.benchCode,_that.coram,_that.status,_that.uploadedAt,_that.hasPdf);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courtNo,  String? benchCode,  String? coram,  String status,  String? uploadedAt,  bool hasPdf)  $default,) {final _that = this;
switch (_that) {
case _PublicationCourt():
return $default(_that.courtNo,_that.benchCode,_that.coram,_that.status,_that.uploadedAt,_that.hasPdf);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courtNo,  String? benchCode,  String? coram,  String status,  String? uploadedAt,  bool hasPdf)?  $default,) {final _that = this;
switch (_that) {
case _PublicationCourt() when $default != null:
return $default(_that.courtNo,_that.benchCode,_that.coram,_that.status,_that.uploadedAt,_that.hasPdf);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicationCourt implements PublicationCourt {
  const _PublicationCourt({required this.courtNo, this.benchCode, this.coram, required this.status, this.uploadedAt, this.hasPdf = false});
  factory _PublicationCourt.fromJson(Map<String, dynamic> json) => _$PublicationCourtFromJson(json);

@override final  String courtNo;
@override final  String? benchCode;
@override final  String? coram;
@override final  String status;
@override final  String? uploadedAt;
@override@JsonKey() final  bool hasPdf;

/// Create a copy of PublicationCourt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicationCourtCopyWith<_PublicationCourt> get copyWith => __$PublicationCourtCopyWithImpl<_PublicationCourt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicationCourtToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicationCourt&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.benchCode, benchCode) || other.benchCode == benchCode)&&(identical(other.coram, coram) || other.coram == coram)&&(identical(other.status, status) || other.status == status)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.hasPdf, hasPdf) || other.hasPdf == hasPdf));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,courtNo,benchCode,coram,status,uploadedAt,hasPdf);
}

@override
String toString() {
    return 'PublicationCourt(courtNo: $courtNo, benchCode: $benchCode, coram: $coram, status: $status, uploadedAt: $uploadedAt, hasPdf: $hasPdf)';
}


}

/// @nodoc
abstract mixin class _$PublicationCourtCopyWith<$Res> implements $PublicationCourtCopyWith<$Res> {
  factory _$PublicationCourtCopyWith(_PublicationCourt value, $Res Function(_PublicationCourt) _then) = __$PublicationCourtCopyWithImpl;
@override @useResult
$Res call({
 String courtNo, String? benchCode, String? coram, String status, String? uploadedAt, bool hasPdf
});




}
/// @nodoc
class __$PublicationCourtCopyWithImpl<$Res>
    implements _$PublicationCourtCopyWith<$Res> {
  __$PublicationCourtCopyWithImpl(this._self, this._then);

  final _PublicationCourt _self;
  final $Res Function(_PublicationCourt) _then;

/// Create a copy of PublicationCourt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtNo = null,Object? benchCode = freezed,Object? coram = freezed,Object? status = null,Object? uploadedAt = freezed,Object? hasPdf = null,}) {
  return _then(_PublicationCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,benchCode: freezed == benchCode ? _self.benchCode : benchCode // ignore: cast_nullable_to_non_nullable
as String?,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as String?,hasPdf: null == hasPdf ? _self.hasPdf : hasPdf // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PublicationStatus {

 String get listDate; String? get fetchedAt; bool get stale; Map<String, int> get summary; List<PublicationCourt> get courts;
/// Create a copy of PublicationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicationStatusCopyWith<PublicationStatus> get copyWith => _$PublicationStatusCopyWithImpl<PublicationStatus>(this as PublicationStatus, _$identity);

  /// Serializes this PublicationStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PublicationStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicationStatus&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&const DeepCollectionEquality().equals(other.summary, _this.summary)&&const DeepCollectionEquality().equals(other.courts, _this.courts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PublicationStatus;
  return Object.hash(runtimeType,_this.listDate,_this.fetchedAt,_this.stale,const DeepCollectionEquality().hash(_this.summary),const DeepCollectionEquality().hash(_this.courts));
}

@override
String toString() {
  final _this = this as PublicationStatus;
  return 'PublicationStatus(listDate: ${_this.listDate}, fetchedAt: ${_this.fetchedAt}, stale: ${_this.stale}, summary: ${_this.summary}, courts: ${_this.courts})';
}


}

/// @nodoc
abstract mixin class $PublicationStatusCopyWith<$Res>  {
  factory $PublicationStatusCopyWith(PublicationStatus value, $Res Function(PublicationStatus) _then) = _$PublicationStatusCopyWithImpl;
@useResult
$Res call({
 String listDate, String? fetchedAt, bool stale, Map<String, int> summary, List<PublicationCourt> courts
});




}
/// @nodoc
class _$PublicationStatusCopyWithImpl<$Res>
    implements $PublicationStatusCopyWith<$Res> {
  _$PublicationStatusCopyWithImpl(this._self, this._then);

  final PublicationStatus _self;
  final $Res Function(PublicationStatus) _then;

/// Create a copy of PublicationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listDate = null,Object? fetchedAt = freezed,Object? stale = null,Object? summary = null,Object? courts = null,}) {
  return _then(PublicationStatus(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<PublicationCourt>,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicationStatus].
extension PublicationStatusPatterns on PublicationStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicationStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicationStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicationStatus value)  $default,){
final _that = this;
switch (_that) {
case _PublicationStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicationStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PublicationStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listDate,  String? fetchedAt,  bool stale,  Map<String, int> summary,  List<PublicationCourt> courts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicationStatus() when $default != null:
return $default(_that.listDate,_that.fetchedAt,_that.stale,_that.summary,_that.courts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listDate,  String? fetchedAt,  bool stale,  Map<String, int> summary,  List<PublicationCourt> courts)  $default,) {final _that = this;
switch (_that) {
case _PublicationStatus():
return $default(_that.listDate,_that.fetchedAt,_that.stale,_that.summary,_that.courts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listDate,  String? fetchedAt,  bool stale,  Map<String, int> summary,  List<PublicationCourt> courts)?  $default,) {final _that = this;
switch (_that) {
case _PublicationStatus() when $default != null:
return $default(_that.listDate,_that.fetchedAt,_that.stale,_that.summary,_that.courts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicationStatus implements PublicationStatus {
  const _PublicationStatus({required this.listDate, this.fetchedAt, this.stale = false,  Map<String, int> summary = const {},  List<PublicationCourt> courts = const []}): _summary = summary,_courts = courts;
  factory _PublicationStatus.fromJson(Map<String, dynamic> json) => _$PublicationStatusFromJson(json);

@override final  String listDate;
@override final  String? fetchedAt;
@override@JsonKey() final  bool stale;
 final  Map<String, int> _summary;
@override@JsonKey() Map<String, int> get summary {
  if (_summary is EqualUnmodifiableMapView) return _summary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_summary);
}

 final  List<PublicationCourt> _courts;
@override@JsonKey() List<PublicationCourt> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}


/// Create a copy of PublicationStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicationStatusCopyWith<_PublicationStatus> get copyWith => __$PublicationStatusCopyWithImpl<_PublicationStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicationStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicationStatus&&(identical(other.listDate, listDate) || other.listDate == listDate)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.stale, stale) || other.stale == stale)&&const DeepCollectionEquality().equals(other.summary, _summary)&&const DeepCollectionEquality().equals(other.courts, _courts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listDate,fetchedAt,stale,const DeepCollectionEquality().hash(_summary),const DeepCollectionEquality().hash(_courts));
}

@override
String toString() {
    return 'PublicationStatus(listDate: $listDate, fetchedAt: $fetchedAt, stale: $stale, summary: $summary, courts: $courts)';
}


}

/// @nodoc
abstract mixin class _$PublicationStatusCopyWith<$Res> implements $PublicationStatusCopyWith<$Res> {
  factory _$PublicationStatusCopyWith(_PublicationStatus value, $Res Function(_PublicationStatus) _then) = __$PublicationStatusCopyWithImpl;
@override @useResult
$Res call({
 String listDate, String? fetchedAt, bool stale, Map<String, int> summary, List<PublicationCourt> courts
});




}
/// @nodoc
class __$PublicationStatusCopyWithImpl<$Res>
    implements _$PublicationStatusCopyWith<$Res> {
  __$PublicationStatusCopyWithImpl(this._self, this._then);

  final _PublicationStatus _self;
  final $Res Function(_PublicationStatus) _then;

/// Create a copy of PublicationStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listDate = null,Object? fetchedAt = freezed,Object? stale = null,Object? summary = null,Object? courts = null,}) {
  return _then(_PublicationStatus(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self._summary : summary // ignore: cast_nullable_to_non_nullable
as Map<String, int>,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<PublicationCourt>,
  ));
}


}


/// @nodoc
mixin _$EnrichmentJob {

 String get id; String get status; int get attempts; int get maxAttempts; String? get nextAttemptAt; String? get errorCode;
/// Create a copy of EnrichmentJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrichmentJobCopyWith<EnrichmentJob> get copyWith => _$EnrichmentJobCopyWithImpl<EnrichmentJob>(this as EnrichmentJob, _$identity);

  /// Serializes this EnrichmentJob to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnrichmentJob;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrichmentJob&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.attempts, _this.attempts) || other.attempts == _this.attempts)&&(identical(other.maxAttempts, _this.maxAttempts) || other.maxAttempts == _this.maxAttempts)&&(identical(other.nextAttemptAt, _this.nextAttemptAt) || other.nextAttemptAt == _this.nextAttemptAt)&&(identical(other.errorCode, _this.errorCode) || other.errorCode == _this.errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnrichmentJob;
  return Object.hash(runtimeType,_this.id,_this.status,_this.attempts,_this.maxAttempts,_this.nextAttemptAt,_this.errorCode);
}

@override
String toString() {
  final _this = this as EnrichmentJob;
  return 'EnrichmentJob(id: ${_this.id}, status: ${_this.status}, attempts: ${_this.attempts}, maxAttempts: ${_this.maxAttempts}, nextAttemptAt: ${_this.nextAttemptAt}, errorCode: ${_this.errorCode})';
}


}

/// @nodoc
abstract mixin class $EnrichmentJobCopyWith<$Res>  {
  factory $EnrichmentJobCopyWith(EnrichmentJob value, $Res Function(EnrichmentJob) _then) = _$EnrichmentJobCopyWithImpl;
@useResult
$Res call({
 String id, String status, int attempts, int maxAttempts, String? nextAttemptAt, String? errorCode
});




}
/// @nodoc
class _$EnrichmentJobCopyWithImpl<$Res>
    implements $EnrichmentJobCopyWith<$Res> {
  _$EnrichmentJobCopyWithImpl(this._self, this._then);

  final EnrichmentJob _self;
  final $Res Function(EnrichmentJob) _then;

/// Create a copy of EnrichmentJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? attempts = null,Object? maxAttempts = null,Object? nextAttemptAt = freezed,Object? errorCode = freezed,}) {
  return _then(EnrichmentJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,maxAttempts: null == maxAttempts ? _self.maxAttempts : maxAttempts // ignore: cast_nullable_to_non_nullable
as int,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EnrichmentJob].
extension EnrichmentJobPatterns on EnrichmentJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrichmentJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrichmentJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrichmentJob value)  $default,){
final _that = this;
switch (_that) {
case _EnrichmentJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrichmentJob value)?  $default,){
final _that = this;
switch (_that) {
case _EnrichmentJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  int attempts,  int maxAttempts,  String? nextAttemptAt,  String? errorCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrichmentJob() when $default != null:
return $default(_that.id,_that.status,_that.attempts,_that.maxAttempts,_that.nextAttemptAt,_that.errorCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  int attempts,  int maxAttempts,  String? nextAttemptAt,  String? errorCode)  $default,) {final _that = this;
switch (_that) {
case _EnrichmentJob():
return $default(_that.id,_that.status,_that.attempts,_that.maxAttempts,_that.nextAttemptAt,_that.errorCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  int attempts,  int maxAttempts,  String? nextAttemptAt,  String? errorCode)?  $default,) {final _that = this;
switch (_that) {
case _EnrichmentJob() when $default != null:
return $default(_that.id,_that.status,_that.attempts,_that.maxAttempts,_that.nextAttemptAt,_that.errorCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrichmentJob implements EnrichmentJob {
  const _EnrichmentJob({required this.id, required this.status, this.attempts = 0, this.maxAttempts = 0, this.nextAttemptAt, this.errorCode});
  factory _EnrichmentJob.fromJson(Map<String, dynamic> json) => _$EnrichmentJobFromJson(json);

@override final  String id;
@override final  String status;
@override@JsonKey() final  int attempts;
@override@JsonKey() final  int maxAttempts;
@override final  String? nextAttemptAt;
@override final  String? errorCode;

/// Create a copy of EnrichmentJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrichmentJobCopyWith<_EnrichmentJob> get copyWith => __$EnrichmentJobCopyWithImpl<_EnrichmentJob>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrichmentJobToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrichmentJob&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.maxAttempts, maxAttempts) || other.maxAttempts == maxAttempts)&&(identical(other.nextAttemptAt, nextAttemptAt) || other.nextAttemptAt == nextAttemptAt)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,attempts,maxAttempts,nextAttemptAt,errorCode);
}

@override
String toString() {
    return 'EnrichmentJob(id: $id, status: $status, attempts: $attempts, maxAttempts: $maxAttempts, nextAttemptAt: $nextAttemptAt, errorCode: $errorCode)';
}


}

/// @nodoc
abstract mixin class _$EnrichmentJobCopyWith<$Res> implements $EnrichmentJobCopyWith<$Res> {
  factory _$EnrichmentJobCopyWith(_EnrichmentJob value, $Res Function(_EnrichmentJob) _then) = __$EnrichmentJobCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, int attempts, int maxAttempts, String? nextAttemptAt, String? errorCode
});




}
/// @nodoc
class __$EnrichmentJobCopyWithImpl<$Res>
    implements _$EnrichmentJobCopyWith<$Res> {
  __$EnrichmentJobCopyWithImpl(this._self, this._then);

  final _EnrichmentJob _self;
  final $Res Function(_EnrichmentJob) _then;

/// Create a copy of EnrichmentJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? attempts = null,Object? maxAttempts = null,Object? nextAttemptAt = freezed,Object? errorCode = freezed,}) {
  return _then(_EnrichmentJob(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,maxAttempts: null == maxAttempts ? _self.maxAttempts : maxAttempts // ignore: cast_nullable_to_non_nullable
as int,nextAttemptAt: freezed == nextAttemptAt ? _self.nextAttemptAt : nextAttemptAt // ignore: cast_nullable_to_non_nullable
as String?,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EnrichmentStatus {

 String get caseId; String get state; String? get freshness; String? get fetchedAt; EnrichmentJob? get job; int? get pollAfterSeconds;
/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnrichmentStatusCopyWith<EnrichmentStatus> get copyWith => _$EnrichmentStatusCopyWithImpl<EnrichmentStatus>(this as EnrichmentStatus, _$identity);

  /// Serializes this EnrichmentStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnrichmentStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnrichmentStatus&&(identical(other.caseId, _this.caseId) || other.caseId == _this.caseId)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.freshness, _this.freshness) || other.freshness == _this.freshness)&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.job, _this.job) || other.job == _this.job)&&(identical(other.pollAfterSeconds, _this.pollAfterSeconds) || other.pollAfterSeconds == _this.pollAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnrichmentStatus;
  return Object.hash(runtimeType,_this.caseId,_this.state,_this.freshness,_this.fetchedAt,_this.job,_this.pollAfterSeconds);
}

@override
String toString() {
  final _this = this as EnrichmentStatus;
  return 'EnrichmentStatus(caseId: ${_this.caseId}, state: ${_this.state}, freshness: ${_this.freshness}, fetchedAt: ${_this.fetchedAt}, job: ${_this.job}, pollAfterSeconds: ${_this.pollAfterSeconds})';
}


}

/// @nodoc
abstract mixin class $EnrichmentStatusCopyWith<$Res>  {
  factory $EnrichmentStatusCopyWith(EnrichmentStatus value, $Res Function(EnrichmentStatus) _then) = _$EnrichmentStatusCopyWithImpl;
@useResult
$Res call({
 String caseId, String state, String? freshness, String? fetchedAt, EnrichmentJob? job, int? pollAfterSeconds
});


$EnrichmentJobCopyWith<$Res>? get job;

}
/// @nodoc
class _$EnrichmentStatusCopyWithImpl<$Res>
    implements $EnrichmentStatusCopyWith<$Res> {
  _$EnrichmentStatusCopyWithImpl(this._self, this._then);

  final EnrichmentStatus _self;
  final $Res Function(EnrichmentStatus) _then;

/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? state = null,Object? freshness = freezed,Object? fetchedAt = freezed,Object? job = freezed,Object? pollAfterSeconds = freezed,}) {
  return _then(EnrichmentStatus(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,freshness: freezed == freshness ? _self.freshness : freshness // ignore: cast_nullable_to_non_nullable
as String?,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as EnrichmentJob?,pollAfterSeconds: freezed == pollAfterSeconds ? _self.pollAfterSeconds : pollAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichmentJobCopyWith<$Res>? get job {
    if (_self.job == null) {
    return null;
  }

  return $EnrichmentJobCopyWith<$Res>(_self.job!, (value) {
    return _then(_self.copyWith(job: value));
  });
}
}


/// Adds pattern-matching-related methods to [EnrichmentStatus].
extension EnrichmentStatusPatterns on EnrichmentStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnrichmentStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnrichmentStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnrichmentStatus value)  $default,){
final _that = this;
switch (_that) {
case _EnrichmentStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnrichmentStatus value)?  $default,){
final _that = this;
switch (_that) {
case _EnrichmentStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String state,  String? freshness,  String? fetchedAt,  EnrichmentJob? job,  int? pollAfterSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnrichmentStatus() when $default != null:
return $default(_that.caseId,_that.state,_that.freshness,_that.fetchedAt,_that.job,_that.pollAfterSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String state,  String? freshness,  String? fetchedAt,  EnrichmentJob? job,  int? pollAfterSeconds)  $default,) {final _that = this;
switch (_that) {
case _EnrichmentStatus():
return $default(_that.caseId,_that.state,_that.freshness,_that.fetchedAt,_that.job,_that.pollAfterSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String state,  String? freshness,  String? fetchedAt,  EnrichmentJob? job,  int? pollAfterSeconds)?  $default,) {final _that = this;
switch (_that) {
case _EnrichmentStatus() when $default != null:
return $default(_that.caseId,_that.state,_that.freshness,_that.fetchedAt,_that.job,_that.pollAfterSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnrichmentStatus implements EnrichmentStatus {
  const _EnrichmentStatus({required this.caseId, required this.state, this.freshness, this.fetchedAt, this.job, this.pollAfterSeconds});
  factory _EnrichmentStatus.fromJson(Map<String, dynamic> json) => _$EnrichmentStatusFromJson(json);

@override final  String caseId;
@override final  String state;
@override final  String? freshness;
@override final  String? fetchedAt;
@override final  EnrichmentJob? job;
@override final  int? pollAfterSeconds;

/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnrichmentStatusCopyWith<_EnrichmentStatus> get copyWith => __$EnrichmentStatusCopyWithImpl<_EnrichmentStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnrichmentStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnrichmentStatus&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.state, state) || other.state == state)&&(identical(other.freshness, freshness) || other.freshness == freshness)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.job, job) || other.job == job)&&(identical(other.pollAfterSeconds, pollAfterSeconds) || other.pollAfterSeconds == pollAfterSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,caseId,state,freshness,fetchedAt,job,pollAfterSeconds);
}

@override
String toString() {
    return 'EnrichmentStatus(caseId: $caseId, state: $state, freshness: $freshness, fetchedAt: $fetchedAt, job: $job, pollAfterSeconds: $pollAfterSeconds)';
}


}

/// @nodoc
abstract mixin class _$EnrichmentStatusCopyWith<$Res> implements $EnrichmentStatusCopyWith<$Res> {
  factory _$EnrichmentStatusCopyWith(_EnrichmentStatus value, $Res Function(_EnrichmentStatus) _then) = __$EnrichmentStatusCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String state, String? freshness, String? fetchedAt, EnrichmentJob? job, int? pollAfterSeconds
});


@override $EnrichmentJobCopyWith<$Res>? get job;

}
/// @nodoc
class __$EnrichmentStatusCopyWithImpl<$Res>
    implements _$EnrichmentStatusCopyWith<$Res> {
  __$EnrichmentStatusCopyWithImpl(this._self, this._then);

  final _EnrichmentStatus _self;
  final $Res Function(_EnrichmentStatus) _then;

/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? state = null,Object? freshness = freezed,Object? fetchedAt = freezed,Object? job = freezed,Object? pollAfterSeconds = freezed,}) {
  return _then(_EnrichmentStatus(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,freshness: freezed == freshness ? _self.freshness : freshness // ignore: cast_nullable_to_non_nullable
as String?,fetchedAt: freezed == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as EnrichmentJob?,pollAfterSeconds: freezed == pollAfterSeconds ? _self.pollAfterSeconds : pollAfterSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of EnrichmentStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichmentJobCopyWith<$Res>? get job {
    if (_self.job == null) {
    return null;
  }

  return $EnrichmentJobCopyWith<$Res>(_self.job!, (value) {
    return _then(_self.copyWith(job: value));
  });
}
}


/// @nodoc
mixin _$CaseDetails {

 Map<String, dynamic> get identity; Map<String, dynamic> get information; Map<String, dynamic> get parties; Map<String, dynamic> get advocates; Map<String, dynamic> get additional; EnrichmentStatus get enrichment; Map<String, dynamic> get provenance; List<String> get unavailableSections; String? get unavailableNote;
/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseDetailsCopyWith<CaseDetails> get copyWith => _$CaseDetailsCopyWithImpl<CaseDetails>(this as CaseDetails, _$identity);

  /// Serializes this CaseDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CaseDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseDetails&&const DeepCollectionEquality().equals(other.identity, _this.identity)&&const DeepCollectionEquality().equals(other.information, _this.information)&&const DeepCollectionEquality().equals(other.parties, _this.parties)&&const DeepCollectionEquality().equals(other.advocates, _this.advocates)&&const DeepCollectionEquality().equals(other.additional, _this.additional)&&(identical(other.enrichment, _this.enrichment) || other.enrichment == _this.enrichment)&&const DeepCollectionEquality().equals(other.provenance, _this.provenance)&&const DeepCollectionEquality().equals(other.unavailableSections, _this.unavailableSections)&&(identical(other.unavailableNote, _this.unavailableNote) || other.unavailableNote == _this.unavailableNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CaseDetails;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.identity),const DeepCollectionEquality().hash(_this.information),const DeepCollectionEquality().hash(_this.parties),const DeepCollectionEquality().hash(_this.advocates),const DeepCollectionEquality().hash(_this.additional),_this.enrichment,const DeepCollectionEquality().hash(_this.provenance),const DeepCollectionEquality().hash(_this.unavailableSections),_this.unavailableNote);
}

@override
String toString() {
  final _this = this as CaseDetails;
  return 'CaseDetails(identity: ${_this.identity}, information: ${_this.information}, parties: ${_this.parties}, advocates: ${_this.advocates}, additional: ${_this.additional}, enrichment: ${_this.enrichment}, provenance: ${_this.provenance}, unavailableSections: ${_this.unavailableSections}, unavailableNote: ${_this.unavailableNote})';
}


}

/// @nodoc
abstract mixin class $CaseDetailsCopyWith<$Res>  {
  factory $CaseDetailsCopyWith(CaseDetails value, $Res Function(CaseDetails) _then) = _$CaseDetailsCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> identity, Map<String, dynamic> information, Map<String, dynamic> parties, Map<String, dynamic> advocates, Map<String, dynamic> additional, EnrichmentStatus enrichment, Map<String, dynamic> provenance, List<String> unavailableSections, String? unavailableNote
});


$EnrichmentStatusCopyWith<$Res> get enrichment;

}
/// @nodoc
class _$CaseDetailsCopyWithImpl<$Res>
    implements $CaseDetailsCopyWith<$Res> {
  _$CaseDetailsCopyWithImpl(this._self, this._then);

  final CaseDetails _self;
  final $Res Function(CaseDetails) _then;

/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? information = null,Object? parties = null,Object? advocates = null,Object? additional = null,Object? enrichment = null,Object? provenance = null,Object? unavailableSections = null,Object? unavailableNote = freezed,}) {
  return _then(CaseDetails(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,information: null == information ? _self.information : information // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,parties: null == parties ? _self.parties : parties // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,advocates: null == advocates ? _self.advocates : advocates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,additional: null == additional ? _self.additional : additional // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,enrichment: null == enrichment ? _self.enrichment : enrichment // ignore: cast_nullable_to_non_nullable
as EnrichmentStatus,provenance: null == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,unavailableSections: null == unavailableSections ? _self.unavailableSections : unavailableSections // ignore: cast_nullable_to_non_nullable
as List<String>,unavailableNote: freezed == unavailableNote ? _self.unavailableNote : unavailableNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichmentStatusCopyWith<$Res> get enrichment {
  
  return $EnrichmentStatusCopyWith<$Res>(_self.enrichment, (value) {
    return _then(_self.copyWith(enrichment: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaseDetails].
extension CaseDetailsPatterns on CaseDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseDetails value)  $default,){
final _that = this;
switch (_that) {
case _CaseDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseDetails value)?  $default,){
final _that = this;
switch (_that) {
case _CaseDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> identity,  Map<String, dynamic> information,  Map<String, dynamic> parties,  Map<String, dynamic> advocates,  Map<String, dynamic> additional,  EnrichmentStatus enrichment,  Map<String, dynamic> provenance,  List<String> unavailableSections,  String? unavailableNote)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseDetails() when $default != null:
return $default(_that.identity,_that.information,_that.parties,_that.advocates,_that.additional,_that.enrichment,_that.provenance,_that.unavailableSections,_that.unavailableNote);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> identity,  Map<String, dynamic> information,  Map<String, dynamic> parties,  Map<String, dynamic> advocates,  Map<String, dynamic> additional,  EnrichmentStatus enrichment,  Map<String, dynamic> provenance,  List<String> unavailableSections,  String? unavailableNote)  $default,) {final _that = this;
switch (_that) {
case _CaseDetails():
return $default(_that.identity,_that.information,_that.parties,_that.advocates,_that.additional,_that.enrichment,_that.provenance,_that.unavailableSections,_that.unavailableNote);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> identity,  Map<String, dynamic> information,  Map<String, dynamic> parties,  Map<String, dynamic> advocates,  Map<String, dynamic> additional,  EnrichmentStatus enrichment,  Map<String, dynamic> provenance,  List<String> unavailableSections,  String? unavailableNote)?  $default,) {final _that = this;
switch (_that) {
case _CaseDetails() when $default != null:
return $default(_that.identity,_that.information,_that.parties,_that.advocates,_that.additional,_that.enrichment,_that.provenance,_that.unavailableSections,_that.unavailableNote);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseDetails implements CaseDetails {
  const _CaseDetails({required  Map<String, dynamic> identity,  Map<String, dynamic> information = const {},  Map<String, dynamic> parties = const {},  Map<String, dynamic> advocates = const {},  Map<String, dynamic> additional = const {}, required this.enrichment,  Map<String, dynamic> provenance = const {},  List<String> unavailableSections = const [], this.unavailableNote}): _identity = identity,_information = information,_parties = parties,_advocates = advocates,_additional = additional,_provenance = provenance,_unavailableSections = unavailableSections;
  factory _CaseDetails.fromJson(Map<String, dynamic> json) => _$CaseDetailsFromJson(json);

 final  Map<String, dynamic> _identity;
@override Map<String, dynamic> get identity {
  if (_identity is EqualUnmodifiableMapView) return _identity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_identity);
}

 final  Map<String, dynamic> _information;
@override@JsonKey() Map<String, dynamic> get information {
  if (_information is EqualUnmodifiableMapView) return _information;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_information);
}

 final  Map<String, dynamic> _parties;
@override@JsonKey() Map<String, dynamic> get parties {
  if (_parties is EqualUnmodifiableMapView) return _parties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_parties);
}

 final  Map<String, dynamic> _advocates;
@override@JsonKey() Map<String, dynamic> get advocates {
  if (_advocates is EqualUnmodifiableMapView) return _advocates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_advocates);
}

 final  Map<String, dynamic> _additional;
@override@JsonKey() Map<String, dynamic> get additional {
  if (_additional is EqualUnmodifiableMapView) return _additional;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_additional);
}

@override final  EnrichmentStatus enrichment;
 final  Map<String, dynamic> _provenance;
@override@JsonKey() Map<String, dynamic> get provenance {
  if (_provenance is EqualUnmodifiableMapView) return _provenance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_provenance);
}

 final  List<String> _unavailableSections;
@override@JsonKey() List<String> get unavailableSections {
  if (_unavailableSections is EqualUnmodifiableListView) return _unavailableSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailableSections);
}

@override final  String? unavailableNote;

/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseDetailsCopyWith<_CaseDetails> get copyWith => __$CaseDetailsCopyWithImpl<_CaseDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseDetails&&const DeepCollectionEquality().equals(other.identity, _identity)&&const DeepCollectionEquality().equals(other.information, _information)&&const DeepCollectionEquality().equals(other.parties, _parties)&&const DeepCollectionEquality().equals(other.advocates, _advocates)&&const DeepCollectionEquality().equals(other.additional, _additional)&&(identical(other.enrichment, enrichment) || other.enrichment == enrichment)&&const DeepCollectionEquality().equals(other.provenance, _provenance)&&const DeepCollectionEquality().equals(other.unavailableSections, _unavailableSections)&&(identical(other.unavailableNote, unavailableNote) || other.unavailableNote == unavailableNote));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_identity),const DeepCollectionEquality().hash(_information),const DeepCollectionEquality().hash(_parties),const DeepCollectionEquality().hash(_advocates),const DeepCollectionEquality().hash(_additional),enrichment,const DeepCollectionEquality().hash(_provenance),const DeepCollectionEquality().hash(_unavailableSections),unavailableNote);
}

@override
String toString() {
    return 'CaseDetails(identity: $identity, information: $information, parties: $parties, advocates: $advocates, additional: $additional, enrichment: $enrichment, provenance: $provenance, unavailableSections: $unavailableSections, unavailableNote: $unavailableNote)';
}


}

/// @nodoc
abstract mixin class _$CaseDetailsCopyWith<$Res> implements $CaseDetailsCopyWith<$Res> {
  factory _$CaseDetailsCopyWith(_CaseDetails value, $Res Function(_CaseDetails) _then) = __$CaseDetailsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> identity, Map<String, dynamic> information, Map<String, dynamic> parties, Map<String, dynamic> advocates, Map<String, dynamic> additional, EnrichmentStatus enrichment, Map<String, dynamic> provenance, List<String> unavailableSections, String? unavailableNote
});


@override $EnrichmentStatusCopyWith<$Res> get enrichment;

}
/// @nodoc
class __$CaseDetailsCopyWithImpl<$Res>
    implements _$CaseDetailsCopyWith<$Res> {
  __$CaseDetailsCopyWithImpl(this._self, this._then);

  final _CaseDetails _self;
  final $Res Function(_CaseDetails) _then;

/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? information = null,Object? parties = null,Object? advocates = null,Object? additional = null,Object? enrichment = null,Object? provenance = null,Object? unavailableSections = null,Object? unavailableNote = freezed,}) {
  return _then(_CaseDetails(
identity: null == identity ? _self._identity : identity // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,information: null == information ? _self._information : information // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,parties: null == parties ? _self._parties : parties // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,advocates: null == advocates ? _self._advocates : advocates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,additional: null == additional ? _self._additional : additional // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,enrichment: null == enrichment ? _self.enrichment : enrichment // ignore: cast_nullable_to_non_nullable
as EnrichmentStatus,provenance: null == provenance ? _self._provenance : provenance // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,unavailableSections: null == unavailableSections ? _self._unavailableSections : unavailableSections // ignore: cast_nullable_to_non_nullable
as List<String>,unavailableNote: freezed == unavailableNote ? _self.unavailableNote : unavailableNote // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CaseDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EnrichmentStatusCopyWith<$Res> get enrichment {
  
  return $EnrichmentStatusCopyWith<$Res>(_self.enrichment, (value) {
    return _then(_self.copyWith(enrichment: value));
  });
}
}


/// @nodoc
mixin _$BoardCourt {

 String get courtNo; String get state; String? get currentItem; String? get keptBack; List<String> get pendingSerials; String? get coram;
/// Create a copy of BoardCourt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardCourtCopyWith<BoardCourt> get copyWith => _$BoardCourtCopyWithImpl<BoardCourt>(this as BoardCourt, _$identity);

  /// Serializes this BoardCourt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BoardCourt;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardCourt&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.currentItem, _this.currentItem) || other.currentItem == _this.currentItem)&&(identical(other.keptBack, _this.keptBack) || other.keptBack == _this.keptBack)&&const DeepCollectionEquality().equals(other.pendingSerials, _this.pendingSerials)&&(identical(other.coram, _this.coram) || other.coram == _this.coram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BoardCourt;
  return Object.hash(runtimeType,_this.courtNo,_this.state,_this.currentItem,_this.keptBack,const DeepCollectionEquality().hash(_this.pendingSerials),_this.coram);
}

@override
String toString() {
  final _this = this as BoardCourt;
  return 'BoardCourt(courtNo: ${_this.courtNo}, state: ${_this.state}, currentItem: ${_this.currentItem}, keptBack: ${_this.keptBack}, pendingSerials: ${_this.pendingSerials}, coram: ${_this.coram})';
}


}

/// @nodoc
abstract mixin class $BoardCourtCopyWith<$Res>  {
  factory $BoardCourtCopyWith(BoardCourt value, $Res Function(BoardCourt) _then) = _$BoardCourtCopyWithImpl;
@useResult
$Res call({
 String courtNo, String state, String? currentItem, String? keptBack, List<String> pendingSerials, String? coram
});




}
/// @nodoc
class _$BoardCourtCopyWithImpl<$Res>
    implements $BoardCourtCopyWith<$Res> {
  _$BoardCourtCopyWithImpl(this._self, this._then);

  final BoardCourt _self;
  final $Res Function(BoardCourt) _then;

/// Create a copy of BoardCourt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtNo = null,Object? state = null,Object? currentItem = freezed,Object? keptBack = freezed,Object? pendingSerials = null,Object? coram = freezed,}) {
  return _then(BoardCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as String?,keptBack: freezed == keptBack ? _self.keptBack : keptBack // ignore: cast_nullable_to_non_nullable
as String?,pendingSerials: null == pendingSerials ? _self.pendingSerials : pendingSerials // ignore: cast_nullable_to_non_nullable
as List<String>,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardCourt].
extension BoardCourtPatterns on BoardCourt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardCourt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardCourt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardCourt value)  $default,){
final _that = this;
switch (_that) {
case _BoardCourt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardCourt value)?  $default,){
final _that = this;
switch (_that) {
case _BoardCourt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String courtNo,  String state,  String? currentItem,  String? keptBack,  List<String> pendingSerials,  String? coram)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardCourt() when $default != null:
return $default(_that.courtNo,_that.state,_that.currentItem,_that.keptBack,_that.pendingSerials,_that.coram);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String courtNo,  String state,  String? currentItem,  String? keptBack,  List<String> pendingSerials,  String? coram)  $default,) {final _that = this;
switch (_that) {
case _BoardCourt():
return $default(_that.courtNo,_that.state,_that.currentItem,_that.keptBack,_that.pendingSerials,_that.coram);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String courtNo,  String state,  String? currentItem,  String? keptBack,  List<String> pendingSerials,  String? coram)?  $default,) {final _that = this;
switch (_that) {
case _BoardCourt() when $default != null:
return $default(_that.courtNo,_that.state,_that.currentItem,_that.keptBack,_that.pendingSerials,_that.coram);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardCourt implements BoardCourt {
  const _BoardCourt({required this.courtNo, required this.state, this.currentItem, this.keptBack,  List<String> pendingSerials = const [], this.coram}): _pendingSerials = pendingSerials;
  factory _BoardCourt.fromJson(Map<String, dynamic> json) => _$BoardCourtFromJson(json);

@override final  String courtNo;
@override final  String state;
@override final  String? currentItem;
@override final  String? keptBack;
 final  List<String> _pendingSerials;
@override@JsonKey() List<String> get pendingSerials {
  if (_pendingSerials is EqualUnmodifiableListView) return _pendingSerials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingSerials);
}

@override final  String? coram;

/// Create a copy of BoardCourt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardCourtCopyWith<_BoardCourt> get copyWith => __$BoardCourtCopyWithImpl<_BoardCourt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardCourtToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardCourt&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.state, state) || other.state == state)&&(identical(other.currentItem, currentItem) || other.currentItem == currentItem)&&(identical(other.keptBack, keptBack) || other.keptBack == keptBack)&&const DeepCollectionEquality().equals(other.pendingSerials, _pendingSerials)&&(identical(other.coram, coram) || other.coram == coram));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,courtNo,state,currentItem,keptBack,const DeepCollectionEquality().hash(_pendingSerials),coram);
}

@override
String toString() {
    return 'BoardCourt(courtNo: $courtNo, state: $state, currentItem: $currentItem, keptBack: $keptBack, pendingSerials: $pendingSerials, coram: $coram)';
}


}

/// @nodoc
abstract mixin class _$BoardCourtCopyWith<$Res> implements $BoardCourtCopyWith<$Res> {
  factory _$BoardCourtCopyWith(_BoardCourt value, $Res Function(_BoardCourt) _then) = __$BoardCourtCopyWithImpl;
@override @useResult
$Res call({
 String courtNo, String state, String? currentItem, String? keptBack, List<String> pendingSerials, String? coram
});




}
/// @nodoc
class __$BoardCourtCopyWithImpl<$Res>
    implements _$BoardCourtCopyWith<$Res> {
  __$BoardCourtCopyWithImpl(this._self, this._then);

  final _BoardCourt _self;
  final $Res Function(_BoardCourt) _then;

/// Create a copy of BoardCourt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtNo = null,Object? state = null,Object? currentItem = freezed,Object? keptBack = freezed,Object? pendingSerials = null,Object? coram = freezed,}) {
  return _then(_BoardCourt(
courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,currentItem: freezed == currentItem ? _self.currentItem : currentItem // ignore: cast_nullable_to_non_nullable
as String?,keptBack: freezed == keptBack ? _self.keptBack : keptBack // ignore: cast_nullable_to_non_nullable
as String?,pendingSerials: null == pendingSerials ? _self._pendingSerials : pendingSerials // ignore: cast_nullable_to_non_nullable
as List<String>,coram: freezed == coram ? _self.coram : coram // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LiveBoard {

 String get fetchedAt; int get ageSeconds; bool get stale; bool get isCurrent; int get staleAfterSeconds; String? get source; List<BoardCourt> get courts; String? get note;
/// Create a copy of LiveBoard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveBoardCopyWith<LiveBoard> get copyWith => _$LiveBoardCopyWithImpl<LiveBoard>(this as LiveBoard, _$identity);

  /// Serializes this LiveBoard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LiveBoard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveBoard&&(identical(other.fetchedAt, _this.fetchedAt) || other.fetchedAt == _this.fetchedAt)&&(identical(other.ageSeconds, _this.ageSeconds) || other.ageSeconds == _this.ageSeconds)&&(identical(other.stale, _this.stale) || other.stale == _this.stale)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent)&&(identical(other.staleAfterSeconds, _this.staleAfterSeconds) || other.staleAfterSeconds == _this.staleAfterSeconds)&&(identical(other.source, _this.source) || other.source == _this.source)&&const DeepCollectionEquality().equals(other.courts, _this.courts)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LiveBoard;
  return Object.hash(runtimeType,_this.fetchedAt,_this.ageSeconds,_this.stale,_this.isCurrent,_this.staleAfterSeconds,_this.source,const DeepCollectionEquality().hash(_this.courts),_this.note);
}

@override
String toString() {
  final _this = this as LiveBoard;
  return 'LiveBoard(fetchedAt: ${_this.fetchedAt}, ageSeconds: ${_this.ageSeconds}, stale: ${_this.stale}, isCurrent: ${_this.isCurrent}, staleAfterSeconds: ${_this.staleAfterSeconds}, source: ${_this.source}, courts: ${_this.courts}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $LiveBoardCopyWith<$Res>  {
  factory $LiveBoardCopyWith(LiveBoard value, $Res Function(LiveBoard) _then) = _$LiveBoardCopyWithImpl;
@useResult
$Res call({
 String fetchedAt, int ageSeconds, bool stale, bool isCurrent, int staleAfterSeconds, String? source, List<BoardCourt> courts, String? note
});




}
/// @nodoc
class _$LiveBoardCopyWithImpl<$Res>
    implements $LiveBoardCopyWith<$Res> {
  _$LiveBoardCopyWithImpl(this._self, this._then);

  final LiveBoard _self;
  final $Res Function(LiveBoard) _then;

/// Create a copy of LiveBoard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fetchedAt = null,Object? ageSeconds = null,Object? stale = null,Object? isCurrent = null,Object? staleAfterSeconds = null,Object? source = freezed,Object? courts = null,Object? note = freezed,}) {
  return _then(LiveBoard(
fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String,ageSeconds: null == ageSeconds ? _self.ageSeconds : ageSeconds // ignore: cast_nullable_to_non_nullable
as int,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,staleAfterSeconds: null == staleAfterSeconds ? _self.staleAfterSeconds : staleAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<BoardCourt>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveBoard].
extension LiveBoardPatterns on LiveBoard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveBoard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveBoard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveBoard value)  $default,){
final _that = this;
switch (_that) {
case _LiveBoard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveBoard value)?  $default,){
final _that = this;
switch (_that) {
case _LiveBoard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fetchedAt,  int ageSeconds,  bool stale,  bool isCurrent,  int staleAfterSeconds,  String? source,  List<BoardCourt> courts,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveBoard() when $default != null:
return $default(_that.fetchedAt,_that.ageSeconds,_that.stale,_that.isCurrent,_that.staleAfterSeconds,_that.source,_that.courts,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fetchedAt,  int ageSeconds,  bool stale,  bool isCurrent,  int staleAfterSeconds,  String? source,  List<BoardCourt> courts,  String? note)  $default,) {final _that = this;
switch (_that) {
case _LiveBoard():
return $default(_that.fetchedAt,_that.ageSeconds,_that.stale,_that.isCurrent,_that.staleAfterSeconds,_that.source,_that.courts,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fetchedAt,  int ageSeconds,  bool stale,  bool isCurrent,  int staleAfterSeconds,  String? source,  List<BoardCourt> courts,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _LiveBoard() when $default != null:
return $default(_that.fetchedAt,_that.ageSeconds,_that.stale,_that.isCurrent,_that.staleAfterSeconds,_that.source,_that.courts,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveBoard implements LiveBoard {
  const _LiveBoard({required this.fetchedAt, required this.ageSeconds, required this.stale, required this.isCurrent, this.staleAfterSeconds = 180, this.source,  List<BoardCourt> courts = const [], this.note}): _courts = courts;
  factory _LiveBoard.fromJson(Map<String, dynamic> json) => _$LiveBoardFromJson(json);

@override final  String fetchedAt;
@override final  int ageSeconds;
@override final  bool stale;
@override final  bool isCurrent;
@override@JsonKey() final  int staleAfterSeconds;
@override final  String? source;
 final  List<BoardCourt> _courts;
@override@JsonKey() List<BoardCourt> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

@override final  String? note;

/// Create a copy of LiveBoard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveBoardCopyWith<_LiveBoard> get copyWith => __$LiveBoardCopyWithImpl<_LiveBoard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveBoardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveBoard&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.ageSeconds, ageSeconds) || other.ageSeconds == ageSeconds)&&(identical(other.stale, stale) || other.stale == stale)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.staleAfterSeconds, staleAfterSeconds) || other.staleAfterSeconds == staleAfterSeconds)&&(identical(other.source, source) || other.source == source)&&const DeepCollectionEquality().equals(other.courts, _courts)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fetchedAt,ageSeconds,stale,isCurrent,staleAfterSeconds,source,const DeepCollectionEquality().hash(_courts),note);
}

@override
String toString() {
    return 'LiveBoard(fetchedAt: $fetchedAt, ageSeconds: $ageSeconds, stale: $stale, isCurrent: $isCurrent, staleAfterSeconds: $staleAfterSeconds, source: $source, courts: $courts, note: $note)';
}


}

/// @nodoc
abstract mixin class _$LiveBoardCopyWith<$Res> implements $LiveBoardCopyWith<$Res> {
  factory _$LiveBoardCopyWith(_LiveBoard value, $Res Function(_LiveBoard) _then) = __$LiveBoardCopyWithImpl;
@override @useResult
$Res call({
 String fetchedAt, int ageSeconds, bool stale, bool isCurrent, int staleAfterSeconds, String? source, List<BoardCourt> courts, String? note
});




}
/// @nodoc
class __$LiveBoardCopyWithImpl<$Res>
    implements _$LiveBoardCopyWith<$Res> {
  __$LiveBoardCopyWithImpl(this._self, this._then);

  final _LiveBoard _self;
  final $Res Function(_LiveBoard) _then;

/// Create a copy of LiveBoard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fetchedAt = null,Object? ageSeconds = null,Object? stale = null,Object? isCurrent = null,Object? staleAfterSeconds = null,Object? source = freezed,Object? courts = null,Object? note = freezed,}) {
  return _then(_LiveBoard(
fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as String,ageSeconds: null == ageSeconds ? _self.ageSeconds : ageSeconds // ignore: cast_nullable_to_non_nullable
as int,stale: null == stale ? _self.stale : stale // ignore: cast_nullable_to_non_nullable
as bool,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,staleAfterSeconds: null == staleAfterSeconds ? _self.staleAfterSeconds : staleAfterSeconds // ignore: cast_nullable_to_non_nullable
as int,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<BoardCourt>,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FavouriteAdvocate {

 String get id; String get advocateCode; String? get advocateName; String? get label; String get createdAt;
/// Create a copy of FavouriteAdvocate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavouriteAdvocateCopyWith<FavouriteAdvocate> get copyWith => _$FavouriteAdvocateCopyWithImpl<FavouriteAdvocate>(this as FavouriteAdvocate, _$identity);

  /// Serializes this FavouriteAdvocate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FavouriteAdvocate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavouriteAdvocate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.advocateCode, _this.advocateCode) || other.advocateCode == _this.advocateCode)&&(identical(other.advocateName, _this.advocateName) || other.advocateName == _this.advocateName)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FavouriteAdvocate;
  return Object.hash(runtimeType,_this.id,_this.advocateCode,_this.advocateName,_this.label,_this.createdAt);
}

@override
String toString() {
  final _this = this as FavouriteAdvocate;
  return 'FavouriteAdvocate(id: ${_this.id}, advocateCode: ${_this.advocateCode}, advocateName: ${_this.advocateName}, label: ${_this.label}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $FavouriteAdvocateCopyWith<$Res>  {
  factory $FavouriteAdvocateCopyWith(FavouriteAdvocate value, $Res Function(FavouriteAdvocate) _then) = _$FavouriteAdvocateCopyWithImpl;
@useResult
$Res call({
 String id, String advocateCode, String? advocateName, String? label, String createdAt
});




}
/// @nodoc
class _$FavouriteAdvocateCopyWithImpl<$Res>
    implements $FavouriteAdvocateCopyWith<$Res> {
  _$FavouriteAdvocateCopyWithImpl(this._self, this._then);

  final FavouriteAdvocate _self;
  final $Res Function(FavouriteAdvocate) _then;

/// Create a copy of FavouriteAdvocate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? advocateCode = null,Object? advocateName = freezed,Object? label = freezed,Object? createdAt = null,}) {
  return _then(FavouriteAdvocate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,advocateCode: null == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FavouriteAdvocate].
extension FavouriteAdvocatePatterns on FavouriteAdvocate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavouriteAdvocate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavouriteAdvocate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavouriteAdvocate value)  $default,){
final _that = this;
switch (_that) {
case _FavouriteAdvocate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavouriteAdvocate value)?  $default,){
final _that = this;
switch (_that) {
case _FavouriteAdvocate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String advocateCode,  String? advocateName,  String? label,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavouriteAdvocate() when $default != null:
return $default(_that.id,_that.advocateCode,_that.advocateName,_that.label,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String advocateCode,  String? advocateName,  String? label,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _FavouriteAdvocate():
return $default(_that.id,_that.advocateCode,_that.advocateName,_that.label,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String advocateCode,  String? advocateName,  String? label,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FavouriteAdvocate() when $default != null:
return $default(_that.id,_that.advocateCode,_that.advocateName,_that.label,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavouriteAdvocate implements FavouriteAdvocate {
  const _FavouriteAdvocate({required this.id, required this.advocateCode, this.advocateName, this.label, required this.createdAt});
  factory _FavouriteAdvocate.fromJson(Map<String, dynamic> json) => _$FavouriteAdvocateFromJson(json);

@override final  String id;
@override final  String advocateCode;
@override final  String? advocateName;
@override final  String? label;
@override final  String createdAt;

/// Create a copy of FavouriteAdvocate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavouriteAdvocateCopyWith<_FavouriteAdvocate> get copyWith => __$FavouriteAdvocateCopyWithImpl<_FavouriteAdvocate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavouriteAdvocateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavouriteAdvocate&&(identical(other.id, id) || other.id == id)&&(identical(other.advocateCode, advocateCode) || other.advocateCode == advocateCode)&&(identical(other.advocateName, advocateName) || other.advocateName == advocateName)&&(identical(other.label, label) || other.label == label)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,advocateCode,advocateName,label,createdAt);
}

@override
String toString() {
    return 'FavouriteAdvocate(id: $id, advocateCode: $advocateCode, advocateName: $advocateName, label: $label, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavouriteAdvocateCopyWith<$Res> implements $FavouriteAdvocateCopyWith<$Res> {
  factory _$FavouriteAdvocateCopyWith(_FavouriteAdvocate value, $Res Function(_FavouriteAdvocate) _then) = __$FavouriteAdvocateCopyWithImpl;
@override @useResult
$Res call({
 String id, String advocateCode, String? advocateName, String? label, String createdAt
});




}
/// @nodoc
class __$FavouriteAdvocateCopyWithImpl<$Res>
    implements _$FavouriteAdvocateCopyWith<$Res> {
  __$FavouriteAdvocateCopyWithImpl(this._self, this._then);

  final _FavouriteAdvocate _self;
  final $Res Function(_FavouriteAdvocate) _then;

/// Create a copy of FavouriteAdvocate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? advocateCode = null,Object? advocateName = freezed,Object? label = freezed,Object? createdAt = null,}) {
  return _then(_FavouriteAdvocate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,advocateCode: null == advocateCode ? _self.advocateCode : advocateCode // ignore: cast_nullable_to_non_nullable
as String,advocateName: freezed == advocateName ? _self.advocateName : advocateName // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$FavouriteCase {

 String get id; String get caseId; String get caseNumber; String? get note; String? get petitioner; String? get respondent; String get createdAt;
/// Create a copy of FavouriteCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavouriteCaseCopyWith<FavouriteCase> get copyWith => _$FavouriteCaseCopyWithImpl<FavouriteCase>(this as FavouriteCase, _$identity);

  /// Serializes this FavouriteCase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FavouriteCase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavouriteCase&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.caseId, _this.caseId) || other.caseId == _this.caseId)&&(identical(other.caseNumber, _this.caseNumber) || other.caseNumber == _this.caseNumber)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.petitioner, _this.petitioner) || other.petitioner == _this.petitioner)&&(identical(other.respondent, _this.respondent) || other.respondent == _this.respondent)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FavouriteCase;
  return Object.hash(runtimeType,_this.id,_this.caseId,_this.caseNumber,_this.note,_this.petitioner,_this.respondent,_this.createdAt);
}

@override
String toString() {
  final _this = this as FavouriteCase;
  return 'FavouriteCase(id: ${_this.id}, caseId: ${_this.caseId}, caseNumber: ${_this.caseNumber}, note: ${_this.note}, petitioner: ${_this.petitioner}, respondent: ${_this.respondent}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $FavouriteCaseCopyWith<$Res>  {
  factory $FavouriteCaseCopyWith(FavouriteCase value, $Res Function(FavouriteCase) _then) = _$FavouriteCaseCopyWithImpl;
@useResult
$Res call({
 String id, String caseId, String caseNumber, String? note, String? petitioner, String? respondent, String createdAt
});




}
/// @nodoc
class _$FavouriteCaseCopyWithImpl<$Res>
    implements $FavouriteCaseCopyWith<$Res> {
  _$FavouriteCaseCopyWithImpl(this._self, this._then);

  final FavouriteCase _self;
  final $Res Function(FavouriteCase) _then;

/// Create a copy of FavouriteCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? caseId = null,Object? caseNumber = null,Object? note = freezed,Object? petitioner = freezed,Object? respondent = freezed,Object? createdAt = null,}) {
  return _then(FavouriteCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FavouriteCase].
extension FavouriteCasePatterns on FavouriteCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavouriteCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavouriteCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavouriteCase value)  $default,){
final _that = this;
switch (_that) {
case _FavouriteCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavouriteCase value)?  $default,){
final _that = this;
switch (_that) {
case _FavouriteCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String caseId,  String caseNumber,  String? note,  String? petitioner,  String? respondent,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavouriteCase() when $default != null:
return $default(_that.id,_that.caseId,_that.caseNumber,_that.note,_that.petitioner,_that.respondent,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String caseId,  String caseNumber,  String? note,  String? petitioner,  String? respondent,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _FavouriteCase():
return $default(_that.id,_that.caseId,_that.caseNumber,_that.note,_that.petitioner,_that.respondent,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String caseId,  String caseNumber,  String? note,  String? petitioner,  String? respondent,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FavouriteCase() when $default != null:
return $default(_that.id,_that.caseId,_that.caseNumber,_that.note,_that.petitioner,_that.respondent,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavouriteCase implements FavouriteCase {
  const _FavouriteCase({required this.id, required this.caseId, required this.caseNumber, this.note, this.petitioner, this.respondent, required this.createdAt});
  factory _FavouriteCase.fromJson(Map<String, dynamic> json) => _$FavouriteCaseFromJson(json);

@override final  String id;
@override final  String caseId;
@override final  String caseNumber;
@override final  String? note;
@override final  String? petitioner;
@override final  String? respondent;
@override final  String createdAt;

/// Create a copy of FavouriteCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavouriteCaseCopyWith<_FavouriteCase> get copyWith => __$FavouriteCaseCopyWithImpl<_FavouriteCase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavouriteCaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavouriteCase&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.note, note) || other.note == note)&&(identical(other.petitioner, petitioner) || other.petitioner == petitioner)&&(identical(other.respondent, respondent) || other.respondent == respondent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,caseId,caseNumber,note,petitioner,respondent,createdAt);
}

@override
String toString() {
    return 'FavouriteCase(id: $id, caseId: $caseId, caseNumber: $caseNumber, note: $note, petitioner: $petitioner, respondent: $respondent, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FavouriteCaseCopyWith<$Res> implements $FavouriteCaseCopyWith<$Res> {
  factory _$FavouriteCaseCopyWith(_FavouriteCase value, $Res Function(_FavouriteCase) _then) = __$FavouriteCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String caseId, String caseNumber, String? note, String? petitioner, String? respondent, String createdAt
});




}
/// @nodoc
class __$FavouriteCaseCopyWithImpl<$Res>
    implements _$FavouriteCaseCopyWith<$Res> {
  __$FavouriteCaseCopyWithImpl(this._self, this._then);

  final _FavouriteCase _self;
  final $Res Function(_FavouriteCase) _then;

/// Create a copy of FavouriteCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? caseId = null,Object? caseNumber = null,Object? note = freezed,Object? petitioner = freezed,Object? respondent = freezed,Object? createdAt = null,}) {
  return _then(_FavouriteCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AppNotification {

 String get id; String get category; String get title; String get body; String? get deepLink; Map<String, dynamic> get data; bool get read; String get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AppNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.deepLink, _this.deepLink) || other.deepLink == _this.deepLink)&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.read, _this.read) || other.read == _this.read)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AppNotification;
  return Object.hash(runtimeType,_this.id,_this.category,_this.title,_this.body,_this.deepLink,const DeepCollectionEquality().hash(_this.data),_this.read,_this.createdAt);
}

@override
String toString() {
  final _this = this as AppNotification;
  return 'AppNotification(id: ${_this.id}, category: ${_this.category}, title: ${_this.title}, body: ${_this.body}, deepLink: ${_this.deepLink}, data: ${_this.data}, read: ${_this.read}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String category, String title, String body, String? deepLink, Map<String, dynamic> data, bool read, String createdAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? title = null,Object? body = null,Object? deepLink = freezed,Object? data = null,Object? read = null,Object? createdAt = null,}) {
  return _then(AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String title,  String body,  String? deepLink,  Map<String, dynamic> data,  bool read,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.category,_that.title,_that.body,_that.deepLink,_that.data,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String title,  String body,  String? deepLink,  Map<String, dynamic> data,  bool read,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.category,_that.title,_that.body,_that.deepLink,_that.data,_that.read,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String title,  String body,  String? deepLink,  Map<String, dynamic> data,  bool read,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.category,_that.title,_that.body,_that.deepLink,_that.data,_that.read,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({required this.id, required this.category, required this.title, required this.body, this.deepLink,  Map<String, dynamic> data = const {}, this.read = false, required this.createdAt}): _data = data;
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  String id;
@override final  String category;
@override final  String title;
@override final  String body;
@override final  String? deepLink;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override@JsonKey() final  bool read;
@override final  String createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&const DeepCollectionEquality().equals(other.data, _data)&&(identical(other.read, read) || other.read == read)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,category,title,body,deepLink,const DeepCollectionEquality().hash(_data),read,createdAt);
}

@override
String toString() {
    return 'AppNotification(id: $id, category: $category, title: $title, body: $body, deepLink: $deepLink, data: $data, read: $read, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String title, String body, String? deepLink, Map<String, dynamic> data, bool read, String createdAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? title = null,Object? body = null,Object? deepLink = freezed,Object? data = null,Object? read = null,Object? createdAt = null,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$NotificationPage {

 List<AppNotification> get items; int get unreadCount; int get total;
/// Create a copy of NotificationPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPageCopyWith<NotificationPage> get copyWith => _$NotificationPageCopyWithImpl<NotificationPage>(this as NotificationPage, _$identity);

  /// Serializes this NotificationPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPage&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.unreadCount, _this.unreadCount) || other.unreadCount == _this.unreadCount)&&(identical(other.total, _this.total) || other.total == _this.total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationPage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items),_this.unreadCount,_this.total);
}

@override
String toString() {
  final _this = this as NotificationPage;
  return 'NotificationPage(items: ${_this.items}, unreadCount: ${_this.unreadCount}, total: ${_this.total})';
}


}

/// @nodoc
abstract mixin class $NotificationPageCopyWith<$Res>  {
  factory $NotificationPageCopyWith(NotificationPage value, $Res Function(NotificationPage) _then) = _$NotificationPageCopyWithImpl;
@useResult
$Res call({
 List<AppNotification> items, int unreadCount, int total
});




}
/// @nodoc
class _$NotificationPageCopyWithImpl<$Res>
    implements $NotificationPageCopyWith<$Res> {
  _$NotificationPageCopyWithImpl(this._self, this._then);

  final NotificationPage _self;
  final $Res Function(NotificationPage) _then;

/// Create a copy of NotificationPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? unreadCount = null,Object? total = null,}) {
  return _then(NotificationPage(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPage].
extension NotificationPagePatterns on NotificationPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPage value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPage value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AppNotification> items,  int unreadCount,  int total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPage() when $default != null:
return $default(_that.items,_that.unreadCount,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AppNotification> items,  int unreadCount,  int total)  $default,) {final _that = this;
switch (_that) {
case _NotificationPage():
return $default(_that.items,_that.unreadCount,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AppNotification> items,  int unreadCount,  int total)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPage() when $default != null:
return $default(_that.items,_that.unreadCount,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPage implements NotificationPage {
  const _NotificationPage({ List<AppNotification> items = const [], this.unreadCount = 0, this.total = 0}): _items = items;
  factory _NotificationPage.fromJson(Map<String, dynamic> json) => _$NotificationPageFromJson(json);

 final  List<AppNotification> _items;
@override@JsonKey() List<AppNotification> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  int total;

/// Create a copy of NotificationPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPageCopyWith<_NotificationPage> get copyWith => __$NotificationPageCopyWithImpl<_NotificationPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPage&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),unreadCount,total);
}

@override
String toString() {
    return 'NotificationPage(items: $items, unreadCount: $unreadCount, total: $total)';
}


}

/// @nodoc
abstract mixin class _$NotificationPageCopyWith<$Res> implements $NotificationPageCopyWith<$Res> {
  factory _$NotificationPageCopyWith(_NotificationPage value, $Res Function(_NotificationPage) _then) = __$NotificationPageCopyWithImpl;
@override @useResult
$Res call({
 List<AppNotification> items, int unreadCount, int total
});




}
/// @nodoc
class __$NotificationPageCopyWithImpl<$Res>
    implements _$NotificationPageCopyWith<$Res> {
  __$NotificationPageCopyWithImpl(this._self, this._then);

  final _NotificationPage _self;
  final $Res Function(_NotificationPage) _then;

/// Create a copy of NotificationPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? unreadCount = null,Object? total = null,}) {
  return _then(_NotificationPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$NotificationPrefs {

 bool get causeListPublication; bool get favouriteAdvocates; bool get caseUpdates; bool get courtBoard; bool get enrichment; bool get announcements;
/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPrefsCopyWith<NotificationPrefs> get copyWith => _$NotificationPrefsCopyWithImpl<NotificationPrefs>(this as NotificationPrefs, _$identity);

  /// Serializes this NotificationPrefs to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NotificationPrefs;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPrefs&&(identical(other.causeListPublication, _this.causeListPublication) || other.causeListPublication == _this.causeListPublication)&&(identical(other.favouriteAdvocates, _this.favouriteAdvocates) || other.favouriteAdvocates == _this.favouriteAdvocates)&&(identical(other.caseUpdates, _this.caseUpdates) || other.caseUpdates == _this.caseUpdates)&&(identical(other.courtBoard, _this.courtBoard) || other.courtBoard == _this.courtBoard)&&(identical(other.enrichment, _this.enrichment) || other.enrichment == _this.enrichment)&&(identical(other.announcements, _this.announcements) || other.announcements == _this.announcements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NotificationPrefs;
  return Object.hash(runtimeType,_this.causeListPublication,_this.favouriteAdvocates,_this.caseUpdates,_this.courtBoard,_this.enrichment,_this.announcements);
}

@override
String toString() {
  final _this = this as NotificationPrefs;
  return 'NotificationPrefs(causeListPublication: ${_this.causeListPublication}, favouriteAdvocates: ${_this.favouriteAdvocates}, caseUpdates: ${_this.caseUpdates}, courtBoard: ${_this.courtBoard}, enrichment: ${_this.enrichment}, announcements: ${_this.announcements})';
}


}

/// @nodoc
abstract mixin class $NotificationPrefsCopyWith<$Res>  {
  factory $NotificationPrefsCopyWith(NotificationPrefs value, $Res Function(NotificationPrefs) _then) = _$NotificationPrefsCopyWithImpl;
@useResult
$Res call({
 bool causeListPublication, bool favouriteAdvocates, bool caseUpdates, bool courtBoard, bool enrichment, bool announcements
});




}
/// @nodoc
class _$NotificationPrefsCopyWithImpl<$Res>
    implements $NotificationPrefsCopyWith<$Res> {
  _$NotificationPrefsCopyWithImpl(this._self, this._then);

  final NotificationPrefs _self;
  final $Res Function(NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? causeListPublication = null,Object? favouriteAdvocates = null,Object? caseUpdates = null,Object? courtBoard = null,Object? enrichment = null,Object? announcements = null,}) {
  return _then(NotificationPrefs(
causeListPublication: null == causeListPublication ? _self.causeListPublication : causeListPublication // ignore: cast_nullable_to_non_nullable
as bool,favouriteAdvocates: null == favouriteAdvocates ? _self.favouriteAdvocates : favouriteAdvocates // ignore: cast_nullable_to_non_nullable
as bool,caseUpdates: null == caseUpdates ? _self.caseUpdates : caseUpdates // ignore: cast_nullable_to_non_nullable
as bool,courtBoard: null == courtBoard ? _self.courtBoard : courtBoard // ignore: cast_nullable_to_non_nullable
as bool,enrichment: null == enrichment ? _self.enrichment : enrichment // ignore: cast_nullable_to_non_nullable
as bool,announcements: null == announcements ? _self.announcements : announcements // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPrefs].
extension NotificationPrefsPatterns on NotificationPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPrefs value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool causeListPublication,  bool favouriteAdvocates,  bool caseUpdates,  bool courtBoard,  bool enrichment,  bool announcements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.causeListPublication,_that.favouriteAdvocates,_that.caseUpdates,_that.courtBoard,_that.enrichment,_that.announcements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool causeListPublication,  bool favouriteAdvocates,  bool caseUpdates,  bool courtBoard,  bool enrichment,  bool announcements)  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs():
return $default(_that.causeListPublication,_that.favouriteAdvocates,_that.caseUpdates,_that.courtBoard,_that.enrichment,_that.announcements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool causeListPublication,  bool favouriteAdvocates,  bool caseUpdates,  bool courtBoard,  bool enrichment,  bool announcements)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPrefs() when $default != null:
return $default(_that.causeListPublication,_that.favouriteAdvocates,_that.caseUpdates,_that.courtBoard,_that.enrichment,_that.announcements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPrefs implements NotificationPrefs {
  const _NotificationPrefs({this.causeListPublication = true, this.favouriteAdvocates = true, this.caseUpdates = true, this.courtBoard = true, this.enrichment = true, this.announcements = true});
  factory _NotificationPrefs.fromJson(Map<String, dynamic> json) => _$NotificationPrefsFromJson(json);

@override@JsonKey() final  bool causeListPublication;
@override@JsonKey() final  bool favouriteAdvocates;
@override@JsonKey() final  bool caseUpdates;
@override@JsonKey() final  bool courtBoard;
@override@JsonKey() final  bool enrichment;
@override@JsonKey() final  bool announcements;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPrefsCopyWith<_NotificationPrefs> get copyWith => __$NotificationPrefsCopyWithImpl<_NotificationPrefs>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPrefsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPrefs&&(identical(other.causeListPublication, causeListPublication) || other.causeListPublication == causeListPublication)&&(identical(other.favouriteAdvocates, favouriteAdvocates) || other.favouriteAdvocates == favouriteAdvocates)&&(identical(other.caseUpdates, caseUpdates) || other.caseUpdates == caseUpdates)&&(identical(other.courtBoard, courtBoard) || other.courtBoard == courtBoard)&&(identical(other.enrichment, enrichment) || other.enrichment == enrichment)&&(identical(other.announcements, announcements) || other.announcements == announcements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,causeListPublication,favouriteAdvocates,caseUpdates,courtBoard,enrichment,announcements);
}

@override
String toString() {
    return 'NotificationPrefs(causeListPublication: $causeListPublication, favouriteAdvocates: $favouriteAdvocates, caseUpdates: $caseUpdates, courtBoard: $courtBoard, enrichment: $enrichment, announcements: $announcements)';
}


}

/// @nodoc
abstract mixin class _$NotificationPrefsCopyWith<$Res> implements $NotificationPrefsCopyWith<$Res> {
  factory _$NotificationPrefsCopyWith(_NotificationPrefs value, $Res Function(_NotificationPrefs) _then) = __$NotificationPrefsCopyWithImpl;
@override @useResult
$Res call({
 bool causeListPublication, bool favouriteAdvocates, bool caseUpdates, bool courtBoard, bool enrichment, bool announcements
});




}
/// @nodoc
class __$NotificationPrefsCopyWithImpl<$Res>
    implements _$NotificationPrefsCopyWith<$Res> {
  __$NotificationPrefsCopyWithImpl(this._self, this._then);

  final _NotificationPrefs _self;
  final $Res Function(_NotificationPrefs) _then;

/// Create a copy of NotificationPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? causeListPublication = null,Object? favouriteAdvocates = null,Object? caseUpdates = null,Object? courtBoard = null,Object? enrichment = null,Object? announcements = null,}) {
  return _then(_NotificationPrefs(
causeListPublication: null == causeListPublication ? _self.causeListPublication : causeListPublication // ignore: cast_nullable_to_non_nullable
as bool,favouriteAdvocates: null == favouriteAdvocates ? _self.favouriteAdvocates : favouriteAdvocates // ignore: cast_nullable_to_non_nullable
as bool,caseUpdates: null == caseUpdates ? _self.caseUpdates : caseUpdates // ignore: cast_nullable_to_non_nullable
as bool,courtBoard: null == courtBoard ? _self.courtBoard : courtBoard // ignore: cast_nullable_to_non_nullable
as bool,enrichment: null == enrichment ? _self.enrichment : enrichment // ignore: cast_nullable_to_non_nullable
as bool,announcements: null == announcements ? _self.announcements : announcements // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LastListed {

 String get listDate; String get courtNo; String get itemNo;
/// Create a copy of LastListed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastListedCopyWith<LastListed> get copyWith => _$LastListedCopyWithImpl<LastListed>(this as LastListed, _$identity);

  /// Serializes this LastListed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LastListed;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastListed&&(identical(other.listDate, _this.listDate) || other.listDate == _this.listDate)&&(identical(other.courtNo, _this.courtNo) || other.courtNo == _this.courtNo)&&(identical(other.itemNo, _this.itemNo) || other.itemNo == _this.itemNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LastListed;
  return Object.hash(runtimeType,_this.listDate,_this.courtNo,_this.itemNo);
}

@override
String toString() {
  final _this = this as LastListed;
  return 'LastListed(listDate: ${_this.listDate}, courtNo: ${_this.courtNo}, itemNo: ${_this.itemNo})';
}


}

/// @nodoc
abstract mixin class $LastListedCopyWith<$Res>  {
  factory $LastListedCopyWith(LastListed value, $Res Function(LastListed) _then) = _$LastListedCopyWithImpl;
@useResult
$Res call({
 String listDate, String courtNo, String itemNo
});




}
/// @nodoc
class _$LastListedCopyWithImpl<$Res>
    implements $LastListedCopyWith<$Res> {
  _$LastListedCopyWithImpl(this._self, this._then);

  final LastListed _self;
  final $Res Function(LastListed) _then;

/// Create a copy of LastListed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listDate = null,Object? courtNo = null,Object? itemNo = null,}) {
  return _then(LastListed(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LastListed].
extension LastListedPatterns on LastListed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastListed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastListed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastListed value)  $default,){
final _that = this;
switch (_that) {
case _LastListed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastListed value)?  $default,){
final _that = this;
switch (_that) {
case _LastListed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listDate,  String courtNo,  String itemNo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastListed() when $default != null:
return $default(_that.listDate,_that.courtNo,_that.itemNo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listDate,  String courtNo,  String itemNo)  $default,) {final _that = this;
switch (_that) {
case _LastListed():
return $default(_that.listDate,_that.courtNo,_that.itemNo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listDate,  String courtNo,  String itemNo)?  $default,) {final _that = this;
switch (_that) {
case _LastListed() when $default != null:
return $default(_that.listDate,_that.courtNo,_that.itemNo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastListed implements LastListed {
  const _LastListed({required this.listDate, required this.courtNo, required this.itemNo});
  factory _LastListed.fromJson(Map<String, dynamic> json) => _$LastListedFromJson(json);

@override final  String listDate;
@override final  String courtNo;
@override final  String itemNo;

/// Create a copy of LastListed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastListedCopyWith<_LastListed> get copyWith => __$LastListedCopyWithImpl<_LastListed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastListedToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastListed&&(identical(other.listDate, listDate) || other.listDate == listDate)&&(identical(other.courtNo, courtNo) || other.courtNo == courtNo)&&(identical(other.itemNo, itemNo) || other.itemNo == itemNo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,listDate,courtNo,itemNo);
}

@override
String toString() {
    return 'LastListed(listDate: $listDate, courtNo: $courtNo, itemNo: $itemNo)';
}


}

/// @nodoc
abstract mixin class _$LastListedCopyWith<$Res> implements $LastListedCopyWith<$Res> {
  factory _$LastListedCopyWith(_LastListed value, $Res Function(_LastListed) _then) = __$LastListedCopyWithImpl;
@override @useResult
$Res call({
 String listDate, String courtNo, String itemNo
});




}
/// @nodoc
class __$LastListedCopyWithImpl<$Res>
    implements _$LastListedCopyWith<$Res> {
  __$LastListedCopyWithImpl(this._self, this._then);

  final _LastListed _self;
  final $Res Function(_LastListed) _then;

/// Create a copy of LastListed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listDate = null,Object? courtNo = null,Object? itemNo = null,}) {
  return _then(_LastListed(
listDate: null == listDate ? _self.listDate : listDate // ignore: cast_nullable_to_non_nullable
as String,courtNo: null == courtNo ? _self.courtNo : courtNo // ignore: cast_nullable_to_non_nullable
as String,itemNo: null == itemNo ? _self.itemNo : itemNo // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SearchResult {

 String get caseId; String get caseNumber; String? get petitioner; String? get respondent; String? get status; LastListed? get lastListed;
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResultCopyWith<SearchResult> get copyWith => _$SearchResultCopyWithImpl<SearchResult>(this as SearchResult, _$identity);

  /// Serializes this SearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult&&(identical(other.caseId, _this.caseId) || other.caseId == _this.caseId)&&(identical(other.caseNumber, _this.caseNumber) || other.caseNumber == _this.caseNumber)&&(identical(other.petitioner, _this.petitioner) || other.petitioner == _this.petitioner)&&(identical(other.respondent, _this.respondent) || other.respondent == _this.respondent)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastListed, _this.lastListed) || other.lastListed == _this.lastListed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchResult;
  return Object.hash(runtimeType,_this.caseId,_this.caseNumber,_this.petitioner,_this.respondent,_this.status,_this.lastListed);
}

@override
String toString() {
  final _this = this as SearchResult;
  return 'SearchResult(caseId: ${_this.caseId}, caseNumber: ${_this.caseNumber}, petitioner: ${_this.petitioner}, respondent: ${_this.respondent}, status: ${_this.status}, lastListed: ${_this.lastListed})';
}


}

/// @nodoc
abstract mixin class $SearchResultCopyWith<$Res>  {
  factory $SearchResultCopyWith(SearchResult value, $Res Function(SearchResult) _then) = _$SearchResultCopyWithImpl;
@useResult
$Res call({
 String caseId, String caseNumber, String? petitioner, String? respondent, String? status, LastListed? lastListed
});


$LastListedCopyWith<$Res>? get lastListed;

}
/// @nodoc
class _$SearchResultCopyWithImpl<$Res>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._self, this._then);

  final SearchResult _self;
  final $Res Function(SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? caseNumber = null,Object? petitioner = freezed,Object? respondent = freezed,Object? status = freezed,Object? lastListed = freezed,}) {
  return _then(SearchResult(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,lastListed: freezed == lastListed ? _self.lastListed : lastListed // ignore: cast_nullable_to_non_nullable
as LastListed?,
  ));
}
/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastListedCopyWith<$Res>? get lastListed {
    if (_self.lastListed == null) {
    return null;
  }

  return $LastListedCopyWith<$Res>(_self.lastListed!, (value) {
    return _then(_self.copyWith(lastListed: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchResult].
extension SearchResultPatterns on SearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String? petitioner,  String? respondent,  String? status,  LastListed? lastListed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.petitioner,_that.respondent,_that.status,_that.lastListed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String? petitioner,  String? respondent,  String? status,  LastListed? lastListed)  $default,) {final _that = this;
switch (_that) {
case _SearchResult():
return $default(_that.caseId,_that.caseNumber,_that.petitioner,_that.respondent,_that.status,_that.lastListed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String caseNumber,  String? petitioner,  String? respondent,  String? status,  LastListed? lastListed)?  $default,) {final _that = this;
switch (_that) {
case _SearchResult() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.petitioner,_that.respondent,_that.status,_that.lastListed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResult implements SearchResult {
  const _SearchResult({required this.caseId, required this.caseNumber, this.petitioner, this.respondent, this.status, this.lastListed});
  factory _SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);

@override final  String caseId;
@override final  String caseNumber;
@override final  String? petitioner;
@override final  String? respondent;
@override final  String? status;
@override final  LastListed? lastListed;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResultCopyWith<_SearchResult> get copyWith => __$SearchResultCopyWithImpl<_SearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResult&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.petitioner, petitioner) || other.petitioner == petitioner)&&(identical(other.respondent, respondent) || other.respondent == respondent)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastListed, lastListed) || other.lastListed == lastListed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,caseId,caseNumber,petitioner,respondent,status,lastListed);
}

@override
String toString() {
    return 'SearchResult(caseId: $caseId, caseNumber: $caseNumber, petitioner: $petitioner, respondent: $respondent, status: $status, lastListed: $lastListed)';
}


}

/// @nodoc
abstract mixin class _$SearchResultCopyWith<$Res> implements $SearchResultCopyWith<$Res> {
  factory _$SearchResultCopyWith(_SearchResult value, $Res Function(_SearchResult) _then) = __$SearchResultCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String caseNumber, String? petitioner, String? respondent, String? status, LastListed? lastListed
});


@override $LastListedCopyWith<$Res>? get lastListed;

}
/// @nodoc
class __$SearchResultCopyWithImpl<$Res>
    implements _$SearchResultCopyWith<$Res> {
  __$SearchResultCopyWithImpl(this._self, this._then);

  final _SearchResult _self;
  final $Res Function(_SearchResult) _then;

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? caseNumber = null,Object? petitioner = freezed,Object? respondent = freezed,Object? status = freezed,Object? lastListed = freezed,}) {
  return _then(_SearchResult(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,petitioner: freezed == petitioner ? _self.petitioner : petitioner // ignore: cast_nullable_to_non_nullable
as String?,respondent: freezed == respondent ? _self.respondent : respondent // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,lastListed: freezed == lastListed ? _self.lastListed : lastListed // ignore: cast_nullable_to_non_nullable
as LastListed?,
  ));
}

/// Create a copy of SearchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastListedCopyWith<$Res>? get lastListed {
    if (_self.lastListed == null) {
    return null;
  }

  return $LastListedCopyWith<$Res>(_self.lastListed!, (value) {
    return _then(_self.copyWith(lastListed: value));
  });
}
}


/// @nodoc
mixin _$SearchResponse {

 int get total; List<SearchResult> get results; String? get exactCaseNumber; bool get exactCaseKnown; String? get hint;
/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchResponseCopyWith<SearchResponse> get copyWith => _$SearchResponseCopyWithImpl<SearchResponse>(this as SearchResponse, _$identity);

  /// Serializes this SearchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SearchResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResponse&&(identical(other.total, _this.total) || other.total == _this.total)&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.exactCaseNumber, _this.exactCaseNumber) || other.exactCaseNumber == _this.exactCaseNumber)&&(identical(other.exactCaseKnown, _this.exactCaseKnown) || other.exactCaseKnown == _this.exactCaseKnown)&&(identical(other.hint, _this.hint) || other.hint == _this.hint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SearchResponse;
  return Object.hash(runtimeType,_this.total,const DeepCollectionEquality().hash(_this.results),_this.exactCaseNumber,_this.exactCaseKnown,_this.hint);
}

@override
String toString() {
  final _this = this as SearchResponse;
  return 'SearchResponse(total: ${_this.total}, results: ${_this.results}, exactCaseNumber: ${_this.exactCaseNumber}, exactCaseKnown: ${_this.exactCaseKnown}, hint: ${_this.hint})';
}


}

/// @nodoc
abstract mixin class $SearchResponseCopyWith<$Res>  {
  factory $SearchResponseCopyWith(SearchResponse value, $Res Function(SearchResponse) _then) = _$SearchResponseCopyWithImpl;
@useResult
$Res call({
 int total, List<SearchResult> results, String? exactCaseNumber, bool exactCaseKnown, String? hint
});




}
/// @nodoc
class _$SearchResponseCopyWithImpl<$Res>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._self, this._then);

  final SearchResponse _self;
  final $Res Function(SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? results = null,Object? exactCaseNumber = freezed,Object? exactCaseKnown = null,Object? hint = freezed,}) {
  return _then(SearchResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,exactCaseNumber: freezed == exactCaseNumber ? _self.exactCaseNumber : exactCaseNumber // ignore: cast_nullable_to_non_nullable
as String?,exactCaseKnown: null == exactCaseKnown ? _self.exactCaseKnown : exactCaseKnown // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchResponse].
extension SearchResponsePatterns on SearchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchResponse value)  $default,){
final _that = this;
switch (_that) {
case _SearchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  List<SearchResult> results,  String? exactCaseNumber,  bool exactCaseKnown,  String? hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
return $default(_that.total,_that.results,_that.exactCaseNumber,_that.exactCaseKnown,_that.hint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  List<SearchResult> results,  String? exactCaseNumber,  bool exactCaseKnown,  String? hint)  $default,) {final _that = this;
switch (_that) {
case _SearchResponse():
return $default(_that.total,_that.results,_that.exactCaseNumber,_that.exactCaseKnown,_that.hint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  List<SearchResult> results,  String? exactCaseNumber,  bool exactCaseKnown,  String? hint)?  $default,) {final _that = this;
switch (_that) {
case _SearchResponse() when $default != null:
return $default(_that.total,_that.results,_that.exactCaseNumber,_that.exactCaseKnown,_that.hint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchResponse implements SearchResponse {
  const _SearchResponse({this.total = 0,  List<SearchResult> results = const [], this.exactCaseNumber, this.exactCaseKnown = false, this.hint}): _results = results;
  factory _SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);

@override@JsonKey() final  int total;
 final  List<SearchResult> _results;
@override@JsonKey() List<SearchResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override final  String? exactCaseNumber;
@override@JsonKey() final  bool exactCaseKnown;
@override final  String? hint;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchResponseCopyWith<_SearchResponse> get copyWith => __$SearchResponseCopyWithImpl<_SearchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchResponse&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.exactCaseNumber, exactCaseNumber) || other.exactCaseNumber == exactCaseNumber)&&(identical(other.exactCaseKnown, exactCaseKnown) || other.exactCaseKnown == exactCaseKnown)&&(identical(other.hint, hint) || other.hint == hint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_results),exactCaseNumber,exactCaseKnown,hint);
}

@override
String toString() {
    return 'SearchResponse(total: $total, results: $results, exactCaseNumber: $exactCaseNumber, exactCaseKnown: $exactCaseKnown, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$SearchResponseCopyWith<$Res> implements $SearchResponseCopyWith<$Res> {
  factory _$SearchResponseCopyWith(_SearchResponse value, $Res Function(_SearchResponse) _then) = __$SearchResponseCopyWithImpl;
@override @useResult
$Res call({
 int total, List<SearchResult> results, String? exactCaseNumber, bool exactCaseKnown, String? hint
});




}
/// @nodoc
class __$SearchResponseCopyWithImpl<$Res>
    implements _$SearchResponseCopyWith<$Res> {
  __$SearchResponseCopyWithImpl(this._self, this._then);

  final _SearchResponse _self;
  final $Res Function(_SearchResponse) _then;

/// Create a copy of SearchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? results = null,Object? exactCaseNumber = freezed,Object? exactCaseKnown = null,Object? hint = freezed,}) {
  return _then(_SearchResponse(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<SearchResult>,exactCaseNumber: freezed == exactCaseNumber ? _self.exactCaseNumber : exactCaseNumber // ignore: cast_nullable_to_non_nullable
as String?,exactCaseKnown: null == exactCaseKnown ? _self.exactCaseKnown : exactCaseKnown // ignore: cast_nullable_to_non_nullable
as bool,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
