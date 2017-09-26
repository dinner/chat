//
//  ChatTimeCell.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/19.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "ChatTimeCell.h"

@interface  ChatTimeCell(){
//    UILabel* lb_time;
}

@end

@implementation ChatTimeCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.lb_time = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20.f)];
        [self.lb_time setTextColor:[UIColor lightGrayColor]];
        [self.lb_time setFont:[UIFont systemFontOfSize:12.f]];
//        [self.lb_time setText:@""];
//        [self.lb_time sizeToFit];
//        [self setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
        [self.lb_time setCenter:self.center];
        [self addSubview:self.lb_time];
    }
    return self;
}

@end
