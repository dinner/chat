//
//  chatVc.h
//  UINavigationTest
//
//  Created by James on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "chatListVc.h"
typedef NS_ENUM(NSInteger, ZBMessage){
    ZBMessageSingleChat,
    ZBMessageGroupChat,
} ;

typedef NS_ENUM(NSInteger, ZBMessageViewState) {
    ZBMessageViewStateShowFace,
    ZBMessageViewStateShowShare,
    ZBMessageViewStateShowNone,
};

@interface chatVc : UIViewController

@property(retain,nonatomic) NSString* m_strFriendId;
@property(retain,nonatomic) NSString* m_strSelfId;
@property(retain,nonatomic) NSString* m_strFriendHeadUrl;
@property(retain,nonatomic) NSMutableArray* cellFrames;

-(void)fetchTheDb;

@end
