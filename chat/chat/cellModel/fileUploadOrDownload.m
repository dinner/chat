//
//  fileUploadOrDownload.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/9/2.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "fileUploadOrDownload.h"

@implementation fileUploadOrDownload

-(id)init{
    self = [super init];
    if (self) {
        self.allData = [[NSData alloc] init];
        self.upDownData = [[NSData alloc] init];
        self.image = nil;
        self.allSize = 0;
        self.upDownSize = 0;
        self.bIsSuc = NO;
    }
    return self;
}

@end
