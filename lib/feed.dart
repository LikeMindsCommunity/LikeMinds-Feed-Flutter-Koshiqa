// ignore_for_file: library_private_types_in_public_api

library feed;

import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/utils/credentials/credentials.dart';
import 'package:feed_sx/src/utils/local_preference/user_local_preference.dart';
import 'package:feed_sx/src/views/feed/blocs/new_post/new_post_bloc.dart';
import 'package:feed_sx/src/views/edit_post/edit_post_screen.dart';
import 'package:feed_sx/src/views/feed/feedroom_list_screen.dart';
import 'package:feed_sx/src/views/media_preview/media_preview.dart';
import 'package:feed_sx/src/views/new_post/feedroom_select.dart';
import 'package:feed_sx/src/views/notification/notification_screen.dart';
import 'package:feed_sx/src/views/topic/topic_select_screen.dart';
import 'package:feed_sx/src/widgets/loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/views/feed/feedroom_screen.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:media_kit/media_kit.dart';
import 'src/services/likeminds_service.dart';
export 'src/views/feed/feed_screen.dart';
export 'src/views/likes/likes_screen.dart';
export 'src/views/report_post/report_screen.dart';
export 'src/views/comments/all_comments_screen.dart';
export 'src/views/new_post/new_post_screen.dart';
export 'src/services/service_locator.dart';
export 'src/utils/notification_handler.dart';
export 'src/utils/analytics/analytics.dart';
export 'src/utils/share/share_post.dart';
export 'src/navigation/arguments.dart';

/// Flutter environment manager v0.0.1
const prodFlag = !bool.fromEnvironment('DEBUG');

class LMFeed extends StatefulWidget {
  final String? userId;
  final String? userName;
  final int defaultFeedroom;
  final String apiKey;
  final LMSDKCallback callback;
  final Function() deepLinkCallBack;

  static LMFeed? _instance;

  /// INIT - Get the LMFeed instance and pass the credentials (if any)
  /// to the instance. This will be used to initialize the app.
  /// If no credentials are provided, the app will run with the default
  /// credentials of Bot user in your community in `credentials.dart`
  static LMFeed instance({
    String? userId,
    String? userName,
    required int defaultFeedroom,
    required LMSDKCallback callback,
    required Function() deepLinkCallBack,
    required String apiKey,
  }) {
    setupLMFeed(callback, apiKey);
    return _instance ??= LMFeed._(
      userId: userId,
      userName: userName,
      defaultFeedroom: defaultFeedroom,
      callback: callback,
      deepLinkCallBack: deepLinkCallBack,
      apiKey: apiKey,
    );
  }

  const LMFeed._({
    Key? key,
    this.userId,
    this.userName,
    required this.defaultFeedroom,
    required this.callback,
    required this.apiKey,
    required this.deepLinkCallBack,
  }) : super(key: key);

  @override
  _LMFeedState createState() => _LMFeedState();
}

