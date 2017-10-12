//
//  Mes.h
//  chat
//
//  Created by James on 17/4/11.
//  Copyright © 2017年 James. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Mes : NSManagedObject

@property (nonatomic,retain) NSString* author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, assign) NSInteger type;

@end
