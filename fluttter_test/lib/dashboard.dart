import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _userEmail; // A String variable to store the received email

  @override
  void didChangeDependencies() {
    super
        .didChangeDependencies(); //<== retrieve arguments passed (persisted data)
    final String? receivedEmail =
        ModalRoute.of(context)!.settings.arguments
            as String?; // <== '!' null assetion operator - can be certain value will never be null,
            // as String? is type casting the incoming data to string
    if (receivedEmail != null) {
      //<== if email is not blank, update the state
      setState(() {
        _userEmail = receivedEmail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Welcome ${_userEmail ?? 'User'}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ), //<== string lteral + tristate op. if username is empty, default val is user
      ),
    );
  }
}
