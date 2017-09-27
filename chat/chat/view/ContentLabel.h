//
//  ContentLabel.h
//  hexiProNew
//
//  Created by Apple on 15-5-27.
//
//

#import <UIKit/UIKit.h>

#import "ChartCellFrame.h"

@interface ContentLabel : UILabel

@property (retain,nonatomic) ChartCellFrame* cellFrame;

-(void)drawTheLable:(ChartCellFrame*)info;//绘制label
-(void)setTheLabel:(NSArray*)array;

@end
