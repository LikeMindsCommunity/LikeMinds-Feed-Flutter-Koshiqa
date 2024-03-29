import 'package:equatable/equatable.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

part 'likes_event.dart';
part 'likes_state.dart';

class LikesBloc extends Bloc<LikesEvent, LikesState> {
  LikesBloc() : super(LikesInitial()) {
    on<LikesEvent>((event, emit) async {
      if (event is GetLikes) {
        if (event.offset > 1) {
          emit(LikesPaginationLoading());
        } else {
          emit(LikesLoading());
        }
        try {
          GetPostLikesResponse? response =
              await locator<LikeMindsService>().getPostLikes(
            (GetPostLikesRequestBuilder()
                  ..postId(event.postId)
                  ..page(event.offset)
                  ..pageSize(event.pageSize))
                .build(),
          );

          if (response.success) {
            emit(
              LikesLoaded(response: response),
            );
          } else {
            emit(
              const LikesError(message: "An error occurred, Please try again"),
            );
          }
        } catch (e) {
          emit(
            LikesError(message: "${e.toString()} No data found"),
          );
        }
      } else if (event is GetCommentLikes) {
        // Implement pagination for GetCommentLikes
        if (event.offset > 1) {
          emit(LikesPaginationLoading());
        } else {
          emit(LikesLoading());
        }
        try {
          GetCommentLikesResponse response =
              await locator<LikeMindsService>().getCommentLikes(
            (GetCommentLikesRequestBuilder()
                  ..postId(event.postId)
                  ..commentId(event.commentId)
                  ..pageSize(event.pageSize)
                  ..page(event.offset))
                .build(),
          );
          if (response.success) {
            emit(
              CommentLikesLoaded(response: response),
            );
          } else {
            emit(
              const LikesError(message: "An error occurred, Please try again"),
            );
          }
        } catch (e) {
          emit(
            LikesError(message: "${e.toString()} No data found"),
          );
        }
      }
    });
  }
}
