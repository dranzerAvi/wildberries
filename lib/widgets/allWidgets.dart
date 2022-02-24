import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/dynamic_link_controller.dart';
import 'package:wildberries/screens/tab_screens/home.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/productDetailsScreen.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeSubCategories.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

//SCAFFOLDS-----------------------------------
Widget primaryContainer(
  Widget containerChild,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    color: MColors.primaryWhiteSmoke,
    child: containerChild,
  );
}
//--------------------------------------------

//APPBARS-------------------------------------

Widget primaryAppBar(
  Widget leading,
  Widget title,
  Color backgroundColor,
  PreferredSizeWidget bottom,
  bool centerTile,
  List<Widget> actions,
) {
  return AppBar(
    brightness: Brightness.light,
    elevation: 0.0,
    backgroundColor: backgroundColor,
    leading: leading,
    title: title,
    bottom: bottom,
    centerTitle: centerTile,
    actions: actions,
  );
}

Widget primarySliverAppBar(
  Widget leading,
  Widget title,
  Color backgroundColor,
  PreferredSizeWidget bottom,
  bool centerTile,
  bool floating,
  bool pinned,
  List<Widget> actions,
  double expandedHeight,
  Widget flexibleSpace,
) {
  return SliverAppBar(
    brightness: Brightness.light,
    elevation: 0.0,
    backgroundColor: backgroundColor,
    leading: leading,
    title: title,
    bottom: bottom,
    centerTitle: centerTile,
    floating: floating,
    pinned: pinned,
    actions: actions,
    expandedHeight: expandedHeight,
    flexibleSpace: flexibleSpace,
  );
}
//--------------------------------------------

//FONTS---------------------------------------
TextStyle boldFont(Color color, double size) {
  return GoogleFonts.montserrat(
    color: color,
    fontSize: size,
    fontWeight: FontWeight.w600,
  );
}

TextStyle boldFontStriked(Color color, double size) {
  return GoogleFonts.montserrat(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.lineThrough);
}

TextStyle normalFont(
  Color color,
  double size,
) {
  return GoogleFonts.montserrat(
    color: color,
    fontSize: size,
  );
}

TextStyle myFont(
  Color color,
  double size,
) {
  return GoogleFonts.montserrat(
      color: color, fontSize: size, fontWeight: FontWeight.bold);
}
//--------------------------------------------

//BUTTONS-------------------------------------
Widget primaryButtonPurple(
  Widget buttonChild,
  void Function() onPressed,
) {
  return SizedBox(
    width: double.infinity,
    height: 50.0,
    child: RawMaterialButton(
      elevation: 0.0,
      hoverElevation: 0.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      fillColor: MColors.mainColor,
      child: buttonChild,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
    ),
  );
}

Widget primaryButtonWhiteSmoke(
  Widget buttonChild,
  void Function() onPressed,
) {
  return SizedBox(
    width: double.infinity,
    height: 50.0,
    child: RawMaterialButton(
      elevation: 0.0,
      hoverElevation: 0.0,
      focusElevation: 0.0,
      highlightElevation: 0.0,
      fillColor: MColors.secondaryWhiteSmoke,
      child: buttonChild,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(10.0),
      ),
    ),
  );
}

Widget listTileButton(
  void Function() onPressed,
  String iconImage,
  String listTileName,
  Color color,
) {
  return SizedBox(
    height: 60.0,
    width: double.infinity,
    child: RawMaterialButton(
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            iconImage,
            height: 20,
            color: MColors.textGrey,
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Text(
              listTileName,
              style: normalFont(color, 14.0),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16.0,
          ),
        ],
      ),
    ),
  );
}
//-------------------------------------------

//TEXTFIELDS--------------------------------

