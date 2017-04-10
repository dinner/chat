//
//  ContentAudio.m
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/18.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "ContentAudio.h"
#import "FSAudioStream.h"
#import <AVFoundation/AVFoundation.h>

@interface ContentAudio(){
    int picNum;
}
@property(retain,nonatomic) FSAudioStream* audioStream;
@property(retain,nonatomic) NSTimer* timer;

@end

@implementation ContentAudio

-(id)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioClicked:)];
        [self addGestureRecognizer:tap];
        picNum = 1;
    }
    return self;
}

-(FSAudioStream*)audioStream{
    if (!_audioStream) {
        NSURL* URL;
        /*
        if (self.audioType == e_localAudio) {
            URL = [NSURL fileURLWithPath:self.strUrl];
        }
        else{
         }
         */
        
        URL = [NSURL URLWithString:self.strUrl];
        _audioStream = [[FSAudioStream alloc] initWithUrl:URL];
        _audioStream.onFailure = ^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程遇到错误 %@",description);
        };
        __weak ContentAudio* weakSelf = self;
        _audioStream.onCompletion = ^{
            NSLog(@"播放完成");
            [weakSelf setImage:[UIImage imageNamed:@"sound3"]];
            [weakSelf.timer invalidate];
        };
        [self.audioStream setVolume:0.5f];
    }
    return _audioStream;
}

-(void)audioClicked:(id)sender{
    [self.audioStream play];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(timerSchedule:) userInfo:nil repeats:YES];
    
    /*
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.strUrl]]; //在线
    [player play];
     */
}

-(void)timerSchedule:(id)sender{
    int pic = picNum%3+1;
    picNum++;
    NSString* picPath = [NSString stringWithFormat:@"sound%d",pic];
    [self setImage:[UIImage imageNamed:picPath]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
