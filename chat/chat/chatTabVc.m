//
//  chatTabVc.m
//  CalendarDiary
//
//  Created by zhanglingxiang on 15/9/8.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "chatTabVc.h"


@interface chatTabVc ()<UITabBarControllerDelegate>
{
    NSInteger currentTag;
}
@end

@implementation chatTabVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"好友";
    
//    self.groupVc = [[groupChatListVc alloc] init];
    self.groupVc = [groupChatListVc getInstance];
    self.singleChatVc = [chatListVc getInstance];
    
    self.singleClickDelegate = self.singleChatVc;
    self.groupClickDelegate = self.groupVc;
    
    self.viewControllers = [NSArray arrayWithObjects:self.singleChatVc,self.groupVc, nil];
    self.delegate = self;
    self.groupVc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"群组" image:[UIImage imageNamed:@"groupChat"] tag:1];
    self.singleChatVc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好友" image:[UIImage imageNamed:@"singleChat"] tag:0];
    currentTag = 0;
    //
    //添加聊天按钮
    UIBarButtonItem* btAdd = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add.png"] style:UIBarButtonItemStylePlain target:self action:@selector(btAddClicked:)];
    self.navigationItem.rightBarButtonItem = btAdd;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(id)getInstance{
    static chatTabVc *vc = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        vc = [[self alloc] init];
    });
    return vc;
}

#pragma tabbar
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSLog(@"切换");
    if ([viewController isKindOfClass:[self.singleChatVc class]]) {
        self.navigationItem.title = @"好友";
        currentTag = 0;
    }
    else{
        self.navigationItem.title = @"群组";
        currentTag = 1;
    }
}

//添加按钮点击
-(void)btAddClicked:(id)sender{
    if (currentTag == 0) {
        [self.singleClickDelegate singleAddClicked];
    }
    else{
        [self.groupClickDelegate groupAddClicked];
    }
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
