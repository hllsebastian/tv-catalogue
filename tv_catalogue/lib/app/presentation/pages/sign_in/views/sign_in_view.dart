import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../main.dart';
import '../../../../domain/enums.dart';
import '../../../../domain/repositories/authentication_respository.dart';
import '../../../routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String _userName = '', _password = '';
  bool _fetching = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AbsorbPointer(
            absorbing: _fetching,
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'User Name'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      setState(() {
                        _userName = value.trim().toLowerCase();
                      });
                    },
                    validator: (value) {
                      value = value?.trim().toLowerCase();
                      if (value!.isEmpty) {
                        return 'Invalid User Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'Password'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      setState(() {
                        _password = value.replaceAll(' ', '');
                      });
                    },
                    validator: (value) {
                      value = value?.replaceAll(' ', '');
                      if (value!.length < 4) {
                        return 'Invalid Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Builder(builder: (context) {
                    return _fetching
                        ? const CircularProgressIndicator()
                        : MaterialButton(
                            color: Colors.blue,
                            onPressed: () {
                              final isValid = Form.maybeOf(context)!.validate();
                              if (isValid) {
                                _submit(context);
                              }
                            },
                            child: const Text('Sing In'),
                          );
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _fetching = true;
    });
    final response = await context
        .read<AuthenticationRepository>()
        .signIn(_userName, _password);

    // To check that the wiget is rendered before to use the navigation to home
    // and avoid issue with the context
    if (!mounted) {
      return;
    }

    response.when((failure) {
      setState(() {
        _fetching = false;
      });
      final message = {
        SingInFailure.notFound: 'Not Found',
        SingInFailure.unauthorized: 'Unauthorized',
        SingInFailure.unknown: 'Unknown',
        SingInFailure.network: 'Network error',
      }[failure];
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message!)));
    }, (user) {
      Navigator.pushReplacementNamed(context, Routes.home);
    });
  }
}
