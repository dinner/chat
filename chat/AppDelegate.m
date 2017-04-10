//
//  UIAppDelegate.m
//  UINavigationTest
//
//  Created by mac on 13-9-2.
//  Copyright (c) 2013年 caobo. All rights reserved.
//

#import "AppDelegate.h"
//#import "UIRootViewController.h"
//#import "ModeTable.h"
//#import <ShareSDK/ShareSDK.h>
//#import "WXApi.h"
//#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentOAuth.h>
//#import "Weibo.h"
//#import "APService.h"
//#import "loginVc.h"
//#import "chatListVc.h"
#import "chatListCellInfoModel.h"
#import "util.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
//#import "NSData+AES256.h"
//#import "baseNavController.h"
#import "Reachability.h"

@implementation AppDelegate
@synthesize navController;

@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppReconnect;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;

- (void)dealloc
{
    //    [_window release];
    //    [super dealloc];
    //    [NSString stringWithFormat:@"http://%@:8080/calendar",IP];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"user"];
    //    if ([userId isEqualToString:NULL_STR] != nil) {
    [self setupStream];
    //        [self connectToxmpp];
    //    }
    
//    [chatListVc getInstance];
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //    if([defaults objectForKey:@"user"] == nil){//为空 直接到登陆界面
    //        loginVc* lv = [[loginVc alloc] init];
//    UIRootViewController * lv = [[UIRootViewController alloc]initWithNibName:@"MainView" bundle:nil];
//    baseNavController* nav = [[baseNavController alloc] initWithRootViewController:lv];
//    self.window.rootViewController = nav;
    //    }
    //    else{
    //        UIRootViewController * rootViewController = [[UIRootViewController alloc]initWithNibName:@"MainView" bundle:nil];
    //
    //        self.window.rootViewController = rootViewController;
    //
    //        self.navController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
    //        //设置标题字体颜色
    //        NSDictionary* textDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, [UIFont boldSystemFontOfSize:17],UITextAttributeFont,nil];
    //        [self.navController.navigationBar setTitleTextAttributes:textDic];
    //
    //        [self.navController.navigationBar setBarTintColor:[UIColor colorWithRed:70/255.f green:214/255.f blue:97/255.f alpha:1.f]];
    //        [self.navController.navigationBar setTintColor:[UIColor whiteColor]];
    //
    //        [self.window addSubview:navController.view];
    //    }
    
    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
    //sharesdk分享
//    [ShareSDK registerApp:@"64b01897d4a2"];
//    [ShareSDK importWeChatClass:[WXApi class]];
    
    /*
     //
     #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
     if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
     //可以添加自定义categories
     [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
     UIUserNotificationTypeSound |
     UIUserNotificationTypeAlert)
     categories:nil];
     } else {
     //categories 必须为nil
     [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound |
     UIRemoteNotificationTypeAlert)
     categories:nil];
     }
     #else
     //categories 必须为nil
     [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound |
     UIRemoteNotificationTypeAlert)
     categories:nil];
     #endif
     // Required
     [APService setupWithOption:launchOptions];
     */
    //检测网络状况
    [self checkTheNetworkStatus];
    
    _downloadUrlAr = [NSMutableArray array];
    
//    if (_LoInfo == nil) {
//        _LoInfo = [[loginInfo alloc] init];
//    }
    
    return YES;
}

#ifndef DISABLE_PUSH_NOTIFICATIONS

- (void)                                 application:(UIApplication*)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // re-post ( broadcast )
    //        NSString* token = [[[[deviceToken description]
    //            stringByReplacingOccurrencesOfString:@"<" withString:@""]
    //            stringByReplacingOccurrencesOfString:@">" withString:@""]
    //            stringByReplacingOccurrencesOfString:@" " withString:@""];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    
    //    [APService registerDeviceToken:deviceToken];
}

#endif
//受到推送的处理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //    [APService handleRemoteNotification:userInfo];
    //
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSDictionary* aps = [userInfo valueForKey:@"aps"];
    NSLog(@"%@",aps);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSString* strKey = [NSString stringWithFormat:@"%@zhang",[util dateToString:[NSDate date]]];
    [[NSUserDefaults standardUserDefaults] setObject:strKey forKey:AES_KEY];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
//    return [ShareSDK handleOpenURL:url
//                        wxDelegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
////    return [ShareSDK handleOpenURL:url
//                 sourceApplication:sourceApplication
//                        annotation:annotation
//                        wxDelegate:self];
    return YES;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "-1.coreDataTest1" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"modeTable" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"modeTable.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
