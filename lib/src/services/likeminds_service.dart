import 'dart:io';

import 'package:feed_sx/src/utils/credentials/credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

abstract class ILikeMindsService {
  FeedApi getFeedApi();
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request);
  Future<bool> getMemberState();
  Future<UniversalFeedResponse?> getUniversalFeed(UniversalFeedRequest request);
  Future<GetFeedRoomResponse> getFeedRoom(GetFeedRoomRequest request);
  Future<GetFeedOfFeedRoomResponse> getFeedOfFeedRoom(
      GetFeedOfFeedRoomRequest request);
  Future<AddPostResponse> addPost(AddPostRequest request);
  Future<GetPostResponse> getPost(GetPostRequest request);
  Future<GetPostLikesResponse> getPostLikes(GetPostLikesRequest request);
  Future<GetCommentLikesResponse> getCommentLikes(
      GetCommentLikesRequest request);
  Future<DeletePostResponse> deletePost(DeletePostRequest request);
  Future<LikePostResponse> likePost(LikePostRequest request);
  Future<DeleteCommentResponse> deleteComment(DeleteCommentRequest request);
  Future<String?> uploadFile(File file);
  Future<RegisterDeviceResponse> registerDevice(RegisterDeviceRequest request);
  Future<TagResponseModel> getTags({required TagRequestModel request});
  void routeToProfile(String userId);
}

class LikeMindsService implements ILikeMindsService {
  late final LMFeedClient _sdkApplication;

  int? feedroomId;

  set setFeedroomId(int feedroomId) {
    debugPrint("UI Layer: FeedroomId set to $feedroomId");
    this.feedroomId = feedroomId;
  }

  get getFeedroomId => feedroomId;

  LikeMindsService(LMSdkCallback sdkCallback) {
    print("UI Layer: LikeMindsService initialized");
    final apiKey = false ? CredsProd.apiKey : CredsDev.apiKey;
    _sdkApplication = LMFeedClient.initiateLikeMinds(
      apiKey: apiKey,
      sdkCallback: sdkCallback,
    );
    LMAnalytics.get().initialize();
  }

  @override
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    return await _sdkApplication.initiateUser(request);
  }

  @override
  FeedApi getFeedApi() {
    return _sdkApplication.getFeedApi();
  }

  @override
  Future<UniversalFeedResponse?> getUniversalFeed(
      UniversalFeedRequest request) async {
    return await _sdkApplication.getUniversalFeed(request);
  }

  @override
  Future<AddPostResponse> addPost(AddPostRequest request) async {
    return await _sdkApplication.addPost(request);
  }

  @override
  Future<DeletePostResponse> deletePost(DeletePostRequest request) async {
    return await _sdkApplication.deletePost(request);
  }

  @override
  Future<GetPostResponse> getPost(GetPostRequest request) async {
    return await _sdkApplication.getPost(request);
  }

  @override
  Future<GetPostLikesResponse> getPostLikes(GetPostLikesRequest request) async {
    return await _sdkApplication.getPostLikes(request);
  }

  @override
  Future<GetCommentLikesResponse> getCommentLikes(
      GetCommentLikesRequest request) async {
    return await _sdkApplication.getCommentLikes(request);
  }

  @override
  Future<LikePostResponse> likePost(LikePostRequest likePostRequest) async {
    return await _sdkApplication.likePost(likePostRequest);
  }

  @override
  Future<DeleteCommentResponse> deleteComment(
      DeleteCommentRequest deleteCommentRequest) async {
    return await _sdkApplication.deleteComment(deleteCommentRequest);
  }

  @override
  Future<String?> uploadFile(File file) async {
    return await _sdkApplication.uploadFile(file);
  }

  @override
  Future<GetFeedOfFeedRoomResponse> getFeedOfFeedRoom(
      GetFeedOfFeedRoomRequest request) async {
    return await _sdkApplication.getFeedOfFeedRoom(request);
  }

  @override
  Future<GetFeedRoomResponse> getFeedRoom(GetFeedRoomRequest request) async {
    return await _sdkApplication.getFeedRoom(request);
  }

  @override
  Future<bool> getMemberState() async {
    return await _sdkApplication.getMemberState();
  }

  @override
  Future<RegisterDeviceResponse> registerDevice(
      RegisterDeviceRequest request) async {
    return await LMNotifications.registerDevice(request);
  }

  @override
  Future<TagResponseModel> getTags({required TagRequestModel request}) async {
    return await _sdkApplication.getTags(request: request);
  }

  @override
  void routeToProfile(String userId) {
    _sdkApplication.routeToProfile(userId);
  }
}
