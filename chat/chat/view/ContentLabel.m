//
//  ContentLabel.m
//  hexiProNew
//
//  Created by Apple on 15-5-27.
//
//

#import "ContentLabel.h"
#import "ChartCellFrame.h"
#import "FaceBoard.h"
#import "UIImageView+WebCache.h"
#import "FSAudioStream.h"

@interface ContentLabel(){
    CGFloat upX;
    
    CGFloat upY;
    
    CGFloat lastPlusSize;
    
    CGFloat viewWidth;
    
    CGFloat viewHeight;
    
    BOOL isLineReturn;
    NSArray* data;
}

@property(retain,nonatomic) FSAudioStream* audioStream;

@end

@implementation ContentLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        //点击事件
//        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClicked:)];
//        [self addGestureRecognizer:tap];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        self.m_imgView = [[chatImageView alloc] init];
//        [self addSubview:_m_imgView];
    }
    return self;
}

-(void)setTheData:(NSArray*)array{
    data = array;
    [self setNeedsDisplay];
}
//绘制label
-(void)drawTheLable:(ChartCellFrame*)info{
    _cellFrame = info;
    /*
    if (info.m_mesType == e_pic) {
        if (_m_imgView == nil) {
            _m_imgView = [[chatImageView alloc] initWithFrame:CGRectMake(3, 8, self.bounds.size.width-10, self.bounds.size.height-20)];
            _m_imgView.m_cellFrame = _cellFrame;
            [self addSubview:_m_imgView];
        }
        enum picSource oPicType = info.m_picSource;
            switch (oPicType) {
                case e_localImg://本地图片
                {
                    [self.m_imgView setLocalImage:info.image];
                }
                break;
                case e_serverImg:{
                    
                }
                break;
        }
    }
    else if(info.m_mesType == e_text){//富文本
        if (_m_imgView) {
            [_m_imgView removeFromSuperview];
        }
        [self setNeedsDisplay];
    }
    else{//音频
        if (_m_audioView == nil) {
            _m_audioView = [[chatAudioView alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
            [self addSubview:_m_audioView];
        }
        if (_cellFrame.chartMessage.messageType == kMessageFrom) {
            [_m_audioView setImage:[UIImage imageNamed:@"rc_from_play_voice_three"]];
        }
        else{
            [_m_audioView setImage:[UIImage imageNamed:@"rc_to_play_voice_three"]];
        }
    }
     */
}

- (void)drawRect:(CGRect)rect {
    enum mesType_enum oMesType = _cellFrame.m_mesType;
    switch (oMesType) {
        case e_text:{//文本绘制
        UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
        isLineReturn = NO;
        
        upX = VIEW_LEFT;
        upY = VIEW_TOP;
            NSArray* array = _cellFrame.m_mesArray;
        for (int index = 0; index < array.count; index++) {
            
            NSString *str = [array objectAtIndex:index];
            NSString* Jqstr = @"";
            if (str.length > 2) {
                Jqstr = [str substringWithRange:NSMakeRange(1, str.length - 2)];
            }
            if ([FaceBoard isRichTextEmotionPicCode:Jqstr]) {
                NSString* imageName = Jqstr;
                NSString* strImagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                UIImage *image = [UIImage imageNamed:strImagePath];
                
                if ( image ) {
                    
                    //if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                    if ( upX > ( VIEW_WIDTH_MAX ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    [image drawInRect:CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight)];
                    
                    upX += KFacialSizeWidth;
                    
                    lastPlusSize = KFacialSizeWidth;
                }
                else {
                    
                    [self drawText:str withFont:font];
                }
            }
            else {
                
                [self drawText:str withFont:font];
            }
        }
        }break;
    }
}

- (void)drawText:(NSString *)string withFont:(UIFont *)font{
    
    for ( int index = 0; index < string.length; index++) {
        
        NSString *character = [string substringWithRange:NSMakeRange( index, 1 )];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:FONT_SIZE]};
        CGSize size = [character boundingRectWithSize:CGSizeMake(200, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
        
        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
            
            isLineReturn = YES;
            
            upX = VIEW_LEFT;
            upY += VIEW_LINE_HEIGHT;
        }
        
        [character drawInRect:CGRectMake(upX, upY, size.width, self.bounds.size.height) withFont:font];
        
        upX += size.width;
        
        lastPlusSize = size.width;
    }
}

//label点击
-(void)labelClicked:(id)sender{
    NSLog(@"l");
    [self.audioStream play];
}

-(FSAudioStream *)audioStream{
    if (!_audioStream) {
//        NSURL *url=[self getNetworkUrl];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/music.mp3",SERVER]];
        //创建FSAudioStream对象
        _audioStream=[[FSAudioStream alloc]initWithUrl:url];
        _audioStream.onFailure=^(FSAudioStreamError error,NSString *description){
            NSLog(@"播放过程中发生错误，错误信息：%@",description);
        };
        _audioStream.onCompletion=^(){
            NSLog(@"播放完成!");
        };
        [_audioStream setVolume:0.5];//设置声音
    }
    return _audioStream;
}


@end
