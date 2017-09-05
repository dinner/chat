//
//  groupChatListVc.h
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/8.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface groupChatListVc : UIViewController

+(id)getInstance;

@property(retain,nonatomic) NSMutableDictionary* m_dataDic;//room名称和最新消息
@property(retain,nonatomic) NSMutableDictionary* m_roomNameToGroupVc;//room名称和组名对应字典

@end
