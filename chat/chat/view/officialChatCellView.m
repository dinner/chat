//
//  officialChatCellView.m
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "officialChatCellView.h"

@implementation officialChatCellView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(instancetype)getInstance{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"officialChatCellView" owner:nil options:nil];
    officialChatCellView* view = (officialChatCellView*)array[0];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.lb_content setEditable:NO];
    [view.lb_content setScrollEnabled:NO];
    return view;
}




@end
