import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';

part 'feedroom_event.dart';
part 'feedroom_state.dart';

class FeedRoomBloc extends Bloc<FeedRoomEvent, FeedRoomState> {
  FeedRoomBloc() : super(FeedRoomInitial()) {
    on<FeedRoomEvent>((event, emit) async {
      Map<String, User> users = {};
      if (state is FeedRoomLoaded) {
        users = (state as FeedRoomLoaded).feed.users;
      }
      if (event is GetFeedRoom) {
        event.isPaginationLoading
            ? emit(PaginationLoading())
            : emit(FeedRoomLoading());
        try {
          GetFeedOfFeedRoomResponse? response =
              await locator<LikeMindsService>().getFeedOfFeedRoom(
            (GetFeedOfFeedRoomRequestBuilder()
                  ..feedroomId(event.feedRoomId)
                  ..page(event.offset)
                  ..pageSize(10))
                .build(),
          );
          GetFeedRoomResponse? feedRoomResponse =
              await locator<LikeMindsService>().getFeedRoom(
            (GetFeedRoomRequestBuilder()
                  ..feedroomId(event.feedRoomId)
                  ..page(event.offset))
                .build(),
          );
          if (!response.success) {
            emit(FeedRoomError(
                message: "An error has occured, please try again"));
          } else {
            response.users.addAll(users);
            if ((response.posts == null || response.posts!.isEmpty) &&
                event.offset <= 1) {
              emit(FeedRoomEmpty(
                feedRoom: feedRoomResponse.chatroom!,
                feed: response,
              ));
            } else {
              emit(FeedRoomLoaded(
                  feed: response, feedRoom: feedRoomResponse.chatroom!));
            }
          }
        } catch (e) {
          emit(FeedRoomError(message: e.toString()));
        }
      }
    });
  }
}
