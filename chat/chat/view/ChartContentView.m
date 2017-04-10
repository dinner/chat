//
//  ChartContentView.m
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kContentStartMargin 25
#import "ChartContentView.h"
#import "ChartMessage.h"
@implementation ChartContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backImageView=[[UIImageView alloc]init];
        self.backImageView.userInteractionEnabled=YES;
        [self addSubview:self.backImageView];

        [self addGestureRecognizer: [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)]];

        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPress:)]];
    }
    return self;
}
-(void)label{
    if (self.contentLabel != nil) {
        if (self.chartMessage.messageType == kMessageFrom) {
            self.contentLabel.frame=CGRectMake(17.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        else{
            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        return;
    }else{
        self.contentLabel=[[ContentLabel alloc]init];
        if (self.chartMessage.messageType == kMessageFrom) {
            self.contentLabel.frame=CGRectMake(17.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        else{
            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        self.contentLabel.numberOfLines=0;
        self.contentLabel.textAlignment=NSTextAlignmentLeft;
        self.contentLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:12.f];
        [self addSubview:self.contentLabel];
    }
}

-(void)imagePic{
    if (self.imageView == nil) {
       self.imageView = [[chatImageView alloc] init];
        [self addSubview:self.imageView];
    }
    self.imageView.m_cellFrame = self.cellFrame;
    if (self.chartMessage.messageType == kMessageFrom) {
        self.imageView.frame = CGRectMake(22.f, 8, self.frame.size.width-25.f-10.f, self.frame.size.height-5.f-20.f);
    }
    else{
        self.imageView.frame = CGRectMake(13.f, 8, self.frame.size.width-25.f-10.f, self.frame.size.height-5.f-20.f);
    }
    if (self.cellFrame.m_picSource == e_localImg) {
        [self.imageView setLocalImage:self.cellFrame.image];
    }
    else{//服务器图片
        [self.imageView setRemoteImage:self.cellFrame.m_strPicUrl];
    }
}

-(void)audio{
    if (self.contentAudioView == nil) {
        self.contentAudioView = [[ContentAudio alloc]init];
        [self.contentAudioView setImage:[UIImage imageNamed:@"sound3.png"]];
        
        self.contentAudioView.audioType = self.cellFrame.m_audioSource;
        self.contentAudioView.strUrl = self.cellFrame.m_strAudioUrl;
        [self addSubview:self.contentAudioView];
        if (self.chartMessage.messageType == kMessageFrom) {
            self.contentAudioView.frame = CGRectMake(15, 5, 30.f, 30.f);
        }
        else{
            self.contentAudioView.frame = CGRectMake(15, 5, 30.f, 30.f);
        }
    }
}

-(void)setCellFrame:(ChartCellFrame *)cellFrame{
//    [self setFrame:cellFrame.chartViewRect];
    _cellFrame = cellFrame;
    self.backImageView.frame=self.bounds;
    if (self.chartMessage.messageType == kMessageFrom) {
        if (self.chartMessage.mesType == e_text) {
            [self label];
        }
        if (self.chartMessage.mesType == e_pic) {
//            if (self.cellFrame.m_bIsUploadOrDownloadSuc == NO) {
                [self imagePic];
//            }
        }
        if (self.chartMessage.mesType == e_audio) {
            [self audio];
        }
    }
    else{
        if (self.chartMessage.mesType == e_text) {
            [self label];
        }
        if (self.chartMessage.mesType == e_pic) {
//            if (self.cellFrame.m_bIsUploadOrDownloadSuc == NO) {
                [self imagePic];
//            }
        }
        if (self.chartMessage.mesType == e_audio) {
            [self audio];
        }
    }
}
/*
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backImageView.frame=self.bounds;
    if (self.chartMessage.messageType == kMessageFrom) {
        if (self.chartMessage.mesType == e_text) {
            [self label];
            self.contentLabel.frame=CGRectMake(17.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        if (self.chartMessage.mesType == e_pic) {
//            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-25.f, self.frame.size.height-5.f);
            [self imagePic];
            self.imageView.frame = CGRectMake(13.f, 8, self.frame.size.width-25.f-10.f, self.frame.size.height-5.f-20.f);
        }
    }
    else{
        if (self.chartMessage.mesType == e_text) {
            [self label];
            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        if (self.chartMessage.mesType == e_pic) {
            [self imagePic];
            self.imageView.frame = CGRectMake(13.f, 8, self.frame.size.width-25.f-10.f, self.frame.size.height-5.f-20.f);
        }
    }
}*/
-(void)longTap:(UILongPressGestureRecognizer *)longTap
{
    if([self.delegate respondsToSelector:@selector(chartContentViewLongPress:content:)]){
        
        [self.delegate chartContentViewLongPress:self content:self.contentLabel.text];
    }
}
-(void)tapPress:(UILongPressGestureRecognizer *)tapPress
{
    if([self.delegate respondsToSelector:@selector(chartContentViewTapPress:content:)]){
        NSString* strContent = _chartMessage.content;
        NSString* strAudio = [[strContent componentsSeparatedByString:@"audio:"] lastObject];
        [self.delegate chartContentViewTapPress:self content:strAudio];
    }
}
@end