class _LMFeedState extends State<LMFeed> {
  User? user;
  late final String userId;
  late final String userName;
  late final bool isProd;
  late final Function()? deepLinkCallBack;

  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
    isProd = prodFlag;
    userId = widget.userId!.isEmpty
        ? isProd
            ? CredsProd.botId
            : CredsDev.botId
        : widget.userId!;
    userName = widget.userName!.isEmpty ? "Test username" : widget.userName!;
    firebase();
  }

  void firebase() {
    try {
      final firebase = Firebase.app();
      debugPrint("Firebase - ${firebase.options.appId}");
    } on FirebaseException catch (e) {
      debugPrint("Make sure you have initialized firebase, ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      toastTheme: ToastThemeData(
        textColor: kWhiteColor,
        background: Colors.black,
        alignment: Alignment.bottomCenter,
      ),
      child: FutureBuilder<InitiateUserResponse>(
        future: locator<LikeMindsService>().initiateUser(
          (InitiateUserRequestBuilder()
                ..userId(userId)
                ..userName(userName))
              .build(),
        ),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            InitiateUserResponse response = snapshot.data;
            if (response.success) {
              user = response.initiateUser?.user;
              LMNotificationHandler.instance.registerDevice(user!.id);
              return BlocProvider(
                create: (context) => NewPostBloc(),
                child: MaterialApp(
                  debugShowCheckedModeBanner: !isProd,
                  title: 'LikeMinds Feed',
                  navigatorKey: locator<NavigationService>().navigatorKey,
                  onGenerateRoute: (settings) {
                    if (settings.name == TopicSelectScreen.route) {
                      final args =
                          settings.arguments as TopicSelectScreenArguments;
                      return MaterialPageRoute(
                        builder: (context) => TopicSelectScreen(
                          onTopicSelected: args.onSelect,
                          isEnabled: args.isEnabled,
                          selectedTopic: args.selectedTopic,
                        ),
                      );
                    }
                    if (settings.name == NotificationScreen.route) {
                      return MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      );
                    }
                    if (settings.name == AllCommentsScreen.route) {
                      final args =
                          settings.arguments as AllCommentsScreenArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return AllCommentsScreen(
                            postId: args.postId,
                            feedRoomId: args.feedRoomId,
                            fromComment: args.fromComment,
                          );
                        },
                      );
                    }
                    if (settings.name == LikesScreen.route) {
                      final args = settings.arguments as LikesScreenArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return LikesScreen(
                            postId: args.postId,
                            commentId: args.commentId,
                            isCommentLikes: args.isCommentLikes,
                          );
                        },
                      );
                    }
                    if (settings.name == MediaPreviewScreen.routeName) {
                      final args = settings.arguments as MediaPreviewArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return MediaPreviewScreen(
                            postAttachments: args.postAttachments,
                            post: args.post,
                            user: args.user ?? user!,
                          );
                        },
                      );
                    }
                    if (settings.name == ReportPostScreen.route) {
                      return MaterialPageRoute(
                        builder: (context) {
                          return const ReportPostScreen();
                        },
                      );
                    }
                    if (settings.name == NewPostScreen.route) {
                      final args = settings.arguments as NewPostScreenArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return NewPostScreen(
                            feedRoomId: args.feedroomId,
                            feedRoomTitle: args.feedRoomTitle,
                            isCm: args.isCm,
                            populatePostMedia: args.populatePostMedia,
                            populatePostText: args.populatePostText,
                          );
                        },
                      );
                    }

                    if (settings.name == EditPostScreen.route) {
                      final args =
                          settings.arguments as EditPostScreenArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return EditPostScreen(
                            postId: args.postId,
                            feedRoomId: args.feedRoomId,
                            selectedTopics: args.selectedTopics,
                          );
                        },
                      );
                    }

                    if (settings.name == FeedRoomSelect.route) {
                      final args =
                          settings.arguments as FeedRoomSelectArguments;
                      return MaterialPageRoute(
                        builder: (context) {
                          return FeedRoomSelect(
                            user: args.user,
                            feedRoomIds: args.feedRoomIds,
                          );
                        },
                      );
                    }
                    return null;
                  },
                  home: FutureBuilder(
                    future: locator<LikeMindsService>().getMemberState(),
                    initialData: null,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        final MemberStateResponse response = snapshot.data;
                        final isCm = response.state == 1;
                        if (isCm) {
                          UserLocalPreference.instance.storeMemberState(isCm);
                          return FeedRoomListScreen(user: user!);
                        } else {
                          UserLocalPreference.instance.storeMemberState(false);
                          return FeedRoomScreen(
                            isCm: isCm,
                            user: user!,
                            feedRoomId: widget.defaultFeedroom,
                          );
                        }
                      }

                      return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: kBackgroundColor,
                        child: const Center(
                          child: Loader(
                            isPrimary: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {}
          } else if (snapshot.hasError) {
            debugPrint("Error - ${snapshot.error}");

            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: kBackgroundColor,
              child: const Center(
                child: Text("An error has occured",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    )),
              ),
            );
          }
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: kBackgroundColor,
          );
        },
      ),
    );
  }
}
