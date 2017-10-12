//
//  ChartCell.m
//  UINavigationTest
//
//  Created by James on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "ChartCell.h"
#import "UIImageView+WebCache.h"
#import "ContentPic.h"
#import "ContentAudio.h"
#import "ContentLabel.h"

static s_index=0;
@interface ChartCell()
@property(retain,nonatomic) UIImageView* icon;//头像
@property(retain,nonatomic) UILabel* lbName;//名字

@property (nonatomic,strong) UIImageView *bubbleView;//气泡
@property (nonatomic,strong) ContentLabel *contentLabel;//文字
@property (nonatomic,strong) ContentPic* picView;//图片
@property (nonatomic,strong) ContentAudio* contentAudioView;//音频
//@property (nonatomic,assign) id <ChartContentViewDelegate> delegate;

@property(nonatomic,assign) NSString* m_strAudioPath;

@end

@implementation ChartCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        self.bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.bubbleView setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.bubbleView];
    }
    NSLog(@"cell创建第%d次",s_index++);
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
    if(self.cellType == ZBMessageGroup){
        CGRect rect = cellFrame.chartViewRect;
        self.bubbleView.frame = CGRectMake(rect.origin.x,rect.origin.y+18.f , rect.size.width, rect.size.height);
    }
    else{
        self.bubbleView.frame = cellFrame.chartViewRect;
    }
    [self setBackGroundImageViewImage:@"chatfrom_bg_normal.png" to:@"chatto_bg_normal.png"];
    [self setTheSub];
}

-(void)setTheSub{
    enum mesType_enum mesType = _cellFrame.chartMessage.mesType;
    if (mesType == e_text) {
        [self label];
    }
    if (mesType == e_pic) {
        [self imagePic];
    }
    if (mesType == e_audio) {
        [self audio];
    }
}

-(void)setBackGroundImageViewImage:(NSString *)from to:(NSString *)to
{
    UIImage *normal=nil ;
    ChartMessageType type = _cellFrame.chartMessage.messageType;
    if(type == kMessageFrom){
        normal = [UIImage imageNamed:from];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
    }else if(type == kMessageTo){
        normal = [UIImage imageNamed:to];
        normal = [normal stretchableImageWithLeftCapWidth:normal.size.width * 0.5 topCapHeight:normal.size.height * 0.7];
    }
    self.bubbleView.image = normal;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark 
-(void)label{
    ChartMessageType FromOrToType = _cellFrame.chartMessage.messageType;
    if (self.contentLabel != nil) {
        if (FromOrToType == kMessageFrom) {
            self.contentLabel.frame=CGRectMake(17.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        else{
            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
    }else{
        self.contentLabel=[[ContentLabel alloc]init];
        if (FromOrToType == kMessageFrom) {
            self.contentLabel.frame=CGRectMake(17.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        else{
            self.contentLabel.frame=CGRectMake(10.f, 0, self.frame.size.width-10.f, self.frame.size.height);
        }
        self.contentLabel.numberOfLines=0;
        self.contentLabel.textAlignment=NSTextAlignmentLeft;
        self.contentLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:12.f];
        [self.bubbleView addSubview:self.contentLabel];
    }
    self.contentLabel.cellFrame = self.cellFrame;
    [self.contentLabel setNeedsDisplay];
    
//    [self.contentLabel setTheLabel:self.cellFrame.m_mesArray];
}

-(void)imagePic{
    if (self.picView == nil) {
        self.picView = [[ContentPic alloc] init];
        [self.bubbleView addSubview:self.picView];
    }
    self.picView.m_cellFrame = self.cellFrame;
    ChartMessageType FromOrToType = _cellFrame.chartMessage.messageType;
    if (FromOrToType == kMessageFrom) {
        self.picView.frame = CGRectMake(22.f, 8, self.bubbleView.frame.size.width-25.f-10.f, self.bubbleView.frame.size.height-5.f-20.f);
    }
    else{
        self.picView.frame = CGRectMake(13.f, 8, self.bubbleView.frame.size.width-25.f-10.f, self.bubbleView.frame.size.height-5.f-20.f);
    }
    if (self.cellFrame.m_picSource == e_localImg) {
        [self.picView setLocalImage:self.cellFrame.image];
    }
    else{//服务器图片
        [self.picView setRemoteImage:self.cellFrame.m_strPicUrl];
    }
}

-(void)audio{
    if (self.contentAudioView == nil) {
        self.contentAudioView = [[ContentAudio alloc]init];
        [self.contentAudioView setImage:[UIImage imageNamed:@"sound3.png"]];
        
        self.contentAudioView.audioType = self.cellFrame.m_audioSource;
        self.contentAudioView.strUrl = self.cellFrame.m_strAudioUrl;
        [self.bubbleView addSubview:self.contentAudioView];
        ChartMessageType FromOrToType = _cellFrame.chartMessage.messageType;
        if (FromOrToType == kMessageFrom) {
            self.contentAudioView.frame = CGRectMake(15, 5, 30.f, 30.f);
        }
        else{
            self.contentAudioView.frame = CGRectMake(15, 5, 30.f, 30.f);
        }
    }
}


@end
