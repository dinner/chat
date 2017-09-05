//
//  chatVc.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/17.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "groupChatVc.h"
#import "ChartCell.h"
#import "KeyBordVIew.h"
#import "XMPPFramework.h"
#import "ChartCellFrame.h"
#import "UIAppDelegate.h"
#import "util.h"
#import "FaceBoard.h"
#import "addOperateView.h"
#import "ChatTimeCell.h"
#import "MJRefresh.h"
#import "chatVc.h"
#import "MessageGroup.h"
//#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"

#define AddOperateHeight       200.f
#define KeyBoardHeight          50.f

@interface groupChatVc ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate>
{
    CGFloat scrollOffset;
    CGRect keyboarRect;
    int nPage;
    
    AVAudioRecorder* recorder;
    NSString* audioFileName;
}
@property(retain,nonatomic) UITableView* tableView;
@property(retain,nonatomic) KeyBordVIew* keyBordView;
@property(retain,nonatomic) FaceBoard* faceBoardView;
@property(retain,nonatomic) addOperateView* AddOperateView;


@end

static NSString *const cellIdentifier=@"QQChart";
@implementation groupChatVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tableInit];
    [self keyBordInit];
    [self emotionViewInit];
    
    [self addOperateView];
    //    [self fetchTheDb];//查询数据库
}

-(id)initWithRoomName:(NSString*)strRoom{
    self = [self init];
    if (self) {
        self.strName = strRoom;
        [self dataInit];
        [self fetchTheDb];
    }
    return self;
}

-(id)init{
    self = [super init];
    if (self) {
        [self dataInit];
        [self fetchTheDb];
        [self notificationInit];
    }
    return self;
}

//数据初始化
-(void)dataInit{
    self.cellFrames = [NSMutableArray array];
    scrollOffset = 0.f;
    nPage = 0;
    self.m_strSelfId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
}

//table初始化
-(void)tableInit{
    self.navigationItem.title = self.strName;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-KeyBoardHeight) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ChartCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //添加刷新头
    __block groupChatVc* vc = self;
    [self.tableView addHeaderWithCallback:^{
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
//    [[NSNotificationCenter defaultCenter] addObserver:self selectsor:@selector(receiveInfo:) name:RECEIVE_MES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picUploadSuc:) name:PIC_SEND_SUC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
//查询数据库
-(void)fetchTheDb{
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* context = [dele managedObjectContext];
    
    NSFetchRequest* fetchRec = [[NSFetchRequest alloc] init];
    [fetchRec setFetchLimit:10];
    [fetchRec setFetchOffset:10 * nPage];
    nPage++;
    //时间排序
    NSSortDescriptor*sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [fetchRec setSortDescriptors:sortDescriptors];
    
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"MessageGroup" inManagedObjectContext:context];
    [fetchRec setEntity:entity];
    NSError* error;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"author==%@ and groupName==%@",self.m_strSelfId,self.strName];
    [fetchRec setEntity:entity];
    [fetchRec setPredicate:predicate];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRec error:&error];
    
    for (NSManagedObject* ob in fetchedObjects) {
        MessageGroup* mes = (MessageGroup*)ob;
        ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
        cellFrame.m_userName = mes.from;
        ChartMessage* chartMessage = [[ChartMessage alloc] init];
        chartMessage.content = mes.content;
        chartMessage.mesType = mes.type.intValue;
        chartMessage.date = mes.date;
        chartMessage.icon = mes.head;
        if (mes.type != [NSNumber numberWithInt:e_timeInterval]) {
            NSString* strFrom = mes.from;
            NSString* strHead = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];
            
            if ([mes.type intValue] == e_pic) {//图片
                chartMessage.picType = e_serverImg;
            }
            
            if ([strFrom isEqualToString:self.m_strSelfId]) {
                chartMessage.messageType = kMessageTo;
                chartMessage.icon = strHead;
            }
            else{
                chartMessage.messageType = kMessageFrom;
                chartMessage.icon = mes.head;
            }
            cellFrame.chartMessage = chartMessage;
        }
        else{
            cellFrame.m_strDate = [util dateToString:mes.date];
            cellFrame.cellHeight = TIME_CELLHEIGHT;
            cellFrame.chartMessage = chartMessage;
        }
        [self.cellFrames insertObject:cellFrame atIndex:0];
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
    [self saveInfoToDb:strUrl type:e_pic from:self.m_strSelfId to:self.strName];
}

