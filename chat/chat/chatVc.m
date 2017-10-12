//
//  chatVc.m
//  UINavigationTest
//
//  Created by James on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "chatVc.h"
#import "ChartCell.h"
#import "KeyBordVIew.h"
#import "XMPPFramework.h"
#import "ChartCellFrame.h"
#import "AppDelegate.h"
#import "util.h"
#import "FaceBoard.h"
#import "addOperateView.h"
#import "ChatTimeCell.h"
#import "MJRefresh.h"
#import <AVFoundation/AVFoundation.h>
#import "FSAudioStream.h"
#import "AFNetworking.h"
#import "lame.h"
#import "Mes.h"

#define AddOperateHeight       200.f
#define KeyBoardHeight          50.f

@interface chatVc ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    CGFloat scrollOffset;
    CGRect keyboarRect;
    int nPage;
    
    NSString* audioFileName,*mp3FileName;//
    AVAudioRecorder* recorder;
    NSMutableDictionary* configDic;
    
    NSMutableDictionary* dataSourcePicCellDic;
}
@property(retain,nonatomic) UITableView* tableView;
@property(retain,nonatomic) KeyBordVIew* keyBordView;
@property(retain,nonatomic) FaceBoard* faceBoardView;
@property(retain,nonatomic) addOperateView* AddOperateView;

@end

//static NSString *const cellIdentifier=@"QQChart";
@implementation chatVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tableInit];
    [self keyBordInit];
    [self emotionViewInit];
    
    [self addOperateView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imgClicked:) name:IMG_CLICKED object:nil];
    
//    [self fetchTheDb];//查询数据库
}

-(void)imgClicked:(NSNotification*)not{
    UIImageView* imgView = not.object;
    
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow* window = dele.window;
    CGRect oriRect = [imgView convertRect:imgView.bounds toView:window];//关键代码，坐标系转换
    UIImageView* copySmall = [[UIImageView alloc] init];
//    copySmall.layer.borderColor = [UIColor redColor].CGColor;
//    copySmall.layer.borderWidth = 1.f;
    copySmall.clipsToBounds = YES;
    [copySmall setContentMode:UIViewContentModeScaleAspectFill];
    [copySmall setFrame:oriRect];
    [copySmall setImage:imgView.image];
    
    UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backClicked:)];
    [backView addGestureRecognizer:tap];
    [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    
    [window addSubview:backView];
    [backView addSubview:copySmall];
    
    //显示的图片大小设置
    UIImage* image = imgView.image;
    CGFloat picHeight = image.size.height;
    CGFloat picWidth = image.size.width;
//    CGFloat picHeight = oriRect.size.height;
//    CGFloat picWidth = oriRect.size.width;
    CGFloat bigPicW;
    CGFloat bigPicH;
    if (picHeight/picWidth < ScreenHeight/ScreenWidth) {
        bigPicH = picHeight*ScreenWidth/picWidth;
        bigPicW = ScreenWidth;
    }
    else{
        bigPicH = ScreenHeight;
        bigPicW = picWidth*ScreenHeight/picHeight;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        [copySmall setFrame:CGRectMake(0, 0, bigPicW, bigPicH)];
        [copySmall setCenter:window.center];
        [backView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)backClicked:(UITapGestureRecognizer*)tap{
    UIView* bk = tap.view;
    [bk removeFromSuperview];
}

-(id)init{
    self = [super init];
    if (self) {
        [self dataInit];
        [self notificationInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self dataInit];
        [self notificationInit];
    }
    return self;
}

//数据初始化
-(void)dataInit{
    self.cellFrames = [NSMutableArray array];
    dataSourcePicCellDic = [NSMutableDictionary dictionary];
    scrollOffset = 0.f;
    nPage = 0;
    
    //配置文件读取
    [self readConfig];
}

-(void)readConfig{
    NSString* config= [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    configDic = [[NSMutableDictionary alloc] initWithContentsOfFile:config];
    
    self.m_strSelfId = configDic[@"selfUserName"];
    self.m_strFriendId = configDic[@"friendUserName"];
}

//table初始化
-(void)tableInit{
    self.navigationItem.title = self.m_strFriendId;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-KeyBoardHeight) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //添加刷新头
    __weak chatVc* vc = self;
    [vc.tableView addHeaderWithCallback:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [vc.tableView headerEndRefreshing];
            [vc fetchTheDb];
            [vc.tableView reloadData];
        });
    }];
    
    [self.view addSubview:self.tableView];
}
//键盘初始化
-(void)keyBordInit{
    NSLog(@"宽度：%.2f",ScreenWidth);
    NSLog(@"view的宽度:%.2f",CGRectGetWidth(self.view.bounds));
    self.keyBordView = [[KeyBordVIew alloc] initWithFrame:CGRectMake(0, ScreenHeight-KeyBoardHeight, ScreenWidth, KeyBoardHeight)];
    self.keyBordView.delegate = self;
    [self.view addSubview:self.keyBordView];
}
//表情包视图初始化
-(void)emotionViewInit{
    self.faceBoardView = [[FaceBoard alloc] init];
    self.faceBoardView.delegate = self;
    [self.view addSubview:self.faceBoardView];
}
//其他操作时图初始化
-(void)addOperateView{
    self.AddOperateView = [addOperateView getInstance];
    self.AddOperateView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, AddOperateHeight);
