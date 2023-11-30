//
//  LSYConditionOperatorOr.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/25.
//

#import "LSYConditionOperatorOr.h"

@implementation LSYConditionOperatorOr

- (NSString *)operatorString{
    return @"||";
}

- (int)priority{
    return 0;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeNumber;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand boolValue] || [rightOperand boolValue];
}

@end
