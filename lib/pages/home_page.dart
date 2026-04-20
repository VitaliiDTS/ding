import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:ding/cubits/connectivity_cubit.dart';
import 'package:ding/cubits/mqtt_cubit.dart';
import 'package:ding/cubits/mqtt_state.dart';
import 'package:ding/cubits/tables_cubit.dart';
import 'package:ding/cubits/tables_state.dart';
import 'package:ding/cubits/user_cubit.dart';
import 'package:ding/cubits/user_state.dart';
import 'package:ding/data/models/table_notification.dart';
import 'package:ding/pages/profile_page.dart';
import 'package:ding/widgets/stat_card.dart';
import 'package:ding/widgets/table_card.dart';
import 'package:flashlight_plugin/flashlight_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openProfile(BuildContext context) {
    final userCubit = context.read<UserCubit>();
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
    ).then((_) => userCubit.loadUser());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectivityCubit, bool>(
          listener: (context, isOnline) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isOnline
                      ? 'Internet connection restored.'
                      : 'Internet connection lost. '
                          'Some features may be unavailable.',
                ),
                backgroundColor: isOnline ? Colors.green : Colors.orange,
                duration: Duration(seconds: isOnline ? 2 : 4),
              ),
            );
            if (isOnline) {
              context.read<MqttCubit>().connect();
              context.read<TablesCubit>().fetchMyTables();
            }
          },
        ),
        BlocListener<TablesCubit, TablesState>(
          listenWhen: (_, curr) => curr.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tables'),
          actions: [
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state.user == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      state.user!.name,
                      style: AppTextStyles.secondary,
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<MqttCubit, MqttState>(
              builder: (context, state) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Tooltip(
                  message: _mqttTooltip(state.status),
                  child: Icon(
                    Icons.sensors,
                    size: 20,
                    color: _mqttColor(state.status),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _openProfile(context),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<ConnectivityCubit, bool>(
              builder: (context, isOnline) {
                if (isOnline) return const SizedBox.shrink();
                return const _OfflineBanner(
                  message:
                      'No internet. Some features may be unavailable.',
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Restaurant service dashboard',
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manage new requests and your assigned tables.',
                          style: AppTextStyles.secondary,
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onLongPress: () =>
                              FlashlightPlugin.toggle(context),
                          child: const StatCard(
                            title: 'Free tables',
                            value: '6',
                            icon: Icons.table_restaurant_outlined,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<MqttCubit, MqttState>(
                          builder: (context, state) => StatCard(
                            title: 'New requests',
                            value: '${state.notifications.length}',
                            icon: Icons.notifications_active_outlined,
                          ),
                        ),
                        const SizedBox(height: 28),
                        BlocBuilder<MqttCubit, MqttState>(
                          builder: (context, state) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'New requests',
                                    style: AppTextStyles.sectionTitle,
                                  ),
                                  const Spacer(),
                                  if (state.notifications.isNotEmpty)
                                    TextButton(
                                      onPressed: () => context
                                          .read<MqttCubit>()
                                          .clearNotifications(),
                                      child: const Text('Clear'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _MqttStatusRow(state: state),
                              const SizedBox(height: 12),
                              if (state.notifications.isEmpty)
                                _EmptyRequests(state: state)
                              else
                                ...state.notifications.map(
                                  (n) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    child: _notificationCard(context, n),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'My tables',
                          style: AppTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<TablesCubit, TablesState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state.tables.isEmpty) {
                              return const _EmptyTables();
                            }
                            return Column(
                              children: state.tables
                                  .map(
                                    (t) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: TableCard(
                                        tableNumber: t.tableNumber,
                                        statusText: t.status,
                                        statusColor:
                                            _statusColor(t.status),
                                        statusTextColor:
                                            _statusTextColor(t.status),
                                        requestText: t.requestText,
                                        assignedTo: t.assignedTo,
                                        buttonText: 'Close table',
                                        onPressed: () => context
                                            .read<TablesCubit>()
                                            .closeTable(t.id),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, TableNotification n) {
    final isBill = n.requestType.toLowerCase().contains('bill');
    final userName =
        context.read<UserCubit>().state.user?.name ?? 'Waiter';
    return TableCard(
      tableNumber: n.tableNumber,
      statusText: isBill ? 'Bill' : 'New',
      statusColor: isBill
          ? AppColors.statusBillBackground
          : AppColors.statusNewBackground,
      statusTextColor:
          isBill ? AppColors.statusBillText : AppColors.statusNewText,
      requestText: n.requestType,
      buttonText: 'Accept',
      onPressed: () =>
          context.read<TablesCubit>().acceptTable(n, userName),
    );
  }

  Color _statusColor(String status) {
    if (status.toLowerCase().contains('bill')) {
      return AppColors.statusBillBackground;
    }
    return AppColors.statusAssignedBackground;
  }

  Color _statusTextColor(String status) {
    if (status.toLowerCase().contains('bill')) {
      return AppColors.statusBillText;
    }
    return AppColors.statusAssignedText;
  }

  Color _mqttColor(MqttStatus status) => switch (status) {
        MqttStatus.connected => Colors.green,
        MqttStatus.connecting => Colors.orange,
        MqttStatus.error => Colors.red,
        MqttStatus.disconnected => Colors.grey,
      };

  String _mqttTooltip(MqttStatus status) => switch (status) {
        MqttStatus.connected => 'Live: connected',
        MqttStatus.connecting => 'Connecting…',
        MqttStatus.error => 'Connection error',
        MqttStatus.disconnected => 'Not connected',
      };
}

// ---------------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------------

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              size: 18,
              color: Colors.deepOrange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MqttStatusRow extends StatelessWidget {
  const _MqttStatusRow({required this.state});

  final MqttState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state.status) {
      MqttStatus.connected => ('Live updates active', Colors.green),
      MqttStatus.connecting => ('Connecting to broker…', Colors.orange),
      MqttStatus.error =>
        (state.errorMessage ?? 'Connection error', Colors.red),
      MqttStatus.disconnected => ('Not connected', Colors.grey),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        const Spacer(),
        if (!state.isConnected && state.status != MqttStatus.connecting)
          BlocBuilder<MqttCubit, MqttState>(
            builder: (context, _) => TextButton(
              onPressed: () => context.read<MqttCubit>().connect(),
              child: const Text('Reconnect'),
            ),
          ),
      ],
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests({required this.state});

  final MqttState state;

  @override
  Widget build(BuildContext context) {
    if (!state.isConnected) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none, size: 36, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Waiting for new requests…',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _EmptyTables extends StatelessWidget {
  const _EmptyTables();

  @override
  Widget build(BuildContext context) {
    final isOnline = context.read<ConnectivityCubit>().state;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            isOnline
                ? Icons.table_restaurant_outlined
                : Icons.wifi_off,
            size: 36,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            isOnline
                ? 'No tables assigned yet.'
                : 'No cached data. Connect to load tables.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
