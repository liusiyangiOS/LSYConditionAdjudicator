//
//  Invitation.h
//  LSYConditionAdjudicator
//
//  Created by 刘思洋 on 2022/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Invitation : NSObject

@property (copy, nonatomic) NSString *scene;
@property (copy, nonatomic) NSString *cateid;
@property (copy, nonatomic) NSDictionary *cate_extra;
@property (assign, nonatomic) long rootcateid;
@property (assign, nonatomic) long role;

@end

NS_ASSUME_NONNULL_END
