import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/core.dart';
import '/presentation/presentation.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<RegisterBloc>()),
        BlocProvider(create: (context) => getIt<LoginBloc>()),
      ],
      child: MaterialApp.router(
        title: 'NoteApp',
        debugShowCheckedModeBanner: false,

        // [Router]
        routerConfig: appRouter,

        /// [Theme]
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
