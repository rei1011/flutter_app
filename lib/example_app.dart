import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/dynamic_link_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'constants.dart';
import 'hero.dart';
import 'user.dart';

class ExampleApp extends StatefulWidget {
  final Auth0? auth0;
  const ExampleApp({this.auth0, final Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  UserProfile? _user;
  late Auth0 auth0;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    auth0 = widget.auth0 ??
        Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  }

  Future<void> initDynamicLinks() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      // debugPrint('dynamicLinkData.link.path = ${dynamicLinkData.link.path}');
      // print('dynamicLinkData.link.path = ${dynamicLinkData.link.path}');
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
      login();
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future<void> login() async {
    Credentials credentials = await auth0
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
        .login();

    setState(() {
      _user = credentials.user;
    });
  }

  Future<void> logout() async {
    await auth0
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
        .logout();

    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                        ? UserWidget(user: _user)
                        : const Expanded(child: HeroWidget())
                  ],
                ),
              ),
              _user != null
                  ? ElevatedButton(
                      onPressed: logout,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Text('Logout'),
                    )
                  : ElevatedButton(
                      onPressed: login,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Text('Login'),
                    )
            ],
          ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/helloworld': (BuildContext context) => const DynamicLinkPage(),
      },
    );
  }
}
