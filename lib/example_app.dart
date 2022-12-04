import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/side_menu.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'constants.dart';
import 'hero.dart';
import 'user.dart';

class MainScreen extends StatefulWidget {
  final Auth0? auth0;
  const MainScreen({this.auth0, final Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  UserProfile? _user;
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = widget.auth0 ??
        Auth0(
          dotenv.env['AUTH0_DOMAIN']!,
          dotenv.env['AUTH0_CLIENT_ID']!,
        );
  }

  Future<void> login() async {
    Credentials credentials = await auth0
        .webAuthentication(
          scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'],
        )
        .login(useEphemeralSession: true);

    setState(
      () {
        _user = credentials.user;
      },
    );
  }

  Future<void> logout() async {
    await auth0
        .webAuthentication(
          scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'],
        )
        .logout();

    setState(
      () {
        _user = null;
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: const SideMenu(),
        body: Padding(
          padding: const EdgeInsets.only(
            top: padding,
            bottom: padding,
            left: padding / 2,
            right: padding / 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _user != null
                        ? UserWidget(
                            user: _user,
                          )
                        : const Expanded(
                            child: HeroWidget(),
                          )
                  ],
                ),
              ),
              _user != null
                  ? ElevatedButton(
                      onPressed: logout,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                      ),
                      child: const Text(
                        'Logout',
                      ),
                    )
                  : ElevatedButton(
                      onPressed: login,
                      // onPressed: () {
                      //   Navigator.pushNamed(context, "/helloworld");
                      // },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.black,
                        ),
                      ),
                      child: const Text(
                        'Login',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
