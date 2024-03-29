import 'package:equatable/equatable.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

part 'topic_event.dart';
part 'topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  TopicBloc() : super(TopicInitial()) {
    on<TopicEvent>((event, emit) async {
      if (event is InitTopicEvent) {
        emit(TopicLoading());
      } else if (event is GetTopic) {
        emit(TopicLoading());
        GetTopicsResponse response = await locator<LikeMindsService>()
            .getTopics(event.getTopicFeedRequest);
        if (response.success) {
          emit(TopicLoaded(response));
        } else {
          emit(TopicError(response.errorMessage!));
        }
      }
    });
  }
}
