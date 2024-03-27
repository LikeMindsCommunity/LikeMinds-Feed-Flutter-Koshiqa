import 'dart:async';

// import 'package:feed_example/likeminds_callback.dart';
import 'package:feed_example/network_handling.dart';
// import '../ios/user_local_preference.dart';
import 'package:flutter/material.dart';
// import 'package:likeminds_feed_flutter_koshiqa/feed.dart';
import 'package:likeminds_feed_flutter_koshiqa/likeminds_feed_flutter_koshiqa.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:uni_links/uni_links.dart';
import 'main.dart';

const debug = bool.fromEnvironment('DEBUG');

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Integration App for UI + SDK package',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CredScreen(),
    );
  }
}

class CredScreen extends StatefulWidget {
  const CredScreen({super.key});

  @override
  State<CredScreen> createState() => _CredScreenState();
}

class _CredScreenState extends State<CredScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  StreamSubscription? _streamSubscription;
  LMFeedKoshiqa? lmFeed;
  String? userId;

  @override
  void initState() {
    super.initState();
    NetworkConnectivity networkConnectivity = NetworkConnectivity.instance;
    networkConnectivity.initialise();
    // userId = UserLocalPreference.instance.fetchUserId();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initUniLinks(context);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _userIdController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future initUniLinks(BuildContext context) async {
    // Get the initial deep link if the app was launched with one
    final initialLink = await getInitialLink();

    // Handle the deep link
    if (initialLink != null) {
      initialURILinkHandled = true;
      // You can extract any parameters from the initialLink object here
      // and use them to navigate to a specific screen in your app
      debugPrint('Received initial deep link: $initialLink');

      // TODO: add api key to the DeepLinkRequest
      // TODO: add user id and user name of logged in user
      final uriLink = Uri.parse(initialLink);
      if (uriLink.isAbsolute) {
        if (uriLink.path == '/community/post') {
          List secondPathSegment = initialLink.split('post_id=');
          if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
            String postId = secondPathSegment[1];

            // Call initiate user if not called already
            // It is recommened to call initiate user with your login flow
            // so that navigation works seemlessly
            InitiateUserResponse response = await LMFeedCore.instance
                .initiateUser((InitiateUserRequestBuilder()
                      ..uuid(userId ?? "Test-User-Id")
                      ..userName("Test User"))
                    .build());

            if (response.success) {
              // Replace the below code
              // if you wanna navigate to your screen
              // Either navigatorKey or context must be provided
              // for the navigation to work
              // if both are null an exception will be thrown
              navigateToLMPostDetailsScreen(
                postId,
                navigatorKey: rootNavigatorKey,
              );
            }
          }
        } else if (uriLink.path == '/community/post/create') {
          rootNavigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LMFeedComposeScreen(),
            ),
          );
        }
      }
    }

    // Subscribe to link changes
    LMFeedCore.deepLinkStream = linkStream.listen((String? link) async {
      if (link != null) {
        initialURILinkHandled = true;
        // Handle the deep link
        // You can extract any parameters from the uri object here
        // and use them to navigate to a specific screen in your app
        debugPrint('Received deep link: $link');
        // TODO: add api key to the DeepLinkRequest
        // TODO: add user id and user name of logged in user

        final uriLink = Uri.parse(link);
        if (uriLink.isAbsolute) {
          if (uriLink.path == '/community/post') {
            List secondPathSegment = link.split('post_id=');
            if (secondPathSegment.length > 1 && secondPathSegment[1] != null) {
              String postId = secondPathSegment[1];

              InitiateUserResponse response = await LMFeedCore.instance
                  .initiateUser((InitiateUserRequestBuilder()
                        ..uuid(userId ?? "Test-User-Id")
                        ..userName("Test User"))
                      .build());

              if (response.success) {
                // Replace the below code
                // if you wanna navigate to your screen
                // Either navigatorKey or context must be provided
                // for the navigation to work
                // if both are null an exception will be thrown
                navigateToLMPostDetailsScreen(
                  postId,
                  navigatorKey: rootNavigatorKey,
                );
              }
            }
          } else if (uriLink.path == '/community/post/create') {
            rootNavigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => const LMFeedComposeScreen(),
              ),
            );
          }
        }
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      toast('An error occurred');
    });
  }

  @override
  Widget build(BuildContext context) {
    // return lmFeed;
    // userId = UserLocalPreference.instance.fetchUserId();
    userId = "";
    // If the local prefs have user id stored
    // Login using that user Id
    // otherwise show the cred screen for login
    if (userId != null && userId!.isNotEmpty) {
      return lmFeed = LMFeedKoshiqa(
        userId: userId,
        userName: 'Test',
        // defaultFeedroom: debug ? 83301 : 2238799,
        // callback: LikeMindsCallback(),
        // deepLinkCallBack: () {
        //   debugPrint("Deep Link Callback");
        // },
        // apiKey: "",
      );
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 6, 92, 193),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              const SizedBox(height: 72),
              const Text(
                "Koshiqa Beta\nSample App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                "Enter your credentials",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                controller: _usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                cursorColor: Colors.white,
                controller: _userIdController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'User ID',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                onSubmitted: (value) {
                  if (_userIdController.text.isNotEmpty) {
                    lmFeed = LMFeedKoshiqa(
                      userId: _userIdController.text,
                      userName: _usernameController.text,
                    );

                    if (_userIdController.text.isNotEmpty) {}

                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => lmFeed!,
                    );
                    Navigator.of(context).pushReplacement(route);
                  }
                },
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () {
                  lmFeed = LMFeedKoshiqa(
                    userId: _userIdController.text,
                    userName: _usernameController.text,
                  );

                  if (_userIdController.text.isNotEmpty) {}

                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => lmFeed!,
                  );
                  Navigator.of(context).pushReplacement(route);
                },
                child: Container(
                  width: 200,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text("Submit")),
                ),
              ),
              const SizedBox(height: 72),
              const Text(
                "If no credentials are provided, the app will run with the default credentials of Bot user in your community",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

void navigateToLMPostDetailsScreen(
  String postId, {
  GlobalKey<NavigatorState>? navigatorKey,
  BuildContext? context,
}) async {
  if (context == null && navigatorKey == null) {
    throw Exception('''
Either context or navigator key must be
         provided to navigate to PostDetailScreen''');
  }
  String visiblePostId =
      LMFeedVideoProvider.instance.currentVisiblePostId ?? postId;

  VideoController? videoController =
      LMFeedVideoProvider.instance.getVideoController(visiblePostId);

  await videoController?.player.pause();

  MaterialPageRoute route = MaterialPageRoute(
    builder: (context) => LMFeedPostDetailScreen(
      postId: postId,
      // postBuilder: suraasaPostWidgetBuilder,
      // commentBuilder: suraasaCommentWidgetBuilder,
      // appBarBuilder: suraasaPostDetailScreenAppBarBuilder,
    ),
  );
  if (navigatorKey != null) {
    await navigatorKey.currentState!.push(
      route,
    );
  } else {
    await Navigator.of(context!, rootNavigator: true).push(route);
  }

  await videoController?.player.play();
}
