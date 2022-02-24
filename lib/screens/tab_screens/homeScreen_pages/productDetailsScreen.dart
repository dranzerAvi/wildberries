import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/notifiers/wishlist_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/review_rating.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/bag.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/similarProducts_Wigdet.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/starRatings.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/model/data/variants.dart';

import '../dynamic_link_controller.dart';

class ProductDetailsProv extends StatelessWidget {
  final ProdProducts prodDetails;
  final Iterable<ProdProducts> prods;
  final DynamicLinkController controller;

  ProductDetailsProv(this.prodDetails, this.prods, this.controller);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartNotifier>(
      create: (BuildContext context) => CartNotifier(),
      child: ChangeNotifierProvider<WishlistNotifier>(
          create: (BuildContext context) => WishlistNotifier(),
          child: ProductDetails(prodDetails, prods, controller)),
    );
  }
}

class ProductDetails extends StatefulWidget {
  final ProdProducts prodDetails;
  final Iterable<ProdProducts> prods;
  final DynamicLinkController controller;
  ProductDetails(this.prodDetails, this.prods, this.controller);

  @override
  _ProductDetailsState createState() =>
      _ProductDetailsState(prodDetails, prods, controller);
}

class _ProductDetailsState extends State<ProductDetails> {
  _ProductDetailsState(this.prodDetails, this.prods, this.controller);

  ProdProducts prodDetails;
  Iterable<ProdProducts> prods;
  final DynamicLinkController controller;
  bool _isbuttonDisabled = false;
  bool _isProductadded = false;
  String urlUniv, url2, url3;
  String chosenColor;
  String chosenSize;
  String chosendrop;
  List<String> colors = [];
  double price;
  List<Widget> details = [];
  List<Widget> specs = [];
  @override
  void initState() {
    // check();
    // getvariants();
    prodDetails.tablespecs.forEach((element) {
      details.add(Container(
        padding: const EdgeInsets.only(
          left: 14.0,
          bottom: 20.0,
          right: 14.0,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                element['name'],
                style: normalFont(MColors.textDark, 16.0),
              ),
            ),
            Expanded(
              child: Text(
                element['value'],
                style: normalFont(MColors.textGrey, 14.0),
              ),
            ),
          ],
        ),
      ));
    });

    prodDetails.specs.forEach((element) {
      specs.add(Container(
        padding: const EdgeInsets.only(
          left: 14.0,
          bottom: 20.0,
          right: 14.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              element['name'],
              style: boldFont(MColors.textDark, 16.0),
            ),
            Text(
              element['value'],
              style: normalFont(MColors.textGrey, 14.0),
            ),
          ],
        ),
      ));
    });
    urlUniv = prodDetails.image;
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

  int j = 0;
  bool drop;
  List<String> dropdown = [];
  //TODO:Check
