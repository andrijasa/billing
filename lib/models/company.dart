import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;

  final List<ProductItem> product;
  final List<SaleItem> sale;
  final List<PartyItem> party;

  Company({this.id, this.name, this.product, this.sale, this.party});

  double get totalSale {
    double totalSale = 0;
    sale.forEach((element) {
      totalSale = totalSale + element.totalAmount;
    });
    return totalSale;
  }

  double balance(String partyId) {
    double totalAmount = 0;
    this.sale.where((element) => element.partyId == partyId).forEach((v) {
      totalAmount = totalAmount + v.balance;
    });

    return totalAmount;
  }

  
}

class PartyItem {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final double openingBalance;
  final Timestamp asOfDate;
  final int toPayOrRecieve;
  PartyItem(
      {this.id,
      this.name,
      this.email,
      this.phoneNumber,
      this.address,
      this.asOfDate,
      this.openingBalance,
      this.toPayOrRecieve});

  double balance (Company company) {
    return company.balance(this.id);
  }
}

class SaleItem {
  final String id;
  final Timestamp dateTime;
  final String partyId;
  final List<BilledItem> billedItem;
  final double discount;
  final double tax;
  final double recieved;
  final String paymentType;
  final String discription;
  final List<Images> image;

  SaleItem({
    this.id,
    this.dateTime,
    this.partyId,
    this.billedItem,
    this.discount,
    this.tax,
    this.recieved,
    this.paymentType,
    this.discription,
    this.image,
  });
  double get totalAmount {
    double totalAmount = 0;
    this.billedItem.forEach((element) {
      totalAmount = totalAmount + (element.qty * element.rate);
    });
    totalAmount = totalAmount - totalAmount*(this.discount/100); //discount
    totalAmount = totalAmount + totalAmount*(this.tax/100); //tax
    return totalAmount;
  }

  double get balance {
    double totalAmount = 0;
    this.billedItem.forEach((element) {
      totalAmount = totalAmount + (element.qty * element.rate);
    });
    return totalAmount - (recieved + ((discount / 100) * totalAmount));
  }

  String get paidStatus {
    if (balance == 0) {
      return 'PAID';
    } else {
      return 'UNPAID';
    }
  }

  String partyName(List<PartyItem> partyItems) {
    return partyItems
        .where((element) => element.id == this.partyId)
        .elementAt(0)
        .name;
  }
  String partyAddress(List<PartyItem> partyItems) {
    return partyItems
        .where((element) => element.id == this.partyId)
        .elementAt(0)
        .address;
  }
  String partyPhoneNumber(List<PartyItem> partyItems) {
    return partyItems
        .where((element) => element.id == this.partyId)
        .elementAt(0)
        .phoneNumber;
  }

  double totalStockSaleByProductId(String productId){
    double totalSale=0;
    this.billedItem.where((element) => element.productId == productId).forEach((v) {
      totalSale = totalSale + v.qty;
    });

    return totalSale;
  }

}

class BilledItem {
  String productId;
  double qty;
  String unit;
  double rate;

  BilledItem({this.productId, this.qty, this.unit, this.rate});
  String productName(List<ProductItem> productItems) {
    return productItems
        .where((element) => element.id == this.productId)
        .elementAt(0)
        .itemName;
  }
  

  //void setQty => null;
}

class Images {
  String url;
  Images({this.url});
}

class ProductItem {
  final String id;
  final String itemName;
  final String code;
  final double salePrice;
  final double purchasePrice;
  final double openingStock;
  final String asOfDate;
  final double atPrice;
  final double minStock;
  final String itemLocation;

  ProductItem({
    this.id,
    this.itemName,
    this.code,
    this.salePrice,
    this.purchasePrice,
    this.openingStock,
    this.asOfDate,
    this.atPrice,
    this.minStock,
    this.itemLocation,
  });

  

  double totalStockSale(List<SaleItem> saleItem){
    double result=0;
    saleItem.forEach((element) {
      result = result + element.totalStockSaleByProductId(this.id);
    });
    return result;
  }

  //stockQuantity = openingStock + totalStockPurchase - totalStockSale
  double stockQuantity(List<SaleItem> saleItem){
    return this.openingStock - totalStockSale(saleItem);   
  }

  //stockValue = purchasePrice * stockQuantity
  double stockValue(List<SaleItem> saleItem) {
    return purchasePrice * stockQuantity(saleItem);
  }

  //reservedQty = totalStockSaleOrder
  double reservedQty(List<SaleItem> saleItem) {
    return 0;
  }


  //availableQty = stockQuantity - reservedQty
  double availableQty(List<SaleItem> saleItem) {
    return stockQuantity(saleItem) - reservedQty(saleItem);
  }



  
}

class SaleOrder {
  double get totalQty => null;
}

class Purchase {
  double get totalQty => null;
}

class StockItemListData {
  final ProductItem productItem;
  final List<SaleOrder> saleOrder;
  final List<SaleItem> saleItem;
  final Purchase purchase;
  StockItemListData({this.productItem, this.saleOrder, this.purchase, this.saleItem});

  double totalStockSale(List<SaleItem> saleItem){
    double result=0;
    saleItem.forEach((element) {
      result = result + element.totalStockSaleByProductId(productItem.id);
    });
    return result;
  }

  //stockQuantity = openingStock + totalStockPurchase - totalStockSale
  double get stockQuantity{
    return productItem.openingStock - totalStockSale(saleItem);   
  }

  double get stockValue {
    return productItem.purchasePrice * productItem.openingStock;
  }

  // double get stockQuantity {
  //   return productItem.openingStock + saleOrder.totalQty + purchase.totalQty;
  // }

  // double get stockAvailable {
  //   return productItem.openingStock - saleOrder.totalQty + purchase.totalQty;
  // }
}
