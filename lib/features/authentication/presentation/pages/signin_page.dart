import 'package:flutter/material.dart';
import 'package:leodys/features/authentication/presentation/controllers/signin_controller.dart';

class SigninPage extends StatefulWidget {
  final SignInController signInController;

  const SigninPage({super.key, required this.signInController});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () {
                  final _email = _emailController.text;
                  final _password = _passwordController.text;

                  widget.signInController.login(_email, _password);
                },
                child: Text("Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
