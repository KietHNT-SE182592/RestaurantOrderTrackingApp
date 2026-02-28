import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../features/auth/presentation/cubit/auth_cubit.dart';

/// Màn hình hồ sơ / cài đặt — dùng chung cho tất cả role.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthSuccess ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blueGrey.shade100,
                child: Text(
                  user?.fullName.isNotEmpty == true
                      ? user!.fullName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.fullName ?? 'Người dùng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Chip(
                  label: Text(user?.role ?? ''),
                  backgroundColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Tên đăng nhập'),
                subtitle: Text(user?.userName ?? ''),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('ID'),
                subtitle: Text(user?.id ?? ''),
              ),
              const Divider(),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => context.read<AuthCubit>().logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      ),
    );
  }
}
