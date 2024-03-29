import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:feed_sx/src/widgets/close_icon.dart';
import 'package:flutter/material.dart';

import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/views/feed/components/post/post_media/post_image_shimmer.dart';

import 'package:likeminds_feed/likeminds_feed.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PostMedia extends StatefulWidget {
  final String postId;
  final double? height;
  final List<Attachment>? attachments;
  final List<MediaModel>? mediaFiles;
  final Function(int)? removeAttachment;

  const PostMedia({
    super.key,
    this.height,
    this.attachments,
    this.removeAttachment,
    required this.postId,
    this.mediaFiles,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  Size? screenSize;
  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);
  List<Widget> mediaWidgets = [];
  VideoController? videoController;
  // Current index of carousel

  @override
  void dispose() {
    rebuildCurr.dispose();
    videoController?.player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    videoController?.player.pause();
  }

  bool checkIfMultipleAttachments() {
    return ((widget.attachments != null && widget.attachments!.length > 1) ||
        (widget.mediaFiles != null && widget.mediaFiles!.length > 1));
  }

  void mapMedia() {
    mediaWidgets = widget.attachments == null
        ? widget.mediaFiles!.map((e) {
            if (e.mediaType == MediaType.image) {
              return Stack(
                children: [
                  Container(
                     width: widget.height != null ? widget.height! - 32 : null,
                      height: widget.height != null ? widget.height! - 32 : null,
                      color:Colors.black,
                    child: Image.file(
                      e.mediaFile!,
                      fit: BoxFit.contain,
                      width: widget.height != null ? widget.height! - 32 : null,
                      height: widget.height != null ? widget.height! - 32 : null,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                        onTap: () {
                          int fileIndex = widget.mediaFiles!.indexOf(e);
                          if (fileIndex == widget.mediaFiles!.length - 1) {
                            currPosition -= 1;
                          }
                          widget.removeAttachment!(fileIndex);
                          setState(() {});
                        },
                        child: const CloseIcon()),
                  )
                ],
              );
            } else if (e.mediaType == MediaType.video) {
              return Stack(
                children: [
                  LMVideo(
                    videoFile: e.mediaFile,
                    isMute: true,
                    showControls: false,
                    autoPlay: false,
                    initialiseVideoController: (controller) {
                      videoController = controller;
                    },
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        int fileIndex = widget.mediaFiles!.indexOf(e);
                        if (fileIndex == widget.mediaFiles!.length - 1) {
                          currPosition -= 1;
                        }
                        widget.removeAttachment!(fileIndex);
                        setState(() {});
                      },
                      child: const CloseIcon(),
                    ),
                  )
                ],
              );
            }
            return const SizedBox.shrink();
          }).toList()
        : widget.attachments!.map((e) {
            if (e.attachmentType == 1) {
              return CachedNetworkImage(
                imageUrl: e.attachmentMeta.url!,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(
                  milliseconds: 200,
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    color: kBackgroundColor,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 24,
                          color: kGrey3Color,
                        ),
                        SizedBox(height: 24),
                        Text(
                          "An error occurred fetching media",
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  );
                },
                progressIndicatorBuilder: (context, url, progress) =>
                    const PostShimmer(),
              );
            } else if ((e.attachmentType == 2)) {
              return LMVideo(
                videoUrl: e.attachmentMeta.url,
                initialiseVideoController: (controller) {
                  videoController = controller;
                },
                showControls: false,
                autoPlay: false,
                isMute: true,
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList();
  }

  @override
  void initState() {
    mapMedia();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PostMedia oldWidget) {
    mapMedia();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(top: kPaddingMedium),
      child: Column(
        children: [
          SizedBox(
            width: widget.height ?? screenSize?.width,
            height: widget.height ?? screenSize?.width,
            child: CarouselSlider.builder(
              itemCount: mediaWidgets.length,
              itemBuilder: (context, index, index2) => mediaWidgets[index],
              options: CarouselOptions(
                  aspectRatio: 1.0,
                  initialPage: 0,
                  disableCenter: true,
                  scrollDirection: Axis.horizontal,
                  enableInfiniteScroll: false,
                  enlargeFactor: 0.0,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    currPosition = index;
                    rebuildCurr.value = !rebuildCurr.value;
                  }),
            ),
          ),
          ValueListenableBuilder(
              valueListenable: rebuildCurr,
              builder: (context, _, __) {
                return Column(
                  children: [
                    checkIfMultipleAttachments()
                        ? kVerticalPaddingMedium
                        : const SizedBox(),
                    checkIfMultipleAttachments()
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: widget.attachments != null
                                ? widget.attachments!.map((url) {
                                    int index =
                                        widget.attachments!.indexOf(url);
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 7.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currPosition == index
                                            ? const Color.fromRGBO(0, 0, 0, 0.9)
                                            : const Color.fromRGBO(
                                                0, 0, 0, 0.4),
                                      ),
                                    );
                                  }).toList()
                                : widget.mediaFiles!.map((data) {
                                    int index =
                                        widget.mediaFiles!.indexOf(data);
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 7.0, horizontal: 2.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currPosition == index
                                            ? const Color.fromRGBO(0, 0, 0, 0.9)
                                            : const Color.fromRGBO(
                                                0, 0, 0, 0.4),
                                      ),
                                    );
                                  }).toList(),
                          )
                        : const SizedBox(),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
