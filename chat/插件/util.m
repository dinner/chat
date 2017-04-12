//
//  util.m
//  hexiProNew
//
//  Created by Apple on 15-5-21.
//
//

#import "util.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@implementation util

+(NSDate*)stringToDate:(NSString*)strDate{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate* date = [formater dateFromString:strDate];
    return date;
}

+(NSString*)dateToString:(NSDate*)date{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* strDate = [formater stringFromDate:date];
    return strDate;
}

+(void)showTheMbprogressView:(NSString*)str view:(UIView*)view{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = str;
    [hud showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [hud removeFromSuperview];
        return;
    }];
}

+(void)addZhezhao:(UIView*)view{
    UIWindow* window = [AppDelegate getWindow];
    [window addSubview:view];
    
    [SVProgressHUD showWithStatus:@"正在注册 "];
}

+(void)removeZhezhao:(UIView*)view{
    [view removeFromSuperview];
    
    [SVProgressHUD dismiss];
}
//判断是否登录
+(BOOL)isLogin{
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"];
    if (str == nil) {
        return NO;
    }
    else{
        return YES;
    }
}

+(void)clearUserInfo;{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    for(NSString* key in [dictionary allKeys]){
        
        if ([key isEqualToString:@"user"]) {
            continue;
        }
        
        [userDefatluts removeObjectForKey:key];
        [userDefatluts synchronize];
    }
}

/*
+(mesStr*)getMesStrFromXmppMessage:(XMPPMessage*)message{
    mesStr* newStr = [[mesStr alloc] init];
    NSString* strBody = message.body;
    strBody = [strBody stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSString* strFrom = message.fromStr;
    NSString* strTo = message.toStr;
    NSData* data = [strBody dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    newStr.strFrom = strFrom;
    newStr.strTo = strTo;
    newStr.strContent = dic[@"content"];
    newStr.strHead = dic[@"head"];//聊天消息的图片 url地址
    newStr.strName = dic[@"name"];
    newStr.strDetail = dic[@"detail"];
    newStr.strTitle = dic[@"title"];
//    newStr.strPic = dic[@"pic"];
    NSString* strTime = dic[@"time"];
    NSDate* date = [util stringToDate:strTime];
    newStr.date = date;
    //判断来源是否为空
    if (dic[@"laiyuan"] != nil) {
        if ([dic[@"laiyuan"] isEqualToString:@"官方消息"]) {
            newStr.mesType = e_gf;
            newStr.strPic = dic[@"head"];//官方消息的图片
        }
        else if([dic[@"laiyuan"] isEqualToString:@"交易消息"]){
            newStr.mesType = e_jy;
        }
        else if([dic[@"laiyuan"] isEqualToString:@"店铺"]){
            newStr.mesType = e_chatDp;
        }
    }
    else{
        newStr.mesType = e_chatHf;
    }
    return newStr;
}
*/
@end
