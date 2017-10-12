//
//  officialChatCellView.h
//  CalendarDiary
//
//  Created by James on 15/9/22.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface officialChatCellView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (weak, nonatomic) IBOutlet UITextView *lb_content;


+(instancetype)getInstance;

@end
