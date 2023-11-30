//
//  LSYConditionAdjudicator.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/21.
//

#import "LSYConditionAdjudicator.h"
#import "LSYConditionOperator.h"

@implementation LSYConditionAdjudicator

+ (BOOL)calculateWithExpressionString:(NSString *)expressionString
                               target:(id)target
                              context:(NSDictionary *)context
                                error:(NSError **)error{
    NSArray *conditionArray = [self postfixExpressionArrayWithString:expressionString error:error];
    if (*error) {
        return NO;
    }
    return [self calculateWithPostfixExpressionArray:conditionArray target:target context:context error:error];
}

#pragma mark - private method

+ (NSDictionary<NSString *,id<LSYConditionOperator>> *)operatorMap{
    static NSDictionary *operatorMap = nil;
    if (!operatorMap) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"OperatorMap" ofType:@"plist"];
        NSDictionary *originMap = [NSDictionary dictionaryWithContentsOfFile:path];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:originMap.count];
        for (NSString *operatorStr in originMap.allKeys) {
            id<LSYConditionOperator> operator = [NSClassFromString(originMap[operatorStr]) new];
            [dic setObject:operator forKey:operatorStr];
        }
        operatorMap = dic.copy;
    }
    return operatorMap;
}

+ (NSArray *)postfixExpressionArrayWithString:(NSString *)expressionString error:(NSError **)error{
    NSMutableArray *array = [expressionString componentsSeparatedByString:@" "].mutableCopy;
    //如果表达式不规范,连续输入多个空格,可能会出现空字符串
    for (int i = (int)array.count - 1; i >= 0; i--) {
        if ([array[i] isEqualToString:@""]) {
            [array removeObjectAtIndex:i];
        }
    }
    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:array.count];
    NSMutableArray *stack = [NSMutableArray arrayWithCapacity:array.count / 2];
    for (int i = 0; i < array.count; i++) {
        NSString *item = array[i];
        if (![item isKindOfClass:NSString.class]) {
            //表达式格式错误
            *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                NSLocalizedDescriptionKey:@"表达式错误,表达式数组中的元素只能是字符串类型",
            }];
            return nil;
        }
        if ([item isEqualToString:@"("]) {
            //遇到左括号入栈
            [stack addObject:item];
        }else if ([item isEqualToString:@")"]){
            //遇到右括号,弹出栈顶元素到后缀表达式中,直到匹配到第一个左括号,括号不输出到后缀表达式
            while (YES) {
                if (stack.count == 0) {
                    //括号无法配对,表达式格式错误
                    *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                        NSLocalizedDescriptionKey:@"表达式错误,括号无法配对",
                    }];
                    return nil;
                }
                NSString *topElement = stack.lastObject;
                [stack removeLastObject];
                if ([topElement isEqualToString:@"("]) {
                    break;
                }else{
                    [finalArray addObject:topElement];
                }
            }
        }else if ([[self operatorMap].allKeys containsObject:item]){
            //遇到运算符,弹出所有优先级大于或者等于该运算符的辅助栈顶元素到后缀表达式中,然后将该运算符入栈
            while (YES) {
                if (stack.count == 0) {
                    [stack addObject:item];
                    break;
                }
                NSString *topElement = stack.lastObject;
                if (![topElement isEqualToString:@"("] && [[[self operatorMap] objectForKey:topElement] priority] >= [[[self operatorMap] objectForKey:item] priority]) {
                    [stack removeLastObject];
                    [finalArray addObject:topElement];
                }else{
                    [stack addObject:item];
                    break;
                }
            }
        }else{
            //遇到数字直接添加到后缀表达式末尾
            [finalArray addObject:item];
        }
    }
    //遍历完成后,将辅助栈中的元素依次pop,添加到后缀表达式中
    for (int i = (int)stack.count - 1; i >= 0; i--) {
        [finalArray addObject:stack[i]];
    }
    return finalArray.copy;
}

