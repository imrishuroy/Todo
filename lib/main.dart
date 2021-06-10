import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todo/blocs/add-edit/add_edit_cubit.dart';
import 'package:flutter_todo/blocs/auth/auth_bloc.dart';

import 'package:flutter_todo/blocs/filtered-bloc/flitered_bloc.dart';
import 'package:flutter_todo/blocs/simple_bloc_oberver.dart';
import 'package:flutter_todo/blocs/stats/stats_bloc.dart';
import 'package:flutter_todo/blocs/tab/tab_bloc.dart';
import 'package:flutter_todo/blocs/theme/theme_bloc.dart';
import 'package:flutter_todo/blocs/todo/todo_bloc.dart';
import 'package:flutter_todo/config/custom_router.dart';

import 'package:flutter_todo/config/auth_wrapper.dart';
import 'package:flutter_todo/config/shared_prefs.dart';
import 'package:flutter_todo/repositories/auth/auth_repository.dart';
import 'package:flutter_todo/repositories/services/firebase_service.dart';
import 'package:flutter_todo/repositories/todo/todo_repository.dart';
import 'package:flutter_todo/repositories/utils/util_repository.dart';
import 'package:flutter_todo/theme/app_theme.dart';

import 'blocs/todo/todo_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefs().init();
  Bloc.observer = SimpleBlocObserver();
  EquatableConfig.stringify = kDebugMode;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<TodosRepository>(
          create: (_) => TodosRepository(),
        ),
        RepositoryProvider<UtilsRepository>(
          create: (_) => UtilsRepository(),
        ),
        RepositoryProvider<FirebaseServices>(
          create: (_) => FirebaseServices(),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<TodosBloc>(
            create: (context) => TodosBloc(
              todosRepository: context.read<TodosRepository>(),
            )..add(LoadTodos()),
          ),
          BlocProvider<TabBloc>(
            create: (context) => TabBloc(),
          ),
          BlocProvider<FilteredTodosBloc>(
            create: (context) => FilteredTodosBloc(
              todosBloc: BlocProvider.of<TodosBloc>(context),
            ),
          ),
          BlocProvider<StatsBloc>(
            create: (context) =>
                StatsBloc(todosBloc: BlocProvider.of<TodosBloc>(context)),
          ),
          BlocProvider<AddEditCubit>(
            create: (context) => AddEditCubit(
              utils: RepositoryProvider.of<UtilsRepository>(context),
              todosBloc: BlocProvider.of<TodosBloc>(context),
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            print(
                '${appThemeData[AppTheme.values.elementAt(SharedPrefs().theme)]} -----------------------');
            return MaterialApp(
              //  darkTheme: ThemeData(backgroundColor: Colors.black),
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              //theme: state.themeData,
              theme:
                  appThemeData[AppTheme.values.elementAt(SharedPrefs().theme)],

              // ThemeData(
              //   primarySwatch: Colors.blue,
              //   // scaffoldBackgroundColor: Colors.black,
              // ),
              onGenerateRoute: CustomRouter.onGenerateRoute,
              initialRoute: AuthWrapper.routeName,
            );
          },
        ),
      ),
    );
  }
}
