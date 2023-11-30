//
//  LSYConditionOperator.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/24.
//

/** 运算数类型 */
typedef NS_ENUM(NSUInteger, LSYConditionOperandType) {
    /* 没有固定类型/可能是多种类型 */
    LSYConditionOperandTypeNone   = 0,
    /* 数字类型 */
    LSYConditionOperandTypeNumber = 1,
    /* 字符串类型 */
    LSYConditionOperandTypeString = 2
};

@protocol LSYConditionOperator <NSObject>

/* 运算符字符串 */
- (NSString *)operatorString;

/* 优先级 */
- (int)priority;

- (BOOL)calculateWithLeftOperand:(id)leftOperand rightOperand:(id)rightOperand error:(NSError **)error;

@optional
/** 左运算符类型 */
- (LSYConditionOperandType)leftOperandType;

/** 右运算符类型 */
- (LSYConditionOperandType)rightOperandType;

@end
