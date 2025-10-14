import 'package:aplicativo_capachica/features/servicio/domain/repositories/servicio_repository.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/create_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/delete_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/get_services_usecase.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/toggle_servicio_estado.dart';
import 'package:aplicativo_capachica/features/servicio/domain/usecases/update_servicio.dart';
import 'package:aplicativo_capachica/features/servicio/presentation/bloc/servicio_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:aplicativo_capachica/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aplicativo_capachica/features/auth/presentation/pages/login_page.dart';
import 'package:aplicativo_capachica/features/home/presentation/pages/home_page.dart';
import 'package:aplicativo_capachica/main.dart';

// Mock del AuthCubit
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}
class MockServicesCapachicaRepository extends Mock implements ServiceRepository {}
class MockGetServicesUseCase extends Mock implements GetServicesUseCase {}
class MockCreateServicio extends Mock implements CreateServicio {}
class MockUpdateServicio extends Mock implements UpdateServicio {}
class MockDeleteServicio extends Mock implements DeleteServicio {}
class MockToggleServicioEstado extends Mock implements ToggleServicioEstado {}

void main() {
  late MockAuthCubit mockCubit;
  late MockServicesCapachicaRepository mockRepository;
  late MockGetServicesUseCase mockGetServicesUseCase;
  late MockCreateServicio mockCreateServicio;
  late MockUpdateServicio mockUpdateServicio;
  late MockDeleteServicio mockDeleteServicio;
  late MockToggleServicioEstado mockToggleServicioEstado;

  setUp(() {
    mockCubit = MockAuthCubit();
    mockRepository = MockServicesCapachicaRepository();
    mockGetServicesUseCase = MockGetServicesUseCase();
    mockCreateServicio = MockCreateServicio();
    mockUpdateServicio = MockUpdateServicio();
    mockDeleteServicio = MockDeleteServicio();
    mockToggleServicioEstado = MockToggleServicioEstado();

    // Estado inicial que usará el BlocBuilder
    when(() => mockCubit.state).thenReturn(AuthInitial());

    // Stream vacía con estado inicial
    whenListen<AuthState>(
      mockCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    // AuthGate llama loadProfile() en post-frame
    when(() => mockCubit.loadProfile()).thenAnswer((_) async {});

    // No hace falta stubear login/register/logout para este test
  });

  testWidgets('AuthGate muestra LoginPage cuando el estado es AuthInitial',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AuthCubit>.value(
              value: mockCubit,
              //child: const AuthGate(),
            ),
          ),
        );

        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.byType(HomePage), findsNothing);
      });
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ServicioBloc(repository: mockRepository,
            getServicesUseCase: mockGetServicesUseCase,
            toggleServicioEstadoUseCase: mockToggleServicioEstado
        , createServicioUseCase: mockCreateServicio, updateServicioUseCase: mockUpdateServicio,
          deleteServicioUseCase: mockDeleteServicio
        ),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: Center(
              child: Builder(
                builder: (context) {
                  return const Text('Test Body');
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test Body'), findsOneWidget);

  });
}