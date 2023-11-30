//
//  LSYConditionOperatorEqualOrNot.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import "LSYConditionOperatorEqualOrNot.h"

@implementation LSYConditionOperatorEqual

- (NSString *)operatorString{
    return @"==";
}

- (int)priority{
    return 3;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    if ([leftOperand isKindOfClass:NSString.class]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        NSNumber *result = [formatter numberFromString:leftOperand];
        if (result) {
            leftOperand = result;
        }
    }
    if ([rightOperand isKindOfClass:NSString.class]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        NSNumber *result = [formatter numberFromString:rightOperand];
        if (result) {
            rightOperand = result;
        }
    }
    
    if ([leftOperand isKindOfClass:NSNumber.class] &&
        [rightOperand isKindOfClass:NSNumber.class]) {
        return [leftOperand isEqualToNumber:rightOperand];
    }
    return leftOperand == rightOperand;
}

@end

@implementation LSYConditionOperatorNotEqual

- (NSString *)operatorString{
    return @"!=";
}

- (int)priority{
    return 3;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    if ([leftOperand isKindOfClass:NSString.class]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        NSNumber *result = [formatter numberFromString:leftOperand];
        if (result) {
            leftOperand = result;
        }
    }
    if ([rightOperand isKindOfClass:NSString.class]) {
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        NSNumber *result = [formatter numberFromString:rightOperand];
        if (result) {
            rightOperand = result;
        }
    }
    
    if ([leftOperand isKindOfClass:NSNumber.class] &&
        [rightOperand isKindOfClass:NSNumber.class]) {
        return ![leftOperand isEqualToNumber:rightOperand];
    }
    return leftOperand != rightOperand;
}

@end