//    self.AddOperateView.dele = self;
    [self.AddOperateView.btPhoto addTarget:self action:@selector(photoSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.AddOperateView.btTakePhoto addTarget:self action:@selector(takePhotoSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.AddOperateView];
}

//监听
-(void)notificationInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveInfo:) name:RECEIVE_MES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picUploadSuc:) name:PIC_SEND_SUC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
//查询数据库
-(void)fetchTheDb{
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = [dele managedObjectContext];
    
    NSFetchRequest* fetchRec = [[NSFetchRequest alloc] init];
    [fetchRec setFetchLimit:10];
    [fetchRec setFetchOffset:10 * nPage];
    nPage++;
    //时间排序
    NSSortDescriptor*sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [fetchRec setSortDescriptors:sortDescriptors];
    
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Mes" inManagedObjectContext:context];
    [fetchRec setEntity:entity];
    NSError* error;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"author==%@ and from==%@ or to ==%@",self.m_strSelfId,self.m_strFriendId,self.m_strFriendId];
    [fetchRec setEntity:entity];
    [fetchRec setPredicate:predicate];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRec error:&error];
    
    //判断数据是否已经在数据源中存在
    
    for (int i=0;i<fetchedObjects.count;i++) {
        NSManagedObject *ob = fetchedObjects[i];
        Mes* mes = (Mes*)ob;
        ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
        ChartMessage* chartMessage = [[ChartMessage alloc] init];
        chartMessage.content = mes.content;
        
        NSLog(@"%@",mes);
        chartMessage.mesType = mes.type;
        chartMessage.date = mes.date;
        
        Mes* mesFirstObject = (Mes*)[fetchedObjects objectAtIndex:i];

        NSDate* dateDataSource;
        NSDate* dateDataKu;
        
        if (self.cellFrames.count == 0) {
            dateDataSource = [NSDate distantFuture];
            dateDataKu = mesFirstObject.date;
        }
        else{
            ChartCellFrame* cellFrameFar = [self.cellFrames objectAtIndex:0];
            dateDataSource = cellFrameFar.chartMessage.date;
            dateDataKu = mesFirstObject.date;
            
            NSLog(@"\n数据源最小时间：%@ \n数据库查找到的数据的时间：%@\n内容：%@",dateDataSource,dateDataKu,mes.content);
            NSLog(@"%d",chartMessage.mesType);
        }
        NSString* strDateDataSource = [util dateToString:dateDataSource formate:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSString* strDateDataKu = [util dateToString:dateDataKu formate:@"yyyy-MM-dd HH:mm:ss zzz"];
        if (([dateDataSource compare:dateDataKu] == NSOrderedDescending) && (![strDateDataKu isEqualToString: strDateDataSource])) {
            if (mes.type != e_timeInterval){//不是时间
                if (mes.type != e_timeInterval) {//不是时间
                    NSString* strFrom = mes.from;
                    NSString* strHead = [configDic objectForKey:@"selfUserHeaderUrl"];

                    if (mes.type == e_pic) {//图片
                        chartMessage.picType = e_serverImg;
                    }

                    if ([strFrom isEqualToString:self.m_strSelfId]) {
                        chartMessage.messageType = kMessageTo;
                        chartMessage.icon = strHead;
                    }
                    else{
                        chartMessage.messageType = kMessageFrom;
                        chartMessage.icon = self.m_strFriendHeadUrl;
                    }
                    cellFrame.chartMessage = chartMessage;
                }
                else{//是时间
                    cellFrame.m_mesType = e_timeInterval;
                    cellFrame.m_strDate = [util dateToString:mes.date];
                    cellFrame.cellHeight = TIME_CELLHEIGHT;
                    cellFrame.chartMessage = chartMessage;
                }
                [self.cellFrames insertObject:cellFrame atIndex:0];
        }
    }
    }
    //刷新table
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark notification
//图片上传成功
-(void)picUploadSuc:(NSNotification*)not{
    //发送消息
    NSDictionary* dic = not.userInfo;
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@",IMGSERVER,[dic objectForKey:@"picUrl"]];
    [self mesSend:strUrl mesType:e_pic];
    //保存到数据库
    [self saveInfoToDb:strUrl type:e_pic from:self.m_strSelfId to:self.m_strFriendId];
}

//接收到消息
-(void)receiveInfo:(NSNotification*)not{
    //判断消息来源
    XMPPMessage* message = [not.userInfo objectForKey:@"message"];
    NSString* strFrom = message.fromStr;
    NSString* fromId = [[strFrom componentsSeparatedByString:@"@"] firstObject];//获取id号
    if ([fromId isEqualToString:_m_strFriendId]) {//是该窗口好友
        [self judgeTimeJiange];
        //消息展示
        ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
        ChartMessage* chartMes = [[ChartMessage alloc] init];
        chartMes.icon = self.m_strFriendHeadUrl;
        chartMes.messageType = kMessageFrom;
        NSDate* date = [NSDate date];
        chartMes.date = date;
        NSString* strBody = message.body;
        NSData* data = [strBody dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            chartMes.content = dic[@"content"];
            chartMes.mesType = [dic[@"type"] intValue];
            int type = [dic[@"type"] intValue];
            if (type == e_pic) {
                chartMes.picType = e_serverImg;
            }
            cellFrame.chartMessage = chartMes;
            [self saveInfoToDb:dic[@"content"] type:type from:self.m_strFriendId to:self.m_strSelfId];
            [self.cellFrames addObject:cellFrame];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                //滚动到当前行
                [self tableViewScrollCurrentIndexPath];
            });
        }
    }
}
//键盘将要显示
-(void)keyboardShow:(NSNotification*)not{
    keyboarRect=[not.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    [UIView animateWithDuration:[not.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
//        [self.tableView setFrame:CGRectMake(0, -keyboarRect.size.height, ScreenWidth, ScreenHeight-keyboarRect.size.height)];
//        int cellCount = (int)self.cellFrames.count;
//        if (cellCount > 0) {
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }
//    }];
}
//键盘将要隐藏
-(void)keyboardHide:(NSNotification*)not{
    keyboarRect = [not.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    [UIView animateWithDuration:[not.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
//        [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    }];
}
//键盘将要改变
-(void)keybordChange:(NSNotification*)not{
    if ([[not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y<CGRectGetHeight(self.view.frame)) {
        [self messageViewAnimationWithMessageRect:[[not.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.keyBordView.frame
                                      andDuration:0.25
                                         andState:ZBMessageViewStateShowNone];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.keyBordView.frame
                                      andDuration:0.25
                                         andState:ZBMessageViewStateShowNone];
    }
}

//
- (void)messageViewAnimationWithMessageRect:(CGRect)rect  withMessageInputViewRect:(CGRect)inputViewRect andDuration:(double)duration andState:(ZBMessageViewState)state{
    switch (state) {
        case ZBMessageViewStateShowNone:
        {
            [UIView animateWithDuration:duration animations:^{
                [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-rect.size.height-KeyBoardHeight)];
                
                self.keyBordView.frame = CGRectMake(0, ScreenHeight-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect), ScreenWidth, CGRectGetHeight(inputViewRect));
                
                self.faceBoardView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, CGRectGetHeight(self.faceBoardView.bounds));
                self.AddOperateView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, CGRectGetHeight(self.AddOperateView.bounds));
            }];
        }
            break;
        case ZBMessageViewStateShowFace:{
            [UIView animateWithDuration:duration animations:^{
                self.keyBordView.frame = CGRectMake(0, ScreenHeight-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect), ScreenWidth, CGRectGetHeight(inputViewRect));
                
                self.faceBoardView.frame = CGRectMake(0.f, CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect), ScreenWidth,CGRectGetHeight(self.faceBoardView.frame) );
                self.AddOperateView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, CGRectGetHeight(self.AddOperateView.bounds));
                
                [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-self.faceBoardView.bounds.size.height-KeyBoardHeight)];
            }];
        }
            break;
        case ZBMessageViewStateShowShare:{
            [UIView animateWithDuration:duration animations:^{
                self.keyBordView.frame = CGRectMake(0, ScreenHeight-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect), ScreenWidth, CGRectGetHeight(inputViewRect));
                self.faceBoardView.frame = CGRectMake(0.f, ScreenHeight, ScreenWidth,CGRectGetHeight(self.faceBoardView.frame) );
                self.AddOperateView.frame = CGRectMake(0.f, CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect), ScreenWidth,CGRectGetHeight(self.AddOperateView.frame) );
                
                [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-self.AddOperateView.bounds.size.height-KeyBoardHeight)];
            }];
        }break;
    }
    [self tableViewScrollCurrentIndexPath];
}

