import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    // Trigger interactive sign-in
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    // if (googleUser == null) {
    //   throw Exception('Google sign-in cancelled');
    // }

    // v7+: ONLY idToken is needed for Firebase
    final GoogleSignInAuthentication auth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.disconnect();
    await _auth.signOut();
  }
}
