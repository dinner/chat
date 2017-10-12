//
//  ChatListCell.h
//  UINavigationTest
//
//  Created by James on 15/8/19.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatListCellInfoModel.h"


@interface ChatListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *time;

@property(assign,nonatomic) enum mesSource_enum type;

-(void)setInfo:(chatListCellInfoModel*)info;
-(void)setInfo:(id)info type:(enum mesSource_enum)type;

@end
