//
//  officialChatCell.m
//  CalendarDiary
//
//  Created by James on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "officialChatCell.h"
#import "officialCellModel.h"
#import "UIImageView+WebCache.h"
#import "officialContentView.h"
#import "UIImageView+WebCache.h"

@interface officialChatCell(){
    officialContentView* ctView;
}

@end

@implementation officialChatCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
        CGRect rect = self.frame;
        CGRect rectScreen = [UIScreen mainScreen].bounds;
        ctView = [[officialContentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rectScreen) - 30.f, 90.f)];
        [self.contentView addSubview:ctView];
//        [self.contentView setBackgroundColor:[UIColor orangeColor]];
        [ctView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setInfo:(id)ob{
    CGPoint pt = CGPointMake(CGRectGetWidth(self.bounds)/2, 100.f/2);
    [ctView setCenter:pt];
    officialCellModel* model = (officialCellModel*)ob;
    [ctView.lb_content setText:model.strContent];
    [ctView.lb_title setText:model.strTitle];
//    [ctView.lb_title setText:@"asdf"];
    [ctView.lb_content sizeToFit];
    [ctView.imageV sd_setImageWithURL:[NSURL URLWithString:model.picUrl]];
//    [lb_content setText:model.strContent];
//    [lb_title setText:model.strTitle];
//    [imageV setImage:[UIImage imageNamed:@"officer"]];
}

@end
