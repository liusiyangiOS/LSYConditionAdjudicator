//
//  LSYConditionAdjudicator.m
//  LSYConditionAdjudicatorDemo
//
//  Created by liusiyang on 2023/12/1.
//

#import "LSYConditionAdjudicator.h"
#import "LSYConditionOperator.h"

@interface LSYOperateNode : NSObject

//节点值
@property (strong, nonatomic) id value;
//左子树
@property (strong, nonatomic) id left;
//右子树
@property (strong, nonatomic) id right;

@end

@implementation LSYOperateNode

@end

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
    if (array.count == 1) {
        id result = [self parseOperand:array.firstObject withTarget:target context:context];
        if ([result isKindOfClass:NSNumber.class] ||
            [result isKindOfClass:NSString.class]) {
            return [result boolValue];
        }
        //表达式错误
        *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"表达式错误,非有效的表达式",
        }];
        return NO;
    }
    LSYOperateNode *tree = [self operateTreeWithPostfixExpressionArray:array error:error];
    if (!tree) {
        return NO;
    }
    return [self calculateNode:tree withTarget:target context:context error:error];
}

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

/* 生成二叉树 */
+ (LSYOperateNode *)operateTreeWithPostfixExpressionArray:(NSArray *)array error:(NSError **)error{
    if (array.count < 3) {
        //表达式错误
        *error = [NSError errorWithDomain:@"com.lsy.PostfixExpression" code:-1 userInfo:@{
            NSLocalizedDescriptionKey:@"表达式错误,非有效的表达式",
        }];
        return nil;
    }
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
                return nil;
            }
            LSYOperateNode *node = [[LSYOperateNode alloc] init];
            node.value = item;
            //取出右运算符
            node.right = stack.lastObject;
            [stack removeLastObject];
            //取出左运算符
            node.left = stack.lastObject;
            [stack removeLastObject];

            [stack addObject:node];
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
        return nil;
    }
    return stack.lastObject;
}

+ (BOOL)calculateNode:(LSYOperateNode *)node withTarget:(id)target context:(NSDictionary *)context error:(NSError **)error{
    id<LSYConditionOperator> operator = [[self operatorMap] objectForKey:node.value];
    id leftOperand = nil;
    if ([node.left isKindOfClass:LSYOperateNode.class]) {
        leftOperand = @([self calculateNode:node.left withTarget:target context:context error:error]);
    }else{
        //解析左运算符
        leftOperand = [self parseOperand:node.left withTarget:target context:context];
        //转化左运算符的类型
        if ([operator respondsToSelector:@selector(leftOperandType)]) {
            leftOperand = [self transformOperand:leftOperand withType:[operator leftOperandType] operatorStr:node.value isLeftOperand:YES error:error];
        }
    }
    if (*error) {
        return NO;
    }

    if ([node.value isEqualToString:@"&&"]) {
        if (![leftOperand boolValue]) {
            return NO;
        }
    }else if ([node.value isEqualToString:@"||"]){
        if ([leftOperand boolValue]) {
            return YES;
        }
    }
    
    id rightOperand = nil;
    if ([node.right isKindOfClass:LSYOperateNode.class]) {
        rightOperand = @([self calculateNode:node.right withTarget:target context:context error:error]);
    }else{
        //解析右运算符
        rightOperand = [self parseOperand:node.right withTarget:target context:context];
        //转化右运算符的类型
        if ([operator respondsToSelector:@selector(rightOperandType)]) {
            rightOperand = [self transformOperand:rightOperand withType:[operator rightOperandType] operatorStr:node.value isLeftOperand:NO error:error];
        }
    }
    if (*error) {
        return NO;
    }
    
    if ([node.value isEqualToString:@"&&"] ||
        [node.value isEqualToString:@"||"]) {
        return [rightOperand boolValue];
    }
    
    BOOL result = [operator calculateWithLeftOperand:leftOperand rightOperand:rightOperand error:error];
//    NSLog(@"Origin left operand: %@ \n",node.left);
//    NSLog(@"Origin right operand: %@ \n",node.right);
//    NSLog(@"-> %@ %@ %@ = %d \n=======",leftOperand,node.value,rightOperand,result);
    if (*error) {
        return NO;
    }
    return result;
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
