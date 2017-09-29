//
//  KeyBordVIew.m
//  气泡
//
//  Created by zzy on 14-5-13.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import "KeyBordVIew.h"
#import "ChartMessage.h"
#import "ChartCellFrame.h"

@interface KeyBordVIew()<UITextFieldDelegate>
{
    enum btOrWz type;
}
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIButton *voiceBtn;
@property (nonatomic,strong) UIButton *imageBtn;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UIButton *speakBtn;
@property (nonatomic,strong) UITextField *textField;
//@property (nonatomic,strong) UITextView* textView;
@end

@implementation KeyBordVIew

-(UITextField*)textField{
    return _textField;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialData];
    }
    return self;
}

-(UIButton *)buttonWith:(NSString *)noraml hightLight:(NSString *)hightLight action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:noraml] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void)initialData
{
    self.backImageView=[[UIImageView alloc]initWithFrame:self.bounds];
    [self.backImageView setBackgroundColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f]];
    [self addSubview:self.backImageView];
    
    type = e_bq;
    
    self.layer.borderWidth = 0.4f;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.voiceBtn=[self buttonWith:@"vioce_icon.png"hightLight:nil action:@selector(voiceBtnPress:)];
    [self.voiceBtn setImage:[UIImage imageNamed:@"bar_keyboard.png"] forState:UIControlStateSelected];
    [self.voiceBtn setFrame:CGRectMake(0,0, 33, 33)];
    [self.voiceBtn setCenter:CGPointMake(27, self.frame.size.height*0.5)];
    [self addSubview:self.voiceBtn];
    
    self.textField=[[UITextField alloc]initWithFrame:CGRectMake(50, 0, self.frame.size.width-130, self.frame.size.height*0.8)];
    self.textField.returnKeyType=UIReturnKeySend;
    self.textField.center=CGPointMake(self.textField.center.x, self.frame.size.height*0.5);
    self.textField.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    self.textField.placeholder=@"请输入";
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    self.textField.layer.cornerRadius = 2.f;
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderWidth = 1.f;
    self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textField.delegate=self;
//    self.textField.insets = UIEdgeInsetsZero;
    [self.textField resignFirstResponder];
    [self addSubview:self.textField];
    
    self.imageBtn=[self buttonWith:@"smiley_normail" hightLight:nil action:@selector(imageBtnPress:)];
    [self.imageBtn setImage:[UIImage imageNamed:@"bar_keyboard.png"] forState:UIControlStateSelected];
    [self.imageBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.imageBtn setCenter:CGPointMake(self.frame.size.width-58, self.frame.size.height*0.5)];
    [self addSubview:self.imageBtn];
    
    self.addBtn=[self buttonWith:@"bar_add.png" hightLight:nil action:@selector(addBtnPress:)];
    [self.addBtn setImage:[UIImage imageNamed:@"bar_keyboard.png"] forState:UIControlStateSelected];
    [self.addBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.addBtn setCenter:CGPointMake(self.frame.size.width-20, self.frame.size.height*0.5)];
    [self addSubview:self.addBtn];
    
    self.speakBtn=[self buttonWith:nil hightLight:nil action:@selector(speakBtnPress:)];
    [self.speakBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.speakBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.speakBtn setTitleColor:[UIColor grayColor] forState:(UIControlState)UIControlEventTouchDown];
    [self.speakBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.speakBtn.layer setBorderWidth:0.3f];
    [self.speakBtn.layer setMasksToBounds:YES];
    [self.speakBtn.layer setCornerRadius:3.f];
    [self.speakBtn setBackgroundColor:[UIColor whiteColor]];
    [self.speakBtn setFrame:self.textField.frame];
    self.speakBtn.hidden=YES;
    [self addSubview:self.speakBtn];
}
-(void)touchDown:(UIButton *)voice
{
    //开始录音
    [self.speakBtn setTitle:@"松开结束" forState:UIControlStateNormal];
    if([self.delegate respondsToSelector:@selector(beginRecord)]){
        [self.delegate beginRecord];
    }
    NSLog(@"开始录音");
}
-(void)speakBtnPress:(UIButton *)voice
{
   //结束录音
    [self.speakBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    if([self.delegate respondsToSelector:@selector(finishRecord)]){
    
        [self.delegate finishRecord];
    }
    NSLog(@"结束录音");
}
-(void)voiceBtnPress:(UIButton *)voice
{
    NSString *normal,*hightLight;
    voice.selected = !voice.selected;
    [self.imageBtn setSelected:NO];
    [self.addBtn setSelected:NO];
    if(voice.isSelected == YES){
        self.speakBtn.hidden=NO;
        self.textField.hidden=YES;
        [self.textField resignFirstResponder];
       normal=@"bar_keyboard.png";
       hightLight=nil;
    
    }else{
        self.speakBtn.hidden=YES;
        self.textField.hidden=NO;
        [self.textField becomeFirstResponder];
        normal=@"vioce_icon.png";
        hightLight=nil;
    
    }
    [voice setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [voice setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
    [self.delegate voiceAndKeyBoradClicked:voice.isSelected];
}
//表情按钮点击
-(void)imageBtnPress:(UIButton *)image
{
    [self.textField resignFirstResponder];
    image.selected = !image.selected;
    [self.voiceBtn setSelected:NO];
    [self.addBtn setSelected:NO];
    [self.delegate emotionClicked:image.selected];
}
//图片添加
-(void)addBtnPress:(UIButton *)image
{
    [self.textField resignFirstResponder];
    [self.imageBtn setSelected:NO];
    [self.voiceBtn setSelected:NO];
    image.selected = !image.selected;
    [self.delegate btAddPicClicked:image.selected];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(KeyBordView:textFiledBegin:)]){
        
        [self.delegate KeyBordView:self textFiledBegin:textField];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(KeyBordView:textFiledReturn:)]){
    
        [self.delegate KeyBordView:self textFiledReturn:textField];
    }
    return YES;
}

-(void)resignTextResponse{
    [self.textField resignFirstResponder];
}
-(void)backToOrigin{
    [self.voiceBtn setSelected:NO];
    [self.imageBtn setSelected:NO];
    [self.addBtn setSelected:NO];
    [self.speakBtn setHidden:YES];
    [self.textField setHidden:NO];
    [self setFrame:CGRectMake(0, ScreenHeight-50.f, ScreenWidth, 50.f)];
}

@end
