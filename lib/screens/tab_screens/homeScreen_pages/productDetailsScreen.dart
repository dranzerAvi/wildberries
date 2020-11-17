import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mrpet/model/notifiers/wishlist_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/bag.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/similarProducts_Wigdet.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/starRatings.dart';
import 'package:provider/provider.dart';

class ProductDetailsProv extends StatelessWidget {
  final ProdProducts prodDetails;
  final Iterable<ProdProducts> prods;
  ProductDetailsProv(this.prodDetails, this.prods);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartNotifier>(
      create: (BuildContext context) => CartNotifier(),
      child: ChangeNotifierProvider<WishlistNotifier>(
          create: (BuildContext context) => WishlistNotifier(),
          child: ProductDetails(prodDetails, prods)),
    );
  }
}

class ProductDetails extends StatefulWidget {
  final ProdProducts prodDetails;
  final Iterable<ProdProducts> prods;
  ProductDetails(this.prodDetails, this.prods);

  @override
  _ProductDetailsState createState() =>
      _ProductDetailsState(prodDetails, prods);
}

class _ProductDetailsState extends State<ProductDetails> {
  _ProductDetailsState(this.prodDetails, this.prods);

  ProdProducts prodDetails;
  Iterable<ProdProducts> prods;
  bool _isbuttonDisabled = false;
  bool _isProductadded = false;
  String urlUniv, url2, url3;
  String chosenColor;
  String chosenSize;

