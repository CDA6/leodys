import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leodys/features/profile/presentation/screens/profile_view.dart';

import '../../../cards/providers.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'empty_profile_view.dart';

class ProfileScreen extends StatelessWidget {
  static const String route = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileLoading() => Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              ),

              ProfileEmpty() => const EmptyProfileView(),

              ProfileLoaded(:final profile) =>
                  ProfileView(profile: profile),

              ProfileError(:final message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    message,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}

