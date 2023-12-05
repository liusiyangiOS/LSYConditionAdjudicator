//
//  LSYOldConditionAdjudicator.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 说明:
 表达式的运算数和运算符之间需要用空格分开
 默认按照字符串进行解析,如Zhaopin会作为字符串进行运算,如果需要特殊解析,则需要添加标识符
 ${null}代表空
 $var{}代表将大括号内的内容作为keyPath来解析,如$var{info.userId},默认在当前类中寻找变量
 $context{}代表将大括号内的内容作为上下问中的内容来解析,如${friendUid}代表去上下问中找friendUid
 
 如果运算数和运算符一样,则需要用$s{}包一层,如,in代表操作符"in",$s{in}代表in字符串
 运算数中如果有空格,需要用$space{}代替,即,运算数和运算符中不能出现空格
 */
@interface LSYOldConditionAdjudicator : NSObject

/**
 计算后缀表达式的值
 @param expressionString 中缀表达式字符串
 @param target 操作对象,变量类型的keyPath来这里取值
 @param context 上下文,存放一些其他的固定的参数
 @param error 错误信息
 @return 计算结果
 */
+ (BOOL)calculateWithExpressionString:(NSString *)expressionString
                               target:(id)target
                              context:(NSDictionary *)context
                                error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
