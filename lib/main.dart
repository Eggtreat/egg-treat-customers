import 'package:flutter/material.dart';
void main() => runApp(EggTreatApp());

class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(primarySwatch: Colors.orange), home: MainScreen());
  }
}

class MainScreen extends StatefulWidget { @override _MainScreenState createState() => _MainScreenState(); }

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> payments = [];

  final items = [
    {"name": "Egg Puff", "price": 25, "vendor": "Thuckalay Bakery"},
    {"name": "Egg Biryani", "price": 120, "vendor": "Padmanabhapuram Hotel"},
    {"name": "Boiled Egg", "price": 15, "vendor": "Colachel Stall"},
    {"name": "Egg Dosa", "price": 60, "vendor": "Marthandam Cafe"},
    {"name": "Egg Sandwich", "price": 70, "vendor": "Nagercoil Foods"},
  ];

  void addToCart(item) { setState(()=> cart.add(item)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item["name"]} Added'), duration: Duration(milliseconds: 800))); }

  void placeOrder(String method) {
    int total = cart.fold(0, (s, e) => s + (e["price"] as int));
    setState((){
      String id = "ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
      orders.insert(0, {"id": id, "items": List.from(cart), "total": total, "status": 0, "time": DateTime.now().toString().substring(11,16), "method": method});
      payments.insert(0, {"id": id, "amount": total, "method": method, "status": "Success", "time": DateTime.now().toString().substring(0,16)});
      cart.clear();
      _index = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(["🥚 Menu", "🛒 Cart", "📦 Tracking", "💳 Payments"][_index]), backgroundColor: Colors.orange),
      body: [buildMenu(), buildCart(), buildTracking(), buildPayments()][_index],
      bottomNavigationBar: BottomNavigationBar(currentIndex: _index, onTap: (i)=> setState(()=> _index=i), type: BottomNavigationBarType.fixed, selectedItemColor: Colors.orange,
        items: [BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"), BottomNavigationBarItem(icon: Badge(label: Text('${cart.length}'), child: Icon(Icons.shopping_cart)), label: "Cart"), BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Tracking"), BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments")]),
    );
  }

  Widget buildMenu() => ListView.builder(itemCount: items.length, itemBuilder: (c,i)=> Card(margin: EdgeInsets.all(8), child: ListTile(title: Text(items[i]["name"], style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${items[i]["vendor"]} • ₹${items[i]["price"]}'), trailing: ElevatedButton(onPressed: ()=> addToCart(items[i]), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white), child: Text("ADD")))));

  Widget buildCart() {
    if(cart.isEmpty) return Center(child: Text("Cart Empty - Add Items from Menu"));
    int total = cart.fold(0, (s,e)=> s + (e["price"] as int));
    return Column(children: [
      Expanded(child: ListView.builder(itemCount: cart.length, itemBuilder: (c,i)=> ListTile(title: Text(cart[i]["name"]), trailing: Text("₹${cart[i]["price"]}"), leading: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: ()=> setState(()=> cart.removeAt(i)))))),
      Container(padding: EdgeInsets.all(16), color: Colors.grey.shade100, child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Total: ₹$total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("${cart.length} Items")]),
        SizedBox(height: 10),
        Row(children: [
          Expanded(child: ElevatedButton(onPressed: ()=> placeOrder("COD"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white), child: Text("COD"))),
          SizedBox(width: 10),
          Expanded(child: ElevatedButton(onPressed: ()=> placeOrder("UPI"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: Text("PAY ₹$total - UPI"))),
        ])
      ]))
    ]);
  }

  Widget buildTracking() {
    if(orders.isEmpty) return Center(child: Text("No Orders Yet"));
    return ListView.builder(itemCount: orders.length, itemBuilder: (c,i){
      var o = orders[i];
      List<String> steps = ["Order Placed", "Preparing", "Out for Delivery", "Delivered"];
      return Card(margin: EdgeInsets.all(10), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o["id"], style: TextStyle(fontWeight: FontWeight.bold)), Text("₹${o["total"]} • ${o["method"]}", style: TextStyle(color: Colors.green))]),
        Text("Today ${o["time"]} - ${o["items"].length} items", style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        Row(children: List.generate(4, (s)=> Expanded(child: Column(children: [
          CircleAvatar(radius: 14, backgroundColor: o["status"] >= s? Colors.green : Colors.grey.shade300, child: Icon(o["status"] >= s? Icons.check : Icons.circle, size: 14, color: Colors.white)),
          SizedBox(height: 4),
          Text(steps[s], style: TextStyle(fontSize: 9, color: o["status"] >= s? Colors.black : Colors.grey)),
        ])))),
        SizedBox(height: 10),
        if(o["status"] < 3) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: ()=> setState(()=> o["status"]++), child: Text("Next Status (Demo) ->"))),
        if(o["status"]==3) Container(padding: EdgeInsets.all(6), color: Colors.green.shade50, child: Row(children: [Icon(Icons.verified, color: Colors.green, size: 16), SizedBox(width: 5), Text("Delivered Successfully!", style: TextStyle(color: Colors.green))]))
      ]))));
    });
  }

  Widget buildPayments() {
    if(payments.isEmpty) return Center(child: Text("No Payments Yet"));
    return ListView.builder(itemCount: payments.length, itemBuilder: (c,i){
      var p = payments[i];
      return Card(margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(
        leading: CircleAvatar(backgroundColor: p["method"]=="UPI"? Colors.green.shade100 : Colors.orange.shade100, child: Icon(p["method"]=="UPI"? Icons.account_balance_wallet : Icons.money, color: p["method"]=="UPI"? Colors.green : Colors.orange)),
        title: Text("${p["id"]} - ₹${p["amount"]}"),
        subtitle: Text("${p["method"]} • ${p["time"]}"),
        trailing: Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)), child: Text(p["status"], style: TextStyle(color: Colors.white, fontSize: 12))),
      ));
    });
  }
}
