import 'package:flutter/material.dart';
import '/providers/orders.dart';
import '/widgets/app_drawer.dart';
import '/widgets/order_tile.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders')),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return Center(child: Text('An error occured.'));
            } else {
              return Consumer<Orders>(
                builder: (_, orderProvider, __) => ListView.builder(
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (_, i) => OrderTile(orderProvider.orders[i]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