-(void)tableViewScrollCurrentIndexPath
{
    NSIndexPath *indexPath;
    if (self.cellFrames.count == 0) {
        indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
    }
    else{
        //        indexPath=[NSIndexPath indexPathForRow:self.cellFrames.count-1 inSection:0];
        //        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        id lastOject = [self.cellFrames lastObject];
        int indexOfLastRow = [self.cellFrames indexOfObject:lastOject];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLastRow inSection:0]
           atScrollPosition:UITableViewScrollPositionBottom
                   animated:YES];
    }
}

#pragma mark tableDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = self.cellFrames.count;
    return self.cellFrames.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isAddToPicDic = NO;
    ChartCellFrame* cellFrame = self.cellFrames[indexPath.row];
    if (cellFrame.m_mesType == e_timeInterval) {//时间间隔
        ChatTimeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
        if (!cell) {
            cell = [[ChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeCell"];
        }
        
        [cell.lb_time setText:cellFrame.m_strDate];
        [cell.lb_time sizeToFit];
        return cell;
    }
    else{//消息内容
        ChartCell* cell = nil;
        NSString* cellIdentifier = nil;
        if (cellFrame.chartMessage.messageType == kMessageFrom) {
            if (cellFrame.chartMessage.mesType == e_text) {//text
                cellIdentifier = @"From_text";
                cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
            else if (cellFrame.chartMessage.mesType == e_pic){//pic
                cellIdentifier = @"From_pic";
                if (cellFrame.fileUploadOrDownLoadManager.bIsSuc == YES) {
                    cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                }
                else{
                    cell = (ChartCell*)[tableView cellForRowAtIndexPath:indexPath];
                }
            }
            else{//audio
                cellIdentifier = @"From_audio";
                cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
        }
        else{
            if (cellFrame.chartMessage.mesType == e_text) {//text
                cellIdentifier = @"To_text";
                cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
            else if (cellFrame.chartMessage.mesType == e_pic){//pic
                cellIdentifier = @"To_pic";
                /*
                if (cellFrame.fileUploadOrDownLoadManager.bIsSuc == YES) {
                    cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                }
                else{
                    NSUInteger index = self.cellFrames.count - indexPath.row;
                    if ([dataSourcePicCellDic objectForKey:[NSNumber numberWithInteger:index]] != nil) {
                        cell = [dataSourcePicCellDic objectForKey:[NSNumber numberWithInteger:index]];
                    }
                    else{
                        cell = (ChartCell*)[tableView cellForRowAtIndexPath:indexPath];
                        isAddToPicDic = YES;
                    }
                }
                 */
                cell = (ChartCell*)[tableView cellForRowAtIndexPath:indexPath];
            }
            else{//audio
                cellIdentifier = @"To_audio";
                cell = (ChartCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
        }
        
        if (!cell) {
            cell = [[ChartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            if (isAddToPicDic == YES) {
                [dataSourcePicCellDic setObject:cell forKey:[NSNumber numberWithInteger:self.cellFrames.count - indexPath.row]];
            }
        }
        cell.cellType = ZBMessageSingle;
        cell.cellFrame = cellFrame;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = [self.cellFrames[indexPath.row] cellHeight];
    return [self.cellFrames[indexPath.row] cellHeight];
}

#pragma mark keyboradDelegate

//开始录音
-(void)beginRecord{
    [util showTheMbprogressView:@"正在录音" view:self.view];
    NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
        [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];//
        [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];//采样率
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];//声音通道，这里必须为双通道
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];//音频质量
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    audioFileName = [NSString stringWithFormat:@"rec_%@.caf",[dateFormater stringFromDate:now]];
    mp3FileName = [NSString stringWithFormat:@"rec_%@.mp3",[dateFormater stringFromDate:now]];
    
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolde = [folders objectAtIndex:0];
    audioFileName = [documentsFolde stringByAppendingPathComponent:audioFileName];
    mp3FileName = [documentsFolde stringByAppendingPathComponent:mp3FileName];
    NSError* error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:audioFileName] settings:recordSetting error:&error];
    if (error != nil) {
        NSLog(@"%@",error.description);
    }
    recorder.delegate = self;
    [recorder prepareToRecord];
    
    recorder.meteringEnabled = YES;
    [recorder peakPowerForChannel:0];
    
    //开始录
    [recorder record];
}

//结束录音
-(void)finishRecord{
    if (recorder.isRecording) {
        [recorder stop];
    }
    recorder = nil;
//    
//    ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
//    ChartMessage *chartMessage=[[ChartMessage alloc]init];
//    chartMessage.icon = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];;
//    chartMessage.messageType = kMessageTo;
//    chartMessage.content = ;
//    chartMessage.date = [NSDate date];
//    chartMessage.mesType = e_audio;
//    cellFrame.chartMessage = chartMessage;
//    [self.cellFrames addObject:cellFrame];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//    });
//    
    BOOL isTransSuc = [self cafToMp3];
    if (isTransSuc == YES) {
        //发送音频到服务器
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = YES;
        manager.securityPolicy  = securityPolicy;
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString* strPostUrl = [NSString stringWithFormat:@"%@/imageUpload",SERVER];
        AFHTTPRequestOperation  * o2= [manager POST:strPostUrl parameters:nil                                  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData* data = [NSData dataWithContentsOfFile:mp3FileName];
            [formData appendPartWithFileData:data name:@"file"fileName:@"audio.mp3"mimeType:@"audio/mp3"];
        }success:^(AFHTTPRequestOperation *operation,id responseObject){
            NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString* strAudio = dic[@"url"];
            strAudio = [NSString stringWithFormat:@"%@/%@",IMGSERVER,strAudio];
            [self mesSend:strAudio mesType:e_audio];
        }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
            NSLog(@"录音上传失败");
        }];
        
        //设置上传操作的进度
        [o2 setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten/totalBytesExpectedToWrite;
            NSLog(@"%.2f",progress);
        }];
        [o2 resume];
    }
}

-(BOOL)cafToMp3{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FileName error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        FILE *pcm = fopen([audioFileName cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        if(pcm == NULL)
        {
            NSLog(@"file not found");
        }
        else
        {
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FileName cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
            lame_set_in_samplerate(lame, 8000.0);//11025.0
            //lame_set_VBR(lame, vbr_default);
            lame_set_brate(lame,8);
            lame_set_mode(lame,3);
            lame_set_quality(lame,2); /* 2=high 5 = medium 7=low 音质*/
            lame_init_params(lame);
            
            do {
                read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
            return YES;
        }
        return NO;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    @finally {
        NSLog(@"执行完成");
    }
}

-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag{
    if (flag){
//        NSLog(@"Successfully stopped the audio recording process.");
//        [self initPlayer];
//        NSError* error;
//        AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:audioFileName] error:&error];
//        
//        if (audioPlayer!=nil){
//            audioPlayer.volume = 1;
//            audioPlayer.delegate=self;
//            [audioPlayer prepareToPlay];
//            [audioPlayer play];
//            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//    }
    }else {
        NSLog(@"Stopping the audio recording failed.");
    }
}

-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled{
    NSString* strText = textFiled.text;
    if ([strText isEqualToString:NULL_STR]) {
        [util showTheMbprogressView:@"发送信息不能为空" view:self.view];
        return;
    }
    [textFiled setText:NULL_STR];
    
    [self judgeTimeJiange];
//    [self saveInfoToDb:strText type:e_text from:self.m_strSelfId to:self.m_strFriendId];
    [self mesSend:strText mesType:e_text];
}
//存储到数据酷
-(void)saveInfoToDb:(NSString*)strMes type:(enum mesType_enum)e from:(NSString*)from to:(NSString*)to{
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* contetx = [dele managedObjectContext];
    Mes* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"Mes" inManagedObjectContext:contetx];
    contactMode.from = from;
    contactMode.to = to;
    NSDate* date = [NSDate date];
    contactMode.date = date;
    //解析
    contactMode.content = strMes;
    contactMode.type = e;//消息类型
    contactMode.author = self.m_strSelfId;
//    contactMode.singleOrGroup = ZBMessageSingleChat;
    //
    NSError* error;
    if (![contetx save:&error]) {
        NSLog(@"error");
    }
    else{
        NSLog(@"插入成功");
    }
}

-(void)saveInfoToDb:(NSString*)strMes type:(enum mesType_enum)e from:(NSString*)from to:(NSString*)to date:(NSDate*)date{
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* contetx = [dele managedObjectContext];
    Mes* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"Mes" inManagedObjectContext:contetx];
    contactMode.from = from;
    contactMode.to = to;
//    NSDate* date = [NSDate date];
    contactMode.date = date;
    //解析
    contactMode.content = strMes;
    contactMode.type = e;//消息类型
//    NSLog(@"%@",contactMode.type);
    contactMode.author = self.m_strSelfId;
    //    contactMode.singleOrGroup = ZBMessageSingleChat;
    //
    NSError* error;
    if (![contetx save:&error]) {
        NSLog(@"error");
    }
    else{
        NSLog(@"插入成功");
    }
}
//表情点击
-(void)singleEmotionClicked:(NSString*)strPic{
    [self.keyBordView.textField setText:[NSString stringWithFormat:@"%@%@",self.keyBordView.textField.text,strPic]];
}

//信息发送 刷新列表
-(void)mesSend:(NSString*)strText mesType:(enum mesType_enum)e{
    NSString* userHead = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];
    //信息发送
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    XMPPStream* xmppStream = dele.xmppStream;
    //日期
    NSDate* date = [NSDate date];
    NSString* strDate = [util dateToString:date];
    //信息发送
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (userHead != nil) {
        [dic setObject:userHead forKey:@"head"];
    }
    [dic setObject:self.m_strFriendId forKey:@"name"];
    [dic setObject:strText forKey:@"content"];
    [dic setObject:strDate forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:e] forKey:@"type"];
    [dic setObject:[NSNumber numberWithInt:e_official] forKey:@"laiyuan"];//放置来源标识
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* strBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSXMLElement* body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:strBody];
    NSXMLElement* message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    NSString* to = [NSString stringWithFormat:@"%@@%@/Smack",self.m_strFriendId,OPENFIRE_DOMAIN];
//    NSString* from = [NSString stringWithFormat:@"%@@%@/Smack",self.m_strSelfId,OPENFIRE_DOMAIN];
    
    NSString* to = [NSString stringWithFormat:@"%@@%@/Spark",self.m_strFriendId,OPENFIRE_DOMAIN];
    NSString* from = [NSString stringWithFormat:@"%@@%@/Spark",self.m_strSelfId,OPENFIRE_DOMAIN];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addAttributeWithName:@"from" stringValue:from];
    [message addChild:body];
    [xmppStream sendElement:message];

    NSLog(@"%@",date);
    [self saveInfoToDb:strText type:e from:self.m_strSelfId to:self.m_strFriendId date:date];
    
    if (e != e_pic) {//非图片才刷新列表
        ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
        ChartMessage *chartMessage=[[ChartMessage alloc]init];
        
        chartMessage.icon = userHead;
        chartMessage.messageType = kMessageTo;
        chartMessage.content = strText;
        chartMessage.date = [NSDate date];
        chartMessage.mesType = e;
        cellFrame.chartMessage = chartMessage;
        [self.cellFrames addObject:cellFrame];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            //滚动到当前行
            [self tableViewScrollCurrentIndexPath];
        });
    }
}
//判断此时是否距离上次已经过去60s 若是，保存时间间隔数据到数据源
-(void)judgeTimeJiange{
    NSDate* currentDate = [NSDate date];
    ChartCellFrame* lastDateCell = [self.cellFrames lastObject];
    NSDate* lastDate = lastDateCell.chartMessage.date;
    if([currentDate timeIntervalSinceDate:lastDate] > TIMEOUT_SECOND){//大于60s
        ChartCellFrame *timeCellFrame=[[ChartCellFrame alloc]init];
        timeCellFrame.m_mesType = e_timeInterval;
        timeCellFrame.m_strDate = [util dateToString:currentDate];
        timeCellFrame.cellHeight = TIME_CELLHEIGHT;
        [self.cellFrames addObject:timeCellFrame];
        
        //保存到数据库
        AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* contetx = [dele managedObjectContext];
        Mes* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"Mes" inManagedObjectContext:contetx];
        NSDate* date = [NSDate date];
        contactMode.date = date;
        //解析
        contactMode.type = e_timeInterval;//消息类型
        contactMode.author = self.m_strSelfId;
        contactMode.from = self.m_strSelfId;
        contactMode.to = self.m_strFriendId;
//       contactMode.singleOrGroup = ZBMessageSingleChat;
        
        //
        NSError* error = nil;
        if ([contetx save:&error] == NO) {
            NSLog(@"error");
        }
        else{
            NSLog(@"插入成功");
        }
    }
}

