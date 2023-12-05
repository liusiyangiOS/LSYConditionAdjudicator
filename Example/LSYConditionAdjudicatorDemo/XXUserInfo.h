//
//  XXUserInfo.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XXUserInfo : NSObject

@property (copy, nonatomic) NSString *scene;
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSDictionary *extraInfo;
@property (assign, nonatomic) long udid;
@property (assign, nonatomic) long vipLevel;

@end

NS_ASSUME_NONNULL_END
