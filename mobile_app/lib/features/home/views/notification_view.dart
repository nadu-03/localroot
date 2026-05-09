import 'package:flutter/material.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationTile(
            title: 'New message from seller',
            subtitle: 'Your item inquiry has a reply.',
            time: '2m ago',
          ),
          _NotificationTile(
            title: 'Order update',
            subtitle: 'Your order is out for delivery.',
            time: '1h ago',
          ),
          _NotificationTile(
            title: 'Promotion',
            subtitle: 'Get 10% off selected thrift items today.',
            time: '5h ago',
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.notifications_none),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(time),
      ),
    );
  }
}
