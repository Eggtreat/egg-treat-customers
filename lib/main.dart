import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(EggTreatApp());
}

class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'Egg-Treat', theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true), home: MainTabScreen());
  }
}

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
      appBar: AppBar(title: Text(currentIndex==0? "🥚 Item-Wise - LIVE" : "🏪 Vendor-Wise - LIVE"), backgroundColor: Colors.deepOrange, foregroundColor: Colors.white,
        actions: [IconButton(icon: Icon(Icons.add_circle, size:30), onPressed: ()=>_addSampleData(), tooltip: "Add Sample Data")]),
      body: currentIndex==0? ItemWiseLive() : VendorWiseLive(),
      bottomNavigationBar: BottomNavigationBar(currentIndex: currentIndex, onTap: (i)=>setState(()=>currentIndex=i), selectedItemColor: Colors.deepOrange,
        items: [BottomNavigationBarItem(icon: Icon(Icons.egg_alt), label: "Item-Wise LIVE"), BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendor-Wise LIVE")]),
    );
  }
  Future<void> _addSampleData() async {
    var db = FirebaseFirestore.instance;
    await db.collection('vendors').doc('v1').set({'name':'Madurai Tea Stall','type':'Tea Stall','lat':9.9252,'lng':78.1198,'rating':4.6,'activeOffers':['4-7 PM Offer']});
    await db.collection('vendors').doc('v2').set({'name':'Thalluvandi Kumar','type':'Thalluvandi','lat':9.93,'lng':78.12,'rating':4.8,'activeOffers':['Today Special']});
    await db.collection('products').doc('p1').set({'name':'Egg Puff','price':25,'vendorId':'v1','inStock':true,'offerType':'4-7 PM OFFER','offerDetail':'Evening 20% OFF'});
    await db.collection('products').doc('p2').set({'name':'Egg Puff','price':20,'vendorId':'v2','inStock':true,'offerType':'TODAY SPECIAL','offerDetail':'Buy 2 Get 1'});
    await db.collection('products').doc('p3').set({'name':'Egg Biryani','price':120,'vendorId':'v1','inStock':true,'offerType':'COMBO','offerDetail':'Biryani+Coke @140'});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Firebase-ல் Sample Data Added!"), backgroundColor: Colors.green));
  }
}

class ItemWiseLive extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').orderBy('price').snapshots(),
      builder: (ctx, snapshot){
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
        if(snapshot.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.egg, size:60, color:Colors.orange), SizedBox(height:10), Text("No Products Yet"), Text("Top Right + Button Click to Add", style: TextStyle(fontSize:12, color:Colors.grey))]));
        var docs = snapshot.data!.docs;
        return ListView.builder(itemCount: docs.length, itemBuilder: (ctx,i){
          var p=docs[i];
          return Card(margin: EdgeInsets.all(8), child: ListTile(
            leading: CircleAvatar(backgroundColor: (p['inStock']??true)?Colors.orange:Colors.grey, child: Icon(Icons.egg, color:Colors.white)),
            title: Text("${p['name']} - Rs.${p['price']}"),
            subtitle: FutureBuilder<DocumentSnapshot>(future: FirebaseFirestore.instance.collection('vendors').doc(p['vendorId']).get(), builder: (c,vSnap){
              if(!vSnap.hasData) return Text("Loading vendor...");
              if(!vSnap.data!.exists) return Text("Vendor not found");
              return Text("${vSnap.data!['name']} | ${(p['inStock']??true)?"✅ In Stock":"❌ Out of Stock"}");
            }),
            trailing: p['offerType']!=null? Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: Text(p['offerType'], style: TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold))):null,
          ));
        });
      }
    );
  }
}

class VendorWiseLive extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    double custLat=9.9252, custLng=78.1198;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vendors').snapshots(),
      builder: (ctx, vSnapshot){
        if(!vSnapshot.hasData) return Center(child: CircularProgressIndicator());
        if(vSnapshot.data!.docs.isEmpty) return Center(child: Text("No Vendors - Click + to add"));
        var vDocs = vSnapshot.data!.docs;
        vDocs.sort((a,b){
          double dA=calcDist(custLat,custLng,a['lat'],a['lng']); double dB=calcDist(custLat,custLng,b['lat'],b['lng']);
          return dA.compareTo(dB);
        });
        return ListView.builder(itemCount: vDocs.length, itemBuilder: (ctx,i){
          var v=vDocs[i]; double dist=calcDist(custLat,custLng,v['lat'],v['lng']);
          double riderPayout=20+(dist*5); double total=riderPayout*1.2;
          return Card(margin: EdgeInsets.all(8), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [CircleAvatar(child: Text(v['type'][0])), SizedBox(width:10), Expanded(child: Text("${v['name']} - ${dist.toStringAsFixed(1)} KM", style: TextStyle(fontWeight: FontWeight.bold))), Container(padding: EdgeInsets.symmetric(horizontal:8,vertical:4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), child: Text("LIVE", style: TextStyle(color:Colors.white,fontSize:10)))]),
            SizedBox(height:8),
            Container(padding: EdgeInsets.all(6), color: Colors.blue[50], child: Text("Delivery Rs.${total.toStringAsFixed(0)}", style: TextStyle(fontSize:11, fontWeight: FontWeight.bold))),
          ]))),
        });
      }
    );
  }
}
