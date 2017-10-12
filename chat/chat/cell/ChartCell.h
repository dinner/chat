//
//  ChartCell.h
//  UINavigationTest
//
//  Created by James on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartCellFrame.h"

typedef NS_ENUM(NSInteger, ZBMessageSingleOrGroup) {
    ZBMessageSingle,
    ZBMessageGroup,
};

@interface ChartCell : UITableViewCell

@property(weak,nonatomic) ChartCellFrame* cellFrame;
//@property(retain,nonatomic) 
@property(assign,nonatomic) ZBMessageSingleOrGroup cellType;

@end
