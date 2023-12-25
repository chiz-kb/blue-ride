import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'login_page.dart';

class MyDrawer extends StatelessWidget {
  String phoneNo = FirebaseAuth.instance.currentUser!.phoneNumber!;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      color: Colors.white,
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('profile');
            },
            child: UserAccountsDrawerHeader(
              accountName: const Text(
                '-',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                ),
              ),
              accountEmail: Text('$phoneNo'),
              currentAccountPicture: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const ListTile(
            title: Text('My account'),
            leading: Icon(Icons.account_box),
          ),
          const ListTile(
            title: Text('Setting'),
            leading: Icon(Icons.settings),
          ),
          const ListTile(
            title: Text('Help'),
            leading: Icon(Icons.help),
          ),
          const ListTile(
            title: Text('Support'),
            leading: Icon(Icons.forum),
          )
        ],
      ),
    );
  }
}
