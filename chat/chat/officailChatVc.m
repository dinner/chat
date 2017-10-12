//
//  officailChatVc.m
//  CalendarDiary
//
//  Created by James on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#define CELL_HEIGHT     100.f
#define BACKGROUND_COLOR    [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.f]

#import "officailChatVc.h"
#import "officialChatCell.h"
#import "officialCellModel.h"
#import "officialChatCellView.h"
//#import "Masonry.h"
#import "XMPP.h"
#import "ChatTimeCell.h"

@interface officailChatVc()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* m_dataArray;
}
@end

@implementation officailChatVc

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    [self dataInit];
    [self tableInit];
//    [self notificationInit];
}

-(id)init{
    self = [super init];
    if (self) {
        [self dataInit];
//        [self notificationInit];
//        [self tableInit];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self tableRresh];
}

//数据初始化
-(void)dataInit{
    self.navigationItem.title = @"官方消息";
    m_dataArray = [NSMutableArray array];
//    officialCellModel* model = [[officialCellModel alloc] init];
//    [model setStrContent:@"我哈哈哈哈"];
//    [model setStrTitle:@"你好"];
//    [model setPicUrl:nil];
//    model
//    [m_dataArray addObject:model];
}

/*
//监听
-(void)notificationInit{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveInfo:) name:RECEIVE_MES object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picUploadSuc:) name:PIC_SEND_SUC object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
 */

//table初始化
-(void)tableInit{
    m_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.f, ScreenWidth, ScreenHeight-64.f) style:UITableViewStylePlain];
    [m_table setBackgroundColor:BACKGROUND_COLOR];
    m_table.delegate = self;
    m_table.dataSource = self;
    m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_table.allowsSelection = NO;
    m_table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:m_table];
//    [m_table registerNib:[UINib nibWithNibName:@"officialChatCell" bundle:nil] forCellReuseIdentifier:@"officialCell"];
}
//table刷新
-(void)tableRresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_table reloadData];
    });
}

#pragma mark uitableDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    officialCellModel* model = (officialCellModel*)[m_dataArray objectAtIndex:indexPath.row];
    if (model.type == e_time) {
        return 30.f;
    }
    else{
    return CELL_HEIGHT;
    }
}

#pragma mark uitableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return m_dataArray.count;
//    return 1;
}
//cell绘制
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    officialCellModel* model = (officialCellModel*)[m_dataArray objectAtIndex:indexPath.row];
    if (model.type == e_time) {
        static NSString* strCell = @"timeCell";
        ChatTimeCell* cell = [tableView dequeueReusableCellWithIdentifier:strCell];
        if (!cell) {
            cell = [[ChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        }
        [cell.lb_time setText:model.strDate];
        [cell.lb_time sizeToFit];
        cell.backgroundColor = BACKGROUND_COLOR;
        return cell;
    }
    else{
        static NSString* strCell = @"cell";
        officialChatCell* cell = [tableView dequeueReusableCellWithIdentifier:strCell];
        if (!cell) {
            cell = [[officialChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        }
        [cell setInfo:[m_dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
}
//接收到消息
-(void)receiveInfo:(NSNotification*)not{
    XMPPMessage* message = [not.userInfo objectForKey:@"message"];
    NSString* strFrom = message.fromStr;
    NSString* fromId = [[strFrom componentsSeparatedByString:@"@"] firstObject];//获取id号
//    if (![fromId isEqualToString:OFFICIAL_ID]) {
//        return;
//    }
    NSString* strBody = message.body;
    NSData* data = [strBody dataUsingEncoding:NSUTF8StringEncoding];
    if (data != nil) {
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [self addTimeInfo];//添加时间源
        officialCellModel* model = [[officialCellModel alloc] init];
        model.strContent = dic[@"content"];
        model.strTitle = dic[@"title"];
        model.picUrl = dic[@"head"];
        model.type = e_info;
        model.strDate = dic[@"time"];
        [m_dataArray addObject:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_table reloadData];
        });
    }
}
//时间
-(void)addTimeInfo{
    NSDate * date = [NSDate date];
    NSString* strDate = [util dateToString:date];
    officialCellModel* model = [[officialCellModel alloc] init];
    model.strDate = strDate;
    model.type = e_time;
    [m_dataArray addObject:model];
}

-(NSArray*)getDataSource{
    return m_dataArray;
}



@end
