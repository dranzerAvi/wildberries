import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/home.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/bag.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Review extends StatefulWidget {
  String productname;
  Review(this.productname);
  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  TextEditingController contrl = new TextEditingController();

  var ratingGlobal = '1';
  String name, number;
  getUserDetails() async {
    // User user = FirebaseAuth.instance.currentUser;
    //TODO:Check
    // var ref = FirebaseFirestore.instance.collection('userData');
    // ref
    //     .doc(user.email)
    //     .collection('profile')
    //     .doc(user.email)
    //     .get()
    //     .then((value) {
    //   Map<String, dynamic> map = value.data();
    //   name = map['name'];
    //   number = map['phone'];
    //   FirebaseFirestore.instance.collection('Reviews').add({
    //     "username": name,
    //     "useremail": user.email,
    //     "user_phn_no": number,
    //     "rating": ratingGlobal,
    //     "details": contrl.text,
    //     "productName": widget.productname,
    //   });
    //   Fluttertoast.showToast(
    //       msg: 'Review Added', toastLength: Toast.LENGTH_SHORT);
    //   Navigator.pop(context);
    // });
  }

  TextEditingController controller = TextEditingController();
  bool showSuffixIcon = false;
  bool hasRestaurantBeenAdded = false;
  bool isCardShowing = false;
  bool canPost = false;
  void postReview() async {
    await getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68.0),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Cancel',
                        style: textTheme.bodyText2.copyWith(
                          color: MColors.secondaryColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "New Review",
                  style: TextStyle(
                    color: MColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 22.0,
                  ),
                ),
                InkWell(
                  onTap: postReview,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Text(
                        'Post',
                        style: textTheme.bodyText2.copyWith(
                          color:
                              canPost ? MColors.secondaryColor : Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: ListView(
            children: <Widget>[
//              Container(
//                width: MediaQuery.of(context).size.width * 0.8,
//                height: 70,
//                child: Row(
//                  children: [
//                    Container(
//                      width: MediaQuery.of(context).size.width * 0.84,
//                      // height: 60,
//                      child: InkWell(
//                        onTap: () {},
//                        child: TextFormField(
//                          controller: controller,
//                          enabled: false,
//                          style: TextStyle(
//                              color: Colors.black,
//                              fontSize: 16,
//                              fontFamily: 'Poppins'),
//                          decoration: InputDecoration(
//                            enabledBorder: OutlineInputBorder(
//                              borderSide:
//                                  BorderSide(color: Colors.grey, width: 0.0),
//                            ),
//                            focusedBorder: OutlineInputBorder(
//                              borderSide:
//                                  BorderSide(color: Colors.grey, width: 0.0),
//                            ),
//                            border: OutlineInputBorder(
//                              borderRadius: BorderRadius.circular(12),
//                              borderSide: BorderSide(
//                                color: Colors.grey,
//                                width: 0.0,
//                                style: BorderStyle.none,
//                              ),
//                            ),
//                            prefixIcon: InkWell(
//                              onTap: () {},
//                              child: Icon(Icons.search),
//                            ),
//                            contentPadding: EdgeInsets.symmetric(
//                              horizontal: 0,
//                              vertical: 22,
//                            ),
//                            hintText: 'Find Products',
//                            hintStyle: TextStyle(color: Colors.grey),
//                            filled: false,
//                          ),
//                          obscureText: false,
//                          onChanged: (value) => _onChange(value),
//                        ),
//                      ),
//                    ),
//                    Center(
//                      child: InkWell(
//                        onTap: () {
//                          controller.clear();
//                          changeState(
//                            showSuffixIcon: false,
//                            isCardShowing: false,
//                            hasRestaurantBeenAdded: false,
//                          );
//                        },
//                        child: Icon(Icons.sort),
//                      ),
//                    )
//                  ],
//                ),
//              ),

//              isCardShowing ? SizedBox(height:30) : Container(),
//              isCardShowing
//                  ? FoodyBiteSearchCard(
//                hasBeenAdded: hasRestaurantBeenAdded,
//                onPressed: () {
//                  changeState(
//                      hasRestaurantBeenAdded: true,
//                      isCardShowing: true,
//                      showSuffixIcon: true,
//                      canPost: true);
//                },
//                onPressClose: () {
//                  changeState(
//                    isCardShowing: false,
//                    hasRestaurantBeenAdded: false,
//                    showSuffixIcon: true,
//                  );
//                },
//              )
//                  : Container(),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Rating',
                  style: TextStyle(
                    color: MColors.secondaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              Container(
                width: MediaQuery.of(context).size.width - 60,
                padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFEEF7FF),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 48,
                    unratedColor: Color(0xFFDFE4ED),
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        ratingGlobal = rating.toString();
                      });
                      // print(rating);
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              Center(
                child: Text(
                  'Rate your experience',
                  style: TextStyle(
                    color: MColors.secondaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildReview(context: context),
            ],
          ),
        ),
      ),
    );
  }

  void _onChange(String value) {
    if (value.length > 0) {
      changeState(showSuffixIcon: true, isCardShowing: true);
    } else {
      changeState(showSuffixIcon: false, isCardShowing: false);
    }
  }

  void changeState({
    bool showSuffixIcon = false,
    bool hasRestaurantBeenAdded = false,
    bool isCardShowing = false,
    bool canPost = false,
  }) {
    setState(() {
      this.showSuffixIcon = showSuffixIcon;
      this.hasRestaurantBeenAdded = hasRestaurantBeenAdded;
      this.isCardShowing = isCardShowing;
      this.canPost = canPost;
    });
  }

  Widget _buildReview({@required BuildContext context}) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(
          "Review",
          style: TextStyle(
            color: MColors.secondaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16.0),
        TextFormField(
          controller: contrl,
          maxLines: 10,
          decoration: InputDecoration(
              hintText: "Write your experience",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16.0),
              contentPadding: EdgeInsets.all(8.0)),
        ),
      ],
    );
  }

  Widget suffixIcon() {
    return Container(
      child: Icon(
        Icons.close,
        color: Colors.lightBlueAccent[100],
      ),
    );
  }
}
