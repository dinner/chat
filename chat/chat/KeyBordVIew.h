//
//  KeyBordVIew.h
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyBordVIew;

@protocol KeyBordVIewDelegate <NSObject>

-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled;
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledBegin:(UITextField *)textFiled;
-(void)beginRecord;
-(void)finishRecord;
-(void)emotionClicked:(BOOL)isEmotion;

-(void)btAddPicClicked:(BOOL)isClick;
-(void)voiceAndKeyBoradClicked:(BOOL)isVoice;
@end

enum btOrWz{
    e_bq,e_wz
};

@interface KeyBordVIew : UIView
@property (nonatomic,assign) id<KeyBordVIewDelegate>delegate;

-(UITextField*)textField;

-(void)resignTextResponse;
-(void)backToOrigin;
@end
