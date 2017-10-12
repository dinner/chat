//
//  fileUploadOrDownload.h
//  UINavigationTest
//
//  Created by James on 15/9/2.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface fileUploadOrDownload : NSObject

@property(retain,nonatomic) NSData* allData;//当前数据
@property(retain,nonatomic) NSData* upDownData;//已上传或下载数据
@property(assign,nonatomic) long long allSize;//所有大小
@property(assign,nonatomic) long long upDownSize;//已上传或下载大小
@property(assign,nonatomic) BOOL bIsSuc;//是否上传或下载完成
@property(retain,nonatomic) UIImage* image;//下载完成的图片
@property(assign,nonatomic) CGFloat fProgress;
@end
