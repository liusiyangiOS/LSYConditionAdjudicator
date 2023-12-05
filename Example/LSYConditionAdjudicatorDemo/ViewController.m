//
//  ViewController.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/9.
//

#import "ViewController.h"
#import "LSYOldConditionAdjudicator.h"
#import "LSYConditionAdjudicator.h"
#import "XXAccountInfo.h"
#import <YYModel/YYModel.h>

@interface ViewController ()<UITextViewDelegate>{
    //上下文
    NSDictionary *_context;
    XXAccountInfo *_target;
    UITextView *_textView;
    UILabel *_resultLabel;
}

@end

@implementation ViewController

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XXAccountInfo *accountInfo = [XXAccountInfo new];
    accountInfo.params = @{
        @"name":@"Tom",
        @"age":@"18"
    };
    
    XXUserInfo *userInfo = [XXUserInfo new];
    userInfo.udid = 555;
    userInfo.vipLevel = 2;
    userInfo.scene = @"scene_1";
    userInfo.extraInfo = @{
        @"mode":@"normal mode",
        @"favoriteFood":@"",
        @"unreadCount":@(74)
    };
    accountInfo.userInfo = userInfo;
    
    _target = accountInfo;
    _context = @{
        @"TargetUid":@"1111",
        @"source":@"5"
    };
    
    NSString *content = [NSString stringWithFormat:@"AccountInfo:%@\nContext:%@",[[accountInfo yy_modelToJSONObject] description],_context.description];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.frame = CGRectMake(10, 40, UIScreen.mainScreen.bounds.size.width - 20, 420);
    [self.view addSubview:contentLabel];
    contentLabel.text = content;
    
    CGFloat currentY = 460;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.frame = CGRectMake(10, currentY, UIScreen.mainScreen.bounds.size.width - 20, 30);
    [self.view addSubview:titleLabel];
    titleLabel.text = @"请在下方输入表达式:";
    currentY += 30;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, currentY, UIScreen.mainScreen.bounds.size.width - 20, 150)];
    _textView.layer.borderColor = UIColor.blackColor.CGColor;
    _textView.layer.borderWidth = 1;
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.delegate = self;
    _textView.text = @" ( ( $var{params.name} == Tom && $var{params.age} > 20 ) || ( $var{userInfo.udid} in 574,577 && $var{userInfo.vipLevel} notIn 1,3 ) ) && $var{userInfo.scene} startWith scene_ && $var{userInfo.extraInfo.mode} isEqualToString normal$space{}mode && $var{userInfo.udid} != ${null} && $context{TargetUid} isEqualToString 1111";
//    _textView.text = @"$var{mode} == normal$space{}mode && $var{userInfo} != ${null}";
    [self.view addSubview:_textView];
    currentY += 160;
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 100;
    button.frame = CGRectMake(10, currentY, (UIScreen.mainScreen.bounds.size.width - 30)/2, 40);
    [button setTitle:@"计算结果(v0)" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(calculateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 5;
    button.layer.borderColor = UIColor.blueColor.CGColor;
    button.layer.borderWidth = 1;
    [self.view addSubview:button];
    
    UIButton *buttonV1 = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonV1.tag = 101;
    buttonV1.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/2 + 5, currentY, (UIScreen.mainScreen.bounds.size.width - 30)/2, 40);
    [buttonV1 setTitle:@"计算结果(v1)" forState:UIControlStateNormal];
    [buttonV1 setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [buttonV1 addTarget:self action:@selector(calculateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    buttonV1.layer.cornerRadius = 5;
    buttonV1.layer.borderColor = UIColor.blueColor.CGColor;
    buttonV1.layer.borderWidth = 1;
    [self.view addSubview:buttonV1];
    currentY += 40;
    
    _resultLabel = [UILabel new];
    _resultLabel.numberOfLines = 0;
    _resultLabel.frame = CGRectMake(10, currentY, UIScreen.mainScreen.bounds.size.width - 20, 30);
    _resultLabel.numberOfLines = 0;
    [self.view addSubview:_resultLabel];
}

#pragma mark - action method

- (void)calculateButtonClicked:(UIButton *)sender{
    NSError *error = nil;
    
    NSTimeInterval startTime = [NSDate.date timeIntervalSince1970];
    BOOL result = NO;
    if (sender.tag - 100 == 0) {
        result = [LSYOldConditionAdjudicator calculateWithExpressionString:_textView.text target:_target context:_context error:&error];
        NSLog(@"------旧方法耗时(毫秒):%lf",[NSDate.date timeIntervalSince1970] - startTime);
    }else{
        result = [LSYConditionAdjudicator calculateWithExpressionString:_textView.text target:_target context:_context error:&error];
        NSLog(@"------新方法耗时(毫秒):%lf",[NSDate.date timeIntervalSince1970] - startTime);
    }
    if (error) {
        _resultLabel.text = [NSString stringWithFormat:@"ERROR:%@",error.localizedDescription];
        [_resultLabel sizeToFit];
        return;
    }
    _resultLabel.text = [NSString stringWithFormat:@"The result is:%d",result];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
