import 'package:aseep/screens/auth/auth_services.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home Screem"),
        actions: [
          IconButton(
              onPressed: logout,
              icon: Icon(Icons.logout)
          )
        ],
      ),
      drawer: Drawer(),
    );
  }
}
