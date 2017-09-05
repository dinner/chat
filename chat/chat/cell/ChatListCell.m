//
//  ChatListCell.m
//  UINavigationTest
//
//  Created by zhanglingxiang on 15/8/19.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "ChatListCell.h"
#import "UIImageView+WebCache.h"
#import "officialCellModel.h"

@implementation ChatListCell

- (void)awakeFromNib {
    // Initialization code
    [self.img.layer setMasksToBounds:YES];
    [self.img.layer setCornerRadius:3.f];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.img.layer setMasksToBounds:YES];
        [self.img.layer setCornerRadius:3.f];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setInfo:(chatListCellInfoModel*)info{
    [self setInfo:info type:e_friend];
}

-(void)setInfo:(id)info type:(enum mesSource_enum)type{
    if (type == e_friend) {
        chatListCellInfoModel* model = (chatListCellInfoModel*)info;
        [self.name setText:model.user];
        [self.name sizeToFit];
        NSString* strContent = model.content;
        if ([strContent hasPrefix:@"assets-library://asset"] == YES && ([strContent hasSuffix:@"JPG"] == YES || [strContent hasSuffix:@"PNG"])) {
            [self.content setText:@"［图片］"];
        }
        else if ([strContent hasPrefix:@"https://23.106.155.217"] && [strContent hasSuffix:@"mp3"]){
            [self.content setText:@"［音频］"];
        }
        else if ([strContent hasPrefix:@"https://23.106.155.217"] && [strContent hasSuffix:@"png"]){
            [self.content setText:@"［图片］"];
        }
        else{
            [self.content setText:strContent];
        }
        if (model.time != nil) {
            [self setTheTime:model.time];
            [self.time sizeToFit];
        }
        [self.img sd_setImageWithURL:[NSURL URLWithString:model.img]];
    }
    else if(type == e_official){
        officialCellModel* model = (officialCellModel*)info;
        [self.name setText:@"管理员"];
        [self.content setText:model.strContent];
        [self setTheTime:model.strDate];
        [self.time sizeToFit];
        [self.img setImage:[UIImage imageNamed:@"officer"]];
    }
    else{
        chatListCellInfoModel* model = (chatListCellInfoModel*)info;
        [self.name setText:model.user];
        NSString* strContent = model.content;
        if ([strContent hasPrefix:@"assets-library://asset"] == YES && ([strContent hasSuffix:@"JPG"] == YES || [strContent hasSuffix:@"PNG"])) {
            [self.content setText:@"［图片］"];
        }
        else if ([strContent hasPrefix:@"https://23.106.155.217"] && [strContent hasSuffix:@"mp3"]){
            [self.content setText:@"［音频］"];
        }
        else if ([strContent hasPrefix:@"https://23.106.155.217"] && [strContent hasSuffix:@"png"]){
            [self.content setText:@"［图片］"];
        }
        else{
             [self.content setText:strContent];
        }
        if (model.time != nil) {
            [self setTheTime:model.time];
            [self.time sizeToFit];
        }
        [self.img setImage:[UIImage imageNamed:@"group"]];
    }
}

-(void)setTheTime:(NSString*)strTime{
    if ([self isToday:strTime] == YES) {
        NSString* time = [NSString stringWithFormat:@"今天 %@",[[strTime componentsSeparatedByString:@" "] lastObject]];
        [self.time setText:time];
    }
    else if ([self isYesterday:strTime] == YES){
        NSString* time = [NSString stringWithFormat:@"昨天 %@",[[strTime componentsSeparatedByString:@" "] lastObject]];
        [self.time setText:time];
    }
    else{
        NSString* time = [NSString stringWithFormat:@"%@-%@",[[strTime componentsSeparatedByString:@"-"] objectAtIndex:1],[[strTime componentsSeparatedByString:@"-"] objectAtIndex:2]];
        [self.time setText:time];
    }
}

- (BOOL)isToday:(NSString*)strDate
{
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    strDate = [[strDate componentsSeparatedByString:@" "] firstObject];
    NSString *nowStr = [fmt stringFromDate:now];
    return [strDate isEqualToString:nowStr];
}

- (BOOL)isYesterday:(NSString*)strDate
{
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSDate* dt = [util stringToDate:strDate];
    NSString *dateStr = [fmt stringFromDate:dt];
    NSString *nowStr = [fmt stringFromDate:now];
    
    NSDate *date = [fmt dateFromString:dateStr];
    now = [fmt dateFromString:nowStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:now options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
}

@end
