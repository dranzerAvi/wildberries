import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrpet/screens/review.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/ratings_widget.dart';

class ReviewRating extends StatefulWidget {
  String reviewRating;
  ReviewRating(this.reviewRating);
  @override
  _ReviewRatingState createState() => _ReviewRatingState();
}

class _ReviewRatingState extends State<ReviewRating> {
  List<Widget> reviews = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        iconTheme: IconThemeData(
          size: 20,
          color: MColors.secondaryColor,
        ),
        backgroundColor: MColors.mainColor,

        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Reviews & Ratings',
          style: TextStyle(
              color: MColors.secondaryColor,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
      ),
      body:Column(
        children: [
          Container(
            height:MediaQuery.of(context).size.height*0.7,
            width:MediaQuery.of(context).size.width*0.9,
            child:StreamBuilder(
              stream:FirebaseFirestore.instance.collection('Reviews').snapshots(),
              builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snap){
                if(snap.hasData&&snap.hasError&&snap.data!=null){
                  reviews.clear();
                  for(int i =0;i<snap.data.docs.length;i++){
                    if(snap.data.docs[i]['productName']==widget.reviewRating){
                      reviews.add(ListTile(
                        title:Row(
                          children: [
                            Text(snap.data.docs[i]['userName'],style:TextStyle(color: MColors.secondaryColor,
                                fontSize: 22,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold)),
                            Ratings(snap.data.docs[i]['rating']),
                          ],
                        ),
                        contentPadding:EdgeInsets.symmetric(horizontal:0),
                        subtitle:Text(snap.data.docs[i]['details'],
                        style:TextStyle(color:MColors.secondaryColor,fontSize: 18.0,fontFamily:'Poppins',fontWeight: FontWeight.bold)),

                      ));
                    }
                  }
                  return reviews.length!=0?Padding(
                padding: EdgeInsets.all(8.0),
                child:ListView(
                children: reviews,
                )
                ):
                Container();
                }else
                  return Container(
                child:Center(child: Text('No Data',style:TextStyle(color:Colors.black))),
                );
              }
            )
          ),
          InkWell(
            onTap:(){
              Navigator.push(context,MaterialPageRoute(builder:(context)=>Review(widget.reviewRating)));
    },
            child: Center(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height:MediaQuery.of(context).size.height*0.05,
                  width:MediaQuery.of(context).size.width*0.4,

                  decoration: BoxDecoration(color:MColors.mainColor,borderRadius: BorderRadius.circular(4.0)),
                  child:Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text('Add your review',style:TextStyle(color:MColors.secondaryColor,fontFamily: 'Poppins'))),
                  )
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
