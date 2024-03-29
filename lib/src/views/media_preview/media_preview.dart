import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:intl/intl.dart';

class MediaPreviewScreen extends StatefulWidget {
  static const routeName = '/media-preview';
  final List<Attachment> postAttachments;
  final Post post;
  final User user;
  final int? position;

  const MediaPreviewScreen({
    Key? key,
    required this.postAttachments,
    required this.post,
    required this.user,
    this.position,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late List<Attachment> postAttachments;
  late Post post;
  late User user;
  late int? position;

  int currPosition = 0;
  CarouselController controller = CarouselController();
  ValueNotifier<bool> rebuildCurr = ValueNotifier<bool>(false);

  bool checkIfMultipleAttachments() {
    return (postAttachments.length > 1);
  }

  @override
  void initState() {
    postAttachments = widget.postAttachments;
    post = widget.post;
    user = widget.user;
    position = widget.position;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM d, hh:mm');
    final String formatted = formatter.format(post.createdAt);
    // final ThemeData theme = LMThemeData.suraasaTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: LMIconButton(
          onTap: (active) {
            Navigator.of(context).pop();
          },
          icon: const LMIcon(
            type: LMIconType.icon,
            // color: LMThemeData.kWhiteColor,
            icon: CupertinoIcons.xmark,
            size: 28,
            boxSize: 64,
            boxPadding: 12,
          ),
        ),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LMTextView(
              text: user.name,
              textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kWhiteColor,
                  ),
            ),
            ValueListenableBuilder(
              valueListenable: rebuildCurr,
              builder: (context, value, child) {
                return LMTextView(
                  text:
                      '${currPosition + 1} of ${postAttachments.length} media • $formatted',
                  textStyle: const TextStyle(
                        fontSize: 12,
                        color: kWhiteColor,
                      ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: CarouselSlider.builder(
                  options: CarouselOptions(
                      clipBehavior: Clip.hardEdge,
                      scrollDirection: Axis.horizontal,
                      initialPage: position ?? 0,
                      aspectRatio: 9 / 16,
                      enlargeCenterPage: false,
                      enableInfiniteScroll: false,
                      enlargeFactor: 0.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        currPosition = index;
                        rebuildCurr.value = !rebuildCurr.value;
                      }),
                  itemCount: postAttachments.length,
                  itemBuilder: (context, index, realIndex) {
                    if (postAttachments[index].attachmentType == 2) {
                      return LMVideo(
                        videoUrl: postAttachments[index].attachmentMeta.url,
                        showControls: true,
                      );
                    }

                    return Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width,
                      child: ExtendedImage.network(
                        postAttachments[index].attachmentMeta.url!,
                        cache: true,
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                            hitTestBehavior: HitTestBehavior.opaque,
                            minScale: 0.9,
                            animationMinScale: 0.7,
                            maxScale: 3.0,
                            animationMaxScale: 3.5,
                            speed: 1.0,
                            inertialSpeed: 100.0,
                            initialScale: 1.0,
                            inPageView: true,
                            initialAlignment: InitialAlignment.center,
                          );
                        },
                      ),
                    );
                  }),
            ),
            ValueListenableBuilder(
                valueListenable: rebuildCurr,
                builder: (context, _, __) {
                  return Column(
                    children: [
                      checkIfMultipleAttachments()
                          ? const SizedBox(
                              height: 8,
                            ) // todo: change to const value
                          : const SizedBox(),
                      checkIfMultipleAttachments()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: postAttachments.map((url) {
                                int index = postAttachments.indexOf(url);
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 7.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currPosition == index
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                );
                              }).toList())
                          : const SizedBox(),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
