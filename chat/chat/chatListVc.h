//
//  chatListVc.h
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/14.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatVc.h"
@interface chatListVc : UIViewController

+(chatListVc*)getInstance;

-(chatVc*)getChatVc:(NSString*)userId head:(NSString*)strHead;

-(NSMutableDictionary*)getFriendListDic;

@property(retain,nonatomic) NSMutableDictionary* m_chatArray;//聊天窗口键值表
@property(retain,nonatomic) NSMutableDictionary* m_chatFriendListDataSource;//聊天显示的朋友列表数据元

@end
