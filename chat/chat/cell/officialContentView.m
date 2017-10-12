//
//  officialContentView.m
//  CalendarDiary
//
//  Created by James on 15/9/25.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "officialContentView.h"

@implementation officialContentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        [super setFrame:frame];
        _lb_title = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 5.f, 100.f, 24.f)];
        _lb_content = [[UILabel alloc] initWithFrame:CGRectMake(80.f, 30.f, 200.f, 50.f)];
        _lb_content.lineBreakMode = UILineBreakModeCharacterWrap;
        _lb_content.numberOfLines = 0;
        _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15.f, 30.f, 50.f, 50.f)];
        [_lb_title setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.f]];
        [_lb_content setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
        [_lb_content setTextColor:[UIColor lightGrayColor]];
        [_lb_title setTextColor:[UIColor blackColor]];
        [self addSubview:_lb_content];
        [self addSubview:_lb_title];
        [self addSubview:_imageV];
    }
    return self;
}

//-(void)setFrame:(CGRect)frame{
//    [super setFrame:frame];
//    _lb_title = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 5.f, 100.f, 24.f)];
//    _lb_content = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 35.f, 200.f, 24.f)];
//    _lb_content.lineBreakMode = UILineBreakModeCharacterWrap;
//    _lb_content.numberOfLines = 0;
//    _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20.f, 35.f, 50.f, 50.f)];
//    [_lb_title setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.f]];
//    [_lb_content setFont:[UIFont fontWithName:@"Helvetica" size:12.f]];
//    [_lb_content setTextColor:[UIColor grayColor]];
//    [self addSubview:_lb_title];
//    [self addSubview:_lb_content];
//    [self addSubview:_imageV];
//}


@end