-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledBegin:(UITextField *)textFiled{
    
}

#pragma mark uiscrollDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"滑动");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset

{
    NSLog(@"%f",velocity.y);
    if (velocity.y > 0.f) {
        [self.keyBordView resignTextResponse];
        [self.keyBordView backToOrigin];
        [self.faceBoardView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, AddOperateHeight)];
        [self.AddOperateView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, AddOperateHeight)];
        [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-KeyBoardHeight)];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
    }
}

#pragma mark keyboardDelegate
-(void)voiceAndKeyBoradClicked:(BOOL)isVoice{
    
}
//表情点击
-(void)emotionClicked:(BOOL)bIsEmotion{
    if (bIsEmotion) {
        [self messageViewAnimationWithMessageRect:self.faceBoardView.frame withMessageInputViewRect:self.keyBordView.frame andDuration:0.25f andState:ZBMessageViewStateShowFace];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero withMessageInputViewRect:self.keyBordView.frame andDuration:0.25f andState:ZBMessageViewStateShowFace];
    }
}
//图片添加点击
-(void)btAddPicClicked:(BOOL)bIs{
    if (bIs) {
        [self messageViewAnimationWithMessageRect:self.AddOperateView.frame withMessageInputViewRect:self.keyBordView.frame andDuration:0.25f andState:ZBMessageViewStateShowShare];
    }
    else{
        [self messageViewAnimationWithMessageRect:CGRectZero withMessageInputViewRect:self.keyBordView.frame andDuration:0.25f andState:ZBMessageViewStateShowShare];
    }
}

