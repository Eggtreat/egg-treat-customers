import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(EggTreatApp());

class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egg-Treat',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: MainTabScreen(),
    );
  }
}

// MODELS
class Vendor {
  String id; String name; String type; double lat; double lng; double rating; List<String> activeOffers;
  Vendor({required this.id, required this.name, required this.type, required this.lat, required this.lng, this.rating=4.5, this.activeOffers=const[]});
}
class Product {
  String name; double price; String vendorId; bool inStock; String? offerType; String offerDetail;
  Product({required this.name, required this.price, required this.vendorId, this.inStock=true, this.offerType, this.offerDetail=""});
}

List<Vendor> vendors = [
  Vendor(id:"v1", name:"Madurai Tea Stall", type:"Tea Stall", lat:9.9252, lng:78.1198, activeOffers:["Today Special Live", "4-7 PM Offer"]),
  Vendor(id:"v2", name:"Thalluvandi Kumar", type:"Thalluvandi", lat:9.93, lng:78.12, rating:4.8, activeOffers:["3 Offers Available"]),
  Vendor(id:"v3", name:"A1 Bakery", type:"Bakery", lat:9.95, lng:78.10, activeOffers:[]),
  Vendor(id:"v4", name:"Hotel Junior Kuppanna", type:"Hotel", lat:9.91, lng:78.11, activeOffers:["COMBO Offer"]),
];

List<Product> products = [
  Product(name:"Egg Puff", price:25, vendorId:"v1", offerType:"4-7 PM OFFER", offerDetail:"4-7 PM 20% OFF - Only Today"),
  Product(name:"Egg Puff", price:20, vendorId:"v2", offerType:"TODAY SPECIAL", offerDetail:"Buy 2 Get 1 Free - Auto expires midnight"),
  Product(name:"Egg Puff", price:35, vendorId:"v3", inStock:false),
  Product(name:"Egg Biryani", price:120, vendorId:"v4", offerType:"COMBO", offerDetail:"Biryani + Coke @ Rs.140 Only"),
  Product(name:"Egg Chaat", price:80, vendorId:"v2", offerType:"COMBO", offerDetail:"Chaat + Lassi Combo"),
  Product(name:"Egg Dosa", price:60, vendorId:"v1", offerType:"TIMING SPECIAL", offerDetail:"Morning 7-10 AM 10% OFF"),
];

double calcDist(double lat1, double lon1, double lat2, double lon2){
  var p=0.017453292519943295; var c=cos; var a=0.5 - c((lat2-lat1)*p)/2 + c(lat1*p)*c(lat2*p)*(1-c((lon2-lon1)*p))/2;
  return 12742*asin(sqrt(a));
}

class MainTabScreen extends StatefulWidget { @override _MainTabScreenState createState()=>_MainTabScreenState(); }
class _MainTabScreenState extends State<MainTabScreen> {
  int currentIndex=0;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: [ItemWiseScreen(), VendorWiseScreen()][currentIndex],
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex, onTap: (i)=>setState(()=>currentIndex=i), selectedItemColor: Colors.orange,
        items: [BottomNavigationBarItem(icon: Icon(Icons.egg), label: "Item-Wise"), BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendor-Wise")]),
    );
  }
}

