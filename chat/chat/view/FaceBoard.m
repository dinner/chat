//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"
#import "btEmotion.h"

#define FACE_COUNT_ALL  85

#define FACE_COUNT_ROW  4

#define FACE_COUNT_CLU  7

#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )

#define FACE_ICON_SIZE  44


@implementation FaceBoard

@synthesize delegate;

@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;

- (id)init {

    self = [super initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 200.f)];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];

        NSArray* array = [NSArray arrayWithObjects:@"u1f60a",@"u1f60b",@"u1f60c",@"u1f60d",
                                  @"u1f60e",
                                  @"u1f60f",
                                  @"u1f61c",
                                  @"u1f61d",
                                  @"u1f61e",
                                  @"u1f61f",
                                  @"u1f62b",
                                  @"u1f62c",
                                  @"u1f62d",
                                  @"u1f62e",
                                  @"u1f62f",
                                  @"u1f600",@"u1f601",@"u1f602",@"u1f603",@"u1f605",@"u1f606",@"u1f607"
                                  ,@"u1f608",@"u1f609",@"u1f611",@"u1f612",@"u1f613",@"u1f614",@"u1f615",
                                  @"u1f616",@"u1f618",@"u1f621",@"u1f622",@"u1f623",@"u1f624",@"u1f628",
                    @"u1f629",@"u1f630",@"u1f631",@"u1f632",@"u1f633",@"u1f634",@"u1f635",@"u1f636",@"u1f637",nil];

        //表情盘
        int count = array.count;
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 190)];
        faceView.pagingEnabled = YES;
        faceView.contentSize = CGSizeMake((count / FACE_COUNT_PAGE + 1) * ScreenWidth, 190);
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        
        for (int i = 0; i < count; i++) {

            btEmotion *faceButton = [btEmotion buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i;
            
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (((i ) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + ((i ) / FACE_COUNT_PAGE * ScreenWidth);
            CGFloat y = (((i ) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
            faceButton.frame = CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
            //图片名称
            NSString* imgName = [NSString stringWithFormat:@"%@.png",array[i]];
            faceButton.strPic = array[i];
            UIImage* image = [UIImage imageNamed:imgName];
            image = [self originImage:image scaleToSize:CGSizeMake(30, 30)];
            [faceButton setImage:image
                        forState:UIControlStateNormal];

            [faceView addSubview:faceButton];
        }
        
        //添加PageControl
        facePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(110, 175, 100, 20)];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        
        facePageControl.numberOfPages = count / FACE_COUNT_PAGE + 1;
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:faceView];
        
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:@"删除" forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(272, 182, 38, 28);
        [self addSubview:back];
    }

    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [facePageControl setCurrentPage:faceView.contentOffset.x / 320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {

    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * 320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    btEmotion* bt = (btEmotion*)sender;
    NSString* strPic = bt.strPic;
    strPic = [NSString stringWithFormat:@"[%@]",strPic];
    
    [self.delegate singleEmotionClicked:strPic];//单独表情点击
    
    /*
    if (self.inputTextField) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]];
                self.inputTextField.text = faceString;
    }

    if (self.inputTextView) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]];
        NSLog([NSString stringWithFormat:@"%03d", i]);
        NSLog([_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]);
        NSLog([_faceMap description]);
        self.inputTextView.text = faceString;

        [delegate textViewDidChange:self.inputTextView];
    }*/
}

- (void)backFace{

    NSString *inputString;
    inputString = self.inputTextField.text;
    if ( self.inputTextView ) {

        inputString = self.inputTextView.text;
    }

    if ( inputString.length ) {
        
        NSString *string = nil;
        NSInteger stringLength = inputString.length;
        if ( stringLength >= FACE_NAME_LEN ) {
            
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                
                string = [inputString substringToIndex:
                          [inputString rangeOfString:FACE_NAME_HEAD
                                             options:NSBackwardsSearch].location];
            }
            else {
                
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            
            string = [inputString substringToIndex:stringLength - 1];
        }
        
        if ( self.inputTextField ) {
            
            self.inputTextField.text = string;
        }
        
        if ( self.inputTextView ) {
            
            self.inputTextView.text = string;
            
            [delegate textViewDidChange:self.inputTextView];
        }
    }
}

-(UIImage*)originImage:(UIImage*)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)dealloc {
    
}

+(BOOL)isRichTextEmotionPicCode:(NSString*)str{
    NSArray* array = [NSArray arrayWithObjects:@"u1f60a",@"u1f60b",@"u1f60c",@"u1f60d",
                      @"u1f60e",
                      @"u1f60f",
                      @"u1f61c",
                      @"u1f61d",
                      @"u1f61e",
                      @"u1f61f",
                      @"u1f62b",
                      @"u1f62c",
                      @"u1f62d",
                      @"u1f62e",
                      @"u1f62f",
                      @"u1f600",@"u1f601",@"u1f602",@"u1f603",@"u1f605",@"u1f606",@"u1f607"
                      ,@"u1f608",@"u1f609",@"u1f611",@"u1f612",@"u1f613",@"u1f614",@"u1f615",
                      @"u1f616",@"u1f618",@"u1f621",@"u1f622",@"u1f623",@"u1f624",@"u1f628",
                      @"u1f629",@"u1f630",@"u1f631",@"u1f632",@"u1f633",@"u1f634",@"u1f635",@"u1f636",@"u1f637",nil];
    return [array containsObject:str];
}


@end
