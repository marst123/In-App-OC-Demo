//
//  GGBuy.h
//  In-App OC
//
//  Created by 光光 on 7/31/19.
//  Copyright © 2019 feilei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GGBuy : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
+ (instancetype)buy;
//启动内购
- (void)startBuyInnerProduct:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
