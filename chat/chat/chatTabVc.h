//
//  chatTabVc.h
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/8.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupChatListVc.h"
#import "chatListVc.h"

@protocol singleAddClick <NSObject>

-(void)singleAddClicked;

@end

@protocol groupAddClick <NSObject>

-(void)groupAddClicked;
@end

@interface chatTabVc : UITabBarController

@property(retain,nonatomic) groupChatListVc* groupVc;
@property(retain,nonatomic) chatListVc* singleChatVc;

@property(weak,nonatomic) id<singleAddClick> singleClickDelegate;
@property(weak,nonatomic) id<groupAddClick> groupClickDelegate;

+(id)getInstance;

@end
