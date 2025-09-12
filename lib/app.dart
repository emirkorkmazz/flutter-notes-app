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
        BlocProvider(create: (context) => getIt<HomeBloc>()),
        BlocProvider(create: (context) => getIt<AddNoteCubit>()),
        BlocProvider(create: (context) => getIt<EditNoteCubit>()),
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
