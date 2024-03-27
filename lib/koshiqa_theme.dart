import 'dart:ui';

import 'package:likeminds_feed_flutter_koshiqa/likeminds_feed_flutter_koshiqa.dart';

const Color kPrimaryColor = Color.fromARGB(255, 6, 92, 193);
const Color kBackgroundColor = Color(0xffF5F5F5);
const Color kWhiteColor = Color(0xffFFFFFF);
const Color kGreyColor = Color(0xff666666);
const Color kGrey1Color = Color(0xff222020);
const Color kGrey2Color = Color(0xff504B4B);
const Color kGrey3Color = Color(0xff9B9B9B);
const Color kGreyWebBGColor = Color(0xffE6EBF5);
const Color kGreyBGColor = Color.fromRGBO(208, 216, 226, .4);
const Color kBlueGreyColor = Color(0xff484F67);
const Color kLinkColor = Color(0xff007AFF);
const Color kHeadingColor = Color(0xff333149);
const Color kBorderColor = Color.fromRGBO(208, 216, 226, 0.5);
const Color notificationRedColor = Color.fromRGBO(208, 216, 226, 0.4);

LMFeedThemeData get koshiqaTheme {
  return LMFeedThemeData.light(
    primaryColor: kPrimaryColor,
    backgroundColor: kBackgroundColor,
    onContainer: kHeadingColor,
    onPrimary: kWhiteColor,
    linkColor: kLinkColor,
    headerStyle: LMFeedPostHeaderStyle.basic().copyWith(
      showCustomTitle: false,
    ),
  );
}
