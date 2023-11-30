//
//  ViewController.m
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/11/9.
//

#import "ViewController.h"
#import "LSYConditionAdjudicator.h"
#import "Refer.h"
#import <YYModel/YYModel.h>

@interface ViewController ()<UITextViewDelegate>{
    //上下文
    NSDictionary *_context;
    Refer *_target;
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
    
    Refer *refer = [Refer new];
    refer.params = @{
        @"name":@"Tom",
        @"age":@"18"
    };
    
    Invitation *invitation = [Invitation new];
    invitation.rootcateid = 555;
    invitation.role = 2;
    invitation.scene = @"job_detait";
    invitation.cate_extra = @{
        @"biz_mode":@"normal mode",
        @"c_chatid":@"",
        @"newrootcateid":@(674)
    };
    refer.invitation = invitation;
    
    _target = refer;
    _context = @{
        @"TargetUid":@"1111",
        @"source":@"5"
    };
    
    NSString *content = [NSString stringWithFormat:@"Refer:%@\nContext:%@",[[refer yy_modelToJSONObject] description],_context.description];
    
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
//    _textView.text = @"$var{invitation.cate_extra.biz_mode} == normal$space{}mode && $var{invitation} != ${null}";
    _textView.text = @" ( ( $var{params.name} == Tom && $var{params.age} > 20 ) || ( $var{invitation.rootcateid} in 574,577 && $var{invitation.role} notIn 1,3 ) ) && $var{invitation.scene} startWith job_ && $var{invitation.cate_extra.biz_mode} isEqualToString normal$space{}mode && $var{invitation.cateid} != ${null} && $context{TargetUid} isEqualToString 1111";
//    _textView.text = @"$var{mode} == normal$space{}mode && $var{invitation} != ${null}";
    [self.view addSubview:_textView];
    currentY += 160;
        
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, currentY, UIScreen.mainScreen.bounds.size.width - 20, 40);
    [button setTitle:@"计算结果" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(calculateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 5;
    button.layer.borderColor = UIColor.blueColor.CGColor;
    button.layer.borderWidth = 1;
    [self.view addSubview:button];
    currentY += 40;
    
    _resultLabel = [UILabel new];
    _resultLabel.numberOfLines = 0;
    _resultLabel.frame = CGRectMake(10, currentY, UIScreen.mainScreen.bounds.size.width - 20, 30);
    _resultLabel.numberOfLines = 0;
    [self.view addSubview:_resultLabel];
}

#pragma mark - action method

- (void)calculateButtonClicked{
    NSError *error = nil;
    BOOL result = [LSYConditionAdjudicator calculateWithExpressionString:_textView.text target:_target context:_context error:&error];
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
