//
//  ChartContentView.h
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentLabel.h"
#import "chatImageView.h"
#import "ChartCellFrame.h"
#import "ContentAudio.h"

@class ChartContentView,ChartMessage;

@protocol ChartContentViewDelegate <NSObject>

-(void)chartContentViewLongPress:(ChartContentView *)chartView content:(NSString *)content;
-(void)chartContentViewTapPress:(ChartContentView *)chartView content:(NSString *)content;

@end

@interface ChartContentView : UIView
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) ContentLabel *contentLabel;
@property (nonatomic,strong) chatImageView* imageView;

@property(nonatomic,strong) ContentAudio* contentAudioView;//音频
@property (nonatomic,strong) ChartMessage *chartMessage;
@property (nonatomic,assign) id <ChartContentViewDelegate> delegate;

@property (weak,nonatomic) ChartCellFrame* cellFrame;

@property(nonatomic,assign) NSString* m_strAudioPath;
@end
