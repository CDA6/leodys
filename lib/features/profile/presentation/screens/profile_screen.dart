import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leodys/features/profile/presentation/screens/profile_view.dart';

import '../../providers.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'empty_profile_view.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Mon profil")),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),

              ProfileEmpty() => const EmptyProfileView(),

              ProfileLoaded(:final profile) =>
                  ProfileView(profile: profile),

              ProfileError(:final message) => Center(
                child: Text(message),
              ),

              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
