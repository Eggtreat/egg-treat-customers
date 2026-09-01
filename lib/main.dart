import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

void main() => runApp(EggTreatApp());

class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egg-Treat',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Poppins'),
      home: HomeScreen(),
    );
  }
}

// MOCK DATA - Later will connect to Firebase
class Product {
  String name; double price; String vendor; double vendorLat; double vendorLng; bool inStock; String? offerType; String? offerDetail;
  Product({required this.name, required this.price, required this.vendor, required this.vendorLat, required this.vendorLng, this.inStock=true, this.offerType, this.offerDetail});
}

List<Product> allProducts = [
  Product(name: "Egg Puff", price: 25, vendor: "Madurai Tea Stall", vendorLat: 9.92, vendorLng: 78.11, offerType: "4-7 PM OFFER", offerDetail: "Evening 4-7 PM 20% OFF"),
  Product(name: "Egg Puff", price: 20, vendor: "Thalluvandi Kumar", vendorLat: 9.93, vendorLng: 78.12, offerType: "TODAY SPECIAL", offerDetail: "Buy 2 Get 1 Free Today", inStock: true),
  Product(name: "Egg Puff", price: 35, vendor: "A1 Bakery", vendorLat: 9.95, vendorLng: 78.10, inStock: false),
  Product(name: "Egg Biryani", price: 120, vendor: "Hotel Junior Kuppanna", vendorLat: 9.91, vendorLng: 78.11, offerType: "COMBO", offerDetail: "Egg Biryani + Coke @ Rs.140"),
  Product(name: "Egg Chaat", price: 80, vendor: "Chaat Corner", vendorLat: 9.92, vendorLng: 78.13, offerType: "COMBO", offerDetail: "Chaat Combo Offer"),
];

class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  bool isItemWise = true; // true = Item Wise, false = Vendor Wise
  LatLng customerLoc = LatLng(9.9252, 78.1198); // Madurai center

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295; var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filtered = allProducts.where((p)=> p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    // SORTING LOGIC AS PER YOUR REQUIREMENT
    if(isItemWise){
      // ITEM-WISE: Price Low to High, Out of stock at bottom
      filtered.sort((a,b){
        if(!a.inStock && b.inStock) return 1;
        if(a.inStock &&!b.inStock) return -1;
        return a.price.compareTo(b.price);
      });
    } else {
      // VENDOR-WISE: Nearest to Farthest
      filtered.sort((a,b){
        double dA = calculateDistance(customerLoc.latitude, customerLoc.longitude, a.vendorLat, a.vendorLng);
        double dB = calculateDistance(customerLoc.latitude, customerLoc.longitude, b.vendorLat, b.vendorLng);
        return dA.compareTo(dB);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text("🥚 Egg-Treat - Only Egg Foods"), backgroundColor: Colors.orange),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(8), child: TextField(onChanged: (v)=>setState(()=>searchQuery=v), decoration: InputDecoration(hintText: "Search Egg Puff, Biryani...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ChoiceChip(label: Text("Item-Wise (Low Price First)"), selected: isItemWise, onSelected: (v)=>setState(()=>isItemWise=true)),
          SizedBox(width: 10),
          ChoiceChip(label: Text("Vendor-Wise (Nearest First)"), selected:!isItemWise, onSelected: (v)=>setState(()=>isItemWise=false)),
        ]),
        Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (ctx,i){
          var p = filtered[i];
          double dist = calculateDistance(customerLoc.latitude, customerLoc.longitude, p.vendorLat, p.vendorLng);
          // BILLING LOGIC PREVIEW
          double riderPayout = 20 + (dist * 5);
          double deliveryFee = riderPayout * 0.2;
          double totalDeliveryCharge = riderPayout + deliveryFee;

          return Card(margin: EdgeInsets.all(8), child: ListTile(
            title: Text("${p.name} - Rs.${p.price}", style: TextStyle(fontWeight: FontWeight.bold, color: p.inStock?Colors.black:Colors.grey)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${p.vendor} - ${dist.toStringAsFixed(1)} KM away ${p.inStock?"✅ In Stock":"❌ Out of Stock"}"),
              if(!isItemWise) Text("Delivery Charge: Rs.${totalDeliveryCharge.toStringAsFixed(0)} (${dist.toStringAsFixed(1)}KM)", style: TextStyle(fontSize: 12, color: Colors.green)),
            ]),
            trailing: p.offerType!= null? InkWell(onTap: (){
              showDialog(context: context, builder: (_) => AlertDialog(title: Text(p.offerType!), content: Text(p.offerDetail!), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))]));
            }, child: Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text(p.offerType!, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))) : null,
          ));
        }))
      ]),
    );
  }
}