Widget primaryTextField(
  TextEditingController controller,
  String initialValue,
  String labelText,
  void Function(String) onsaved,
  bool enabled,
  String Function(String) validator,
  bool obscureText,
  bool autoValidate,
  bool enableSuggestions,
  TextInputType keyboardType,
  List<TextInputFormatter> inputFormatters,
  Widget suffix,
  double textfieldBorder,
) {
  return TextFormField(
    controller: controller,
    initialValue: initialValue,
    onSaved: onsaved,
    enabled: enabled,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    autovalidate: autoValidate,
    enableSuggestions: enableSuggestions,
    style: normalFont(
      enabled == true ? MColors.textDark : MColors.textGrey,
      16.0,
    ),
    cursorColor: MColors.secondaryColor,
    decoration: InputDecoration(
      suffixIcon: Padding(
        padding: EdgeInsets.only(
          right: suffix == null ? 0.0 : 15.0,
          left: suffix == null ? 0.0 : 15.0,
        ),
        child: suffix,
      ),
      labelText: labelText,
      labelStyle: normalFont(null, 14.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
      fillColor: MColors.primaryWhite,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: textfieldBorder == 0.0 ? Colors.transparent : MColors.textGrey,
          width: textfieldBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: MColors.secondaryColor,
          width: 1.0,
        ),
      ),
    ),
  );
}

Widget searchTextField(
  bool autofocus,
  TextEditingController controller,
  String initialValue,
  String labelText,
  void Function(String) onsaved,
  void Function(String) onChanged,
  bool enabled,
  String Function(String) validator,
  bool obscureText,
  bool autoValidate,
  bool enableSuggestions,
  TextInputType keyboardType,
  List<TextInputFormatter> inputFormatters,
  Widget suffix,
  double textfieldBorder,
) {
  return TextFormField(
    autofocus: autofocus,
    controller: controller,
    initialValue: initialValue,
    onSaved: onsaved,
    onChanged: onChanged,
    enabled: enabled,
    validator: validator,
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    autovalidate: autoValidate,
    enableSuggestions: enableSuggestions,
    style: normalFont(
      enabled == true ? MColors.textDark : MColors.textGrey,
      16.0,
    ),
    cursorColor: MColors.secondaryColor,
    decoration: InputDecoration(
      suffixIcon: Padding(
        padding: EdgeInsets.only(
          right: suffix == null ? 0.0 : 15.0,
          left: suffix == null ? 0.0 : 15.0,
        ),
        child: suffix,
      ),
      labelText: labelText,
      labelStyle: normalFont(null, 14.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
      fillColor: MColors.primaryWhite,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: textfieldBorder == 0.0 ? Colors.transparent : MColors.textGrey,
          width: textfieldBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: MColors.secondaryColor,
          width: 1.0,
        ),
      ),
    ),
  );
}
//-------------------------------------------

//PROGRESS----------------------------------
Widget progressIndicator(Color color) {
  return Container(
    color: MColors.primaryWhiteSmoke,
    child: Center(
      child: CupertinoActivityIndicator(
        radius: 12.0,
      ),
    ),
  );
}

Widget gettingLocationIndicator() {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Getting your current location",
          style: normalFont(MColors.textGrey, 14.0),
        ),
        SizedBox(width: 5.0),
        progressIndicator(MColors.secondaryColor),
      ],
    ),
  );
}
//-------------------------------------------

//SNACKBARS----------------------------------
void showSimpleSnack(
  String value,
  IconData icon,
  Color iconColor,
  GlobalKey<ScaffoldState> _scaffoldKey,
) {
  _scaffoldKey.currentState.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: 1000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              value,
              style: normalFont(null, null),
            ),
          ),
          Icon(
            icon,
            color: iconColor,
          )
        ],
      ),
    ),
  );
}

void showNoInternetSnack(
  GlobalKey<ScaffoldState> _scaffoldKey,
) {
  _scaffoldKey.currentState.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(milliseconds: 7000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "No internet connection! Please connect to the internet to continue.",
              style: normalFont(null, null),
            ),
          ),
          Icon(
            Icons.error_outline,
            color: Colors.amber,
          )
        ],
      ),
    ),
  );
}
//-------------------------------------------

