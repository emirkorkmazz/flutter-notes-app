import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    return MultiBlocProvider(
      providers: const [

      ],
      child: MaterialApp.router(
        title: 'NoteApp',
        debugShowCheckedModeBanner: false,

        /// [Theme]
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
