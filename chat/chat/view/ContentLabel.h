//
//  ContentLabel.h
//  hexiProNew
//
//  Created by Apple on 15-5-27.
//
//

#import <UIKit/UIKit.h>

#import "ChartCellFrame.h"
#import "chatImageView.h"
#import "chatAudioView.h"

@interface ContentLabel : UILabel

@property (retain,nonatomic) ChartCellFrame* cellFrame;
@property (retain,nonatomic) chatImageView* m_imgView;
@property (retain,nonatomic) chatAudioView* m_audioView;


-(void)drawTheLable:(ChartCellFrame*)info;//绘制label

@end
