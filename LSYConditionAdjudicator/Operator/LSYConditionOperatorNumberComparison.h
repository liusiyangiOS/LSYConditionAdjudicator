//
//  LSYConditionOperatorNumberComparison.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import <Foundation/Foundation.h>
#import "LSYConditionOperator.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSYConditionOperatorGreaterThan : NSObject <LSYConditionOperator>

@end

@interface LSYConditionOperatorLessThan : NSObject <LSYConditionOperator>

@end

@interface LSYConditionOperatorNotGreaterThan : NSObject <LSYConditionOperator>

@end

@interface LSYConditionOperatorNotLessThan : NSObject <LSYConditionOperator>

@end

NS_ASSUME_NONNULL_END
