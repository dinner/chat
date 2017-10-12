//
//  addOperateView.m
//  UINavigationTest
//
//  Created by James on 15/8/18.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "addOperateView.h"

@interface addOperateView(){
    
}

@property(retain,nonatomic) UIButton* bt_imgSelect;

@end

@implementation addOperateView

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
        _bt_imgSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bt_imgSelect setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self addSubview:_bt_imgSelect];
    }
    return self;
}
+(addOperateView*)getInstance{
    NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"addOperateView" owner:nil options:nil];
    addOperateView* view = (addOperateView*)array[0];
    return view;
}


@end
