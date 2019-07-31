//
//  GGBuy.m
//  In-App OC
//
//  Created by 光光 on 7/31/19.
//  Copyright © 2019 feilei. All rights reserved.
//

#import "GGBuy.h"
static GGBuy *serviceBuy = nil;
@implementation GGBuy
+ (instancetype)buy {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serviceBuy = [[GGBuy alloc] init];
    });
    return serviceBuy;
}

- (void)startBuyInnerProduct:(NSString *)type {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self localRequest:type];
}

- (void)localRequest:(NSString *)type {
    if (SKPaymentQueue.canMakePayments) {
        NSSet *set = [NSSet setWithArray:[NSArray arrayWithObject:type]];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
    }else {
        NSLog(@"禁止购买");
    }
}

//恢复购买
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"错误恢复 code: %@",error);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSMutableArray *array = [NSMutableArray array];
    NSLog(@"received restored transactions: %lu",(unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *pay in queue.transactions) {
        NSString *productID = pay.payment.productIdentifier;
        [array addObject:productID];
        NSLog(@"message-> %@",array);
    }
    
}

- (void)replyToBuy {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

//代理: 交易信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *pro = response.products;
    if (pro.count > 0) {
        SKProduct *product;
        for (SKProduct *pid in pro) {
            NSLog(@"描述信息-> %@",pid.description);
            NSLog(@"产品标题-> %@; 产品描述-> %@",pid.localizedTitle,pid.localizedDescription);
            NSLog(@"价格-> %@",pid.price);
            product = pid;
        }
        [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:(SKProduct *)product]];
    }else {
        NSLog(@"无法获得商品");
    }
    
}
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"处理交易请求完成");
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"处理交易请求失败");
}

//代理: 交易监听
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                //交易完成
                [self paymentTransactionPurchased];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                //交易中
                [self paymentTransactionPurchasing];
                break;
            case SKPaymentTransactionStateRestored:
                //已经购买过
                [self paymentTransactionRestored];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed:
                //交易失败
                [self paymentTransactionFailed:tran];
                break;
            default:
                break;
        }
    }
}
- (void)paymentTransactionPurchased {
    NSURL *receiptUrl = NSBundle.mainBundle.appStoreReceiptURL;
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    if (!receiptData) {
        return;
    }
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"订单信息-> %@",receiptStr);
    //验证购买
    [self verify_IapCode:receiptStr];
}
- (void)paymentTransactionPurchasing {
    NSLog(@"交易中");
}
- (void)paymentTransactionRestored {
    NSLog(@"已经过买过");
}
- (void)paymentTransactionFailed:(SKPaymentTransaction *)transaction {
    NSError *error = transaction.error;
    if (error) {
        if (error.code != SKErrorPaymentCancelled) {
            NSLog(@"交易失败");
        }else {
            NSLog(@"交易取消");
        }
    }else {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (void)verify_IapCode:(NSString *)code {
    NSLog(@"开始验证购买...");
    
}


@end
