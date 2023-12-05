//
//  Refer.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/25.
//

#import <Foundation/Foundation.h>
#import "XXUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface XXAccountInfo : NSObject

@property (strong, nonatomic) XXUserInfo *userInfo;

@property (strong, nonatomic) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
