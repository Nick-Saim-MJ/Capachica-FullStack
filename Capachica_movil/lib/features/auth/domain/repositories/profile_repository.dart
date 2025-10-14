// domain/repositories/profile_repository.dart

import '../usecases/update_profile_usecase.dart';
import '../../data/models/user_model.dart'; // Domain-friendly entity or model

/// The contract for the Profile repository.
/// Defines the methods that the Use Cases will call.
abstract class ProfileRepository {
  /// Fetches the user's profile information.
  Future<UserModel> getProfile();

  /// Updates the user's profile information.
  /// Takes the necessary parameters via [UpdateProfileParams].
  Future<UserModel> updateProfile(UpdateProfileParams params);
}