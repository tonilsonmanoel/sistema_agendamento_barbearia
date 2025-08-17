import 'package:agendamento_barber/models/Estabelecimento.dart';
import 'package:agendamento_barber/models/Profissional.dart';
import 'package:agendamento_barber/views/administrador/login_administrador.dart';
import 'package:agendamento_barber/views/administrador/page_view_admin.dart';
import 'package:agendamento_barber/views/lading_page.dart';
import 'package:agendamento_barber/views/sections_lading_page/set_up_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LadingPage(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => SetUpLandingPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => LoginAdministrador(),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final estabelecimento = data['estabelecimento'] as Estabelecimento;
          final profissional = data['profissional'] as Profissional;
          return MaterialPage(
              key: state.pageKey,
              child: PageViewAdmin(
                estabelecimento: estabelecimento,
                profissional: profissional,
              ));
        },
      ),
    ],
  );
}
