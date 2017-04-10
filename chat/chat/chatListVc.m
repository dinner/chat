//
//  chatListVc.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/14.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "chatListVc.h"
#import "chatVc.h"
#import "AFNetworking.h"
#import "ChatListCell.h"
#import "ChartCellFrame.h"
#import "officailChatVc.h"
#import "officialCellModel.h"

#import "UIAppDelegate.h"
#import "SVProgressHUD.h"
#import "UIAppDelegate.h"

#define CELL_HEIGHT     90.f
@interface chatListVc ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* m_table;
    
    UIButton* btRetry;
    
    UIView* backView;
}

@end
//static chatListVc* vc = nil;
@implementation chatListVc

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationBar setHidden:NO];
//    [self dataInit];
    [self tableInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMes:) name:RECEIVE_MES object:nil];
    self.navigationItem.title = @"聊天列表";
    //添加聊天按钮
    UIBarButtonItem* btAdd = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(btAddClicked:)];
    self.navigationItem.rightBarButtonItem = btAdd;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppLogin:) name:@"xmppLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutMes:) name:@"logOutMes" object:nil];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"xmppLogin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logOutMes" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    //好友列表刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_table reloadData];
    });
    
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    XMPPStream* xs = dele.xmppStream;
    if (xs.isAuthenticated == NO) {
        self.tabBarController.title = @"未连接";
        if (backView == nil) {
            backView = [[UIView alloc] initWithFrame:ScreenBounds];
            [dele.window addSubview:backView];
        }
        [backView setHidden:NO];
        [SVProgressHUD showWithStatus:@"正在连接"];
        UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
        [dele connectToxmpp];
    }
    else{
        self.tabBarController.title = @"好友";
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_table reloadData];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
    [backView setHidden:YES];
}

-(void)xmppLogin:(NSNotification*)not{
    [SVProgressHUD dismiss];
    [backView setHidden:YES];
    
    NSDictionary* info = not.userInfo;
    if ([[info objectForKey:@"result"] intValue] == 0) {//连接失败
        if (btRetry == nil) {
            btRetry = [UIButton buttonWithType:UIButtonTypeCustom];
            [btRetry setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            btRetry.layer.cornerRadius = 2.f;
            btRetry.layer.masksToBounds = YES;
            btRetry.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btRetry.layer.borderWidth = 0.3f;
            
            [btRetry setFrame:CGRectMake(0, 0, 120, 45)];
            [btRetry setCenter:CGPointMake(ScreenWidth/2, ScreenHeight/2)];
            [self.view addSubview:btRetry];
            
            [btRetry setTitle:@"重新连接" forState:UIControlStateNormal];
            [btRetry addTarget:self action:@selector(loginXmpp) forControlEvents:UIControlEventTouchUpInside];
        }
        [btRetry setHidden:NO];
    }
    else{//连接成功
        self.tabBarController.title = @"好友";
        [btRetry setHidden:YES];
    }
}
//登录xmpp
-(void)loginXmpp{
    [btRetry setHidden:YES];
    
    [backView setHidden:NO];
    [SVProgressHUD showWithStatus:@"正在连接"];
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    [dele connectToxmpp];
}

//注销
-(void)logOutMes:(id)sender{
    self.tabBarController.title = @"未连接";
}

//table初始化
-(void)tableInit{
    m_table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    m_table.delegate = self;
    m_table.dataSource = self;
    m_table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [m_table registerNib:[UINib nibWithNibName:@"ChatListCell" bundle:nil] forCellReuseIdentifier:@"chatListCell"];
    [self.view addSubview:m_table];
}
//
-(void)dataInit{
    self.m_chatFriendListDataSource = [NSMutableDictionary dictionary];
    self.m_chatArray = [NSMutableDictionary dictionary];
}

+(chatListVc*)getInstance{
    static chatListVc *vc = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        vc = [[self alloc] init];
        [vc dataInit];
    });
    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加按钮点击
