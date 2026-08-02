import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:journexa_app/shared/app_env.dart';
import 'package:uuid/uuid.dart';

const _kServerClientId =
    '258991680918-fi3vhtmuevq9qlkj06f7512j6lthonok.apps.googleusercontent.com';

/// Module that includes external dependencies
@module
abstract class ExternalModule {
  /// Instance of [FirebaseAuth]
  @lazySingleton
  @preResolve
  Future<FirebaseAuth> get firebaseAuth async {
    if (AppEnv.isDebug) {
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }
    return FirebaseAuth.instance;
  }

  /// Instance of [GoogleSignIn]
  @lazySingleton
  @preResolve
  Future<GoogleSignIn> get googleSignIn async {
    await GoogleSignIn.instance.initialize(serverClientId: _kServerClientId);
    return GoogleSignIn.instance;
  }

  /// Instance of [Uuid]
  @lazySingleton
  Uuid get uuid => const Uuid();
}
