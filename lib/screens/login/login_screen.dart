import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_todo/repository/auth/auth_repository.dart';
import 'package:flutter_todo/screens/login/cubit/login_cubit.dart';
import 'package:flutter_todo/widgets/error_dialog.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  static Route route() {
    return PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: const Duration(seconds: 0),
      pageBuilder: (context, _, __) => BlocProvider<LoginCubit>(
        create: (_) =>
            LoginCubit(authRepository: context.read<AuthRepository>()),
        child: LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.read<AuthRepository>().signOut();
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.error) {
            showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                content: state.failure!.message,
              ),
            );
          }
        },
        builder: (context, state) {
          return state.status == LoginStatus.submitting
              ? Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<LoginCubit>().logInWithGoogle();
                          },
                          child: Text('Google Sign In'),
                        ),
                      )
                    ],
                  ),
                );
        },
      ),
    );
  }
}