-(void)btAddClicked:(id)sender{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"添加"
                                                     message:@"用户Id"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定", nil];
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //可以调整弹出框在屏幕上的位置
    [prompt show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    if (buttonIndex == 0) {
    }
    else{
        ///根据id获取好友信息
        UITextField* tf = [alertView textFieldAtIndex:0];
        NSString* strUser = tf.text;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/json"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        //单向验证
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];
        NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        NSArray *cerSet = [[NSArray alloc] initWithObjects:cerData, nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [securityPolicy setAllowInvalidCertificates:YES];
        [securityPolicy setPinnedCertificates:cerSet];
        manager.securityPolicy = securityPolicy;
        
        NSString* strUrl = [NSString stringWithFormat:@"%@/getFriendHead",SERVER];
        
        NSDictionary* dic = [NSDictionary dictionaryWithObject:strUser forKey:@"user"];
        
        [manager POST:strUrl parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSLog(@"%@",responseObject);
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([[dic objectForKey:@"result"] intValue] == 1) {//请求成功
                if ([_m_chatArray objectForKey:tf]) {
                    chatVc* vc = [_m_chatArray objectForKey:tf];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else{
                    NSString* strHead = [dic objectForKey:@"head"];
                    NSString* friendHeadUrl = [NSString stringWithFormat:@"%@/%@",IMGSERVER,strHead];
                    chatVc* vc = [[chatVc alloc] init];
                    vc.m_strFriendHeadUrl = friendHeadUrl;//好友头像
                    vc.m_strFriendId = strUser;//好友账号
//                    [vc addObserver:self forKeyPath:@"cellFrames" options:NSKeyValueObservingOptionNew context:nil];
                    [self.m_chatArray setObject:vc forKey:strUser];
                    //tableview刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [m_table reloadData];
                    });
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else{//请求失败
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"没有该用户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error:%@",error);
        }];
    }
}

//接收到消息
-(void)receiveMes:(NSNotification*)not{
    NSLog(@"收到消息");
    //
//    XMPPMessage* message = [not.userInfo objectForKey:@"message"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [m_table reloadData];
    });
}

-(chatVc*)getChatVc:(NSString*)tf head:(NSString *)strHead{
    if ([_m_chatArray objectForKey:tf]) {
        chatVc* vc = [_m_chatArray objectForKey:tf];
        return vc;
    }
    else{
        if ([tf isEqualToString:OFFICIAL_ID]) {//官方id
            officailChatVc* vc = [[officailChatVc alloc] init];
            vc.m_strFriendId = tf;
            vc.m_strFriendHeadUrl = OFFICIAL_HEAD;
            [vc fetchTheDb];
            [_m_chatArray setObject:vc forKey:tf];
            return vc;
        }
        else{//好友id
            chatVc* vc = [[chatVc alloc] init];
            vc.m_strFriendId = tf;
            vc.m_strFriendHeadUrl = strHead;
            [vc fetchTheDb];
            [_m_chatArray setObject:vc forKey:tf];
            return vc;
        }
    }
}

#pragma mark tableDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [self.m_chatArray allKeys].count;
    return count;
}
//cell绘制
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* strCell = @"chatListCell";
    ChatListCell* cell = (ChatListCell*)[tableView dequeueReusableCellWithIdentifier:strCell];
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
    }
    NSInteger index = indexPath.row;
    chatVc* vc = [[self.m_chatArray allValues] objectAtIndex:index];
    NSString* friendId = [vc.m_strFriendId copy];
    if (vc) {
        if ([vc isKindOfClass:[officailChatVc class]]) {//官方消息
            officailChatVc* official = (officailChatVc*)vc;
            officialCellModel* model = (officialCellModel*)[[official getDataSource] lastObject];
            
            [cell setInfo:model type:e_official];
        }
        else{
            chatListCellInfoModel* model = [[chatListCellInfoModel alloc] init];
//            [cell setInfo:model type:e_friend];
            model.user = vc.m_strFriendId;
            model.img = vc.m_strFriendHeadUrl;
            model.content = [[[vc.cellFrames lastObject] chartMessage] content];
            model.time = [[vc.cellFrames lastObject] m_strDate];
            [self.m_chatFriendListDataSource setObject:model forKey:friendId];
//            [cell setInfo:model type:e_official];
            [cell setInfo:model type:e_friend];
        }
    }
    
//  chatListCellInfoModel* model = (chatListCellInfoModel*)[[self.m_chatFriendListDataSource allValues] objectAtIndex:index];
    
    return cell;
}
//cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}
//cell点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    NSString* strFriend = [[self.m_chatFriendListDataSource allKeys] objectAtIndex:row];
    //判断是否为admin消息，amdmin消息默认为系统消息，绘制不同
    if ([strFriend isEqualToString:OFFICIAL_ID]) {
        officailChatVc* vc = [self.m_chatArray objectForKey:OFFICIAL_ID];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        chatVc* vc = [self.m_chatArray objectForKey:strFriend];
        [self.navigationController pushViewController:vc animated:YES ];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%ld",(long)indexPath.row);
        NSString* key = [self.m_chatArray.allKeys objectAtIndex:indexPath.row];
        [self.m_chatArray removeObjectForKey:key];
        [self.m_chatFriendListDataSource removeObjectForKey:key];
        // Delete the row from the data source.
        [m_table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(NSMutableDictionary*)getFriendListDic{
    return self.m_chatFriendListDataSource;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"cellFrame"]){//这里只处理balance属性
        NSLog(@"keyPath=%@,object=%@,newValue=%.2f,context=%@",keyPath,object,[[change objectForKey:@"new"] floatValue],context);
    }
}

#pragma mark btAddClicked
-(void)singleAddClicked{
    [self btAddClicked:nil];
}


@end
