import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(EggTreatApp());

class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Egg-Treat',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true, fontFamily: 'Roboto'),
      home: MainTabScreen(),
    );
  }
}

class Vendor {
  String id; String name; String type; double lat; double lng; double rating; List<String> activeOffers;
  Vendor({required this.id, required this.name, required this.type, required this.lat, required this.lng, this.rating=4.5, this.activeOffers=const[]});
}
class Product {
  String name; double price; String vendorId; bool inStock; String? offerType; String offerDetail;
  Product({required this.name, required this.price, required this.vendorId, this.inStock=true, this.offerType, this.offerDetail=""});
}

List<Vendor> vendors = [
  Vendor(id:"v1", name:"Madurai Tea Stall", type:"Tea Stall", lat:9.9252, lng:78.1198, rating:4.6, activeOffers:["4-7 PM Offer"]),
  Vendor(id:"v2", name:"Thalluvandi Kumar", type:"Thalluvandi", lat:9.93, lng:78.12, rating:4.8, activeOffers:["Today Special","COMBO"]),
  Vendor(id:"v3", name:"A1 Bakery", type:"Bakery", lat:9.95, lng:78.10, rating:4.2, activeOffers:[]),
  Vendor(id:"v4", name:"Hotel Junior Kuppanna", type:"Hotel", lat:9.91, lng:78.11, rating:4.7, activeOffers:["COMBO Offer"]),
];

List<Product> products = [
  Product(name:"Egg Puff", price:25, vendorId:"v1", offerType:"4-7 PM OFFER", offerDetail:"4-7 PM 20% OFF - Evening special. Auto applied between 4PM to 7PM."),
  Product(name:"Egg Puff", price:20, vendorId:"v2", offerType:"TODAY SPECIAL", offerDetail:"Buy 2 Get 1 Free Today Only! Midnight auto expiry."),
  Product(name:"Egg Puff", price:35, vendorId:"v3", inStock:false),
  Product(name:"Egg Biryani", price:120, vendorId:"v4", offerType:"COMBO", offerDetail:"Egg Biryani + Coke @ Rs.140 Only"),
  Product(name:"Egg Chaat", price:80, vendorId:"v2", offerType:"COMBO", offerDetail:"Chaat + Lassi Combo Rs.99"),
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
      appBar: AppBar(title: Text(currentIndex==0? "🥚 Item-Wise - Low Price First" : "🏪 Vendor-Wise - Nearest First"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
      body: currentIndex==0? ItemWiseContent() : VendorWiseContent(),
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex, onTap: (i)=>setState(()=>currentIndex=i), selectedItemColor: Colors.deepOrange,
        items: [BottomNavigationBarItem(icon: Icon(Icons.egg_alt), label: "Item-Wise"), BottomNavigationBarItem(icon: Icon(Icons.store_mall_directory), label: "Vendor-Wise")]),
    );
  }
}

class ItemWiseContent extends StatefulWidget { @override _ItemWiseContentState createState()=>_ItemWiseContentState(); }
class _ItemWiseContentState extends State<ItemWiseContent> {
  String search="Egg Puff";
  @override
  Widget build(BuildContext context){
    List<Product> filtered = products.where((p)=>p.name.toLowerCase().contains(search.toLowerCase())).toList();
    filtered.sort((a,b){
      if(!a.inStock && b.inStock) return 1;
      if(a.inStock &&!b.inStock) return -1;
      return a.price.compareTo(b.price);
    });
    return Column(children: [
      Padding(padding: EdgeInsets.all(12), child: TextField(decoration: InputDecoration(hintText:"Search Egg Puff, Biryani, Chaat...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged: (v)=>setState(()=>search=v))),
      Container(padding: EdgeInsets.symmetric(horizontal:12, vertical:6), color: Colors.orange[50], child: Row(children: [Icon(Icons.info, size:14), SizedBox(width:6), Expanded(child: Text("Sorting: Price Low to High | Out of stock at bottom | Offer badge on right", style: TextStyle(fontSize:11)))])),
      Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (ctx,i){
        var p=filtered[i]; var v=vendors.firstWhere((vn)=>vn.id==p.vendorId);
        return Card(elevation: 2, margin: EdgeInsets.symmetric(horizontal:12, vertical:6), child: ListTile(
          leading: CircleAvatar(backgroundColor: p.inStock?Colors.orange:Colors.grey, child: Icon(Icons.egg, color:Colors.white)),
          title: Text("${p.name} - Rs.${p.price.toInt()}", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${v.name} | ${p.inStock?"✅ In Stock":"❌ Out of Stock - Bottom"}"),
          trailing: p.offerType!=null? InkWell(onTap: (){
            showDialog(context: context, builder: (_)=>AlertDialog(title: Text(p.offerType!), content: Text(p.offerDetail), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))]));
          }, child: Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:5), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text(p.offerType!, style: TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold)))):null,
        ));
      }))
    ]);
  }
}

class VendorWiseContent extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    double custLat=9.9252, custLng=78.1198;
    List<Vendor> sorted = List.from(vendors);
    sorted.sort((a,b)=>calcDist(custLat,custLng,a.lat,a.lng).compareTo(calcDist(custLat,custLng,b.lat,b.lng)));
    return Column(children: [
      Container(padding: EdgeInsets.all(8), color: Colors.green[50], child: Row(children: [Icon(Icons.my_location, size:14), SizedBox(width:6), Expanded(child: Text("Your Location: Madurai | Sorting: Nearest to Farthest | Delivery Charge = 20 + (KM x 5)", style: TextStyle(fontSize:11)))])),
      Expanded(child: ListView.builder(itemCount: sorted.length, itemBuilder: (ctx,i){
        var v=sorted[i];
        double dist=calcDist(custLat,custLng,v.lat,v.lng);
        double riderPayout=20+(dist*5); double deliveryFee=riderPayout*0.2; double total=riderPayout+deliveryFee;
        var vProducts=products.where((p)=>p.vendorId==v.id).toList();
        return Card(elevation: 3, margin: EdgeInsets.symmetric(horizontal:12, vertical:8), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: Colors.deepOrange, child: Text(v.type[0], style: TextStyle(color:Colors.white))),
            SizedBox(width:10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize:16)),
              Text("${v.type} | ${dist.toStringAsFixed(1)} KM Away | ⭐ ${v.rating}", style: TextStyle(fontSize:12, color:Colors.grey[700])),
            ])),
            if(v.activeOffers.isNotEmpty) Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: Text("${v.activeOffers.length} Offers", style: TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold)))
          ]),
          Divider(),
          Text("Egg Items: ${vProducts.map((e)=>"${e.name} Rs.${e.price.toInt()}").join(", ")}", style: TextStyle(fontSize:12)),
          SizedBox(height:6),
          Container(padding: EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)), child: Text("💰 Delivery: Rs.${total.toStringAsFixed(0)} = Rider Rs.${riderPayout.toStringAsFixed(0)} + Fee Rs.${deliveryFee.toStringAsFixed(0)}", style: TextStyle(fontSize:11, color:Colors.blue[800], fontWeight: FontWeight.bold))),
          if(vProducts.any((p)=>p.offerType!=null)) Wrap(spacing:6, children: vProducts.where((p)=>p.offerType!=null).map((p)=> ActionChip(label: Text(p.offerType!, style: TextStyle(fontSize:9)), backgroundColor: Colors.red[100], onPressed: (){
            showDialog(context: context, builder: (_)=>AlertDialog(title: Text(p.offerType!), content: Text("${p.name}\n${p.offerDetail}"), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))]));
          })).toList())
        ]))),
      }))
    ]);
  }
}
