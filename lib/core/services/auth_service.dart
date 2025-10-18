import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/firebase_user_response.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Update user login status
  static Future<void> updateLoginStatus(bool isLoggedIn) async {
    try {
      final updateData = {
        'logged_in': isLoggedIn,
        'last_signed_in': DateTime.now().toIso8601String(),
      };

      print('Updating login status to: $isLoggedIn');
      final result = await ApiService.updateFirebaseUserProfile(updateData);
      if (result != null) {
        print('Login status updated successfully: ${result['updated_fields']}');
        // Refresh user data after status update
        final userData = await validateUserWithBackend();
        if (userData != null) {
          await saveFirebaseUserData(userData);
        }
      } else {
        print('Failed to update login status - API returned null');
      }
    } catch (e) {
      print('Error updating login status: $e');
      // Don't rethrow - we still want to sign out locally even if API fails
    }
  }

  // Upgrade user to premium
  static Future<bool> upgradeToPremium() async {
    try {
      final updateData = {
        'is_premium': true,
        'premium_expires_at': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'subscription_plan': 'premium_monthly',
        'logged_in': true,
        'last_signed_in': DateTime.now().toIso8601String(),
      };

      final result = await ApiService.updateFirebaseUserProfile(updateData);
      if (result != null) {
        print('User upgraded to premium: ${result['updated_fields']}');
        // Refresh user data after upgrade
        final userData = await validateUserWithBackend();
        if (userData != null) {
          await saveFirebaseUserData(userData);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error upgrading to premium: $e');
      return false;
    }
  }

  // Validate user with backend and get user data
  static Future<FirebaseUserResponse?> validateUserWithBackend() async {
    try {
      final userData = await ApiService.getFirebaseUser();
      if (userData != null) {
        return FirebaseUserResponse.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error validating user with backend: $e');
      rethrow;
    }
  }

  // Save Firebase user data to SharedPreferences
  static Future<void> saveFirebaseUserData(
    FirebaseUserResponse userData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', userData.uid);
      await prefs.setString('user_email', userData.email);
      await prefs.setBool('email_verified', userData.emailVerified);
      await prefs.setString('user_name', userData.name ?? 'NA');
      await prefs.setString('user_picture', userData.picture ?? '');
      // Save phone number to both user_phone and user_mobile for consistency
      await prefs.setString('user_phone', userData.phoneNumber ?? 'NA');
      await prefs.setString('user_mobile', userData.phoneNumber ?? 'NA');
      await prefs.setBool('is_premium', userData.isPremium);
      await prefs.setString(
        'subscription_plan',
        userData.subscriptionPlan ?? '',
      );
      await prefs.setString(
        'premium_expires_at',
        userData.premiumExpiresAt?.toIso8601String() ?? '',
      );
      await prefs.setBool('logged_in', userData.loggedIn);
    } catch (e) {
      print('Error saving Firebase user data: $e');
    }
  }

  // Get saved Firebase user data
  static Future<FirebaseUserResponse?> getSavedFirebaseUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('user_uid');
      if (uid == null) return null;

      return FirebaseUserResponse(
        uid: uid,
        email: prefs.getString('user_email') ?? '',
        emailVerified: prefs.getBool('email_verified') ?? false,
        name: prefs.getString('user_name'),
        picture: prefs.getString('user_picture'),
        phoneNumber: prefs.getString('user_phone'),
        isPremium: prefs.getBool('is_premium') ?? false,
        subscriptionPlan: prefs.getString('subscription_plan'),
        premiumExpiresAt:
            prefs.getString('premium_expires_at')?.isNotEmpty == true
            ? DateTime.parse(prefs.getString('premium_expires_at')!)
            : null,
        loggedIn: prefs.getBool('logged_in') ?? false,
        purchaseHistory: [], // Purchase history not saved locally
      );
    } catch (e) {
      print('Error getting saved Firebase user data: $e');
      return null;
    }
  }

  // Check if user is premium
  static Future<bool> isUserPremium() async {
    try {
      final userData = await getSavedFirebaseUserData();
      if (userData != null) {
        return userData.isPremium;
      }

      // Fallback: try to get fresh data from backend
      final freshData = await validateUserWithBackend();
      if (freshData != null) {
        await saveFirebaseUserData(freshData);
        return freshData.isPremium;
      }

      return false;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

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

      // Validate with backend after successful Firebase auth
      try {
        final userData = await validateUserWithBackend();
        if (userData != null) {
          await saveFirebaseUserData(userData);
          // Update login status to true
          await updateLoginStatus(true);
        }
      } catch (e) {
        // If backend validation fails, sign out from Firebase
        await _auth.signOut();
        rethrow;
      }

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

      // Validate with backend after successful Firebase auth
      try {
        final userData = await validateUserWithBackend();
        if (userData != null) {
          await saveFirebaseUserData(userData);
          // Update login status to true
          await updateLoginStatus(true);
        }
      } catch (e) {
        // If backend validation fails, sign out from Firebase
        await _auth.signOut();
        await _googleSignIn.signOut();
        rethrow;
      }

      return result;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      print('Starting sign out process...');

      // First, ensure we update login status to false
      print('Step 1: Updating login status to false...');
      bool loginStatusUpdated = false;

      try {
        final updateData = {
          'logged_in': false,
          'last_signed_in': DateTime.now().toIso8601String(),
        };

        print('Sending logout request to backend...');
        final result = await ApiService.updateFirebaseUserProfile(updateData);

        if (result != null) {
          print(
            '✅ Login status updated successfully: ${result['updated_fields']}',
          );
          loginStatusUpdated = true;
        } else {
          print('❌ Failed to update login status - API returned null');
        }
      } catch (e) {
        print('❌ Error updating login status: $e');
      }

      // Wait a moment to ensure API call completes
      if (loginStatusUpdated) {
        print('Step 2: Waiting for API call to complete...');
        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('Step 3: Proceeding with Firebase sign out...');

      // Sign out from Google and Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();

      print('Step 4: Clearing local data...');

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('✅ Sign out completed successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      // Even if there's an error, try to clear local data
      try {
        print('Attempting to clear local data despite error...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await _googleSignIn.signOut();
        await _auth.signOut();
        print('✅ Local data cleared despite error');
      } catch (clearError) {
        print('❌ Error clearing local data: $clearError');
      }
    }
  }

  // Check if user profile is complete
  static Future<bool> isProfileComplete() async {
    try {
      // First check if we have Firebase user data from backend
      final firebaseUserData = await getSavedFirebaseUserData();
      if (firebaseUserData != null) {
        print('Profile completeness check - Firebase data:');
        print('  Phone: ${firebaseUserData.phoneNumber}');
        print('  Name: ${firebaseUserData.name}');
        print('  Email: ${firebaseUserData.email}');

        // If phone number exists in backend data, profile is complete
        if (firebaseUserData.phoneNumber != null &&
            firebaseUserData.phoneNumber!.isNotEmpty &&
            firebaseUserData.phoneNumber != 'NA') {
          print('Profile is complete - phone number found in Firebase data');
          return true;
        }
      }

      // Fallback: check local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? '';
      final mobile = prefs.getString('user_mobile') ?? '';
      final email = prefs.getString('user_email') ?? '';

      print('Profile completeness check - Local data:');
      print('  Name: $name');
      print('  Mobile: $mobile');
      print('  Email: $email');

      // Profile is complete if mobile is not "NA" (user has entered their mobile)
      final isComplete =
          name.isNotEmpty &&
          mobile.isNotEmpty &&
          email.isNotEmpty &&
          mobile != 'NA';

      print('Profile completeness result: $isComplete');
      return isComplete;
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
      // Update local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_mobile', mobile);

      // Update backend API with phone number
      final updateData = {'phone_number': mobile, 'name': name};

      print('Updating profile with phone number: $mobile');
      final result = await ApiService.updateFirebaseUserProfile(updateData);
      if (result != null) {
        print('Profile updated successfully: ${result['updated_fields']}');
        // Refresh user data after profile update
        final userData = await validateUserWithBackend();
        if (userData != null) {
          await saveFirebaseUserData(userData);
        }
      } else {
        print('Failed to update profile - API returned null');
      }
    } catch (e) {
      print('Error updating profile: $e');
      // Don't rethrow - local update still succeeded
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
