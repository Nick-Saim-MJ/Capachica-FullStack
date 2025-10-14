import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/plan_list_widget.dart';
import '../bloc/plan_bloc.dart';
// Asegúrate que la ruta a tu injection_container.dart sea correcta
// Si está en lib/injection_container.dart, esta ruta debería ser:
import '../../../../injection_container.dart';
import '../bloc/plan_event.dart'; // <<< AÑADIDO: Import para PlanEvent


class PlansFeedPage extends StatelessWidget {
  const PlansFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes Disponibles'),
      ),
      body: BlocProvider<PlanBloc>(
        create: (context) => sl<PlanBloc>()..add(FetchPublicPlans()), // <<< CAMBIO AQUÍ
        child: const PlanListWidget(),
      ),
    );
  }
}
