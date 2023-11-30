//
//  Refer.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/25.
//

#import <Foundation/Foundation.h>
#import "Invitation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Refer : NSObject

@property (strong, nonatomic) Invitation *invitation;

@property (strong, nonatomic) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END
