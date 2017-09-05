//
//  groupChatVc.h
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/8.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoom.h"

@interface groupChatVc : UIViewController

@property(retain,nonatomic) NSString* strName;
@property(retain,nonatomic) NSMutableArray* cellFrames;
@property(retain,nonatomic) NSString* m_strSelfId;

@property(retain,nonatomic) XMPPRoom* m_xmppRoom;

-(id)initWithRoomName:(NSString*)strRoom;

@end
