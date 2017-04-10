//
//  ChartMessage.h
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
typedef enum {
  
    kMessageFrom=0,
    kMessageTo
 
}ChartMessageType;

enum picSource{//本地图片  服务器图片
    e_localImg,e_serverImg
};
enum audioSource{//本地语音 服务器语音
    e_localAudio,e_serverAudio
};

#import <Foundation/Foundation.h>
//#import "ChartCellFrame.h"

@interface ChartMessage : NSObject
@property (nonatomic,assign) ChartMessageType messageType;
@property (nonatomic, copy) NSString *icon;
//@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSDictionary *dict;
@property (nonatomic,assign) enum mesType_enum mesType;
@property (nonatomic,copy) NSDate* date;
@property (retain,nonatomic) UIImage* image;

@property(assign,nonatomic) enum picSource picType;
@property(assign,nonatomic) enum audioSource audioType;

@end

