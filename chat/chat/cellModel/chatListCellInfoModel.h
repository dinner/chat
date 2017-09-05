//
//  chatListCellInfoModel.h
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/20.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface chatListCellInfoModel : NSObject

@property(retain,nonatomic) NSString* img;
@property(retain,nonatomic) NSString* user;
@property(retain,nonatomic) NSString* content;
@property(retain,nonatomic) NSString* time;
@property(retain,nonatomic) NSString* title;//官方消息用到

@end
