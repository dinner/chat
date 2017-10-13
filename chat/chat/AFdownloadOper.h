//
//  AFdownloadOper.h
//  CalendarDiary
//
//  Created by James on 16/4/22.
//  Copyright (c) 2016年 caobo. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "SDDemoItemView.h"
#import "SDBallProgressView.h"
//#import "ChartCellFrame.h"

@interface AFdownloadOper : AFHTTPRequestOperation

@property(retain,nonatomic) SDBaseProgressView* progressView;
//@property(retain,nonatomic) ChartCellFrame* m_cellFrame;

@end
