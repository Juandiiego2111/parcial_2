import 'package:go_router/go_router.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/views/accidentes/estadisticas_view.dart';
import 'package:parcial_2/views/dashboard/dashboard_view.dart';
import 'package:parcial_2/views/establecimientos/establecimiento_detail_view.dart';
import 'package:parcial_2/views/establecimientos/establecimiento_form_view.dart';
import 'package:parcial_2/views/establecimientos/establecimientos_list_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/estadisticas',
      builder: (context, state) => const EstadisticasView(),
    ),
    GoRoute(
      path: '/establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    GoRoute(
      path: '/establecimientos/create',
      builder: (context, state) => const EstablecimientoFormView(
        id: null,
        establecimiento: null,
      ),
    ),
    GoRoute(
      path: '/establecimientos/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return EstablecimientoDetailView(id: id);
      },
    ),
    GoRoute(
      path: '/establecimientos/:id/edit',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final establecimiento = state.extra as EstablecimientoModel?;
        return EstablecimientoFormView(
          id: id,
          establecimiento: establecimiento,
        );
      },
    ),
  ],
);
