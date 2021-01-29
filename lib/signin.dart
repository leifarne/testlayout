import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signIn() async {
  final firebaseAuth = FirebaseAuth.instance;
  print(firebaseAuth);
  print('current user = ${firebaseAuth.currentUser?.email}');

  if (firebaseAuth.currentUser != null) {
    return firebaseAuth.currentUser.email;
  }

  final credential = await getAuthCredentialWithGoogleSignIn();

  final UserCredential userCredential =
      await firebaseAuth.signInWithCredential(credential);

  // sorry...
  if (userCredential.user == null) {
    return null;
  }

  // Successful login.
  print('User: ${userCredential.user.email}');
  return userCredential.user.email;
}

Future<AuthCredential> getAuthCredentialWithGoogleSignIn() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  return credential;
}
