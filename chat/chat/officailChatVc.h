//
//  officailChatVc.h
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatVc.h"

@interface officailChatVc : chatVc

{
    UITableView* m_table;
}

-(NSArray*)getDataSource;

@end
