import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firebaseAuth = FirebaseAuth.instance;

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent.shade700,
        elevation: 1.0,
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error!!");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading....");
          }
          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildListViewItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildListViewItem(DocumentSnapshot doc) {
    Map<String, dynamic> dataMap = doc.data()! as Map<String, dynamic>;
    if (_firebaseAuth.currentUser!.email != dataMap['email']) {
      return ListTile(
        title: Text(dataMap['email']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: dataMap['email'],
                receiverUid: dataMap['uid'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
