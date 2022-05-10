import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/notifications_notifier.dart';

import 'package:wildberries/model/services/pushNotification_service.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/notificationDetails.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class InboxScreen extends StatefulWidget {
  InboxScreen({Key key}) : super(key: key);

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future notificationsFuture;

  UserDataProfile user;

  getUser() async {
    final Preference<String> userData =
        await preferences.getString('user', defaultValue: '');
    // userData.listen((value) {
    //   print('User $value');
    // });
    userData.listen((value) async {
      if (value == null) {
        user = UserDataProfile.fromMap(json.decode(value));
      }
    });
  }

  @override
  void initState() {
    getUser();
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  NotificationsNotifier notificationsNotifier =
                      Provider.of<NotificationsNotifier>(context,
                          listen: false);
                  //TODO:Check
                  // notificationsFuture = getNotifications(notificationsNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    super.initState();
  }

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?   phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    NotificationsNotifier notificationsNotifier =
        Provider.of<NotificationsNotifier>(context);
    var nots = notificationsNotifier.notificationMessageList;

    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
      floatingActionButton: CustomFloatingButton(
          CurrentScreen(currentScreen: InboxScreen(), tab_no: 0)),
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 20,
          color: MColors.secondaryColor,
        ),
        backgroundColor: MColors.mainColor,
        actions: [
          InkWell(
              onTap: () {
                launch('tel:+919027553376');
              },
              child: Icon(
                Icons.phone,
              )),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
                launchWhatsApp(
                    phone: '7060222315', message: 'Check out this awesome app');
              },
              child: Container(
                  alignment: Alignment.center,
                  child: FaIcon(FontAwesomeIcons.whatsapp))),
          SizedBox(
            width: 8,
          ),
          InkWell(
              onTap: () {
//                print(1);
                launch(
                    'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
              },
              child: Icon(
                Icons.mail,
              )),
          SizedBox(
            width: 14,
          )
        ],
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Wildberries',
          style: TextStyle(
              color: MColors.secondaryColor,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
      ),
      drawer: CustomDrawer(user, null, {}, {}),
      body: RefreshIndicator(
        // onRefresh: () => getNotifications(notificationsNotifier),
        child: primaryContainer(
          FutureBuilder(
            future: notificationsFuture,
            builder: (c, s) {
              switch (s.connectionState) {
                case ConnectionState.active:
                  return progressIndicator(MColors.primaryPurple);
                  break;
                case ConnectionState.done:
                  return nots.isEmpty
                      ? noNotifications()
                      : notificationsScreen(nots);
                  break;
                case ConnectionState.waiting:
                  return progressIndicator(MColors.primaryPurple);
                  break;
                default:
                  return noNotifications();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget notificationsScreen(nots) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: nots.length,
      itemBuilder: (context, i) {
        var not = nots[i];

        return GestureDetector(
          onTap: () async {
            NotificationsNotifier notificationsNotifier =
                Provider.of<NotificationsNotifier>(context, listen: false);
            var navigationResult = await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => NotificationsDetails(not),
              ),
            );
            if (navigationResult == true) {
              // updateNotificationStatusToTrue(not.notID);
              //
              // setState(() {
              //   getNotifications(notificationsNotifier);
              // });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: not.isRead == "true"
                  ? MColors.primaryWhite
                  : MColors.primaryPlatinum,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.0),
                      height: 35,
                      child: Image.asset(
                        not.senderAvatar,
                        height: 30,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MColors.primaryWhite,
                        border: Border.all(
                          color: MColors.primaryPurple,
                          width: 0.50,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      not.senderName,
                      style: normalFont(MColors.textDark, 14.0),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          not.sentTime,
                          style: normalFont(MColors.textGrey, 12.0),
                        ),
                        SizedBox(width: 5.0),
                        not.isRead == "true"
                            ? Container()
                            : Container(
                                height: 8.0,
                                width: 8.0,
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: MColors.primaryPurple,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Text(
                  not.notificationTitle,
                  style: boldFont(MColors.textDark, 14.0),
                ),
                SizedBox(height: 5.0),
                Text(
                  not.notificationBody,
                  style: normalFont(MColors.textDark, 13.0),
                ),
                SizedBox(height: 15.0),
                Text(
                  "$i days ago",
                  style: normalFont(MColors.primaryPurple, 12.0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget noNotifications() {
    return emptyScreen(
      "assets/images/noInbox.svg",
      "No Notifications",
      "Messages, promotions and general information from stores, pet news and the Pet Shop team will show up here.",
    );
  }
}