+ (BOOL)calculateWithPostfixExpressionArray:(NSArray *)array
                                     target:(id)target
                                    context:(NSDictionary *)context
                                      error:(NSError **)error{
    NSMutableArray *stack = [NSMutableArray arrayWithCapacity:array.count / 2];
    for (int i = 0; i < array.count; i++) {
        NSString *item = array[i];
        if ([[self operatorMap].allKeys containsObject:item]) {
            //遇到操作符则从栈顶取出两个元素,第一个为右运算数,第二个为左运算数,运算后的结果入栈
            if (stack.count < 2) {
                //表达式错误
                *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                    NSLocalizedDescriptionKey:@"表达式错误,缺少运算数",
                }];
                return NO;
            }
            //取出右运算符
            id rightOperand = stack.lastObject;
            [stack removeLastObject];
            NSLog(@"Origin right operand: %@ \n",rightOperand);
            //解析右运算符
            rightOperand = [self parseOperand:rightOperand withTarget:target context:context];
            id<LSYConditionOperator> operator = [[self operatorMap] objectForKey:item];
            //转化右运算符的类型
            if ([operator respondsToSelector:@selector(rightOperandType)]) {
                rightOperand = [self transformOperand:rightOperand withType:[operator rightOperandType] operatorStr:item isLeftOperand:NO error:error];
                if (*error) {
                    return NO;
                }
            }
            
            //取出左运算符
            id leftOperand = stack.lastObject;
            [stack removeLastObject];
            NSLog(@"Origin left operand: %@ \n",leftOperand);
            //解析左运算符
            leftOperand = [self parseOperand:leftOperand withTarget:target context:context];
            //转化左运算符的类型
            if ([operator respondsToSelector:@selector(leftOperandType)]) {
                leftOperand = [self transformOperand:leftOperand withType:[operator leftOperandType] operatorStr:item isLeftOperand:YES error:error];
                if (*error) {
                    return NO;
                }
            }
            
            BOOL result = [operator calculateWithLeftOperand:leftOperand rightOperand:rightOperand error:error];
            NSLog(@"-> %@ %@ %@ = %d \n=======",leftOperand,item,rightOperand,result);
            if (*error) {
                return NO;
            }
            [stack addObject:@(result)];
        }else{
            //遇到操作数压入栈中
            [stack addObject:item];
        }
    }
    if (stack.count != 1) {
        //表达式错误
        *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"表达式错误,缺少运算符",
        }];
        return NO;
    }
    if (![stack.lastObject isKindOfClass:NSNumber.class]) {
        //表达式错误
        *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"表达式错误,运算结果不是bool类型",
        }];
        return NO;
    }
    return [stack.lastObject boolValue];
}

//解析运算符
+ (id)parseOperand:(id)operand withTarget:(id)target context:(NSDictionary *)context{
    if ([operand isKindOfClass:NSString.class]) {
        if ([operand isEqualToString:@"${null}"]) {
            return nil;
        }else if ([operand hasPrefix:@"$var{"]){
            operand = [operand stringByReplacingOccurrencesOfString:@"$var{" withString:@""];
            operand = [operand stringByReplacingOccurrencesOfString:@"}" withString:@""];
            id result = [target valueForKeyPath:operand];
            if ([result isKindOfClass:NSNull.class]) {
                return nil;
            }
            return result;
        }else if ([operand hasPrefix:@"$context{"]){
            operand = [operand stringByReplacingOccurrencesOfString:@"$context{" withString:@""];
            operand = [operand stringByReplacingOccurrencesOfString:@"}" withString:@""];
            id result = [context objectForKey:operand];
            if ([result isKindOfClass:NSNull.class]) {
                return nil;
            }
            return result;
        }
        operand = [operand stringByReplacingOccurrencesOfString:@"$space{}" withString:@" "];
        if ([operand hasPrefix:@"$s{"]){
            operand = [operand substringWithRange:NSMakeRange(3, [operand length] - 4)];
        }
        return operand;
    }
    //不是string的话,只能是之前计算的结果,直接返回
    return operand;
}

+ (id)transformOperand:(id)operand
              withType:(LSYConditionOperandType)type
           operatorStr:(NSString *)operatorStr
         isLeftOperand:(BOOL)isLeft
                 error:(NSError **)error{
    switch (type) {
        case LSYConditionOperandTypeNumber:{
            if ([operand isKindOfClass:NSNumber.class]) {
                return operand;
            }else if ([operand isKindOfClass:NSString.class]) {
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                operand = [formatter numberFromString:operand];
                if (operand) {
                    return operand;
                }
            }
            //表达式错误
            *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                NSLocalizedDescriptionKey:[NSString stringWithFormat:@"表达式错误,%@运算%@参数必须是数字",operatorStr,isLeft?@"左":@"右"],
            }];
            return nil;
        }
        case LSYConditionOperandTypeString:{
            if (![operand isKindOfClass:NSString.class]) {
                //表达式错误
                *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
                    NSLocalizedDescriptionKey:[NSString stringWithFormat:@"表达式错误,%@运算%@参数必须是string类型",operatorStr,isLeft?@"左":@"右"],
                }];
                return nil;
            }
            return operand;
        }
        default:
            //默认不转化
            return operand;
    }
}

@end
