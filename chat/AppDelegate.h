//
//  UIAppDelegate.h
//  UINavigationTest
//
//  Created by mac on 13-9-2.
//  Copyright (c) 2013年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UICalendarElement.h"
#import "XMPPFramework.h"
#import "Mes.h"

//#import "loginInfo.h"

//tag类型
enum tagType{weather=0,
    expression};

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * navController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (weak,nonatomic) UICalendarElement* selectedCalendar;//选中的日历元素


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+(UIWindow*)getWindow;

//数据插入
-(void)insertCoreData:(enum tagType)type value:(int)value date:(NSString*)date;
//微博数据插入
-(void)insertWeibo:(NSInteger)picNum picString:(NSString*)picString date:(NSDate*)strDate content:(NSString*)content addr:(NSString*)addr;
//微博数据删除
-(void)deleteWeibo:(NSDate*)date;

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;
-(BOOL)connectToxmpp;//连接xmpp服务器

+(XMPPStream*)getXmppStream;
-(void)disconnect;

-(void)xmppLogin;

@property(retain,nonatomic) NSMutableArray* downloadUrlAr;
@property(retain,nonatomic) NSMutableArray* uploadPicAr;

//@property(retain,nonatomic) loginInfo* LoInfo;

@end
