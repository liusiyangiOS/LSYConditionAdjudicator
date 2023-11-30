//
//  LSYConditionOperatorInOrNot.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/10.
//

#import "LSYConditionOperatorInOrNot.h"

@implementation LSYConditionOperatorIn

- (NSString *)operatorString{
    return @"in";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    NSArray<NSString *> *components = [rightOperand componentsSeparatedByString:@","];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    for (NSString *item in components) {
        NSNumber *itemNum = [formatter numberFromString:item];
        if (!itemNum) {
            //表达式错误
            *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                NSLocalizedDescriptionKey:@"表达式错误,in运算右参数存在非数字项",
            }];
            return NO;
        }
        if ([leftOperand isEqualToNumber:itemNum]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation LSYConditionOperatorNotIn

- (NSString *)operatorString{
    return @"notIn";
}

- (int)priority{
    return 3;
}

-(LSYConditionOperandType)leftOperandType{
    return LSYConditionOperandTypeNumber;
}

-(LSYConditionOperandType)rightOperandType{
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error{
    NSArray<NSString *> *components = [rightOperand componentsSeparatedByString:@","];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    for (NSString *item in components) {
        NSNumber *itemNum = [formatter numberFromString:item];
        if (!itemNum) {
            //表达式错误
            *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                NSLocalizedDescriptionKey:@"表达式错误,notIn运算右参数存在非数字项",
            }];
            return NO;
        }
        if ([leftOperand isEqualToNumber:itemNum]) {
            return NO;
        }
    }
    return YES;
}

@end
