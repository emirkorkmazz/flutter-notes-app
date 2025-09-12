import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    ///
    return MultiBlocProvider(
      providers: [

      ],
      child: MaterialApp.router(
        title: 'NoteApp',
        debugShowCheckedModeBanner: false,


      ),
    );
  }
}
