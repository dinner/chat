//
//  Message.h
//  chat
//
//  Created by zhanglingxiang on 17/4/7.
//  Copyright © 2017年 zhanglingxiang. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Mes : NSManagedObject

@property (nonatomic,retain) NSString* author;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * type;

@end