// 1. ITEM-WISE SCREEN - Price Low to High
class ItemWiseScreen extends StatefulWidget { @override _ItemWiseScreenState createState()=>_ItemWiseScreenState(); }
class _ItemWiseScreenState extends State<ItemWiseScreen> {
  String search="Egg Puff";
  @override
  Widget build(BuildContext context){
    List<Product> filtered = products.where((p)=>p.name.toLowerCase().contains(search.toLowerCase())).toList();
    filtered.sort((a,b){
      if(!a.inStock && b.inStock) return 1;
      if(a.inStock &&!b.inStock) return -1;
      return a.price.compareTo(b.price); // Low to High
    });
    return Scaffold(appBar: AppBar(title: Text("🥚 Egg-Treat: Item-Wise"), backgroundColor: Colors.orange),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: TextField(decoration: InputDecoration(hintText:"Search Egg Puff, Biryani...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v)=>setState(()=>search=v))),
        Padding(padding: EdgeInsets.symmetric(horizontal:12), child: Text("SORTING: Price Low to High | Out of stock at bottom", style: TextStyle(fontSize:11, color:Colors.grey))),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (ctx,i){
          var p=filtered[i]; var v=vendors.firstWhere((vn)=>vn.id==p.vendorId);
          return Card(margin: EdgeInsets.all(8), color: p.inStock?Colors.white:Colors.grey[200], child: ListTile(
            title: Text("${p.name} - Rs.${p.price}", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${v.name} | ${p.inStock?"✅ In Stock":"❌ Out of Stock"}"),
            trailing: p.offerType!=null? GestureDetector(onTap: ()=>showOfferPopup(context, p.offerType!, p.offerDetail), child: Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text(p.offerType!, style: TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold)))):null,
          ));
        }))
      ]));
  }
}

// 2. VENDOR-WISE SCREEN - Nearest to Farthest
class VendorWiseScreen extends StatefulWidget { @override _VendorWiseScreenState createState()=>_VendorWiseScreenState(); }
class _VendorWiseScreenState extends State<VendorWiseScreen> {
  LatLng customerLoc = LatLng(9.9252, 78.1198);
  @override
  Widget build(BuildContext context){
    List<Vendor> sortedVendors = List.from(vendors);
    sortedVendors.sort((a,b){
      double dA=calcDist(customerLoc.latitude, customerLoc.longitude, a.lat, a.lng);
      double dB=calcDist(customerLoc.latitude, customerLoc.longitude, b.lat, b.lng);
      return dA.compareTo(dB); // Nearest to Farthest
    });
    return Scaffold(appBar: AppBar(title: Text("🏪 Vendor-Wise (Nearest First)"), backgroundColor: Colors.orange),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(12), child: Text("SORTING: Distance - Nearest to Farthest from you (Madurai)", style: TextStyle(fontSize:11, color:Colors.grey))),
        Expanded(child: ListView.builder(itemCount: sortedVendors.length, itemBuilder: (ctx,i){
          var v=sortedVendors[i];
          double dist=calcDist(customerLoc.latitude, customerLoc.longitude, v.lat, v.lng);
          double riderPayout = 20 + (dist*5); double deliveryFee = riderPayout*0.2; double totalDelivery = riderPayout+deliveryFee;
          int itemCount = products.where((p)=>p.vendorId==v.id).length;
          return Card(margin: EdgeInsets.all(8), child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.orange[100], child: Text(v.type[0])),
            title: Text("${v.name} - ${dist.toStringAsFixed(1)} KM", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${v.type} | ⭐ ${v.rating} | ${itemCount} Egg Items"),
              Text("Delivery: Rs.${totalDelivery.toStringAsFixed(0)} (Rider Rs.${riderPayout.toStringAsFixed(0)} + Fee Rs.${deliveryFee.toStringAsFixed(0)})", style: TextStyle(fontSize:11, color:Colors.green, fontWeight: FontWeight.bold)),
            ]),
            trailing: v.activeOffers.isNotEmpty? GestureDetector(onTap: ()=>showVendorOffers(context, v), child: Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)), child: Text(v.activeOffers[0], style: TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold)))):null,
          ));
        }))
      ]));
  }
}

void showOfferPopup(BuildContext ctx, String type, String detail){
  showDialog(context: ctx, builder: (_)=>AlertDialog(title: Text("🏷️ $type"), content: Text(detail+"\n\nThis offer will auto-apply at checkout if timing matches."), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text("OK"))]));
}
void showVendorOffers(BuildContext ctx, Vendor v){
  var vProducts = products.where((p)=>p.vendorId==v.id && p.offerType!=null).toList();
  showDialog(context: ctx, builder: (_)=>AlertDialog(title: Text("${v.name} Offers"), content: Column(mainAxisSize: MainAxisSize.min, children: vProducts.map((p)=>ListTile(title: Text(p.offerType!), subtitle: Text("${p.name} - ${p.offerDetail}"))).toList()), actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: Text("Close"))]));
}
