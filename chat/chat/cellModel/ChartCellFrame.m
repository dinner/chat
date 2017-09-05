//
//  ChartCellFrame.m
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kIconMarginX 5
#define kIconMarginY 5
#define AUDIO_PRIFIX    @"audio:"
#define IMG_PRIFIX      @"img:"

#define PIC_WID      100
#define PIC_HEIGHT   120
#define AUDIO_WID    30
#define AUDIO_HEIGHT 20
#define HTTP_PRIFIX     @"http"

#import "ChartCellFrame.h"
#import "FaceBoard.h"
#import "util.h"

@implementation ChartCellFrame

-(void)setChartMessage:(ChartMessage *)chartMessage
{
    self.fileUploadOrDownLoadManager = [[fileUploadOrDownload alloc] init];
    _chartMessage=chartMessage;
    CGSize winSize=[UIScreen mainScreen].bounds.size;
    CGFloat iconX=kIconMarginX;
    CGFloat iconY=kIconMarginY;
    CGFloat iconWidth=40;
    CGFloat iconHeight=40;
    
    if(chartMessage.messageType==kMessageTo){
        iconX=winSize.width-kIconMarginX-iconWidth;
    }
    self.iconRect=CGRectMake(iconX, iconY, iconWidth, iconHeight);
    
    CGFloat contentX=CGRectGetMaxX(self.iconRect)+kIconMarginX;
    CGFloat contentY=iconY;
    
    NSDate* date = chartMessage.date;
    NSString* strDate = [util dateToString:date];
    self.m_strDate = strDate;
    NSString* strContent = chartMessage.content;//内容
    if (chartMessage.mesType == e_audio) {//音频
        self.m_strAudioUrl = chartMessage.content;
        self.m_audioSource = e_localAudio;
        self.m_audioSource = chartMessage.audioType;
        self.m_mesType = e_audio;
    }
    else if (chartMessage.mesType == e_pic){//图片
        self.m_strPicUrl = chartMessage.content;
        self.m_picSource = chartMessage.picType;
        self.m_mesType = e_pic;
        self.image = chartMessage.image;
    }
    else if(chartMessage.mesType == e_text){//文本消息
        self.m_mesArray = [self analysisTextToArray:strContent];
        self.m_mesType = e_text;
    }
    else if (chartMessage.mesType == e_timeInterval){//时间间隔
        _m_mesType = e_timeInterval;
    }
    
    CGSize size = [self getContentSize];
    if(chartMessage.messageType==kMessageTo){
        contentX = iconX-size.width-28.f;
    }
    
    self.chartViewRect=CGRectMake(contentX, contentY, size.width+28.f, size.height+30);
    self.cellHeight=MAX(CGRectGetMaxY(self.iconRect), CGRectGetMaxY(self.chartViewRect))+kIconMarginX+18.f;
    
    if (chartMessage.mesType == e_timeInterval) {
        self.cellHeight = TIME_CELLHEIGHT;
    }
}


//将文本解析
-(NSArray*)analysisTextToArray:(NSString *)atstring
{
    if (!atstring.length)
    {
        return nil;
    }
    NSMutableArray* array = [NSMutableArray array];
    int indexBegin = 0;
    BOOL isBegin = NO;
    for (int i = 0;i < atstring.length;i++) {
        NSString *s = [atstring substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:@"["]) {
            if (!isBegin) {
                isBegin = YES;
                if (indexBegin != i) {
                    NSString* arrayOb = [atstring substringWithRange:NSMakeRange(indexBegin, i-indexBegin)];
                    indexBegin = i;
                    [array addObject:arrayOb];
                }
                indexBegin = i;
            }
            else{
                continue;
            }
        }
        else if([s isEqualToString:@"]"]){
            if (isBegin) {
                isBegin = NO;
                NSString* arrayOb = [atstring substringWithRange:NSMakeRange(indexBegin, i-indexBegin+1)];
                indexBegin = i+1;
                [array addObject:arrayOb];
            }
            else{
                continue;
            }
        }
        if (i == atstring.length-1) {
            if (indexBegin <= i) {
                NSString* arrayOb = [atstring substringWithRange:NSMakeRange(indexBegin, i-indexBegin+1)];
                [array addObject:arrayOb];
            }
        }
    }
    NSLog(@"%@",array);
    return array;
}


//是富文本信息时解析文本计算高度
-(CGSize)getContentSize{
//    @synchronized ( self ) {
    switch (self.m_mesType) {
    
        case e_text:{
        CGFloat upX;
        
        CGFloat upY;
        
        CGFloat lastPlusSize;
        
        CGFloat viewWidth;
        
        CGFloat viewHeight;
        
        BOOL isLineReturn;
        
        UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
        
        isLineReturn = NO;
        
        upX = VIEW_LEFT;
        upY = VIEW_TOP;
        
        for (int index = 0; index < _m_mesArray.count; index++) {
            
            NSString *str = [_m_mesArray objectAtIndex:index];
            NSString *strPic = @"";
            if (str.length > 2) {
                strPic = [str substringWithRange:NSMakeRange(1, str.length - 2)];
            }
            if ([FaceBoard isRichTextEmotionPicCode:strPic]) {//判断是否是表情图片
                
                NSString *imageName = strPic;
                
                NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                
                if ( imagePath ) {
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += KFacialSizeWidth;
                    
                    lastPlusSize = KFacialSizeWidth;
                }
            }
            else {
                
                for ( int index = 0; index < str.length; index++) {
                    
                    NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE]};
                    CGSize size = [character boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += size.width;
                    
                    lastPlusSize = size.width;
                }
            }
        }
        if ( isLineReturn ) {
            viewWidth = VIEW_WIDTH_MAX;
        }
        else {
            viewWidth = upX + VIEW_LEFT;
        }
        viewHeight = upY;
            return CGSizeMake(viewWidth, viewHeight);
        }break;
        case e_pic:{
            return CGSizeMake(PIC_WID, PIC_HEIGHT);
        }break;
        case e_audio:{
            return CGSizeMake(AUDIO_WID, AUDIO_HEIGHT);
        }break;
    }
    return CGSizeMake(0, 0);
}




@end
