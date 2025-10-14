import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';

class DeleteServicio {
  final ServiceRepository repository;

  DeleteServicio({required this.repository});

  Future<void> call(int id) {
    return repository.deleteService(id);
  }
}