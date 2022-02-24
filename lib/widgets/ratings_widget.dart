import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:wildberries/utils/colors.dart';

class Ratings extends StatelessWidget {
  String rating;

  Ratings(this.rating);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: MColors.mainColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.star,
            color: Colors.yellow,
            size: 13,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(
            rating,
            style: TextStyle(
              color: MColors.secondaryColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          )
        ],
      ),
    );
  }
}

double initRat = 0;

class RatingsBar extends StatelessWidget {
  RatingsBar({
    this.title = "Rating",
    this.hasSubtitle = true,
    this.subtitle = "Rate your experience",
    this.hasTitle = true,
  });

  final String title;
  final bool hasTitle;
  final String subtitle;
  final bool hasSubtitle;
  var rat = 0.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        hasTitle
            ? Text(
                title,
                style: TextStyle(
                  color: MColors.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              )
            : Container(),
        hasTitle ? SizedBox(height: 16) : Container(),
        Container(
          width: MediaQuery.of(context).size.width - 60,
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: MColors.mainColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Center(
            child: RatingBar.builder(
              initialRating: initRat,
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
                rat = rating;
                // print(rating);
              },
            ),
          ),
        ),
        SizedBox(height: 12.0),
        hasSubtitle
            ? Text(
                subtitle,
                style: TextStyle(
                  color: MColors.secondaryColor,
                  fontSize: 16,
                ),
              )
            : Container(),
      ],
    );
  }
}
