import 'package:ding/core/app_colors.dart';
import 'package:ding/core/app_text_styles.dart';
import 'package:ding/data/models/table_notification.dart';
import 'package:ding/data/models/user_model.dart';
import 'package:ding/data/repositories/user_repository.dart';
import 'package:ding/pages/profile_page.dart';
import 'package:ding/providers/connectivity_provider.dart';
import 'package:ding/providers/mqtt_provider.dart';
import 'package:ding/widgets/stat_card.dart';
import 'package:ding/widgets/table_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final UserRepository userRepository;
  final bool offlineSession;

  const HomePage({
    required this.userRepository,
    this.offlineSession = false,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static void _emptyAction() {}

  static const _myTables = [
    TableCard(
      tableNumber: 1,
      statusText: 'Assigned',
      statusColor: AppColors.statusAssignedBackground,
      statusTextColor: AppColors.statusAssignedText,
      requestText: 'Serving table',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
    TableCard(
      tableNumber: 4,
      statusText: 'Bill',
      statusColor: AppColors.statusBillBackground,
      statusTextColor: AppColors.statusBillText,
      requestText: 'Bill request',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
    TableCard(
      tableNumber: 6,
      statusText: 'Assigned',
      statusColor: AppColors.statusAssignedBackground,
      statusTextColor: AppColors.statusAssignedText,
      requestText: 'Waiter call',
      assignedTo: 'Andrii',
      buttonText: 'Close table',
      onPressed: _emptyAction,
    ),
  ];

  UserModel? _currentUser;
  ConnectivityProvider? _connectivityProvider;

  @override
  void initState() {
    super.initState();
    _loadUser();

    if (widget.offlineSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No internet. Signed in with saved session. '
              'Some features may be unavailable.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_connectivityProvider == null) {
      _connectivityProvider = context.read<ConnectivityProvider>();
      _connectivityProvider!.addListener(_onConnectivityChanged);
    }
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    final isOnline = _connectivityProvider!.isOnline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOnline
              ? 'Internet connection restored.'
              : 'Internet connection lost. Some features may be unavailable.',
        ),
        backgroundColor: isOnline ? Colors.green : Colors.orange,
        duration: Duration(seconds: isOnline ? 2 : 4),
      ),
    );

    if (isOnline) {
      final mqtt = context.read<MqttProvider>();
      if (!mqtt.isConnected) mqtt.connect();
    }
  }

  @override
  void dispose() {
    _connectivityProvider?.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await widget.userRepository.getCurrentUser();
    if (!mounted) return;
    setState(() => _currentUser = user);

    final connectivity = context.read<ConnectivityProvider>();
    if (connectivity.isOnline) {
      context.read<MqttProvider>().connect();
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProfilePage(userRepository: widget.userRepository),
      ),
    ).then((_) => _loadUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        actions: [
          if (_currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(_currentUser!.name, style: AppTextStyles.secondary),
              ),
            ),
          // MQTT status dot
          Consumer<MqttProvider>(
            builder: (context, mqtt, _) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: _mqttTooltip(mqtt.state),
                child: Icon(
                  Icons.sensors,
                  size: 20,
                  color: _mqttColor(mqtt.state),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, _) {
              if (connectivity.isOnline) return const SizedBox.shrink();
              return const _OfflineBanner(
                message:
                    'No internet connection. Some features may be unavailable.',
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
                      const StatCard(
                        title: 'Free tables',
                        value: '6',
                        icon: Icons.table_restaurant_outlined,
                      ),
                      const SizedBox(height: 12),
                      // New requests count from MQTT
                      Consumer<MqttProvider>(
                        builder: (context, mqtt, _) => StatCard(
                          title: 'New requests',
                          value: '${mqtt.notifications.length}',
                          icon: Icons.notifications_active_outlined,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const StatCard(
                        title: 'My tables',
                        value: '3',
                        icon: Icons.assignment_ind_outlined,
                      ),
                      const SizedBox(height: 28),
                      // -------------------------------------------------------
                      // New requests — live from MQTT
                      // -------------------------------------------------------
                      Consumer<MqttProvider>(
                        builder: (context, mqtt, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'New requests',
                                  style: AppTextStyles.sectionTitle,
                                ),
                                const Spacer(),
                                if (mqtt.notifications.isNotEmpty)
                                  TextButton(
                                    onPressed: mqtt.clearNotifications,
                                    child: const Text('Clear'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _MqttStatusRow(mqtt: mqtt),
                            const SizedBox(height: 12),
                            if (mqtt.notifications.isEmpty)
                              _EmptyRequests(mqtt: mqtt)
                            else
                              ...mqtt.notifications.map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _notificationCard(n),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // -------------------------------------------------------
                      // My tables — static
                      // -------------------------------------------------------
                      const Text(
                        'My tables',
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: 12),
                      ..._myTables.expand(
                        (card) => [card, const SizedBox(height: 12)],
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
    );
  }

  Widget _notificationCard(TableNotification n) {
    final isBill = n.requestType.toLowerCase().contains('bill');
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
      onPressed: _emptyAction,
    );
  }

  Color _mqttColor(MqttState state) => switch (state) {
        MqttState.connected => Colors.green,
        MqttState.connecting => Colors.orange,
        MqttState.error => Colors.red,
        MqttState.disconnected => Colors.grey,
      };

  String _mqttTooltip(MqttState state) => switch (state) {
        MqttState.connected => 'Live: connected',
        MqttState.connecting => 'Connecting…',
        MqttState.error => 'Connection error',
        MqttState.disconnected => 'Not connected',
      };
}

// ---------------------------------------------------------------------------
// Small widgets
// ---------------------------------------------------------------------------

class _OfflineBanner extends StatelessWidget {
  final String message;

  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.wifi_off, size: 18, color: Colors.deepOrange),
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
  final MqttProvider mqtt;

  const _MqttStatusRow({required this.mqtt});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (mqtt.state) {
      MqttState.connected => ('Live updates active', Colors.green),
      MqttState.connecting => ('Connecting to broker…', Colors.orange),
      MqttState.error => (mqtt.errorMessage ?? 'Connection error', Colors.red),
      MqttState.disconnected => ('Not connected', Colors.grey),
    };

    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        const Spacer(),
        if (!mqtt.isConnected && mqtt.state != MqttState.connecting)
          TextButton(
            onPressed: mqtt.connect,
            child: const Text('Reconnect'),
          ),
      ],
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  final MqttProvider mqtt;

  const _EmptyRequests({required this.mqtt});

  @override
  Widget build(BuildContext context) {
    if (!mqtt.isConnected) {
      return const SizedBox.shrink();
    }
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
