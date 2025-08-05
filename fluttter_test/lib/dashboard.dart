import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _userName; // A String variable to store the received username

  @override
  void didChangeDependencies() {
    super
        .didChangeDependencies(); //<== retrieve arguments passed (persisted data)
    final String? receivedUsername =
        ModalRoute.of(context)!.settings.arguments
            as String?; // <== '!' null assetion operator - can be certain value will never be null,  // as String? is type casting the incoming data to string
    if (receivedUsername != null) {
      //<== if username is not blank, update the state
      setState(() {
        _userName = receivedUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Welcome ${_userName ?? 'User'}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ), //<== string lteral + tristate op. if username is empty, default val is user
      ),
    );
  }
}