//EMPTYCART----------------------------------
Widget emptyScreen(
  String image,
  String title,
  String subTitle,
) {
  return primaryContainer(
    Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: SvgPicture.asset(
                image,
                height: 150,
              ),
            ),
            Container(
              child: Text(
                title,
                style: boldFont(MColors.textDark, 20),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: Text(
                subTitle,
                style: normalFont(MColors.textGrey, 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ------------------------------------------

//CART DISMISS-------------------------------
Widget backgroundDismiss(AlignmentGeometry alignment) {
  return Container(
    decoration: BoxDecoration(
      color: MColors.primaryWhiteSmoke,
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    alignment: alignment,
    child: Container(
      height: double.infinity,
      width: 50.0,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Colors.white,
      ),
    ),
  );
}
//-------------------------------------------

//WARNING------------------------------------
Widget warningWidget() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: Icon(
              Icons.error_outline,
              color: Colors.redAccent,
            ),
          ),
          Expanded(
            child: Container(
              child: Text(
                "PLEASE NOTE -  This is a side project by Nifemi. Please do not enter real info. Thank you!",
                style: normalFont(Colors.redAccent, 14.0),
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.redAccent),
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
    ),
  );
}
//-------------------------------------------

//SHARE WIDGET-------------------------------
Future shareWidget() {
  return WcFlutterShare.share(
      sharePopupTitle: 'Pet Shop',
      subject: 'Hi!',
      text:
          'Hi, I use Pet Shop to care for my pets fast and easy, Download it here at https://github.com/thenifemi/PetShop and for every download, a dog gets a treat.',
      mimeType: 'text/plain');
}
//-------------------------------------------

//MODAL BAR WIDGET-------------------------------
modalBarWidget() {
  return Container(
    height: 6.0,
    child: Center(
      child: Container(
        width: 50.0,
        height: 6.0,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    ),
  );
}
//-------------------------------------------

//ORDER TRACKER WIDGET-------------------------------
orderTrackerWidget(String status) {
  bool processing = false,
      confirmed = false,
      shipped = false,
      delivered = false;

  if (status == "Confirmed") {
    confirmed = true;
  } else if (status == "Processing") {
    processing = true;
    confirmed = true;
  } else if (status == "Shipped") {
    processing = true;
    confirmed = true;
    shipped = true;
  } else if (status == "Delivered") {
    processing = true;
    confirmed = true;
    shipped = true;
    delivered = true;
  } else {}

  Widget checkMark() {
    return Icon(
      Icons.check,
      color: MColors.primaryWhite,
      size: 12.0,
    );
  }

  Widget smallDonut() {
    return Container(
      width: 5.0,
      height: 5.0,
      decoration: BoxDecoration(
        color: MColors.primaryWhiteSmoke,
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
    );
  }

  Widget bar(Color color) {
    return Container(
      width: 70.0,
      height: 3.0,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
    );
  }

  Widget checkPoint(Color color, Widget center) {
    return Container(
        width: 16.0,
        height: 16.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: center);
  }

  return Container(
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Confirmed",
              style:
                  normalFont(confirmed ? Colors.green : Colors.grey[400], 12.0),
            ),
            SizedBox(width: 35.0),
            Text(
              "Processing",
              style: normalFont(
                  processing ? Colors.green : Colors.grey[400], 12.0),
            ),
            SizedBox(width: 35.0),
            Text(
              "Shipped",
              style:
                  normalFont(shipped ? Colors.green : Colors.grey[400], 12.0),
            ),
            SizedBox(width: 35.0),
            Text(
              "Delivered",
              style:
                  normalFont(delivered ? Colors.green : Colors.grey[400], 12.0),
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //PROCESSING
            checkPoint(
              confirmed ? Colors.green : Colors.grey[400],
              Center(
                child: confirmed ? checkMark() : smallDonut(),
              ),
            ),

            SizedBox(width: 5.0),

            bar(processing && confirmed ? Colors.green : Colors.grey[400]),

            SizedBox(width: 5.0),

            //CONFIRMED
            checkPoint(
              processing ? Colors.green : Colors.grey[400],
              Center(
                child: processing && shipped ? checkMark() : smallDonut(),
              ),
            ),

            SizedBox(width: 5.0),

            bar(shipped ? Colors.green : Colors.grey[400]),

            SizedBox(width: 5.0),

            //EN ROUTE
            checkPoint(
              shipped ? Colors.green : Colors.grey[400],
              Center(
                child: shipped && delivered ? checkMark() : smallDonut(),
              ),
            ),

            SizedBox(width: 5.0),

            bar(delivered ? Colors.green : Colors.grey[400]),

            SizedBox(width: 5.0),

            //DELIVERED
            checkPoint(
              delivered ? Colors.green : Colors.grey[400],
              Center(
                child: delivered ? checkMark() : smallDonut(),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

final DynamicLinkController _dynamicLinkController = DynamicLinkController();

//-------------------------------------------
Widget blockWigdet(
    String blockTitle,
    String blockSubTitle,
    double _picHeight,
    double _itemHeight,
    List<ProdProducts> prods,
    CartNotifier cartNotifier,
    Iterable<String> cartProdID,
    GlobalKey _scaffoldKey,
    BuildContext context,
    allProds,
    void Function() seeMore,
    UserDataProfile profile,
    IconData icon,
    {String iconPath}) {
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
                          cartQuantity: 1,
                          sold: _product.sold,
                          tablespecs: _product.tablespecs,
                          varientID: _product.varientID),
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
                  Navigator.of(context).pop();

                  // if (cartProdID.contains(_product.id)) {
                  //   showSimpleSnack(
                  //     "Product already in bag",
                  //     Icons.error_outline,
                  //     Colors.amber,
                  //     scaffoldKey,
                  //   );
                  // } else {

                  //
                  // }
                },
              ),
            ],
          );
        });
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Container(width: 30, child: Image.asset(iconPath)
            //     // FaIcon(FontAwesomeIcons.fish, color: Colors.grey)
            //     ),
            FaIcon(
              icon,
              color: MColors.mainColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              blockTitle,
              style: boldFont(MColors.mainColor, 16.0),
            ),
            Spacer(),
            Container(
              height: 17.0,
              child: InkWell(
                onTap: seeMore,
                child: Text(
                  "See more",
                  style: boldFont(MColors.mainColor, 14.0),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 5.0),
      Container(
        height: 307,
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: prods.length,
            itemBuilder: (context, i) {
              var product = prods[i];
              // print('https://wild-grocery.herokuapp.com/${product.image}');

              return GestureDetector(
                onTap: () async {
                  var navigationResult = await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ProductDetailsProv(
                          product, allProds, _dynamicLinkController),
                    ),
                  );
                  if (navigationResult == true) {
                    getCart(cartNotifier);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  width: 150.0,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MColors.primaryWhite,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.03),
                          offset: Offset(0, 10),
                          blurRadius: 10,
                          spreadRadius: 0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: FadeInImage.assetNetwork(
                                image:
                                    ('https://wild-grocery.herokuapp.com/${product.image}'),
                                fit: BoxFit.fill,
                                height: 150,
                                placeholder: "assets/images/placeholder.jpg",
                                placeholderScale:
                                    MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: MColors.dashPurple,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    '${((product.original_price - product.selling_price) / product.original_price * 100).toInt()}% OFF',
                                    style: boldFont(MColors.mainColor, 13),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: normalFont(MColors.textGrey, 15.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.0),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 7),
                            child: Text(
                              product.productQuantity.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: normalFont(MColors.textGrey, 15.0),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: MColors.dashPurple,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                      SizedBox(height: 3.0),
                      Spacer(),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: [
                                Container(
                                  child: Text(
                                    "₹ ${product.selling_price}",
                                    style: boldFont(MColors.textDark, 18.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "₹ ${product.selling_price}",
                                    style:
                                        boldFontStriked(MColors.textGrey, 15.0),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                getCart(cartNotifier);
                                addProductToCart(
                                    Cart(
                                        id: product.id,
                                        name: product.name,
                                        selling_price: product.selling_price,
                                        category: product.category,
                                        specs: product.specs,
                                        productQuantity:
                                            product.productQuantity,
                                        original_price: product.original_price,
                                        quantity: product.quantity,
                                        image: product.image,
                                        imgcollection: product.imgcollection,
                                        filterValue: product.filterValue,
                                        description: product.description,
                                        prices: product.prices,
                                        cartQuantity: 1,
                                        sold: product.sold,
                                        tablespecs: product.tablespecs,
                                        varientID: product.varientID),
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
                                // Navigator.of(context).pop();

                                // if (cartProdID.contains(_product.id)) {
                                //   showSimpleSnack(
                                //     "Product already in bag",
                                //     Icons.error_outline,
                                //     Colors.amber,
                                //     scaffoldKey,
                                //   );
                                // } else {

                                //
                                // }
                                // addToBagshowDialog(product,
                                //   cartNotifier, cartProdID, _scaffoldKey);
                              },
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: MColors.dashPurple,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: SvgPicture.asset(
                                  "assets/images/icons/basket.svg",
                                  height: 22.0,
                                  color: MColors.textGrey,
                                ),
                              ),
                              // child: Container(
                              //   width: 45.0,
                              //   height: 45.0,
                              //   padding: const EdgeInsets.all(8.0),
                              //   decoration: BoxDecoration(
                              //     color: MColors.mainColor,
                              //     borderRadius: BorderRadius.circular(18.0),
                              //   ),
                              //   child: SvgPicture.asset(
                              //     "assets/images/icons/basket.svg",
                              //     height: 20.0,
                              //     color: MColors.primaryWhite,
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    ],
  );
}

Widget blockWigdet2(
    String blockTitle,
    String blockSubTitle,
    double _picHeight,
    double _itemHeight,
    List<Cat> prods,
    CartNotifier cartNotifier,
    ProductsNotifier productsNotifier,
    CategoryNotifier catNotifier,
    Iterable<String> cartProdID,
    GlobalKey _scaffoldKey,
    BuildContext context,
    allProds,
    void Function() seeMore,
    IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FaIcon(
              icon,
              color: MColors.mainColor,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              blockTitle,
              style: boldFont(MColors.mainColor, 16.0),
            ),
            // Container(
            //   height: 17.0,
            //   child: RawMaterialButton(
            //     onPressed: seeMore,
            //     child: Text(
            //       "See more",
            //       style: boldFont(MColors.mainColor, 14.0),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      SizedBox(height: 5.0),
      Container(
        height: 410,
        padding: EdgeInsets.only(left: 18.0),
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: prods.length,
          itemBuilder: (context, i) {
            var product = prods[i];
            // print('https://wild-grocery.herokuapp.com/${product.banner}');
            // print(product.name);
            return Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    var navigationResult = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SeeMoreScreen(
                          title: product.name,
                          products: productsNotifier.productsList
                              .where((element) =>
                                  element.category['name'] == product.name)
                              .toList(),
                          productsNotifier: productsNotifier,
                          cartNotifier: cartNotifier,
                          cartProdID: cartProdID,
                          categoryId: product.id,
                        ),
                      ),
                    );
                    if (navigationResult == true) {
                      getCart(cartNotifier);
                    }
                  },
                  child: Container(
//                      padding: EdgeInsets.all(10),
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    decoration: BoxDecoration(
                      color: MColors.primaryWhite,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.03),
                            offset: Offset(0, 10),
                            blurRadius: 10,
                            spreadRadius: 0),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      //TODO: Removed Hero from Column
                      child: Column(
                        children: [
                          Expanded(
                            child: FadeInImage.assetNetwork(
                              image:
                                  'https://wild-grocery.herokuapp.com/${product.banner}',
                              fit: BoxFit.fill,
                              // height: _picHeight - 40,
                              // width: 150,
                              placeholder: "assets/images/placeholder.jpg",
                              placeholderScale:
                                  MediaQuery.of(context).size.height / 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              product.name,
                              style: boldFont(MColors.mainColor, 16),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
//                  SizedBox(width: 2.0),
              ],
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1, crossAxisCount: 2, mainAxisSpacing: 10),
        ),
      ),
    ],
  );
}
