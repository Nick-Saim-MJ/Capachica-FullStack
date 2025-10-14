// data/repositories/profile_repository_impl.dart

import 'package:aplicativo_capachica/features/auth/data/models/user_model.dart';

// Import the abstract class we created above
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';

import '../datasources/profile_remote_datasource.dart';

/// Implementation of the ProfileRepository contract.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> getProfile() {
    return remoteDataSource.fetchProfile();
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileParams params) {
    // Passes the JSON map and the optional file path to the remote data source.
    return remoteDataSource.updateProfile(
      params.toJson(),
      filePath: params.fotoPerfilPath,
    );
  }
}