import 'dart:developer';
import 'package:connect/data/models/user_model.dart';
import 'package:connect/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String username,
  }) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
          RegExp(r'\s+'), "".trim());
      final emailExists = await checkEmailExists(email);
      if(emailExists) {
        throw "An account already exists with this email";
      }
      final phoneExists = await checkPhoneExists(phoneNumber);
      if(phoneExists) {
        throw "An account already exists with this phone number";
      }
      final userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user == null) {
        throw "Failed to create user";
      }
      //create user model and save the user in the db firestore

      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: formattedPhoneNumber,
      );

      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print("Error check email exists;");
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final formattedPhoneNumber = phoneNumber.replaceAll(
          RegExp(r'\s+'), "".trim());
      final querySnapshot = await firebaseFirestore.collection("users").where(
          "phoneNumber", isEqualTo: formattedPhoneNumber).get();
      return querySnapshot.docs.isNotEmpty;
    } catch(e) {
      print("Error check phone exists");
      return false;
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential == null) {
        throw "No such user existed";
      }
      final user = await getUserData(userCredential.user!.uid);
      return user;
    } catch (e) {
      print("No user");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firebaseFirestore.collection("users").doc(uid).get();
      if (!doc.exists) {
        throw "No such user existed";
      };
      log(doc.id);
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw "Failed to get user data";
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await firebaseFirestore.collection("users").doc(user.uid).set(
          user.toMap());
    } catch (e) {
      throw "Failed to save user data";
    }
  }

}
