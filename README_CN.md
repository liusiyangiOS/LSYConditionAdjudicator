# LSYConditionAdjudicator
[English Document](./README.md)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/language-Objective--C-orange.svg)](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

一个轻量级、可扩展的 iOS 表达式求值引擎,基于后序表达式(逆波兰表示法)和二叉树算法实现。支持动态条件求值、变量绑定、上下文注入和自定义运算符。

## 特性

- ✅ **后序表达式解析**: 使用调度场算法将中缀表达式转换为后序表达式
- ✅ **二叉树求值**: 构建并遍历表达式树以优化计算过程
- ✅ **动态变量绑定**: 支持基于 KeyPath 的变量解析
- ✅ **上下文注入**: 允许通过上下文字典传递外部参数
- ✅ **可扩展运算符系统**: 通过协议实现轻松添加自定义运算符
- ✅ **短路求值**: 优化逻辑运算(&&, ||)避免不必要的计算
- ✅ **类型安全**: 自动类型检查和转换,提供清晰的错误信息
- ✅ **丰富的内置运算符**: 支持比较、逻辑、字符串和集合运算符


## 支持的运算符

| 类别 | 运算符 | 优先级 | 说明 |
|------|--------|--------|------|
| 逻辑运算 | `&&`, `||` | 1 | 逻辑与、或,支持短路求值 |
| 相等比较 | `==`, `!=` | 3 | 相等和不相等判断 |
| 数值比较 | `>`, `<`, `>=`, `<=` | 3 | 数值大小比较 |
| 字符串运算 | `startWith`, `endWith`, `isEqualToString` | 3 | 字符串模式匹配 |
| 集合运算 | `in`, `notIn` | 3 | 成员关系判断 |
| 分组 | `(`, `)` | - | 表达式分组 |

## 表达式语法

### 基本规则

1. **空格分隔**: 运算符和运算数之间必须用空格分开
2. **变量绑定**: 使用 `$var{keyPath}` 访问目标对象的属性
3. **上下文访问**: 使用 `$context{key}` 从上下文字典中获取值
4. **空值处理**: 使用 `${null}` 表示空值/nil
5. **字符串转义**:
   - 使用 `$s{text}` 将运算符转义为字符串(例如 `$s{in}` 表示字符串 "in")
   - 使用 `$space{}` 表示运算数中的空格

### 表达式示例

```objc
// 简单比较
"$var{age} > 18"

// 逻辑组合
"$var{name} == Tom && $var{age} >= 18"

// 字符串操作
"$var{scene} startWith scene_ && $var{mode} isEqualToString normal$space{}mode"

// 集合成员判断
"$var{userId} in 100,200,300"

// 上下文使用
"$context{source} == homepage && $var{vipLevel} > 1"

// 复杂嵌套表达式
"( ( $var{name} == Tom && $var{age} > 20 ) || ( $var{userId} in 574,577 && $var{vipLevel} notIn 1,3 ) ) && $var{scene} != ${null}"
```

## 使用方法

### 基本用法

```objc
#import "LSYConditionAdjudicator.h"

// 创建数据模型
YourModel *model = [[YourModel alloc] init];
model.age = 25;
model.name = @"Tom";
model.vipLevel = 2;

// 准备上下文(可选)
NSDictionary *context = @{
    @"source": @"homepage",
    @"platform": @"iOS"
};

// 定义表达式
NSString *expression = @"$var{name} == Tom && $var{age} > 18 && $context{source} == homepage";

// 求值
NSError *error = nil;
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:model
                                                            context:context
                                                              error:&error];

if (error) {
    NSLog(@"错误: %@", error.localizedDescription);
} else {
    NSLog(@"结果: %@", result ? @"YES" : @"NO");
}
```

### 嵌套对象访问

```objc
// 模型结构
@interface UserInfo : NSObject
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSDictionary *extraInfo;
@end

@interface AccountInfo : NSObject
@property (nonatomic, strong) UserInfo *userInfo;
@end

// 使用示例
AccountInfo *account = [[AccountInfo alloc] init];
account.userInfo.userId = 12345;
account.userInfo.extraInfo = @{@"unreadCount": @(10)};

NSString *expression = @"$var{userInfo.userId} > 10000 && $var{userInfo.extraInfo.unreadCount} < 100";

BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:account
                                                            context:nil
                                                              error:nil];
```

### 错误处理

```objc
NSError *error = nil;
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:target
                                                            context:context
                                                              error:&error];

if (error) {
    // 常见错误类型:
    // - 表达式格式错误(括号不匹配)
    // - 类型不匹配(在数值比较中使用字符串)
    // - 缺少运算数或运算符
    // - 无效的变量路径
    NSLog(@"求值失败: %@", error.localizedDescription);
}
```

## 添加自定义运算符

### 步骤1: 实现运算符协议

```objc
// CustomOperator.h
#import "LSYConditionOperator.h"

@interface CustomContainsOperator : NSObject <LSYConditionOperator>
@end

// CustomOperator.m
@implementation CustomContainsOperator

- (NSString *)operatorString {
    return @"contains";
}

- (int)priority {
    return 3; // 与比较运算符相同的优先级
}

- (LSYConditionOperandType)leftOperandType {
    return LSYConditionOperandTypeString;
}

- (LSYConditionOperandType)rightOperandType {
    return LSYConditionOperandTypeString;
}

- (BOOL)calculateWithLeftOperand:(id)leftOperand 
                   rightOperand:(id)rightOperand 
                          error:(NSError **)error {
    if (![leftOperand isKindOfClass:[NSString class]] || 
        ![rightOperand isKindOfClass:[NSString class]]) {
        *error = [NSError errorWithDomain:@"com.lsy.CustomOperator" 
                                     code:-1 
                                 userInfo:@{NSLocalizedDescriptionKey: @"两个运算数都必须是字符串"}];
        return NO;
    }
    return [leftOperand containsString:rightOperand];
}

@end
```

### 步骤2: 在 OperatorMap.plist 中注册

```xml
<key>contains</key>
<string>CustomContainsOperator</string>
```

### 步骤3: 使用自定义运算符

```objc
NSString *expression = @"$var{email} contains @gmail.com";
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:user
                                                            context:nil
                                                              error:nil];
```

## 架构亮点

### 核心算法: 调度场算法 + 二叉树

1. **中缀转后序**: 使用调度场算法将 `a && ( b || c )` 转换为后序表达式 `a b c || &&`
2. **构建树**: 从后序表达式构建二叉表达式树
3. **递归求值**: 递归遍历树来计算最终结果

### 设计原则应用

- **单一职责原则(SRP)**: 每个运算符类只处理一个特定操作
- **开放封闭原则(OCP)**: 通过新增运算符类扩展功能,无需修改核心引擎
- **里氏替换原则(LSP)**: 所有运算符实现可通过协议互相替换
- **接口隔离原则(ISP)**: 协议中的可选方法用于类型指定
- **依赖倒置原则(DIP)**: 核心引擎依赖运算符协议抽象,而非具体实现

### 性能优化

- **短路求值**: `&&` 和 `||` 运算符跳过不必要的求值
- **懒加载解析**: 变量仅在求值时才解析
- **静态运算符映射**: 运算符注册表采用单例缓存

## 实际应用场景

- **A/B 测试**: 基于用户属性的动态功能开关
- **权限控制**: 多条件复杂权限检查
- **业务规则引擎**: 服务端驱动的业务逻辑,无需更新应用
- **智能推荐**: 基于行为和档案数据的用户定向
- **动态 UI**: 根据运行时条件显示/隐藏 UI 元素

## 系统要求

- iOS 8.0+
- Xcode 8.0+
- Objective-C

## 许可证

LSYConditionAdjudicator 基于 MIT 许可证开源。详见 [LICENSE](./LICENSE) 文件。

## 相关博客

- [作者博客](https://www.jianshu.com/u/e1fee33c72bc)

## 贡献

欢迎贡献代码!请随时提交 Pull Request。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request