// void check(){
//   print('Length:${prodDetails.variants.length}');
//     if(prodDetails.variants.length>1){
//       for(int i=0;i<prodDetails.variants.length;i++) {
//         if (prodDetails.variants[i]['withAC'] == 'N/A') {
//           j++;
//         }
//       }
//       if(j==prodDetails.variants.length){
//         drop=false;
//
//       }
//       else{
//         drop=true;
//       }
//     }
// }
// void getvariants(){
//   setState(() {
//     alldata.clear();
//   });
//
//   if(prodDetails.variants.length>1){
//     for(int i=0;i<prodDetails.variants.length;i++){
//       if(prodDetails.variants[i]['withAC']=='true'){
//         alldata.add(Variants(List.from(prodDetails.variants[i]['color']),prodDetails.variants[i]['size'],prodDetails.variants[i]['price']));
//
//       }
//       print(alldata.length);
//     }
//     if(alldata.length==0){
//       dropdown.add('Without AC');
//       for(int i=0;i<prodDetails.variants.length;i++){
//         alldata.add(Variants(List.from(prodDetails.variants[i]['color']),prodDetails.variants[i]['size'],prodDetails.variants[i]['price']));
//       }
//     }
//     else{
//       dropdown.add('With AC');
//       dropdown.add('Without AC');
//     }
//     colors=List.from(alldata[0].colors);
//     chosenSize=alldata[0].size;
//     price=double.parse(alldata[0].price);
//   }
//
// }
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
        bundleId: 'com.axactstudios.wildberries',
        appStoreId: '1576741080',
      ),
    );
    return await parameters.buildUrl();
  }

  List<Variants> alldata = [];
  @override
  Widget build(BuildContext context) {
    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;
    WishlistNotifier wishlistNotifier = Provider.of<WishlistNotifier>(context);
    var wishlistList = wishlistNotifier.wishList;

    UserDataProfileNotifier userNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var profileData = userNotifier.userDataProfile;

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
    void addToBagshowDialog(
        ProdProducts _product, cartNotifier, cartProdID, scaffoldKey) async {
      await showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text(
                "Sure you want to add to Bag?",
                style: normalFont(MColors.textDark, null),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "Cancel",
                    style: normalFont(Colors.red, null),
                  ),
                  onPressed: () async {
                    getCart(cartNotifier);

                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(
                    "Yes",
                    style: normalFont(Colors.blue, null),
                  ),
                  onPressed: () {
                    getCart(cartNotifier);
                    addProductToCart(
                        Cart(
                            id: _product.id,
                            name: _product.name,
                            selling_price: _product.selling_price,
                            category: _product.category,
                            specs: _product.specs,
                            productQuantity: _product.productQuantity,
                            original_price: _product.original_price,
                            quantity: _product.quantity,
                            image: _product.image,
                            imgcollection: _product.imgcollection,
                            filterValue: _product.filterValue,
                            description: _product.description,
                            prices: _product.prices,
                            cartQuantity: quantity,
                            sold: _product.sold,
                            tablespecs: _product.tablespecs,
                            varientID: _product.varientID),
                        _scaffoldKey);

                    getCart(cartNotifier);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    void addToBagshowDialogCombined(cartProdID, fil, fil2) async {
      CartNotifier cartNotifier =
          Provider.of<CartNotifier>(context, listen: false);

      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text(
              "Sure you want to add to Bag?",
              style: normalFont(MColors.textDark, null),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  "Cancel",
                  style: normalFont(Colors.red, null),
                ),
                onPressed: () async {
                  setState(() {
                    getCart(cartNotifier);
                  });
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Yes",
                  style: normalFont(Colors.blue, null),
                ),
                onPressed: () {
                  setState(() {
                    getCart(cartNotifier);
                  });
                  if (cartProdID.contains(fil.productID) ||
                      cartProdID.contains(fil2.productID)) {
                    showSimpleSnack(
                      "Product already in bag",
                      Icons.error_outline,
                      Colors.amber,
                      _scaffoldKey,
                    );
                  } else {
                    addProductToCart(fil, _scaffoldKey);
                    addProductToCart(fil2, _scaffoldKey);

                    setState(() {
                      getCart(cartNotifier);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhite,
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 20,
          color: MColors.secondaryColor,
        ),
        backgroundColor: MColors.mainColor,
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () async {
                var link = await widget.controller
                    .createDynamicLink(widget.prodDetails.id);
                await widget.controller.share(link.toString(),
                    widget.prodDetails.name, widget.prodDetails.description);
              },
              child: Icon(
                Icons.share,
                size: 36,
                color: MColors.primaryWhiteSmoke,
              ),
            ),
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
                          child: prod == null
                              ? Center(child: CircularProgressIndicator())
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Container(
                                        child: Stack(
                                          children: [
                                            CarouselSlider(
                                              options: CarouselOptions(
                                                height: 250.0,
                                                autoPlay: true,
                                                enableInfiniteScroll: false,
                                                initialPage: 0,
                                                viewportFraction: 1,
                                                scrollPhysics:
                                                    BouncingScrollPhysics(),
                                              ),
                                              items: prodDetails.imgcollection
                                                  .map((banner) {
                                                return Builder(
                                                  builder:
                                                      (BuildContext context) {
                                                    return Hero(
                                                      child: InkWell(
                                                        onTap: () {
                                                          _scaffoldKey
                                                              .currentState
                                                              .showBottomSheet(
                                                                  (context) {
                                                            return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        state) {
                                                              return Container(
                                                                color: Colors
                                                                    .white,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.8,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    // InkWell(
                                                                    //
                                                                    //   child: Icon(
                                                                    //     Icons
                                                                    //         .keyboard_arrow_down,
                                                                    //     size: 30,
                                                                    //   ),
                                                                    // ),
                                                                    Expanded(
                                                                      child:
                                                                          PhotoView(
                                                                        imageProvider: NetworkImage('https://wild-grocery.herokuapp.com/${banner}'.replaceAll(
                                                                            '\\',
                                                                            '/')),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            });
                                                          });
                                                        },
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          image:
                                                              'https://wild-grocery.herokuapp.com/${banner}'
                                                                  .replaceAll(
                                                                      '\\',
                                                                      '/'),
                                                          placeholder:
                                                              "assets/images/placeholder.jpg",
                                                          placeholderScale:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2,
                                                        ),
                                                      ),
                                                      tag: prod.id,
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                            Positioned(
                                              left: 0,
                                              bottom: 0,
                                              child: Container(
                                                height: 60,
                                                width: 60,
                                                alignment: Alignment.bottomLeft,
                                                decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    60))),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${((prodDetails.original_price - prodDetails.selling_price) / prodDetails.original_price * 100).toStringAsFixed(0)}%\nOFF',
                                                    style: boldFont(
                                                        MColors
                                                            .primaryWhiteSmoke,
                                                        12.0),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      // Hero(
                                      //   child: InkWell(
                                      //     onTap: () {
                                      //       _scaffoldKey.currentState
                                      //           .showBottomSheet((context) {
                                      //         return StatefulBuilder(builder:
                                      //             (BuildContext context,
                                      //                 StateSetter state) {
                                      //           return Container(
                                      //             color: Colors.white,
                                      //             height: MediaQuery.of(context)
                                      //                     .size
                                      //                     .height *
                                      //                 0.8,
                                      //             width: MediaQuery.of(context)
                                      //                 .size
                                      //                 .width,
                                      //             child: Column(
                                      //               crossAxisAlignment:
                                      //                   CrossAxisAlignment.end,
                                      //               children: [
                                      //                 // InkWell(
                                      //                 //
                                      //                 //   child: Icon(
                                      //                 //     Icons
                                      //                 //         .keyboard_arrow_down,
                                      //                 //     size: 30,
                                      //                 //   ),
                                      //                 // ),
                                      //                 Expanded(
                                      //                   child: PhotoView(
                                      //                     imageProvider: NetworkImage(
                                      //                         'https://wild-grocery.herokuapp.com/${urlUniv}'
                                      //                             .replaceAll(
                                      //                                 '\\',
                                      //                                 '/')),
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           );
                                      //         });
                                      //       });
                                      //     },
                                      //     child: Stack(
                                      //       children: [
                                      //         FadeInImage.assetNetwork(
                                      //           image:
                                      //               'https://wild-grocery.herokuapp.com/${urlUniv}'
                                      //                   .replaceAll('\\', '/'),
                                      //           placeholder:
                                      //               "assets/images/placeholder.jpg",
                                      //           placeholderScale:
                                      //               MediaQuery.of(context)
                                      //                       .size
                                      //                       .height /
                                      //                   2,
                                      //         ),
                                      //         Positioned(
                                      //           left: 0,
                                      //           bottom: 0,
                                      //           child: Container(
                                      //             height: 60,
                                      //             width: 60,
                                      //             alignment:
                                      //                 Alignment.bottomLeft,
                                      //             decoration: BoxDecoration(
                                      //                 color: Colors.red
                                      //                     .withOpacity(0.9),
                                      //                 borderRadius:
                                      //                     BorderRadius.only(
                                      //                         topRight: Radius
                                      //                             .circular(
                                      //                                 60))),
                                      //             child: Padding(
                                      //               padding:
                                      //                   const EdgeInsets.all(
                                      //                       8.0),
                                      //               child: Text(
                                      //                 '${((prodDetails.original_price - prodDetails.selling_price) / prodDetails.original_price * 100).toStringAsFixed(0)}%\nOFF',
                                      //                 style: boldFont(
                                      //                     MColors
                                      //                         .primaryWhiteSmoke,
                                      //                     12.0),
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         )
                                      //       ],
                                      //     ),
                                      //   ),
                                      //   tag: prod.id,
                                      // ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      child: ListView.builder(
                                        itemCount:
                                            prodDetails.imgcollection.length,
                                        itemBuilder: (context, i) {
                                          return Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    urlUniv = prodDetails
                                                        .imgcollection[i];
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
                                                                            .imgcollection[
                                                                        i]
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
                                                        imageUrl:
                                                            'https://wild-grocery.herokuapp.com/${prodDetails.imgcollection[i]}'
                                                                .replaceAll(
                                                                    '\\', '/'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                          height: 10,
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
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: MColors.secondaryColor,
                                    ),
                                    child: RawMaterialButton(
                                      onPressed: subQty,
                                      child: Icon(
                                        Icons.remove,
                                        color: MColors.mainColor,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.0,
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
                                        color: MColors.mainColor,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
//TODO:Check
//                               (prodDetails.variants.length>1&&drop)?DropDown<String>(
//                                 initialValue: dropdown[0],
//                                 items: dropdown,
//                                 hint: Text("Select option"),
//                                 onChanged: (value) async {
//                                   setState(() {
//                                     alldata.clear();
//                                     colors.clear();
//                                     chosenSize='';
//                                     chosendrop=value;
//                                   });
//
//                                   for(int i=0;i<prodDetails.variants.length;i++){
//                                     if(value=='With AC'){
//
//                                       if(prodDetails.variants[i]['withAC']=='true'){
//                                         setState(() {
//                                           alldata.add(Variants(List.from(prodDetails.variants[i]['color']),prodDetails.variants[i]['size'],prodDetails.variants[i]['price']));
//                                         });
//
//
//                                       }
//                                       print('here:${alldata.length}');
//
//                                     }
//                                     else{
//
//                                       if(prodDetails.variants[i]['withAC']=='false'){
//                                         setState(() {
//                                           alldata.add(Variants(List.from(prodDetails.variants[i]['color']),prodDetails.variants[i]['size'],prodDetails.variants[i]['price']));
//                                         });
//
//                                       }
//                                     }
//                                   }
//                                   print('out:${alldata.length}');
//                                   setState(() {
//                                     chosenSize=alldata[0].size;
//                                     colors=List.from(alldata[0].colors);
//                                     price=double.parse(alldata[0].price);
//                                   });
//
//                                   print('Colors:${colors.length}');
//                                 },
//                               ):Container(),
                            ],
                          ),
                        ),

//                         prodDetails.foodType == 'Dry'&&prodDetails.variants.length>1
//                             ? Container(
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Color ',
//                                           style:
//                                               boldFont(MColors.textDark, 16.0),
//                                         ),
// //                                        Text(
// //                                          colors[0],
// //                                          style: normalFont(
// //                                              MColors.textGrey, 14.0),
// //                                        ),
//                                       ],
//                                     ),
//                                    colors.length>0? Container(
//                                       height: 70,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(5.0),
//                                         child: ListView.builder(
//                                           itemCount: colors.length,
//                                           scrollDirection: Axis.horizontal,
//                                           itemBuilder: (context,index){
//                                             return  Padding(
//                                               padding:
//                                               const EdgeInsets.symmetric(
//                                                   horizontal: 4.0),
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     chosenColor = colors[index];
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   height: 70,
//                                                   width: 60,
//                                                   decoration: BoxDecoration(
//                                                       borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               45)),
//                                                       color: Color(int.parse(colors[index],radix: 16)).withOpacity(1.0),
//                                                       border: Border.all(
//                                                           width: 2,
//                                                           color: chosenColor ==
//                                                               colors[index]
//                                                               ? MColors
//                                                               .secondaryColor
//                                                               : MColors
//                                                               .primaryWhiteSmoke)),
//                                                 ),
//                                               ),
//                                             );
//                                           },
// //                                          children: [
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenColor = 'White';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  45)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenColor ==
// //                                                                  'White'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenColor = 'Red';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius
// //                                                              .all(
// //                                                                  Radius
// //                                                                      .circular(
// //                                                                          45)),
// //                                                      color: Colors.red,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenColor ==
// //                                                                  'Red'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenColor = 'Blue';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  45)),
// //                                                      color: Colors.blue,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenColor ==
// //                                                                  'Blue'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenColor = 'Grey';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  45)),
// //                                                      color: Colors.grey,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenColor ==
// //                                                                  'Grey'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenColor = 'Green';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  45)),
// //                                                      color: Colors.green,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenColor ==
// //                                                                  'Green'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            )
//
//                                         ),
//                                       ),
//                                     ):Container(),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Size: ',
//                                           style:
//                                               boldFont(MColors.textDark, 16.0),
//                                         ),
//                                         Text(
//                                           'Select size to see price',
//                                           style: normalFont(
//                                               MColors.textGrey, 14.0),
//                                         ),
//                                       ],
//                                     ),
//                                     (alldata.length>0)?Container(
//                                       height: 70,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(5.0),
//                                         child: ListView.builder(
//                                           itemCount: alldata.length,
//                                           scrollDirection: Axis.horizontal,
//                                           itemBuilder: (context,index){
//                                             return Padding(
//                                               padding:
//                                               const EdgeInsets.symmetric(
//                                                   horizontal: 4.0),
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     chosenSize = alldata[index].size;
//                                                     colors=List.from(alldata[index].colors);
//                                                     price=double.parse(alldata[index].price);
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   height: 70,
//                                                   width: 60,
//                                                   alignment: Alignment.center,
//                                                   child: Text(
//                                                     alldata[index].size,
//                                                     style: boldFont(
//                                                         MColors.textDark, 20.0),
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                       borderRadius:
//                                                       BorderRadius.all(
//                                                           Radius.circular(
//                                                               5)),
//                                                       color: Colors.white,
//                                                       border: Border.all(
//                                                           width: 2,
//                                                           color: chosenSize ==
//                                                               alldata[index].size
//                                                               ? MColors
//                                                               .secondaryColor
//                                                               : MColors
//                                                               .primaryWhiteSmoke)),
//                                                 ),
//                                               ),
//                                             );
//                                           },
// //                                          children: [
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'XS';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'XS',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'XS'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'S';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'S',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'S'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'M';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'M',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'M'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'L';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'L',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'L'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'XL';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'XL',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'XL'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                            Padding(
// //                                              padding:
// //                                                  const EdgeInsets.symmetric(
// //                                                      horizontal: 4.0),
// //                                              child: InkWell(
// //                                                onTap: () {
// //                                                  setState(() {
// //                                                    chosenSize = 'XXL';
// //                                                  });
// //                                                },
// //                                                child: Container(
// //                                                  height: 70,
// //                                                  width: 60,
// //                                                  alignment: Alignment.center,
// //                                                  child: Text(
// //                                                    'XXL',
// //                                                    style: boldFont(
// //                                                        MColors.textDark, 20.0),
// //                                                  ),
// //                                                  decoration: BoxDecoration(
// //                                                      borderRadius:
// //                                                          BorderRadius.all(
// //                                                              Radius.circular(
// //                                                                  5)),
// //                                                      color: Colors.white,
// //                                                      border: Border.all(
// //                                                          width: 2,
// //                                                          color: chosenSize ==
// //                                                                  'XXL'
// //                                                              ? MColors
// //                                                                  .secondaryColor
// //                                                              : MColors
// //                                                                  .primaryWhiteSmoke)),
// //                                                ),
// //                                              ),
// //                                            ),
// //                                          ],
//                                         ),
//                                       ),
//                                     ):Container()
//                                   ],
//                                 ),
//                               )
//                             : Container(),
                        Builder(builder: (context) {
                          return Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      prodDetails.productQuantity == null
                                          ? "1 Kg"
                                          : "${prodDetails.productQuantity}",
                                      style: GoogleFonts.montserrat(
                                        color: MColors.mainColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      prodDetails.selling_price ==
                                              prodDetails.original_price
                                          ? Text(
                                              "Rs. ${prodDetails.selling_price}",
                                              style: GoogleFonts.montserrat(
                                                color: MColors.mainColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          : Text(
                                              "Rs. ${prodDetails.selling_price}",
                                              style: GoogleFonts.montserrat(
                                                color: MColors.mainColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      prodDetails.selling_price ==
                                              prodDetails.original_price
                                          ? Container()
                                          : Text(
                                              "Rs. ${prodDetails.original_price}",
                                              style: GoogleFonts.montserrat(
                                                  color: MColors.mainColor,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),

                                      //             prodDetails.selling_price != null
                                      //                 ? Container()
                                      //                 : (price!=null)?Text(
                                      //                     "AED ${(price * (100 - prodDetails.discount) / 100).toStringAsPrecision(4)}",
                                      //                     style: boldFont(
                                      //                         MColors.secondaryColor, 17.0),
                                      //                   ):Text(
                                      // "AED ${(prodDetails.totalPrice * (100 - prodDetails.discount) / 100).toStringAsPrecision(4)}",
                                      // style: boldFont(
                                      // MColors.secondaryColor, 17.0)),
                                    ],
                                  ),
                                )
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
                            prodDetails.description,
                            style: normalFont(MColors.textGrey, 14.0),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        // Container(
                        //   child: Text(
                        //     "People Also Bought",
                        //     style: boldFont(MColors.textDark, 16.0),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        // Container(
                        //   height: 200,
                        //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                        //   child: ListView(
                        //     scrollDirection: Axis.horizontal,
                        //     children: [
                        //       GestureDetector(
                        //         onTap: () async {
                        //           CartNotifier cartNotifier =
                        //               Provider.of<CartNotifier>(context,
                        //                   listen: false);
                        //           var navigationResult =
                        //               await Navigator.of(context).push(
                        //             CupertinoPageRoute(
                        //               builder: (context) => ProductDetailsProv(
                        //                   prods[0] == prodDetails
                        //                       ? prods[1]
                        //                       : prods[0],
                        //                   prods),
                        //             ),
                        //           );
                        //           if (navigationResult == true) {
                        //             setState(() {
                        //               getCart(cartNotifier);
                        //             });
                        //           }
                        //         },
                        //         child: Container(
                        //           margin: EdgeInsets.all(5.0),
                        //           width: 110.0,
                        //           padding: EdgeInsets.all(10),
                        //           decoration: BoxDecoration(
                        //             color: MColors.primaryWhite,
                        //             borderRadius: BorderRadius.all(
                        //               Radius.circular(10.0),
                        //             ),
                        //             boxShadow: [
                        //               BoxShadow(
                        //                   color: Color.fromRGBO(0, 0, 0, 0.03),
                        //                   offset: Offset(0, 10),
                        //                   blurRadius: 10,
                        //                   spreadRadius: 0),
                        //             ],
                        //           ),
                        //           child: Column(
                        //             children: <Widget>[
                        //               Container(
                        //                 child: ClipRRect(
                        //                   borderRadius:
                        //                       BorderRadius.circular(10.0),
                        //                   child: FadeInImage.assetNetwork(
                        //                     image: prods[0] == prodDetails
                        //                         ? prods[1].image
                        //                         : prods[0].image,
                        //                     fit: BoxFit.fill,
                        //                     height: 90,
                        //                     placeholder:
                        //                         "assets/images/placeholder.jpg",
                        //                     placeholderScale:
                        //                         MediaQuery.of(context)
                        //                                 .size
                        //                                 .height /
                        //                             2,
                        //                   ),
                        //                 ),
                        //               ),
                        //               SizedBox(height: 10.0),
                        //               Align(
                        //                 alignment: Alignment.bottomLeft,
                        //                 child: Container(
                        //                   child: Text(
                        //                     prods[0] == prodDetails
                        //                         ? prods[1].name
                        //                         : prods[0].name,
                        //                     maxLines: 2,
                        //                     overflow: TextOverflow.ellipsis,
                        //                     style: normalFont(
                        //                         MColors.textGrey, 10.0),
                        //                   ),
                        //                 ),
                        //               ),
                        //               Spacer(),
                        //               Container(
                        //                 child: Row(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.center,
                        //                   children: <Widget>[
                        //                     Container(
                        //                       child: Text(
                        //                         "AED\n${prods[0] == prodDetails ? prods[1].selling_price : prods[0].selling_price}",
                        //                         style: boldFont(
                        //                             MColors.secondaryColor,
                        //                             15.0),
                        //                       ),
                        //                     ),
                        //                     Spacer(),
                        //                     GestureDetector(
                        //                       onTap: () => addToBagshowDialog(
                        //                         cartProdID,
                        //                         prods[0] == prodDetails
                        //                             ? prods[1]
                        //                             : prods[0],
                        //                       ),
                        //                       child: Container(
                        //                         width: 25.0,
                        //                         height: 25.0,
                        //                         padding:
                        //                             const EdgeInsets.all(4.0),
                        //                         decoration: BoxDecoration(
                        //                           color: MColors.dashPurple,
                        //                           borderRadius:
                        //                               BorderRadius.circular(
                        //                                   8.0),
                        //                         ),
                        //                         child: SvgPicture.asset(
                        //                           "assets/images/icons/basket.svg",
                        //                           height: 20.0,
                        //                           color: MColors.textGrey,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //       Icon(
                        //         Icons.add,
                        //         color: MColors.secondaryColor,
                        //       ),
                        //       GestureDetector(
                        //         onTap: () async {
                        //           CartNotifier cartNotifier =
                        //               Provider.of<CartNotifier>(context,
                        //                   listen: false);
                        //           var navigationResult =
                        //               await Navigator.of(context).push(
                        //             CupertinoPageRoute(
                        //               builder: (context) => ProductDetailsProv(
                        //                   prodDetails, prods),
                        //             ),
                        //           );
                        //           if (navigationResult == true) {
                        //             setState(() {
                        //               getCart(cartNotifier);
                        //             });
                        //           }
                        //         },
                        //         child: Container(
                        //           margin: EdgeInsets.all(5.0),
                        //           width: 110.0,
                        //           padding: EdgeInsets.all(10),
                        //           decoration: BoxDecoration(
                        //             color: MColors.primaryWhite,
                        //             borderRadius: BorderRadius.all(
                        //               Radius.circular(10.0),
                        //             ),
                        //             boxShadow: [
                        //               BoxShadow(
                        //                   color: Color.fromRGBO(0, 0, 0, 0.03),
                        //                   offset: Offset(0, 10),
                        //                   blurRadius: 10,
                        //                   spreadRadius: 0),
                        //             ],
                        //           ),
                        //           child: Column(
                        //             children: <Widget>[
                        //               Container(
                        //                 child: ClipRRect(
                        //                   borderRadius:
                        //                       BorderRadius.circular(10.0),
                        //                   child: FadeInImage.assetNetwork(
                        //                     image: prodDetails.image,
                        //                     fit: BoxFit.fill,
                        //                     height: 90,
                        //                     placeholder:
                        //                         "assets/images/placeholder.jpg",
                        //                     placeholderScale:
                        //                         MediaQuery.of(context)
                        //                                 .size
                        //                                 .height /
                        //                             2,
                        //                   ),
                        //                 ),
                        //               ),
                        //               SizedBox(height: 10.0),
                        //               Align(
                        //                 alignment: Alignment.bottomLeft,
                        //                 child: Container(
                        //                   child: Text(
                        //                     prodDetails.name,
                        //                     maxLines: 2,
                        //                     overflow: TextOverflow.ellipsis,
                        //                     style: normalFont(
                        //                         MColors.textGrey, 10.0),
                        //                   ),
                        //                 ),
                        //               ),
                        //               Spacer(),
                        //               Container(
                        //                 child: Row(
                        //                   crossAxisAlignment:
                        //                       CrossAxisAlignment.center,
                        //                   children: <Widget>[
                        //                     Container(
                        //                       child: Text(
                        //                         "AED\n${prodDetails.selling_price}",
                        //                         style: boldFont(
                        //                             MColors.secondaryColor,
                        //                             15.0),
                        //                       ),
                        //                     ),
                        //                     Spacer(),
                        //                     GestureDetector(
                        //                       onTap: () => addToBagshowDialog(
                        //                           cartProdID, prodDetails),
                        //                       child: Container(
                        //                         width: 25.0,
                        //                         height: 25.0,
                        //                         padding:
                        //                             const EdgeInsets.all(4.0),
                        //                         decoration: BoxDecoration(
                        //                           color: MColors.dashPurple,
                        //                           borderRadius:
                        //                               BorderRadius.circular(
                        //                                   8.0),
                        //                         ),
                        //                         child: SvgPicture.asset(
                        //                           "assets/images/icons/basket.svg",
                        //                           height: 20.0,
                        //                           color: MColors.textGrey,
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //       Icon(
                        //         Icons.drag_handle,
                        //         color: MColors.secondaryColor,
                        //       ),
                        //       Container(
                        //         margin: EdgeInsets.all(5.0),
                        //         width: 110.0,
                        //         padding: EdgeInsets.all(10),
                        //         decoration: BoxDecoration(
                        //           color: MColors.primaryWhite,
                        //           borderRadius: BorderRadius.all(
                        //             Radius.circular(10.0),
                        //           ),
                        //           boxShadow: [
                        //             BoxShadow(
                        //                 color: Color.fromRGBO(0, 0, 0, 0.03),
                        //                 offset: Offset(0, 10),
                        //                 blurRadius: 10,
                        //                 spreadRadius: 0),
                        //           ],
                        //         ),
                        //         child: Column(
                        //           children: <Widget>[
                        //             Spacer(),
                        //             (price != null)
                        //                 ? Container(
                        //                     child: Text(
                        //                       "AED\n${(prods[0] == prodDetails ? prods[1].selling_price : prods[0].selling_price + prodDetails.selling_price)}",
                        //                       style: GoogleFonts.montserrat(
                        //                           color: MColors.secondaryColor,
                        //                           fontSize: 15,
                        //                           fontWeight: FontWeight.w600,
                        //                           decoration: TextDecoration
                        //                               .lineThrough),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   )
                        //                 : Container(
                        //                     child: Text(
                        //                       "AED\n${(prods[0] == prodDetails ? prods[1].selling_price : prods[0].selling_price + prodDetails.selling_price)}",
                        //                       style: GoogleFonts.montserrat(
                        //                           color: MColors.secondaryColor,
                        //                           fontSize: 15,
                        //                           fontWeight: FontWeight.w600,
                        //                           decoration: TextDecoration
                        //                               .lineThrough),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   ),
                        //             Icon(
                        //               Icons.arrow_downward_rounded,
                        //               color: MColors.secondaryColor,
                        //             ),
                        //             (price != null)
                        //                 ? Container(
                        //                     child: Text(
                        //                       "AED\n${(prods[0] == prodDetails ? prods[1].selling_price : prods[0].selling_price + prodDetails.selling_price) * 0.9}",
                        //                       style: GoogleFonts.montserrat(
                        //                         color: MColors.secondaryColor,
                        //                         fontSize: 15,
                        //                         fontWeight: FontWeight.w600,
                        //                       ),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   )
                        //                 : Container(
                        //                     child: Text(
                        //                       "AED\n${(prods[0] == prodDetails ? prods[1].selling_price : prods[0].selling_price + prodDetails.selling_price) * 0.9}",
                        //                       style: GoogleFonts.montserrat(
                        //                         color: MColors.secondaryColor,
                        //                         fontSize: 15,
                        //                         fontWeight: FontWeight.w600,
                        //                       ),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   ),
                        //             Spacer(),
                        //             GestureDetector(
                        //               onTap: () => addToBagshowDialogCombined(
                        //                   cartProdID,
                        //                   prods[0] == prodDetails
                        //                       ? prods[1]
                        //                       : prods[0],
                        //                   prodDetails),
                        //               child: Container(
                        //                 width: 100.0,
                        //                 height: 25.0,
                        //                 padding: const EdgeInsets.all(4.0),
                        //                 decoration: BoxDecoration(
                        //                   color: MColors.dashPurple,
                        //                   borderRadius:
                        //                       BorderRadius.circular(8.0),
                        //                 ),
                        //                 child: SvgPicture.asset(
                        //                   "assets/images/icons/basket.svg",
                        //                   height: 20.0,
                        //                   color: MColors.textGrey,
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
//TODO: Fix List View
//                         Container(
//                           height: prodDetails.specs.length * 70.0,
//                           child: ListView.builder(
//                               itemCount: prodDetails.specs.length,
//                               itemBuilder: (context, i) {
//                                 return Container(
//                                   child: ExpansionTile(
//                                     title: Text(
//                                       prodDetails.specs[i]['name'],
//                                       style: boldFont(MColors.textDark, 16.0),
//                                     ),
//                                     children: <Widget>[
//                                       Container(
//                                         padding: const EdgeInsets.only(
//                                           left: 30.0,
//                                           bottom: 10.0,
//                                           right: 30.0,
//                                         ),
//                                         child: Text(
//                                           prodDetails.specs[i]['value'],
//                                           style: normalFont(
//                                               MColors.textGrey, 14.0),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }),
//                         ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "Description",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: <Widget>[
                              Container(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 0, 14, 20),
                                  child: Text(
                                    prodDetails.description,
                                    style: normalFont(MColors.textGrey, 14.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   child: ExpansionTile(
                        //     title: Text(
                        //       "Brand",
                        //       style: boldFont(MColors.textDark, 16.0),
                        //     ),
                        //     children: <Widget>[
                        //       Container(
                        //         padding: const EdgeInsets.only(
                        //           left: 30.0,
                        //           bottom: 10.0,
                        //           right: 30.0,
                        //         ),
                        //         child: Text(
                        //           prodDetails.category['name'],
                        //           style: normalFont(MColors.textGrey, 14.0),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          child: ExpansionTile(
                            title: Text(
                              "Details",
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                            children: details,
                            // children: <Widget>[
                            //
                            //   Container(
                            //     padding: const EdgeInsets.only(
                            //       left: 30.0,
                            //       bottom: 10.0,
                            //       right: 30.0,
                            //     ),
                            //     child: Row(
                            //       children: <Widget>[
                            //         Expanded(
                            //           child: Text(
                            //             "Food type",
                            //             style:
                            //                 normalFont(MColors.textDark, 16.0),
                            //           ),
                            //         ),
                            //         Expanded(
                            //           child: Text(
                            //             prodDetails.category['name'],
                            //             style:
                            //                 normalFont(MColors.textGrey, 14.0),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            //   Container(
                            //     padding: const EdgeInsets.only(
                            //       left: 30.0,
                            //       bottom: 10.0,
                            //       right: 30.0,
                            //     ),
                            //     child: Row(
                            //       children: <Widget>[
                            //         Expanded(
                            //           child: Text(
                            //             "Life stage",
                            //             style:
                            //                 normalFont(MColors.textDark, 16.0),
                            //           ),
                            //         ),
                            //         Expanded(
                            //           child: Text(
                            //             prodDetails.category['name'],
                            //             style:
                            //                 normalFont(MColors.textGrey, 14.0),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            //   Container(
                            //     padding: const EdgeInsets.only(
                            //       left: 30.0,
                            //       bottom: 10.0,
                            //       right: 30.0,
                            //     ),
                            //     child: Row(
                            //       children: <Widget>[
                            //         Expanded(
                            //           child: Text(
                            //             "Weight",
                            //             style:
                            //                 normalFont(MColors.textDark, 16.0),
                            //           ),
                            //         ),
                            //         Expanded(
                            //           child: Text(
                            //             prodDetails.name,
                            //             style:
                            //                 normalFont(MColors.textGrey, 14.0),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            //   Container(
                            //     padding: const EdgeInsets.only(
                            //       left: 30.0,
                            //       bottom: 10.0,
                            //       right: 30.0,
                            //     ),
                            //     child: Row(
                            //       children: <Widget>[
                            //         Expanded(
                            //           child: Text(
                            //             "Flavor",
                            //             style:
                            //                 normalFont(MColors.textDark, 16.0),
                            //           ),
                            //         ),
                            //         Expanded(
                            //           child: Text(
                            //             prodDetails.name,
                            //             style:
                            //                 normalFont(MColors.textGrey, 14.0),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ],
                          ),
                        ),
                        Container(
                          child: ExpansionTile(
                              title: Text(
                                "Specification",
                                style: boldFont(MColors.textDark, 16.0),
                              ),
                              children: specs),
                        ),
                        // Container(
                        //   child: ExpansionTile(
                        //     title: Text(
                        //       "Ingredients",
                        //       style: boldFont(MColors.textDark, 16.0),
                        //     ),
                        //     children: <Widget>[
                        //       Container(
                        //         padding: const EdgeInsets.only(
                        //           left: 30.0,
                        //           bottom: 10.0,
                        //           right: 30.0,
                        //         ),
                        //         child: Text(
                        //           prodDetails.name,
                        //           style: normalFont(MColors.textGrey, 14.0),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          child: Text(
                            "Similar products",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        SimilarProductsWidget(
                          prods: prods.where((element) =>
                              element.category['name'] ==
                                  prodDetails.category['name'] &&
                              element.id != prodDetails.id),
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
                      width: MediaQuery.of(context).size.width * 0.5 - 1,
                      color: MColors.dashPurple,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: _isbuttonDisabled
                            ? null
                            : () =>
                                addProductToWishlist(prodDetails, _scaffoldKey),
                        child: Text(
                          "Add to Wishlist",
                          style: boldFont(MColors.mainColor, 15.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 2,
                      color: MColors.mainColor,
                    ),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width * 0.5 - 1,
                      color: MColors.dashPurple,
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: _isbuttonDisabled
                            ? null
                            : () {
                                getCart(cartNotifier);
                                addProductToCart(
                                    Cart(
                                        id: widget.prodDetails.id,
                                        name: widget.prodDetails.name,
                                        selling_price:
                                            widget.prodDetails.selling_price,
                                        category: widget.prodDetails.category,
                                        specs: widget.prodDetails.specs,
                                        productQuantity:
                                            widget.prodDetails.productQuantity,
                                        original_price:
                                            widget.prodDetails.original_price,
                                        quantity: widget.prodDetails.quantity,
                                        image: widget.prodDetails.image,
                                        imgcollection:
                                            widget.prodDetails.imgcollection,
                                        filterValue:
                                            widget.prodDetails.filterValue,
                                        description:
                                            widget.prodDetails.description,
                                        prices: widget.prodDetails.prices,
                                        cartQuantity: 1,
                                        sold: widget.prodDetails.sold,
                                        tablespecs:
                                            widget.prodDetails.tablespecs,
                                        varientID:
                                            widget.prodDetails.varientID),
                                    _scaffoldKey);
                                // addAndApdateData(
                                //     Cart(
                                //         id: _product.id,
                                //         name: _product.name,
                                //         selling_price: _product.selling_price,
                                //         category: _product.category,
                                //         specs: _product.specs,
                                //         productQuantity: _product.productQuantity,
                                //         original_price: _product.original_price,
                                //         quantity: _product.quantity,
                                //         image: _product.image,
                                //         imgcollection: _product.imgcollection,
                                //         filterValue: _product.filterValue,
                                //         description: _product.description,
                                //         prices: _product.prices,
                                //         cartQuantity: 1,
                                //         sold: _product.sold,
                                //         tablespecs: _product.tablespecs,
                                //         varientID: _product.varientID),
                                //     _scaffoldKey);
                                getCart(cartNotifier);
                              },
                        child: Text(
                          "Add to Cart",
                          style: boldFont(MColors.mainColor, 15.0),
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
    // var cartProdID = cartNotifier.cartList.map((e) => e.productID);
    // setState(() {
    //   getCart(cartNotifier);
    // });
    //
    // try {
    //   if (cartProdID.contains(prodDetails.productID)) {
    //     showSimpleSnack(
    //       "Product already in bag",
    //       Icons.error_outline,
    //       Colors.amber,
    //       _scaffoldKey,
    //     );
    //   } else {
    //     setState(() {
    //       cartNotifier.cartList.map((e) {
    //         setState(() {
    //           e.size = chosenSize;
    //           e.color = chosenColor;
    //         });
    //       });
    //       prodDetails.quantity = quantity;
    //       (price != null)
    //           ? prodDetails.totalPrice = price * prodDetails.quantity
    //           : prodDetails.totalPrice =
    //               prodDetails.totalPrice * prodDetails.quantity;
    //       prodDetails.size = chosenSize;
    //       prodDetails.color = chosenColor;
    //     });
    //
    //     print('totalprice:${prodDetails.totalPrice}');
    //     addProductToCart(prodDetails, _scaffoldKey);
    //
    //     setState(() {
    //       getCart(cartNotifier);
    //       isCartBadge = true;
    //       _isProductadded = true;
    //     });
    //   }
    // } catch (e) {
    //   print("ERRORR ==>");
    //   print(e);
    // }
  }

  void _submitWishlist(wishlistNotifier) {
    //TODO:Check
    // var wishlistProdID = wishlistNotifier.wishlistList.map((e) => e.productID);
    // setState(() {
    //   getWishlist(wishlistNotifier);
    // });
    //
    // try {
    //   if (wishlistProdID.contains(prodDetails.productID)) {
    //     showSimpleSnack(
    //       "Product already in Wishlist",
    //       Icons.error_outline,
    //       Colors.amber,
    //       _scaffoldKey,
    //     );
    //   } else {
    //     wishlistNotifier.wishlistList.map((e2) {
    //       setState(() {
    //         e2.size = chosenSize;
    //         e2.color = chosenColor;
    //       });
    //     });
    //     setState(() {
    //       prodDetails.quantity = quantity;
    //       (price != null)
    //           ? prodDetails.totalPrice = price * prodDetails.quantity
    //           : prodDetails.totalPrice =
    //               prodDetails.totalPrice * prodDetails.quantity;
    //       prodDetails.size = chosenSize;
    //       prodDetails.color = chosenColor;
    //     });
    //
    //     addProductToWishlist(prodDetails, _scaffoldKey);
    //     showSimpleSnack(
    //       "Product added to Wishlist",
    //       Icons.check_circle_outline,
    //       Colors.green,
    //       _scaffoldKey,
    //     );
    //     setState(() {
    //       getCart(wishlistNotifier);
    //       isCartBadge = true;
    //       _isProductadded = true;
    //     });
    //   }
    // } catch (e) {
    //   print("ERRORR ==>");
    //   print(e);
    // }
  }
}
