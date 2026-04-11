import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permis_app/core/router/app_router.dart';
import 'package:permis_app/core/services/hive_service.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/features/pdf/presentation/cubits/pdf_cubit.dart';
import 'package:permis_app/features/session/data/repositories/session_repository.dart';
import 'package:permis_app/features/session/presentation/cubits/report_cubit.dart';
import 'package:permis_app/features/session/presentation/cubits/session_history_cubit.dart';

class PermisApp extends StatelessWidget {
  const PermisApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SessionRepository(HiveService.getReportsBox());

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ReportCubit()),
        BlocProvider(create: (_) => SessionHistoryCubit(repository)..loadSessions()),
        BlocProvider(create: (_) => PdfCubit(repository)),
      ],
      child: MaterialApp(
        title: 'قائمة المترشحين',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRouter.candidates,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
