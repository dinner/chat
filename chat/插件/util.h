//
//  util.h
//  hexiProNew
//
//  Created by Apple on 15-5-21.
//
//

#import <Foundation/Foundation.h>
//#import "AppDelegate.h"

#import <UIKit/UIKit.h>

@interface util : NSObject

+(NSDate*)stringToDate:(NSString*)strDate;
+(NSString*)dateToString:(NSDate*)date;

//+(mesStr*)getMesStrFromXmppMessage:(XMPPMessage*)message;


+(void)showTheMbprogressView:(NSString*)str view:(UIView*)view;

//遮罩的添加和删除
+(void)addZhezhao:(UIView*)view;
+(void)removeZhezhao:(UIView*)view;

//判断是否登录
+(BOOL)isLogin;

+(void)clearUserInfo;

@end
