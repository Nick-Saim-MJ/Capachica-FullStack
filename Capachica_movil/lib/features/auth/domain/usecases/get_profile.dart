import 'package:aplicativo_capachica/features/auth/data/models/user_model.dart';
import 'package:aplicativo_capachica/features/auth/domain/repositories/profile_repository.dart';


class GetProfileUse {
  final ProfileRepository repository;
  GetProfileUse(this.repository);

  Future<UserModel> call() => repository.getProfile();
}
