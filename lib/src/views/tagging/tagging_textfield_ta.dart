import 'dart:async';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/packages/flutter_typeahead-4.3.7/lib/flutter_typeahead.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

class TaggingAheadTextField extends StatefulWidget {
  final bool isDown;
  final FocusNode focusNode;
  final Function(UserTag) onTagSelected;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final Function(String)? onChange;
  final int feedroomId;

  const TaggingAheadTextField({
    super.key,
    required this.isDown,
    required this.feedroomId,
    required this.onTagSelected,
    required this.controller,
    required this.focusNode,
    this.decoration,
    this.onChange,
  });

  @override
  State<TaggingAheadTextField> createState() => _TaggingAheadTextFieldState();
}

class _TaggingAheadTextFieldState extends State<TaggingAheadTextField> {
  late final TextEditingController _controller;
  FocusNode? _focusNode;
  final ScrollController _scrollController = ScrollController();
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController();

  List<UserTag> userTags = [];

  int page = 1;
  int tagCount = 0;
  bool tagComplete = false;
  String textValue = "";
  String tagValue = "";
  static const fixedSize = 6;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode!.dispose();
    _scrollController.dispose();
    _suggestionsBoxController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode;
    _controller = widget.controller!;
    _scrollController.addListener(() async {
      // page++;
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        final taggingData = await locator<LikeMindsService>().getTaggingList(
          request: (GetTaggingListRequestBuilder()
                ..feedroomId(widget.feedroomId)
                ..page(page)
                ..pageSize(fixedSize))
              .build(),
        );
        if (taggingData.members != null && taggingData.members!.isNotEmpty) {
          userTags.addAll(taggingData.members!.map((e) => e).toList());
          // return userTags;
        }
      }
    });
  }

  TextEditingController? get controller => _controller;

  FutureOr<Iterable<UserTag>> _getSuggestions(String query) async {
    String currentText = query;
    try {
      if (currentText.isEmpty) {
        return const Iterable.empty();
      } else if (!tagComplete && currentText.contains('@')) {
        String tag = tagValue.substring(1).replaceAll(' ', '');
        final taggingData = await locator<LikeMindsService>().getTaggingList(
          request: (GetTaggingListRequestBuilder()
                ..feedroomId(widget.feedroomId)
                ..page(1)
                ..pageSize(fixedSize)
                ..searchQuery(tag))
              .build(),
        );
        if (taggingData.members != null && taggingData.members!.isNotEmpty) {
          userTags = taggingData.members!.map((e) => e).toList();
          return userTags;
        }
        return const Iterable.empty();
      } else {
        return const Iterable.empty();
      }
    } catch (e) {
      return const Iterable.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TypeAheadField<UserTag>(
        onTagTap: (p) {
          // print(p);
        },
        suggestionsBoxController: _suggestionsBoxController,
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          elevation: 4,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.22,
          ),
        ),
        // keepSuggestionsOnLocading: true,
        noItemsFoundBuilder: (context) => const SizedBox.shrink(),
        hideOnEmpty: true,
        debounceDuration: const Duration(milliseconds: 500),
        scrollController: _scrollController,
        textFieldConfiguration: TextFieldConfiguration(
          keyboardType: TextInputType.multiline,
          controller: _controller,
          focusNode: _focusNode,
          minLines: 2,
          maxLines: 200,
          decoration: widget.decoration ??
              const InputDecoration(
                hintText: 'Write something here...',
                border: InputBorder.none,
              ),
          onChanged: ((value) {
            widget.onChange!(value);
            final int newTagCount = '@'.allMatches(value).length;
            final int completeCount = '~'.allMatches(value).length;
            if (newTagCount == completeCount) {
              textValue = _controller.value.text;
              tagComplete = true;
            } else if (newTagCount > completeCount) {
              tagComplete = false;
              tagCount = completeCount;
              tagValue = value.substring(value.lastIndexOf('@'));
              textValue = value.substring(0, value.lastIndexOf('@'));
            }
          }),
        ),
        direction: widget.isDown ? AxisDirection.down : AxisDirection.up,
        suggestionsCallback: (suggestion) async {
          return await _getSuggestions(suggestion);
        },
        keepSuggestionsOnSuggestionSelected: true,
        itemBuilder: ((context, opt) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: kGrey3Color,
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ProfilePicture(
                      user: User(
                        id: opt.id!,
                        imageUrl: opt.imageUrl!,
                        name: opt.name!,
                        userUniqueId: opt.userUniqueId!,
                        isGuest: opt.isGuest!,
                        isDeleted: false,
                      ),
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      opt.name!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        onSuggestionSelected: ((suggestion) {
          print(suggestion);
          widget.onTagSelected.call(suggestion);
          setState(() {
            tagComplete = true;
            tagCount = '@'.allMatches(_controller.text).length;
            // _controller.text.substring(_controller.text.lastIndexOf('@'));
            if (textValue.length > 2 &&
                textValue.substring(textValue.length - 1) == '~') {
              textValue += " @${suggestion.name!}~";
            } else {
              textValue += "@${suggestion.name!}~";
            }
            _controller.text = '$textValue ';
            _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length));
            tagValue = '';
            textValue = _controller.value.text;
          });
        }),
      ),
    );
  }
}

extension NthOccurrenceOfSubstring on String {
  int nThIndexOf(String stringToFind, int n) {
    if (indexOf(stringToFind) == -1) return -1;
    if (n == 1) return indexOf(stringToFind);
    int subIndex = -1;
    while (n > 0) {
      subIndex = indexOf(stringToFind, subIndex + 1);
      n -= 1;
    }
    return subIndex;
  }

  bool hasNthOccurrence(String stringToFind, int n) {
    return nThIndexOf(stringToFind, n) != -1;
  }
}
