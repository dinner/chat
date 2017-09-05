//
//  chatImageView.h
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/20.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartCellFrame.h"

@interface ContentPic : UIImageView

@property(weak,nonatomic) ChartCellFrame* m_cellFrame;
//@property(assign,nonatomic) BOOL bIsUploadOrDownload;
@property(retain,nonatomic) NSData* imageData;

-(void)setLocalImage:(UIImage*)image;
-(void)setRemoteImage:(NSString*)url;

@end