//键盘将要显示
-(void)keyboardShow:(NSNotification*)not{
    keyboarRect=[not.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//        [UIView animateWithDuration:[not.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
//            [self.tableView setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//            int cellCount = (int)self.cellFrames.count;
//            if (cellCount > 0) {
//                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            }
//        }];
}
//键盘将要隐藏
-(void)keyboardHide:(NSNotification*)not{
//        [UIView animateWithDuration:[not.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
//            self.view.transform = CGAffineTransformIdentity;
//        }];
    keyboarRect = [not.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
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
            }];
        }
            break;
        case ZBMessageViewStateShowShare:{
            [UIView animateWithDuration:duration animations:^{
                self.keyBordView.frame = CGRectMake(0, ScreenHeight-CGRectGetHeight(rect)-CGRectGetHeight(inputViewRect), ScreenWidth, CGRectGetHeight(inputViewRect));
                self.faceBoardView.frame = CGRectMake(0.f, ScreenHeight, ScreenWidth,CGRectGetHeight(self.faceBoardView.frame) );
                self.AddOperateView.frame = CGRectMake(0.f, CGRectGetHeight(self.view.frame)-CGRectGetHeight(rect), ScreenWidth,CGRectGetHeight(self.AddOperateView.frame) );
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
        NSInteger indexOfLastRow = [self.cellFrames indexOfObject:lastOject];
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
        ChartCell* cell = (ChartCell*)[tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[ChartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        //        [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //            UIView *subView = (UIView *)obj;
        //            [subView removeFromSuperview];
        //        }];
        [cell.imageView setImage:[UIImage imageNamed:@"group.icon"]];
        cell.cellType = ZBMessageGroup;
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
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled{
    NSString* strText = textFiled.text;
    if ([strText isEqualToString:NULL_STR]) {
//        [SVProgressHUD showWithStatus:@"消息内容不能为空"];
//        [SVProgressHUD dismissWithDelay:2.f];
        MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"消息内容不能为空";
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(2);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
        return;
    }
    [textFiled setText:NULL_STR];
    [self judgeTimeJiange];
    [self saveInfoToDb:strText type:e_text from:self.m_strSelfId to:self.strName];
    [self mesSend:strText mesType:e_text];
}
//存储到数据酷
-(void)saveInfoToDb:(NSString*)strMes type:(enum mesType_enum)e from:(NSString*)from to:(NSString*)to{
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext* contetx = [dele managedObjectContext];
    MessageGroup* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"MessageGroup" inManagedObjectContext:contetx];
    contactMode.from = from;
//    contactMode.author = to;
    contactMode.groupName = self.strName;
    NSDate* date = [NSDate date];
    contactMode.date = date;
    //解析
    contactMode.content = strMes;
    contactMode.type = [NSNumber numberWithInt:e];//消息类型
    contactMode.author = self.m_strSelfId;
    contactMode.head = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];
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
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    XMPPStream* xmppStream = dele.xmppStream;
    //日期
    NSDate* date = [NSDate date];
    NSString* strDate = [util dateToString:date];
    //信息发送
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:userHead forKey:@"head"];
//    [dic setObject:self.m_strFriendId forKey:@"name"];
    [dic setObject:strText forKey:@"content"];
    [dic setObject:strDate forKey:@"time"];
    [dic setObject:[NSNumber numberWithInt:e] forKey:@"type"];
    [dic setObject:[NSNumber numberWithInt:e_official] forKey:@"laiyuan"];//放置来源标识
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString* strBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSXMLElement* body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:strBody];
    NSXMLElement* message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    NSString* to = [NSString stringWithFormat:@"%@@conference.%@",self.strName,OPENFIRE_DOMAIN];
//    NSString* from = [NSString stringWithFormat:@"%@/%@",to,self.m_strSelfId];
     NSString* from = [NSString stringWithFormat:@"%@.%@",self.m_strSelfId,OPENFIRE_DOMAIN];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addAttributeWithName:@"from" stringValue:from];
    [message addChild:body];
    [xmppStream sendElement:message];
    
    if (e != e_pic) {//非图片才刷新列表
        ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
        NSString* strUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        cellFrame.m_userName = strUser;
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
        UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext* contetx = [dele managedObjectContext];
        MessageGroup* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"MessageGroup" inManagedObjectContext:contetx];
        NSDate* date = [NSDate date];
        contactMode.date = date;
        //解析
        contactMode.type = [NSNumber numberWithInt:e_timeInterval];//消息类型
        contactMode.author = self.m_strSelfId;
        contactMode.from = self.m_strSelfId;
        contactMode.groupName = self.strName;
        //
        NSError* error;
        if (![contetx save:&error]) {
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
    NSLog(@"滑动");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset

{
    NSLog(@"%f",velocity.y);
    if (velocity.y > 0.f) {
        [self.keyBordView resignTextResponse];
        [self.keyBordView backToOrigin];
        [self.faceBoardView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, AddOperateHeight)];
        [self.AddOperateView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, AddOperateHeight)];
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
    NSLog(@"相册选择");
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
    NSString* strUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
    cellFrame.m_userName = strUser;
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

#pragma mark xmppRoom 
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    NSLog(@"收到群聊消息");
    //解析from,获取群内发送者的用户名
    NSString* strChatJid = [NSString stringWithFormat:@"%@@conference.zhang",self.strName];
    NSString* strUser = [[message.fromStr componentsSeparatedByString:[NSString stringWithFormat:@"%@/",strChatJid]] lastObject];
    if ([strUser isEqualToString:self.m_strSelfId]) {//如果是自己发的不显示
        return;
    }
    //
    NSString* strBody = message.body;
    NSData* data = [strBody dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        
        ChartCellFrame* cellFrame = [[ChartCellFrame alloc] init];
        ChartMessage* chartMes = [[ChartMessage alloc] init];
//        chartMes.icon = self.m_strFriendHeadUrl;
        chartMes.messageType = kMessageFrom;
        cellFrame.m_userName = strUser;
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        chartMes.content = dic[@"content"];
        chartMes.mesType = [dic[@"type"] intValue];
        chartMes.date = [NSDate date];
        int type = [dic[@"type"] intValue];
        chartMes.icon = dic[@"head"];
        if (type == e_pic) {
            chartMes.picType = e_serverImg;
        }
        cellFrame.chartMessage = chartMes;
        [self saveInfoToDb:dic[@"content"] type:type from:strUser to:self.m_strSelfId];
        [self.cellFrames addObject:cellFrame];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self tableViewScrollCurrentIndexPath];
        });
    }
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID{
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID{
    
}

#pragma mark
-(void)beginRecord{
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    audioFileName = [NSString stringWithFormat:@"rec_%@.wav",[dateFormater stringFromDate:now]];
    
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsFolde = [folders objectAtIndex:0];
    audioFileName = [documentsFolde stringByAppendingPathComponent:audioFileName];
    NSError* error = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:audioFileName] settings:settings error:&error];
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
-(void)finishRecord{
    if (recorder.isRecording) {
        [recorder stop];
    }
    recorder = nil;
    
    //保存到数据源
    NSString* userHead = [[NSUserDefaults standardUserDefaults] objectForKey:@"userHead"];
    NSString* user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    ChartCellFrame *cellFrame=[[ChartCellFrame alloc]init];
    cellFrame.m_userName = user;
    ChartMessage *chartMessage=[[ChartMessage alloc]init];
    
    chartMessage.icon = userHead;
    chartMessage.messageType = kMessageTo;
    chartMessage.content = audioFileName;
    chartMessage.date = [NSDate date];
    chartMessage.mesType = e_audio;
    chartMessage.audioType = e_localAudio;
    cellFrame.chartMessage = chartMessage;
    [self.cellFrames addObject:cellFrame];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    //发送音频到服务器
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString* strPostUrl = [NSString stringWithFormat:@"%@/imageUpload",SERVER];
    AFHTTPRequestOperation  * o2= [manager POST:strPostUrl parameters:nil                                  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //        NSData * data=UIImagePNGRepresentation(image);
        NSData* data = [NSData dataWithContentsOfFile:audioFileName];
        [formData appendPartWithFileData:data name:@"file"fileName:@"audio.wav"mimeType:@"audio/wav"];
    }success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString* strAudio = dic[@"url"];
        strAudio = [NSString stringWithFormat:@"%@/%@",IMGSERVER,strAudio];
        //上传完成保存到数据库
        [self saveInfoToDb:strAudio type:e_audio from:self.m_strSelfId to:self.strName];
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        
    }];
    
    //设置上传操作的进度
    [o2 setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        CGFloat progress = totalBytesWritten/totalBytesExpectedToWrite;
    }];
    [o2 resume];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
