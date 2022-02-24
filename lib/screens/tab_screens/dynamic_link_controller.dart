import 'package:flutter/cupertino.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:wildberries/model/data/Products.dart';

import 'homeScreen_pages/productDetailsScreen.dart';

class DynamicLinkController {
  @override
  void onInit() {}

  Future<Uri> createDynamicLink(index) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://wildberries.page.link/',
      navigationInfoParameters:
          NavigationInfoParameters(forcedRedirectEnabled: true),
      link: Uri.parse('https://wildberries.page.link/' + index.toString()),
      androidParameters: AndroidParameters(
        packageName: 'com.axactstudios.wildberries',
      ),
      iosParameters: IosParameters(
        bundleId: 'com.axactstudios.ecom',
        appStoreId: '1576741080',
      ),
    );
    return await parameters.buildUrl();
  }

  Future<void> share(String link, String title, String details) async {
    await FlutterShare.share(
        title: title,
        text: title,
        linkUrl: link,
        chooserTitle: 'Share Product');
  }
}
