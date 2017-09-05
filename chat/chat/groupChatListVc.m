//
//  groupChatListVc.m
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/8.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "groupChatListVc.h"
#import "ChatListCell.h"
#import "XMPP.h"
#import "XMPPRoom.h"
#import "UIAppDelegate.h"
#import "groupChatVc.h"
#import "ChartCellFrame.h"

@interface groupChatListVc ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* m_table;

    UIView* backView;
}
@end

@implementation groupChatListVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tableInit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_table reloadData];
    });
    
    UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
    XMPPStream* xs = dele.xmppStream;
    
    if (xs.isAuthenticated == NO) {
        self.tabBarController.selectedIndex = 0;
    }
    
    /*
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
        self.tabBarController.title = @"群组";
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_table reloadData];
        });
    }
*/
}

-(id)init{
    self = [super init];
    if (self) {
        [self dataInit];
    }
    return self;
}

+(id)getInstance;{
    static groupChatListVc *vc = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        vc = [[self alloc] init];
        [vc dataInit];
    });
    return vc;
}

-(void)dataInit{
    _m_dataDic = [NSMutableDictionary dictionary];
    _m_roomNameToGroupVc = [NSMutableDictionary dictionary];
}

-(void)tableInit{
    m_table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    m_table.delegate = self;
    m_table.dataSource = self;
    [m_table registerNib:[UINib nibWithNibName:NSStringFromClass([ChatListCell class]) bundle:nil] forCellReuseIdentifier:@"chatListCell"];
    m_table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:m_table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark tableDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.f;
}

#pragma mar tableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_m_roomNameToGroupVc allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* strCell = @"chatListCell";
    ChatListCell* cell = (ChatListCell*)[tableView dequeueReusableCellWithIdentifier:strCell];

    groupChatVc* vc = [[_m_roomNameToGroupVc allValues] objectAtIndex:indexPath.row];
    
    chatListCellInfoModel* model = [[chatListCellInfoModel alloc] init];
    model.user = vc.strName;
    model.img = nil;
    model.content = [[[vc.cellFrames lastObject] chartMessage] content];
    model.time = [[vc.cellFrames lastObject] m_strDate];
    [cell setInfo:model type:e_group];
    
    return cell;
}
//cell点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* strName = [[_m_dataDic allKeys] objectAtIndex:indexPath.row];//聊天室名称
    groupChatVc* vc = [_m_roomNameToGroupVc objectForKey:strName];
    vc.strName = strName;
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%ld",(long)indexPath.row);
        NSString* key = [self.m_dataDic.allKeys objectAtIndex:indexPath.row];
        [self.m_dataDic removeObjectForKey:key];
        [self.m_roomNameToGroupVc removeObjectForKey:key];
        // Delete the row from the data source.
        [m_table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark groupDelegate
//群组添加碘剂
-(void)groupAddClicked{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"添加"
                                                     message:@"群组名称"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定", nil];
    prompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];  //可以调整弹出框在屏幕上的位置
    [prompt show];
}

#pragma mark uialertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    UITextField* tf = [alertView textFieldAtIndex:0];
    NSString* strUser = tf.text;
    if ([strUser isEqualToString:NULL_STR]) {
        return;
    }
    if (buttonIndex == 1) {
        //
        if ([[_m_roomNameToGroupVc allKeys] containsObject:strUser]) {
            groupChatVc* vc = [_m_roomNameToGroupVc objectForKey:strUser];
            [self presentViewController:vc animated:YES completion:nil];
        }
        else{
            XMPPJID* roomJID = [XMPPJID jidWithString:[NSString stringWithFormat: @"%@@conference.zhang",strUser]];
//            XMPPRoomCoreDataStorage *rosterstorage = [[XMPPRoomCoreDataStorage alloc] init];
            XMPPRoomCoreDataStorage *rosterstorage = [XMPPRoomCoreDataStorage sharedInstance];
            XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:rosterstorage jid:roomJID];
            UIAppDelegate* dele = (UIAppDelegate*)[UIApplication sharedApplication].delegate;
            XMPPStream* stream = dele.xmppStream;
            [xmppRoom activate:stream];
            
            //用户名作为昵称
            NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
            [xmppRoom joinRoomUsingNickname:userName history:nil];//加入群组
            
            chatListCellInfoModel* model = [[chatListCellInfoModel alloc] init];
            NSDate* date = [NSDate date];
            NSString* strDate = [util dateToString:date];
            model.user = strUser;
            model.time = strDate;
            //
            [_m_dataDic setObject:model forKey:strUser];//room名称和最新消息
            
            groupChatVc* vc = [[groupChatVc alloc] initWithRoomName:strUser];
//            vc.strName = strUser;
            vc.m_xmppRoom = xmppRoom;
            [xmppRoom addDelegate:vc delegateQueue:dispatch_get_main_queue()];
            [_m_roomNameToGroupVc setObject:vc forKey:strUser];
            [self.navigationController pushViewController:vc animated:YES];
            
            //刷新table
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_table reloadData];
            });
        }
    }
}

#pragma mark xmppRoom
- (void)xmppRoomDidJoin:(XMPPRoom *)xmppRoom{
    NSLog(@"xmppRoomDidJoin");
    [xmppRoom fetchConfigurationForm];
    [xmppRoom fetchBanList];
    [xmppRoom fetchMembersList];
    [xmppRoom fetchModeratorsList];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{
    NSLog(@"didNotFetchBanlist");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"didNotFetchMembersList");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    NSLog(@"didNotFetchModeratorsList");
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