//数据插入
-(void)insertCoreData:(enum tagType)type value:(int)value date:(NSString*)strDate{

}

//数据查询
-(void)dataFetchReq{
    NSManagedObjectContext* context = [self managedObjectContext];
    NSFetchRequest* fetchRec = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"ModeTable" inManagedObjectContext:context];
    [fetchRec setEntity:entity];
    NSError* error;
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRec error:&error];
    for (NSManagedObject* info in fetchedObjects) {
        NSLog(@"weahter:%@",[info valueForKey:@"weather"]);
        NSLog(@"mode:%@",[info valueForKey:@"mode"]);
        NSLog(@"date:%@",[info valueForKey:@"date"]);
    }
}

//数据插入
-(void)insertWeibo:(NSInteger)picNum picString:(NSString*)picString date:(NSDate*)date content:(NSString*)content addr:(NSString *)addr{
}

//微博数据删除
-(void)deleteWeibo:(NSDate*)date{
    NSManagedObject* ob = [self getWeiboManageObject:date];
    NSManagedObjectContext* context = [self managedObjectContext];
    [context deleteObject:ob];
}
//查找对应日期的微博
-(NSManagedObject*)getWeiboManageObject:(NSDate*)date{
    NSFetchRequest* pFetch = [[NSFetchRequest alloc] init];
    //设置限制
    NSSortDescriptor*sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [pFetch setSortDescriptors:sortDescriptors];
    NSManagedObjectContext* context = [self managedObjectContext];
    NSManagedObjectModel* model = [self managedObjectModel];
    NSDictionary* entities = [model entitiesByName];
    NSEntityDescription* entity = [entities valueForKey:@"Weibo"];
    //
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"date==%@",date];
    //条件
    [pFetch setEntity:entity];
    [pFetch setPredicate:predicate];
    NSArray* array = [context executeFetchRequest:pFetch error:nil];
    return array[0];
}

+(UIWindow*)getWindow{
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow* window = dele.window;
    return window;
}

#pragma mark xmpp
-(void)setupStream{
    if (xmppStream != nil) {
        xmppStream = nil;
    }
    xmppStream = [[XMPPStream alloc]init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppReconnect = [[XMPPReconnect alloc]init];
    [xmppReconnect activate:self.xmppStream];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:xmppRosterStorage];
    [xmppRoster activate:self.xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //    xmppStream.enableBackgroundingOnSocket = YES;//允许后台模式
}

-(void)goOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    //    [[self xmppStream] sendElement:presence];
    
}

-(void)goOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
    
}

-(BOOL)connectToxmpp{
    //从本地取得用户名，密码和服务器地址
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uId = [defaults objectForKey:@"user"];
    if ([uId isEqualToString:NULL_STR]) {
        return NO;
    }
    uId = [uId stringByReplacingOccurrencesOfString:@" " withString:@""];
    XMPPJID* jid = [XMPPJID jidWithUser:uId domain:@"zhang" resource:@"Spark"];
    NSString *server = OPENFIRE_SERVER;
    
    //设置用户
    [xmppStream setMyJID:jid];
    //设置服务器
    [xmppStream setHostName:server];
    
    if (([xmppStream isConnecting] ==YES) || ([xmppStream isConnected] == YES)) {
        XMPPPresence* presence = [XMPPPresence presenceWithType:@"unavailable"];
        [xmppStream sendElement:presence];
        [xmppStream disconnect];
    }
    
    //连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:8 error:&error]) {
        NSLog(@"cant connect %@", server);
        return NO;
    }
    NSLog(@"%@",error.description);
    return YES;
}

-(void)disconnect{
    [self goOffline];
    [xmppStream disconnect];
}

-(void)xmppLogin{
    NSError *error;
    NSString* pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    if (![xmppStream authenticateWithPassword:pass error:&error]) {
        NSLog(@"error authenticate : %@",error.description);
    }
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWillConnect");
}
//服务器连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
    if ([xmppStream isConnected] == YES) {
        
        NSError *error;
        NSString* pass = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
        if (![xmppStream authenticateWithPassword:pass error:&error]) {
            NSLog(@"error authenticate : %@",error.description);
        }
    }
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    
}
//密码验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidAuthenticate");
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"result"];
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xmppLogin" object:nil userInfo:userInfo];
}
//密码验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate:%@",error);
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"result"];
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xmppLogin" object:nil userInfo:userInfo];
}

