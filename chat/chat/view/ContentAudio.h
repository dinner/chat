//
//  ContentAudio.h
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/18.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartCellFrame.h"

@interface ContentAudio : UIImageView

@property(retain,nonatomic) NSString* strUrl;
@property(retain,nonatomic) ChartCellFrame* m_cellFrame;

@property(assign,nonatomic) enum audioSource audioType;


//-(void)playLocalAudio;
//-(void)playServerAudio;

@end
