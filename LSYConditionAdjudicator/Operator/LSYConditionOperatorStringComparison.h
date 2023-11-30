//
//  LSYConditionOperatorStringComparison.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import <Foundation/Foundation.h>
#import "LSYConditionOperator.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSYConditionOperatorStartWith : NSObject <LSYConditionOperator>

@end

@interface LSYConditionOperatorEndWith : NSObject <LSYConditionOperator>

@end

@interface LSYConditionOperatorEqualToString : NSObject <LSYConditionOperator>

@end

NS_ASSUME_NONNULL_END