#pragma mark addDelegate
-(void)photoSelect{
    NSLog(@"相册选择");
    UIImagePickerController* vc =[[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.allowsEditing = YES;
    [self presentModalViewController:vc animated:YES];
}
-(void)takePhotoSelect{
    NSLog(@"照相选择");
    UIImagePickerController* vc =[[UIImagePickerController alloc] init];
    vc.delegate = self;
    vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    vc.allowsEditing = YES;
    [self presentModalViewController:vc animated:YES];
}

#pragma mark imageDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSString* strFileUrl = [editingInfo[UIImagePickerControllerReferenceURL] absoluteString];
    //添加图片数据元
    [self judgeTimeJiange];
    NSString* userHead = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];
    ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
    ChartMessage* chartMessage = [[ChartMessage alloc] init];
    chartMessage.content = strFileUrl;
    chartMessage.mesType = e_pic;
    NSDate* date = [NSDate date];
    chartMessage.date = date;
    chartMessage.messageType = kMessageTo;
    chartMessage.icon = userHead;
    chartMessage.image = image;
    cellFrame.chartMessage = chartMessage;
    [self.cellFrames addObject:cellFrame];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self messageViewAnimationWithMessageRect:CGRectZero withMessageInputViewRect:self.keyBordView.frame andDuration:0.25f andState:ZBMessageViewStateShowNone];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark audioplayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    [player stop];
    player = nil;
}

-(void)dealloc{
    NSLog(@"chatVc dealloc");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVE_MES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PIC_SEND_SUC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
