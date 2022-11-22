import 'package:flutter/foundation.dart';

import '../../models/auth_token.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductManager with ChangeNotifier {
  List<Product> _item = [];

  final ProductsService _productsService;
  ProductManager([AuthToken? authToken])
      : _productsService = ProductsService(authToken);
  set authToken(AuthToken? authToken) {
    _productsService.authToken = authToken;
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    _item = await _productsService.fetchProducts(filterByUser);
    notifyListeners();
  }

  Future<void> addProducts(Product product) async {
    final newProduct = await _productsService.addProduct(product);
    if (newProduct != null) {
      _item.add(newProduct);
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    final index = _item.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      if (await _productsService.updateProduct(product)) {
        _item[index] = product;
        notifyListeners();
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final index = _item.indexWhere((item) => item.id == id);
    Product? existingProduct = _item[index];
    _item.removeAt(index);
    notifyListeners();
    if (!await _productsService.deleteProduct(id)) {
      _item.insert(index, existingProduct);
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(Product product) async {
    final savedStatus = product.isFavorite;
    product.isFavorite = !savedStatus;
    if (!await _productsService.saveFavoriteStatus(product)) {
      product.isFavorite = !savedStatus;

      if (!await _productsService.saveFavoriteStatus(product)) {
        product.isFavorite == savedStatus;
      }
    }
  }

  // final List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'DREAMCATCHER PRESENT FLOWER PASTEL',
    //   description: 'Dream catcher has high color fastness, does not fade.',
    //   price: 29.00,
    //   imageUrl:
    //       'http://quatanglambangtay.com/uploads/products/532820278_dreamcatcherhandmadedep_10.jpg',
    //   isFavorite: true,
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'DREAMCATCHER COLOR WHITE LAMP',
    //   description:
    //       'With a lovely pink frame design, it will be very appropriate if it is decorated in a space with pure white wall paint or elegant pastel colors. With the way of knitting lotus petals, embellished with eye-catching red and green wood beads, it looks so beautiful.',
    //   price: 19.99,
    //   imageUrl:
    //       'http://quatanglambangtay.com/uploads/products/516610396_dreamcatcherganden.jpg',
    // ),
    
    // Product(
    //   id: 'p3',
    //   title: 'CUTE DOOR TABLE',
    //   description:
    //       'The signboard of the room, the decorative sign will bring a very new color to your home. Handcrafted with attention to the smallest details.',
    //   price: 10.99,
    //   imageUrl:
    //       'https://vn-test-11.slatic.net/p/00c8df80b3e8bca5bca95cd3784a64b3.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'CUTE BLUE DREAMCATCHER',
    //   description:
    //       'With a blue frame design and a different way of knitting fan wires, it is certain that no matter what space she is in, she will highlight her lovely room.',
    //   price: 15.09,
    //   imageUrl:
    //       'http://quatanglambangtay.com/uploads/products/399215302_dreamcatcher_mu_xanh_d_thng_m_drb6.jpg',
    //   isFavorite: true,
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'BRACELET',
    //   description:
    //       'Handmade line with genuine leather materials, decorative accessories & diverse mix but leaning towards simplicity, deep color.',
    //   price: 12.04,
    //   imageUrl:
    //       'https://bizweb.dktcdn.net/100/090/662/products/vong-tay-handmade-nu-3.jpg?v=1614570377983',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'Bamboo house',
    //   description:
    //       'There are many ways to make simple handmade things with paper or available materials such as felt fabric, bamboo paper core, plastic spoon. But you will be mesmerized with this DIY handmade bamboo idea because it's so beautiful.',
    //   price: 37.04,
    //   imageUrl:
    //       'http://tretrucsaigon.com/images/THI_CONG_TRE/%C4%91%E1%BB%93_handmade_t%E1%BB%AB_tre_2.jpg',
    // ),
// ];
  

  int get itemCount {
    return _item.length;
  }

  List<Product> get items {
    return [..._item];
  }

  List<Product> get favoriteItems {
    return _item.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _item.firstWhere((prod) => prod.id == id);
  }
}
