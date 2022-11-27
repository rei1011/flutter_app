import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/dynamic_link_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? _linkMessage;
  bool _isCreatingLink = false;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  final String _testString =
      'To test: long press link and then copy and click from a non-browser '
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      'is properly setup. Look at firebase_dynamic_links/README.md for more '
      'details.';
  final String DynamicLink = 'https://example/helloworld';
  final String Link = 'https://flutterappdev.page.link/oN6u';
  UserProfile? _user;
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = widget.auth0 ??
        Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    initDynamicLinks();
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    dynamicLinks.onLink.listen((dynamicLinkData) async {
      // debugPrint('dynamicLinkData.link.path = ${dynamicLinkData.link.path}');
      // print('dynamicLinkData.link.path = ${dynamicLinkData.link.path}');
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
      debugPrint('onLink is called');
      await login();
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://flutterappdev.page.link',
      longDynamicLink: Uri.parse(
        'https://flutterappdev.page.link?efr=0&ibi=io.flutter.plugins.firebase.dynamiclinksexample&apn=io.flutter.plugins.firebase.dynamiclinksexample&imv=0&amv=0&link=https%3A%2F%2Fexample%2Fhelloworld&ofl=https://ofl-example.com',
      ),
      link: Uri.parse(DynamicLink),
      androidParameters: const AndroidParameters(
        packageName: 'io.flutter.plugins.firebase.dynamiclinksexample',
        minimumVersion: 0,
      ),
      iosParameters: const IOSParameters(
        bundleId: 'io.flutter.plugins.firebase.dynamiclinksexample',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }

  Future<void> login() async {
    Credentials credentials = await auth0
        .webAuthentication(scheme: dotenv.env['AUTH0_CUSTOM_SCHEME'])
        .login(useEphemeralSession: true);

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
                      // onPressed: () {
                      //   Navigator.pushNamed(context, "/helloworld");
                      // },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Text('Login'),
                    ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      final PendingDynamicLinkData? data =
                          await dynamicLinks.getInitialLink();
                      final Uri? deepLink = data?.link;

                      if (deepLink != null) {
                        // ignore: unawaited_futures
                        Navigator.pushNamed(context, deepLink.path);
                      }
                    },
                    child: const Text('getInitialLink'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final PendingDynamicLinkData? data =
                          await dynamicLinks.getDynamicLink(Uri.parse(Link));
                      final Uri? deepLink = data?.link;

                      if (deepLink != null) {
                        // ignore: unawaited_futures
                        Navigator.pushNamed(context, deepLink.path);
                      }
                    },
                    child: const Text('getDynamicLink'),
                  ),
                  ElevatedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(false)
                        : null,
                    child: const Text('Get Long Link'),
                  ),
                  ElevatedButton(
                    onPressed: !_isCreatingLink
                        ? () => _createDynamicLink(true)
                        : null,
                    child: const Text('Get Short Link'),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  if (_linkMessage != null) {
                    await launchUrl(Uri.parse(_linkMessage!));
                  }
                },
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: _linkMessage));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied Link!')),
                  );
                },
                child: Text(
                  _linkMessage ?? '',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
              Text(_linkMessage == null ? '' : _testString)
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
