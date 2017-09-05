//
//  addOperateView.h
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/18.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol picSelect <NSObject>

-(void)photoSelect;
-(void)takePhotoSelect;

@end

@interface addOperateView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btTakePhoto;

+(addOperateView*)getInstance;


@end
