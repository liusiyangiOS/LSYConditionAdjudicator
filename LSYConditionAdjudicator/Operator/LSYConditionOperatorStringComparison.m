//
//  LSYConditionOperatorStringComparison.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import "LSYConditionOperatorStringComparison.h"

@implementation LSYConditionOperatorStartWith

- (NSString *)operatorString{
    return @"startWith";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeString;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand hasPrefix:rightOperand];
}

@end

@implementation LSYConditionOperatorEndWith

- (NSString *)operatorString{
    return @"endWith";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeString;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand hasSuffix:rightOperand];
}

@end

@implementation LSYConditionOperatorEqualToString

- (NSString *)operatorString{
    return @"isEqualToString";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeString;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand isEqualToString:rightOperand];
}

@end
