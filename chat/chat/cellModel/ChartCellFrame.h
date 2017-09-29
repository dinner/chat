//
//  ChartCellFrame.h
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartMessage.h"
#import "fileUploadOrDownload.h"
#import "AFNetworking.h"
#import "AFdownloadOper.h"

#define TIME_CELLHEIGHT     45.f
//enum typeMes{
//  e_text,e_pic,e_audio
//};


@interface ChartCellFrame : NSObject
@property (nonatomic,assign) CGRect iconRect;
@property (nonatomic,assign) CGRect chartViewRect;
@property (nonatomic,strong) ChartMessage *chartMessage;
@property (nonatomic, assign) CGFloat cellHeight; //cell高度

@property (retain,nonatomic) NSArray* m_mesArray;//信息数组 文字信息
@property (retain,nonatomic) NSString* m_strAudioUrl;//音频信息
@property (retain,nonatomic) NSString* m_strPicUrl;
@property (assign,nonatomic) enum mesType_enum m_mesType;//消息类型

//@property (retain,nonatomic) chatImageView* m_chatImageView;//图片
@property (retain,nonatomic) NSURL* m_fileUrl;//文件路径
@property (retain,nonatomic) NSData* m_imgFileData;//图片文件数据
@property (retain,nonatomic) NSData* m_audioFileData;//音频文件数据

@property (assign,nonatomic) enum picSource m_picSource;//图片类型
@property (assign,nonatomic) enum audioSource m_audioSource;//语音类型

@property(assign,nonatomic) BOOL m_bIsUploadOrDownloadSuc;//图片上传或下载成功 直接读取imgFile
@property (assign,nonatomic) BOOL m_bUploadFail;//是否上传失败

@property (retain,nonatomic) NSString* m_strDate;//时间
@property(retain,nonatomic) UIImage* image;
@property(retain,nonatomic) fileUploadOrDownload* fileUploadOrDownLoadManager;//文件上传或下载管理
@property(retain,nonatomic) NSString* m_userName;

@property(retain,nonatomic) AFdownloadOper* downloadOper;

//-(NSArray*)doo:(NSString *)str;

@end
