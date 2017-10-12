//
//  officialCellModel.h
//  CalendarDiary
//
//  Created by James on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <Foundation/Foundation.h>

enum timeOrInfo{e_time,e_info};

@interface officialCellModel : NSObject

@property (retain,nonatomic) NSString* strTitle;
@property (retain,nonatomic) NSString* strContent;
@property (retain,nonatomic) NSString* picUrl;
@property (assign,nonatomic) enum timeOrInfo type;
@property (retain,nonatomic) NSString* strDate;

@end
