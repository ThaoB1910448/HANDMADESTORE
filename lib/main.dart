import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:handmadestore/ui/cart/cart_manager.dart';
import 'package:handmadestore/ui/orders/order_manager.dart';
import 'package:handmadestore/ui/screens.dart';
import 'package:provider/provider.dart';

import 'ui/products/product_manager.dart';
import 'ui/products/product_detail_screen.dart';
import 'ui/products/product_overview_screen.dart';
import 'ui/products/user_product_screen.dart';

import 'ui/cart/cart_screen.dart';
import 'ui/screens.dart';
import 'ui/orders/order_screen.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthManager(),
        ),
        ChangeNotifierProxyProvider<AuthManager, ProductManager>(
          create: (ctx) => ProductManager(),
          update: (ctx, authManager, productsManager) {
            productsManager!.authToken = authManager.authToken;
            return productsManager;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartManager(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => OrdersManager(),
        ),
      ],
      child: Consumer<AuthManager>(builder: (context, authManager, child) {
        return MaterialApp(
          title: 'HANDMADE STORE',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.pink,
            ).copyWith(
              secondary: Colors.deepOrange,
            ),
          ),
          home: authManager.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: authManager.tryAutoLogin(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : const AuthScreen();
                  },
                ),
          routes: {
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == ProductDetailScreen.routeName) {
              final productId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (ctx) {
                  return ProductDetailScreen(
                    ctx.read<ProductManager>().findById(productId),
                  );
                },
              );
            }

            if (settings.name == EditProductScreen.routeName) {
              final productId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (ctx) {
                  return EditProductScreen(
                    productId != null
                        ? ctx.read<ProductManager>().findById(productId)
                        : null,
                  );
                },
              );
            }

            return null;
          },
        );
      }),
    );
  }
}
//      