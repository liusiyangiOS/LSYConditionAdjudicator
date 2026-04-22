# LSYConditionAdjudicator
[中文文档](./README_CN.md)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/language-Objective--C-orange.svg)](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

A lightweight, extensible expression evaluation engine for iOS based on postfix expression (Reverse Polish Notation) and binary tree algorithms. It enables dynamic condition evaluation with support for variable binding, context injection, and custom operators.

## Features

- ✅ **Postfix Expression Parsing**: Converts infix expressions to postfix notation using the Shunting Yard algorithm
- ✅ **Binary Tree Evaluation**: Constructs and evaluates expression trees for optimal calculation
- ✅ **Dynamic Variable Binding**: Supports KeyPath-based variable resolution from target objects
- ✅ **Context Injection**: Allows passing external parameters through context dictionary
- ✅ **Extensible Operator System**: Easy to add custom operators through protocol conformance
- ✅ **Short-circuit Evaluation**: Optimizes logical operations (&&, ||) to avoid unnecessary calculations
- ✅ **Type Safety**: Automatic type checking and conversion with clear error messages
- ✅ **Rich Built-in Operators**: Supports comparison, logical, string, and collection operators


## Supported Operators

| Category | Operators | Priority | Description |
|----------|-----------|----------|-------------|
| Logical | `&&`, `||` | 1 | Logical AND, OR with short-circuit |
| Comparison | `==`, `!=` | 3 | Equality and inequality |
| Numeric | `>`, `<`, `>=`, `<=` | 3 | Numeric comparison |
| String | `startWith`, `endWith`, `isEqualToString` | 3 | String pattern matching |
| Collection | `in`, `notIn` | 3 | Membership testing |
| Grouping | `(`, `)` | - | Expression grouping |

## Expression Syntax

### Basic Rules

1. **Spacing**: Operators and operands must be separated by spaces
2. **Variable Binding**: Use `$var{keyPath}` to access properties from target object
3. **Context Access**: Use `$context{key}` to retrieve values from context dictionary
4. **Null Handling**: Use `${null}` to represent null/nil values
5. **String Escaping**:
   - Use `$s{text}` to escape operators as strings (e.g., `$s{in}` represents the string "in")
   - Use `$space{}` to represent spaces within operands

### Expression Examples

```objc
// Simple comparison
"$var{age} > 18"

// Logical combination
"$var{name} == Tom && $var{age} >= 18"

// String operations
"$var{scene} startWith scene_ && $var{mode} isEqualToString normal$space{}mode"

// Collection membership
"$var{userId} in 100,200,300"

// Context usage
"$context{source} == homepage && $var{vipLevel} > 1"

// Complex nested expression
"( ( $var{name} == Tom && $var{age} > 20 ) || ( $var{userId} in 574,577 && $var{vipLevel} notIn 1,3 ) ) && $var{scene} != ${null}"
```

## Usage

### Basic Usage

```objc
#import "LSYConditionAdjudicator.h"

// Create your data model
YourModel *model = [[YourModel alloc] init];
model.age = 25;
model.name = @"Tom";
model.vipLevel = 2;

// Prepare context (optional)
NSDictionary *context = @{
    @"source": @"homepage",
    @"platform": @"iOS"
};

// Define expression
NSString *expression = @"$var{name} == Tom && $var{age} > 18 && $context{source} == homepage";

// Evaluate expression
NSError *error = nil;
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:model
                                                            context:context
                                                              error:&error];

if (error) {
    NSLog(@"Error: %@", error.localizedDescription);
} else {
    NSLog(@"Result: %@", result ? @"YES" : @"NO");
}
```

### Nested Object Access

```objc
// Model structure
@interface UserInfo : NSObject
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSDictionary *extraInfo;
@end

@interface AccountInfo : NSObject
@property (nonatomic, strong) UserInfo *userInfo;
@end

// Usage
AccountInfo *account = [[AccountInfo alloc] init];
account.userInfo.userId = 12345;
account.userInfo.extraInfo = @{@"unreadCount": @(10)};

NSString *expression = @"$var{userInfo.userId} > 10000 && $var{userInfo.extraInfo.unreadCount} < 100";

BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:account
                                                            context:nil
                                                              error:nil];
```

### Error Handling

```objc
NSError *error = nil;
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:target
                                                            context:context
                                                              error:&error];

if (error) {
    // Common error types:
    // - Expression format errors (unmatched parentheses)
    // - Type mismatch (using string in numeric comparison)
    // - Missing operands or operators
    // - Invalid variable paths
    NSLog(@"Evaluation failed: %@", error.localizedDescription);
}
```

## Adding Custom Operators

### Step 1: Implement the Operator Protocol

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
    return 3; // Same priority as comparison operators
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
                                 userInfo:@{NSLocalizedDescriptionKey: @"Both operands must be strings"}];
        return NO;
    }
    return [leftOperand containsString:rightOperand];
}

@end
```

### Step 2: Register in OperatorMap.plist

```xml
<key>contains</key>
<string>CustomContainsOperator</string>
```

### Step 3: Use Your Custom Operator

```objc
NSString *expression = @"$var{email} contains @gmail.com";
BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:expression
                                                             target:user
                                                            context:nil
                                                              error:nil];
```

## Architecture Highlights

### Core Algorithm: Shunting Yard + Binary Tree

1. **Infix to Postfix Conversion**: Uses the Shunting Yard algorithm to convert expressions like `a && ( b || c )` into postfix notation `a b c || &&`
2. **Tree Construction**: Builds a binary expression tree from postfix notation
3. **Recursive Evaluation**: Traverses the tree recursively to compute the final result

### Design Principles Applied

- **Single Responsibility Principle (SRP)**: Each operator class handles only one specific operation
- **Open/Closed Principle (OCP)**: Extensible through new operator classes without modifying core engine
- **Liskov Substitution Principle (LSP)**: All operator implementations are interchangeable through the protocol
- **Interface Segregation Principle (ISP)**: Optional protocol methods for type specification
- **Dependency Inversion Principle (DIP)**: Core engine depends on operator protocol abstraction, not concrete implementations

### Performance Optimizations

- **Short-circuit Evaluation**: `&&` and `||` operators skip unnecessary evaluations
- **Lazy Parsing**: Variables are resolved only when needed during evaluation
- **Static Operator Map**: Operator registry is cached as singleton

## Real-world Use Cases

- **A/B Testing**: Dynamic feature flag evaluation based on user attributes
- **Access Control**: Complex permission checks with multiple conditions
- **Business Rules Engine**: Server-driven business logic without app updates
- **Smart Recommendation**: User targeting based on behavioral and profile data
- **Dynamic UI**: Show/hide UI elements based on runtime conditions

## Requirements

- iOS 8.0+
- Xcode 8.0+
- Objective-C

## License

LSYConditionAdjudicator is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.

## Blogs

- [Author's Blog](https://www.jianshu.com/u/e1fee33c72bc)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