//收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    /*
     if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
     {
     
     }else{//如果程序在后台运行，收到消息以通知类型来显示
     UILocalNotification *localNotification = [[UILocalNotification alloc] init];
     localNotification.alertAction = @"Ok";
     NSString* strFrom = message.fromStr;
     NSString* fromId = [[strFrom componentsSeparatedByString:@"@"] firstObject];//获取id号
     
     NSString* strBody = message.body;
     NSData* data = [strBody dataUsingEncoding:NSUTF8StringEncoding];
     NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
     NSString* strContent= dic[@"content"];
     
     localNotification.alertBody = [NSString stringWithFormat:@"%@:%@",fromId,strContent];//通知主体
     //        localNotification.soundName = @"crunch.wav";//通知声音
     localNotification.applicationIconBadgeNumber = 1;//标记数
     [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];//发送通知
     }
     */
    NSLog(@"didReceiveMessage: %@",message.description);
    //判断是否为好友消息
    NSString* strFrom = message.fromStr;
    //群消息
    if ([strFrom rangeOfString:@"."].length != 0) {
        return;
    }
    //好友消息
    if (![message.body isEqualToString:NULL_STR] && message.body != nil) {
        [self saveNewMesIntoChatListDic:message];
        //发送通知
        NSDictionary* dic = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_MES object:nil userInfo:dic];
    }
}

//收到好友状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:userId]) {
        
        //在线状态
        if ([presenceType isEqualToString:@"available"]) {
            
            //用户列表委托(后面讲)
            //            [chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
            
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            //用户列表委托(后面讲)
            //            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"nqc1338a"]];
        }
        
    }
    else{
        
    }
}

//发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"didSendMessage:%@",message.description);
}

//将最新消息保存在聊天列表dic里面
-(void)saveNewMesIntoChatListDic:(XMPPMessage*)message{
    /*
    NSDictionary* bodyDic = [self getDic:message.body];
    NSString* strFrom = [[message.fromStr componentsSeparatedByString:@"@"] firstObject];
    chatListVc* vc = [chatListVc getInstance];
    [vc getChatVc:strFrom head:bodyDic[@"head"]];
    NSMutableDictionary* dic = [vc getFriendListDic];
    NSDate* date = [NSDate date];
    NSString* strTime = [util dateToString:date];
    chatListCellInfoModel* model = [[chatListCellInfoModel alloc] init];
    model.user = strFrom;
    model.content = [bodyDic objectForKey:@"content"];
    model.img = [bodyDic objectForKey:@"head"];
    model.time = strTime;
    [dic setObject:model forKey:strFrom];
*/
}

//存储到数据
-(void)saveMesToDataBase:(XMPPMessage*)message{
    NSLog(@"save info to db");
    NSManagedObjectContext* contetx = [self managedObjectContext];
    Mes* contactMode = [NSEntityDescription insertNewObjectForEntityForName:@"Mes" inManagedObjectContext:contetx];
    contactMode.from = [[message.fromStr componentsSeparatedByString:@"@"] firstObject];
    contactMode.to = [[message.toStr componentsSeparatedByString:@"@"] firstObject];
    contactMode.author = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSDate* date = [NSDate date];
    contactMode.date = date;
    //解析
    NSString* strBody = message.body;
    NSDictionary* dic = [self getDic:strBody];
    contactMode.content = [dic objectForKey:@"content"];
    contactMode.type = [dic objectForKey:@"type"];//消息类型
    //
    NSError* error;
    if (![contetx save:&error]) {
        NSLog(@"error");
    }
    else{
        NSLog(@"插入成功");
    }
}
//body消息解析
-(NSDictionary*)getDic:(NSString*)body{
    NSData* data = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dic;
}
//获得朋友列表的


+(XMPPStream*)getXmppStream{
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return dele.xmppStream;
}

//检测网络状态
-(void)checkTheNetworkStatus{
    Reachability* r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    int status = 0;
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            status = 0;
        }break;
        case ReachableViaWWAN:{
            status = 1;
        }break;
        case ReachableViaWiFi:{
            status = 1;
        }break;
    }
    
    if (status == 0) {//无网状态
        [util showTheMbprogressView:@"当前为无网状态，请检查网络连接" view:self.window];
    }
    else{
        
    }
}

@end