  @override
  void initState() {
    chosenColor = 'White';
    chosenSize = 'S';
    urlUniv = prodDetails.productImage;
    url2 = 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png';
    url3 = 'https://homepages.cae.wisc.edu/~ece533/images/arctichare.png';
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);
    getCart(cartNotifier);
    WishlistNotifier wishlistNotifier =
        Provider.of<WishlistNotifier>(context, listen: false);
    getWishlist(wishlistNotifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    WishlistNotifier wishlistNotifier = Provider.of<WishlistNotifier>(context);
    var wishlistList = wishlistNotifier.wishlistList;

    void addQty() {
      setState(() {
        if (quantity > 9) {
          quantity = 9;
        } else if (quantity < 9) {
          setState(() {
            quantity++;
          });
        }
      });
    }

    void subQty() {
      setState(() {
        if (quantity != 1) {
          quantity--;
        } else if (quantity < 1) {
          setState(() {
            quantity = 1;
          });
        }
      });
    }

    var prod = prodDetails;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhite,
      appBar: AppBar(
        elevation: 0.0,
        brightness: Brightness.light,
        backgroundColor: MColors.primaryWhite,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MColors.textGrey,
            size: 22.0,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              _isProductadded,
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Misterpet.ae',
          style: TextStyle(
              color: MColors.secondaryColor,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Container(
            width: 70,
            child: RawMaterialButton(
              child: Container(
                height: 30.0,
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        height: 24.0,
                        color: MColors.textGrey,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cartList.isNotEmpty
                              ? Colors.redAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 7,
                          minHeight: 7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                CartNotifier cartNotifier =
                    Provider.of<CartNotifier>(context, listen: false);
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => Bag(),
                  ),
                );
                if (navigationResult == true) {
                  setState(() {
                    getCart(cartNotifier);
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: MColors.primaryWhiteSmoke,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              // top: 20.0,
              // right: 20.0,
              // left: 20.0,
              ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                      left: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 250,
                          color: MColors.primaryWhite,
                          // padding:
                          //     const EdgeInsets.fromLTRB(20.0, 70.0, 20.0, 10.0),
                          child: prod == null
                              ? Center(child: CircularProgressIndicator())
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Hero(
                                        child: FadeInImage.assetNetwork(
                                          image: urlUniv,
                                          placeholder:
                                              "assets/images/placeholder.jpg",
                                          placeholderScale:
                                              MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2,
                                        ),
                                        tag: prod.productID,
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: Column(
                                        children: [
                                          SizedBox(width: 14),
                                          Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    urlUniv = prodDetails
                                                        .productImage;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    // height: 65,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                        border: Border.all(
                                                            width: 2,
                                                            color: urlUniv !=
                                                                    prodDetails
                                                                        .productImage
                                                                ? MColors
                                                                    .primaryWhiteSmoke
                                                                : MColors
                                                                    .secondaryColor)),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      child: FancyShimmerImage(
                                                        shimmerDuration:
                                                            Duration(
                                                                seconds: 1),
                                                        imageUrl: prodDetails
                                                            .productImage,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )), //just to push
                                          Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    urlUniv = url2;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                      // height: 65,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          border: Border.all(
                                                              width: 2,
                                                              color: urlUniv !=
                                                                      url2
                                                                  ? MColors
                                                                      .primaryWhiteSmoke
                                                                  : MColors
                                                                      .secondaryColor)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        child:
                                                            FancyShimmerImage(
                                                          shimmerDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          // height: 80,
                                                          imageUrl: url2,
                                                        ),
                                                      )),
                                                ),
                                              )),
                                          Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    urlUniv = url3;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                      // height: 65,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5)),
                                                          border: Border.all(
                                                              width: 2,
                                                              color: urlUniv !=
                                                                      url3
                                                                  ? MColors
                                                                      .primaryWhiteSmoke
                                                                  : MColors
                                                                      .secondaryColor)),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        child:
                                                            FancyShimmerImage(
                                                          imageUrl: url3,
                                                          shimmerDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                        ),
                                                      )),
                                                ),
                                              )),
                                          // Expanded(
                                          //     flex: 2,
                                          //     child: Padding(
                                          //       padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          //       child: Container(
                                          //           decoration: BoxDecoration(
                                          //               color: MColors.secondaryElement,
                                          //               border: Border.all(
                                          //                 width: 2,
                                          //                 color: MColors.secondaryElement,
                                          //               ),
                                          //               borderRadius: BorderRadius.only(
                                          //                   topLeft: Radius.circular(10),
                                          //                   bottomLeft: Radius.circular(10))),
                                          //           child: Center(
                                          //               child: Column(
                                          //             mainAxisAlignment: MainAxisAlignment.center,
                                          //             children: [
                                          //               Text(
                                          //                 'Rs. ${int.parse(widget.restaurantDetail.price) * priceFactors[choice]}',
                                          //                 textAlign: TextAlign.left,
                                          //                 style: Styles.customMediumTextStyle(
                                          //                   fontWeight: FontWeight.w600,
                                          //                   color: Color(0xFF6b3600),
                                          //                   // fontWeight: FontWeight.w600,
                                          //                   fontSize: 24,
                                          //                 ),
                                          //               ),
                                          //               Text(
                                          //                 '(${sizes[choice].toString()})',
                                          //                 textAlign: TextAlign.left,
                                          //                 style: Styles.customMediumTextStyle(
                                          //                   color: Color(0xFF6b3600),
                                          //                   // fontWeight: FontWeight.w600,
                                          //                   fontSize: Sizes.TEXT_SIZE_18,
                                          //                 ),
                                          //               ),
                                          //             ],
                                          //           ))),
                                          //     )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Text(
                          prodDetails.name,
                          style: boldFont(MColors.textDark, 22.0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 35.0,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: MColors.dashPurple,
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 25.0,
                                    child: RawMaterialButton(
                                      onPressed: subQty,
                                      child: Icon(
                                        Icons.remove,
                                        color: MColors.secondaryColor,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                      right: 5.0,
                                      left: 5.0,
                                    ),
                                    child: Text(
                                      quantity.toString(),
                                      style: boldFont(MColors.textDark, 22.0),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.0,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: MColors.secondaryColor,
                                    ),
                                    width: 25.0,
                                    child: RawMaterialButton(
                                      onPressed: addQty,
                                      child: Icon(
                                        Icons.add,
                                        color: MColors.primaryWhiteSmoke,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              DropDown<String>(
                                initialValue: 'With AC',
                                items: <String>['With AC', 'Without AC'],
                                hint: Text("Select option"),
                                onChanged: (value) async {},
                              ),
                            ],
                          ),
                        ),
                        prodDetails.foodType == 'Dry'
                            ? Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Color: ',
                                          style:
                                              boldFont(MColors.textDark, 16.0),
                                        ),
                                        Text(
                                          chosenColor,
                                          style: normalFont(
                                              MColors.textGrey, 14.0),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 70,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenColor = 'White';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  45)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenColor ==
                                                                  'White'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenColor = 'Red';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .all(
                                                                  Radius
                                                                      .circular(
                                                                          45)),
                                                      color: Colors.red,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenColor ==
                                                                  'Red'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenColor = 'Blue';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  45)),
                                                      color: Colors.blue,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenColor ==
                                                                  'Blue'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenColor = 'Grey';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  45)),
                                                      color: Colors.grey,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenColor ==
                                                                  'Grey'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenColor = 'Green';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  45)),
                                                      color: Colors.green,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenColor ==
                                                                  'Green'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Size: ',
                                          style:
                                              boldFont(MColors.textDark, 16.0),
                                        ),
                                        Text(
                                          'Select size to see price',
                                          style: normalFont(
                                              MColors.textGrey, 14.0),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 70,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'XS';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'XS',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'XS'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'S';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'S',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'S'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'M';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'M',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'M'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'L';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'L',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'L'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'XL';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'XL',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'XL'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    chosenSize = 'XXL';
                                                  });
                                                },
                                                child: Container(
                                                  height: 70,
                                                  width: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'XXL',
                                                    style: boldFont(
                                                        MColors.textDark, 20.0),
                                                  ),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          width: 2,
                                                          color: chosenSize ==
                                                                  'XXL'
                                                              ? MColors
                                                                  .secondaryColor
                                                              : MColors
                                                                  .primaryWhiteSmoke)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(),
                        Builder(builder: (context) {
                          return Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: IconTheme(
                                      data: IconThemeData(
                                        color: Colors.amberAccent,
                                        size: 18,
                                      ),
                                      child: StarDisplay(value: 4),
                                    ),
                                  ),
                                ),
                                Text(
                                  "AED ${prodDetails.price}",
                                  style: boldFont(MColors.secondaryColor, 20.0),
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            "About this product",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            prodDetails.desc,
                            style: normalFont(MColors.textGrey, 14.0),
                          ),
                        ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "More",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Text(
                                  prodDetails.moreDesc,
                                  style: normalFont(MColors.textGrey, 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "Details",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Food type",
                                        style:
                                            normalFont(MColors.textDark, 16.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        prodDetails.foodType,
                                        style:
                                            normalFont(MColors.textGrey, 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Life stage",
                                        style:
                                            normalFont(MColors.textDark, 16.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        prodDetails.lifeStage,
                                        style:
                                            normalFont(MColors.textGrey, 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Weight",
                                        style:
                                            normalFont(MColors.textDark, 16.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        prodDetails.weight,
                                        style:
                                            normalFont(MColors.textGrey, 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Flavor",
                                        style:
                                            normalFont(MColors.textDark, 16.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        prodDetails.flavor,
                                        style:
                                            normalFont(MColors.textGrey, 14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "Directions",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Text(
                                  prodDetails.directions,
                                  style: normalFont(MColors.textGrey, 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "Ingredients",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 30.0,
                                  bottom: 10.0,
                                  right: 30.0,
                                ),
                                child: Text(
                                  prodDetails.ingredients,
                                  style: normalFont(MColors.textGrey, 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          child: Text(
                            "Similar products",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ),
                        SimilarProductsWidget(
                          prods: prods,
                          prodDetails: prodDetails,
                          scaffoldKey: _scaffoldKey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                // height: 100,
                width: MediaQuery.of(context).size.width,
                color: MColors.primaryWhiteSmoke,

                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: MColors.primaryWhiteSmoke,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: _isbuttonDisabled
                            ? null
                            : () => _submitWishlist(wishlistNotifier),
                        child: Text(
                          "Add to Wishlist",
                          style: boldFont(MColors.secondaryColor, 15.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: MColors.mainColor,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: _isbuttonDisabled
                            ? null
                            : () => _submit(cartNotifier),
                        child: Text(
                          "Add to Bag",
                          style: boldFont(MColors.secondaryColor, 15.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var quantity = 1;

  Widget _buildProductDetails(prodDetails, wishlistNotifier, cartNotifier) {}

  //Snakbar

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void disableButton() {
    setState(() {
      _isbuttonDisabled = true;
    });
  }

  bool isCartBadge = false;

  void _submit(cartNotifier) {
    var cartProdID = cartNotifier.cartList.map((e) => e.productID);
    setState(() {
      getCart(cartNotifier);
    });

    try {
      if (cartProdID.contains(prodDetails.productID)) {
        showSimpleSnack(
          "Product already in bag",
          Icons.error_outline,
          Colors.amber,
          _scaffoldKey,
        );
      } else {
        prodDetails.quantity = quantity;
        prodDetails.totalPrice = prodDetails.price * prodDetails.quantity;

        addProductToCart(prodDetails);
        showSimpleSnack(
          "Product added to bag",
          Icons.check_circle_outline,
          Colors.green,
          _scaffoldKey,
        );
        setState(() {
          getCart(cartNotifier);
          isCartBadge = true;
          _isProductadded = true;
        });
      }
    } catch (e) {
      print("ERRORR ==>");
      print(e);
    }
  }

  void _submitWishlist(wishlistNotifier) {
    var wishlistProdID = wishlistNotifier.wishlistList.map((e) => e.productID);
    setState(() {
      getWishlist(wishlistNotifier);
    });

    try {
      if (wishlistProdID.contains(prodDetails.productID)) {
        showSimpleSnack(
          "Product already in Wishlist",
          Icons.error_outline,
          Colors.amber,
          _scaffoldKey,
        );
      } else {
        prodDetails.quantity = quantity;
        prodDetails.totalPrice = prodDetails.price * prodDetails.quantity;

        addProductToWishlist(prodDetails);
        showSimpleSnack(
          "Product added to Wishlist",
          Icons.check_circle_outline,
          Colors.green,
          _scaffoldKey,
        );
        setState(() {
          getCart(wishlistNotifier);
          isCartBadge = true;
          _isProductadded = true;
        });
      }
    } catch (e) {
      print("ERRORR ==>");
      print(e);
    }
  }
}
