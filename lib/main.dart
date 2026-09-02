import 'package:flutter/material.dart';
void main() => runApp(EggTreatApp());
class EggTreatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ItemWisePage());
  }
}
class ItemWisePage extends StatelessWidget {
  final items = [
    {"name": "Egg Puff", "price": "₹25", "vendor": "Thuckalay Bakery"},
    {"name": "Egg Biryani", "price": "₹120", "vendor": "Padmanabhapuram Hotel"},
    {"name": "Boiled Egg", "price": "₹15", "vendor": "Colachel Stall"},
    {"name": "Egg Dosa", "price": "₹60", "vendor": "Marthandam Cafe"},
    {"name": "Egg Sandwich", "price": "₹70", "vendor": "Nagercoil Foods"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🥚 Egg Treat - Item Wise"), backgroundColor: Colors.orange),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          return Card(margin: EdgeInsets.all(8), child: ListTile(
            leading: CircleAvatar(child: Text(items[i]["name"]![0])),
            title: Text(items[i]["name"]!),
            subtitle: Text("${items[i]["vendor"]} - ${items[i]["price"]}"),
            trailing: Icon(Icons.arrow_forward),
          ));
        },
      ),
    );
  }
}
