//
//  ChartCell.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "ChartCell.h"
#import "ChartContentView.h"
#import "UIImageView+WebCache.h"

@interface ChartCell()
@property(retain,nonatomic) UIImageView* icon;
@property(retain,nonatomic) ChartContentView* chartView;
@property(retain,nonatomic) UILabel* lbName;

@end

@implementation ChartCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        self.chartView = [[ChartContentView alloc] initWithFrame:CGRectZero];

        [self.contentView addSubview:self.chartView];
        
//      [self setBackgroundColor:[UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]];
        
    }
    return self;
}

-(void)setCellFrame:(ChartCellFrame *)cellFrame{
    _cellFrame = cellFrame;
    ChartMessage* chartMessage = cellFrame.chartMessage;
    CGRect iconRect = cellFrame.iconRect;
    self.icon.frame = iconRect;
    if (self.cellType == ZBMessageGroup) {
        self.lbName = [[UILabel alloc] init];
        [self.lbName setTextColor:[UIColor grayColor]];
        [self.lbName setFont:[UIFont systemFontOfSize:12.f]];
        [self.contentView addSubview:self.lbName];
        
        CGSize maximumSize = CGSizeMake(200, 100);
        UIFont *dateFont = [UIFont fontWithName:@"Helvetica" size:12.f];
        CGSize dateStringSize = [cellFrame.m_userName sizeWithFont:dateFont
                                       constrainedToSize:maximumSize
                                           lineBreakMode:self.lbName.lineBreakMode];
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        CGSize nameSize = [cellFrame.m_userName boundingRectWithSize:CGSizeMake(ScreenWidth-80.f, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        
        if(cellFrame.chartMessage.messageType == kMessageFrom){
            [self.lbName setTextAlignment:NSTextAlignmentLeft];
            [self.lbName setText:cellFrame.m_userName];
            [self.lbName setFrame:CGRectMake(CGRectGetMaxX(iconRect)+5.f, CGRectGetMinY(iconRect), nameSize.width, dateStringSize.height)];
        }
        else{
            [self.lbName setTextAlignment:NSTextAlignmentRight];
            [self.lbName setText:cellFrame.m_userName];
            [self.lbName setFrame:CGRectMake(CGRectGetMinX(iconRect)-nameSize.width, CGRectGetMinY(iconRect), nameSize.width, dateStringSize.height)];
        }
        [self.lbName sizeToFit];
    }
    [self.icon sd_setImageWithURL:[NSURL URLWithString:chartMessage.icon]];
    self.icon.layer.cornerRadius = 20.f;
    self.icon.layer.masksToBounds = YES;
    self.chartView.chartMessage = chartMessage;
    if(self.cellType == ZBMessageGroup){
        CGRect rect = cellFrame.chartViewRect;
        self.chartView.frame = CGRectMake(rect.origin.x,rect.origin.y+18.f , rect.size.width, rect.size.height);
    }
    else{
        self.chartView.frame = cellFrame.chartViewRect;
    }
    self.chartView.cellFrame = cellFrame;
    [self setBackGroundImageViewImage:self.chartView from:@"chatfrom_bg_normal.png" to:@"chatto_bg_normal.png"];
    [self.chartView.contentLabel drawTheLable:cellFrame];
}

-(void)setBackGroundImageViewImage:(ChartContentView *)chartView from:(NSString *)from to:(NSString *)to
{
    UIImage *normal=nil ;
    if(chartView.chartMessage.messageType==kMessageFrom){
        
        normal = [UIImage imageNamed:from];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
//        normal = [normal stretchableImageWithLeftCapWidth:30 topCapHeight:10];
        
    }else if(chartView.chartMessage.messageType==kMessageTo){
        normal = [UIImage imageNamed:to];
//        normal = [normal stretchableImageWithLeftCapWidth:33 topCapHeight:30];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
    }
    chartView.backImageView.image=normal;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
