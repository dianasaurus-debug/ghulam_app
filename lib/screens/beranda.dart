import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ghulam_app/controllers/category_controller.dart';
import 'package:ghulam_app/controllers/product_controller.dart';
import 'package:ghulam_app/models/category.dart';
import 'package:ghulam_app/screens/detail_screen.dart';
import 'package:ghulam_app/models/product.dart';
import 'package:ghulam_app/utils/constants.dart';
import 'package:ghulam_app/widgets/app_bar.dart';
import 'package:ghulam_app/widgets/bottom_navbar.dart';
import 'package:ghulam_app/widgets/category_chips.dart';
import 'package:ghulam_app/widgets/grid_product.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomePageState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class HomePageState extends State<HomePage> {
  // final formatCurrency = new NumberFormat.simpleCurrency(locale: 'id_ID');
  late Future<List<Product>> futureListProduct;
  late Future<List<Category>> futureListCategory;

  bool isAuth = false;
  var idSelected = 0;
  List<Product> usedProducts = [];
  List<Category> usedCategory = [];
  final _debouncer = Debouncer();

  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkIfLoggedIn();
    futureListCategory = CategoryNetwork().getCategories();
    futureListProduct = ProductNetwork().getProducts();
  }

  Widget build(BuildContext context) {
    final ButtonStyle styleButton = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      onPrimary: Colors.black,
      padding: EdgeInsets.fromLTRB(100, 15, 100, 15),
      primary: kPrimaryColor,
    );
    return Scaffold(
      appBar: BaseAppBar(appBar: AppBar(), isAuth: isAuth),
      body: Padding(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: FutureBuilder<List<Product>>(
              future: futureListProduct,
              builder: (context, products) {
                if (products.hasData) {
                  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                    ///This schedules the callback to be executed in the next frame
                    /// thus avoiding calling setState during build
                    setState(() {
                      if(idSelected==0){
                        usedProducts = products.data!;
                      }
                    });
                  });
                  return Column(children: [
                    Row(
                      mainAxisAlignment : MainAxisAlignment.spaceBetween,
                      crossAxisAlignment : CrossAxisAlignment.center,
                      children : [
                        Align(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Daftar Produk',
                                      style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold)),
                                  Text('Produk murah dan berkualitas!',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100)),
                                ]),
                            alignment: Alignment.centerLeft),
                        IconButton (
                          icon : Icon(Icons.tune),
                          onPressed : () {
                            showModalBottomSheet(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                ),
                                context: context,
                                builder: (context) {
                                  return SingleChildScrollView(
                                      padding : EdgeInsets.all(20),
                                      child : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Wrap(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  'Header',
                                                ),
                                                tileColor: kPrimaryColor,
                                              ),
                                              ListTile(
                                                title: Text('Title 1'),
                                              ),
                                              ListTile(
                                                title: Text('Title 2'),
                                              ),
                                              ListTile(
                                                title: Text('Title 3'),
                                              ),
                                              ListTile(
                                                title: Text('Title 4'),
                                              ),
                                              ListTile(
                                                title: Text('Title 5'),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                  );
                                });
                          }
                        )

                      ]
                    ),

                    SizedBox(
                      height: 10,
                    ),
                   SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: FutureBuilder<List<Category>>(
                                future: futureListCategory,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    WidgetsBinding.instance
                                        ?.addPostFrameCallback((timeStamp) {
                                      ///This schedules the callback to be executed in the next frame
                                      /// thus avoiding calling setState during build
                                      setState(() {
                                        if (usedCategory.length == 0) {
                                          setState(() {
                                            usedCategory = snapshot.data!;
                                            usedCategory.insert(
                                                0, new Category("Semua", 0));
                                          });
                                        }
                                      });
                                    });
                                    return Row(
                                        children:
                                        snapshot.data!
                                            .map((e) => Container(
                                          margin: EdgeInsets.only(left: 7.0),
                                          child: ChoiceChip(
                                            labelPadding: EdgeInsets.all(0.0),
                                            label: Text(
                                              e.nama_kategori,
                                              style: TextStyle(
                                                  color: kPrimaryColor,
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                            selected: idSelected == e.id,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                idSelected = e.id;
                                              });
                                              if (idSelected != 0) {
                                                setState(() {
                                                  usedProducts = products
                                                      .data!
                                                      .where((data) =>
                                                  data.category_id ==
                                                      idSelected)
                                                      .toList();
                                                });
                                              } else {
                                                setState(() {usedProducts = products.data!;});
                                              }
                                            },
                                            backgroundColor: Colors.white,
                                            shape: StadiumBorder(
                                                side: BorderSide(
                                                    color:
                                                    Color(0xFF4db6ac))),
                                            padding: EdgeInsets.all(6.0),
                                          ),
                                        ))
                                            .toList());
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  }
                                  return Center(child: LinearProgressIndicator());
                                }),
                          ),

                    Container(
                        height: MediaQuery.of(context).size.height * (0.53),
                        child: SingleChildScrollView(
                            child: usedProducts.length > 0
                                ? GridView.builder(
                                    physics: ScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: usedProducts.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 5,
                                            crossAxisSpacing: 7),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        child: GridProduct(usedProducts[index]),
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailPage(
                                                        product: usedProducts[
                                                            index])),
                                          )
                                        },
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text('Produk kosong',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w100,
                                            color: kPrimaryColor)),
                                  )))
                  ]);
                } else if (products.hasError) {
                  return Text("${products.error}");
                }
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: kPrimaryColor,
                      ),
                      Text("\nMemuat data produk...")
                    ],
                  ),
                );
              })),
      bottomNavigationBar: BottomNavbar(current: 0),
    );
  }
}
