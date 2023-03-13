import 'dart:io';

import 'package:likeminds_feed/likeminds_feed.dart';

class AllCommentsScreenArguments {
  final Post post;
  final int feedroomId;
  AllCommentsScreenArguments({
    required this.post,
    required this.feedroomId,
  });
}

class LikesScreenArguments {
  final GetPostLikesResponse response;
  final String postId;
  LikesScreenArguments({
    required this.response,
    required this.postId,
  });
}

class NewPostScreenArguments {
  final User user;
  final int feedroomId;
  NewPostScreenArguments({required this.user, required this.feedroomId});
}

class ImagePreviewArguments {
  final String postId;
  final List<String>? url;
  final List<File>? images;
  ImagePreviewArguments({
    this.url,
    this.images,
    required this.postId,
  });
}
