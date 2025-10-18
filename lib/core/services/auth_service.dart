import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get ID token for API requests
  static Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Save additional user info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_mobile', mobile);
      await prefs.setString('user_email', email);

      return result;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Save Google user info to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', result.user?.displayName ?? 'NA');
      await prefs.setString('user_email', result.user?.email ?? 'NA');
      await prefs.setString('user_mobile', 'NA');

      return result;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Check if user profile is complete
  static Future<bool> isProfileComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? '';
      final mobile = prefs.getString('user_mobile') ?? '';
      final email = prefs.getString('user_email') ?? '';

      // Profile is complete if mobile is not "NA" (user has entered their mobile)
      return name.isNotEmpty &&
          mobile.isNotEmpty &&
          email.isNotEmpty &&
          mobile != 'NA';
    } catch (e) {
      print('Error checking profile completeness: $e');
      return false;
    }
  }

  // Update user profile
  static Future<void> updateProfile({
    required String name,
    required String mobile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_mobile', mobile);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  // Migrate empty strings to "NA" for existing users
  static Future<void> migrateEmptyStringsToNA() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check and update name
      final name = prefs.getString('user_name') ?? '';
      if (name.isEmpty) {
        await prefs.setString('user_name', 'NA');
      }

      // Check and update email
      final email = prefs.getString('user_email') ?? '';
      if (email.isEmpty) {
        await prefs.setString('user_email', 'NA');
      }

      // Check and update mobile
      final mobile = prefs.getString('user_mobile') ?? '';
      if (mobile.isEmpty) {
        await prefs.setString('user_mobile', 'NA');
      }
    } catch (e) {
      print('Error migrating empty strings: $e');
    }
  }

  // Get user profile data
  static Future<Map<String, String>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString('user_name') ?? '',
        'mobile': prefs.getString('user_mobile') ?? '',
        'email': prefs.getString('user_email') ?? '',
      };
    } catch (e) {
      print('Error getting user profile: $e');
      return {'name': '', 'mobile': '', 'email': ''};
    }
  }
}
