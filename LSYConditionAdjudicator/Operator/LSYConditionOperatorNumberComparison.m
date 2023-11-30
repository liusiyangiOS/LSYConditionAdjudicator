//
//  LSYConditionOperatorNumberComparison.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import "LSYConditionOperatorNumberComparison.h"

@implementation LSYConditionOperatorGreaterThan

- (NSString *)operatorString{
    return @">";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeNumber;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand compare:rightOperand] == NSOrderedDescending;
}

@end

@implementation LSYConditionOperatorLessThan

- (NSString *)operatorString{
    return @"<";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeNumber;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand compare:rightOperand] == NSOrderedAscending;
}

@end

@implementation LSYConditionOperatorNotGreaterThan

- (NSString *)operatorString{
    return @"<=";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeNumber;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand compare:rightOperand] != NSOrderedDescending;
}

@end

@implementation LSYConditionOperatorNotLessThan

- (NSString *)operatorString{
    return @">=";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeNumber;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    return [leftOperand compare:rightOperand] != NSOrderedAscending;
}

@end
