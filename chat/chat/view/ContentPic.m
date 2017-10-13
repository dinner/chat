//
//  chatImageView.m
//  UINavigationTest
//
//  Created by James on 15/8/20.
//  Copyright (c) 2015年 caobo. All rights reserved.
//

#import "SDDemoItemView.h"
#import "SDBallProgressView.h"
#import "ContentPic.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "AFdownloadOper.h"

@interface ContentPic(){
    UIView* m_maskView;
    SDDemoItemView* m_progressView;
}

@end

@implementation ContentPic

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)init{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 3.f;
        self.layer.masksToBounds = YES;
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgCLicked:)];
        [self addGestureRecognizer:tap];
        
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

-(void)imgCLicked:(id)sender{
    if (self.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IMG_CLICKED object:self];

    }
}

-(void)addMask:(CGFloat)fProgress{
    m_maskView = [[UIView alloc] initWithFrame:self.bounds];
    [m_maskView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f]];
    m_progressView = [SDDemoItemView demoItemViewWithClass:[SDBallProgressView class]];
    [m_progressView setFrame:CGRectMake(0, 0, 50.f, 50.f)];
    m_progressView.progressView.progress = fProgress;
    CGRect rect = self.bounds;
    CGPoint point = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2);
    [m_progressView setCenter:point];
    [self addSubview:m_maskView];
    [self addSubview:m_progressView];
}
-(void)addMask{
    m_maskView = [[UIView alloc] initWithFrame:self.bounds];
    [m_maskView setBackgroundColor:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f]];
    m_progressView = [SDDemoItemView demoItemViewWithClass:[SDBallProgressView class]];
    [m_progressView setFrame:CGRectMake(0, 0, 50.f, 50.f)];
    CGRect rect = self.bounds;
    CGPoint point = CGPointMake(CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2);
    [m_progressView setCenter:point];
    [self addSubview:m_maskView];
    [self addSubview:m_progressView];
}

-(void)removeMask{
    if (m_progressView != nil) {
        [m_progressView removeFromSuperview];
        m_progressView = nil;
    }
    if (m_maskView != nil) {
        [m_maskView removeFromSuperview];
        m_maskView = nil;
    }
}

//上传
-(void)upload:(UIImage*)image{
    [self addMask:self.m_cellFrame.fileUploadOrDownLoadManager.fProgress];
    
    //判断该数据源
    AFHTTPRequestOperation *oPer;
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if ([dele.uploadPicAr containsObject:_m_cellFrame] == NO) {
        [dele.uploadPicAr addObject:_m_cellFrame];
        AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = YES;
        manager.securityPolicy  = securityPolicy;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString* strPostUrl = [NSString stringWithFormat:@"%@/imageUpload",SERVER];
        
        AFHTTPRequestOperation *o2= [manager POST:strPostUrl parameters:nil                                  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData * data=UIImageJPEGRepresentation(image,1);
            [formData appendPartWithFileData:data name:@"file"fileName:@"111icon.png"mimeType:@"image/png"];
        }success:^(AFHTTPRequestOperation *operation,id responseObject){
            NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [self removeMask];
            [dele.uploadPicAr removeObject:_m_cellFrame];
            self.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc = YES;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString* strHeadUrl = dic[@"url"];
            if (strHeadUrl != nil) {
                [dele.uploadPicAr removeObject:_m_cellFrame];
                [[NSNotificationCenter defaultCenter] postNotificationName:PIC_SEND_SUC object:nil userInfo:[NSDictionary dictionaryWithObject:strHeadUrl forKey:@"picUrl"]];
            }
        }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
            NSLog(@"图片上传失败");
        }];
        
        //设置上传操作的进度
        [o2 setUploadProgressBlock:^(NSUInteger bytesWritten,long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            CGFloat progress = (CGFloat)(totalBytesWritten)/(totalBytesExpectedToWrite);
            self->m_progressView.progressView.progress = progress;
            self.m_cellFrame.fileUploadOrDownLoadManager.fProgress = progress;
            NSLog(@"上传进度%.2f",progress);
        }];
        self.m_cellFrame.uploadOper = o2;
        [o2 resume];
    }
    else{//
        oPer = self.m_cellFrame.uploadOper;
        [oPer setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSLog(@"%@",[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
            [self removeMask];
            [dele.uploadPicAr removeObject:_m_cellFrame];
            self.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc = YES;
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString* strHeadUrl = dic[@"url"];
            if (strHeadUrl != nil) {
                [dele.uploadPicAr removeObject:_m_cellFrame];
                [[NSNotificationCenter defaultCenter] postNotificationName:PIC_SEND_SUC object:nil userInfo:[NSDictionary dictionaryWithObject:strHeadUrl forKey:@"picUrl"]];
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"图片上传失败");
        }];
        [oPer setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            CGFloat progress = (CGFloat)(totalBytesWritten)/(totalBytesExpectedToWrite);
            self->m_progressView.progressView.progress = progress;
            self.m_cellFrame.fileUploadOrDownLoadManager.fProgress = progress;
            NSLog(@"上传进度%.2f",progress);
        }];
        [oPer resume];
    }
}

//下载
-(void)download:(NSString*)url{
    [self addMask:self.m_cellFrame.fileUploadOrDownLoadManager.fProgress];
    
    AFdownloadOper* operation;
    NSURLRequest* request;
    AppDelegate* dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if([dele.downloadUrlAr containsObject:url] == YES){
        operation = self.m_cellFrame.downloadOper;
        request = operation.request;
    }
    else{
        request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        operation = [[AFdownloadOper alloc] initWithRequest:request];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = YES;
        operation.securityPolicy = securityPolicy;
        
        self.m_cellFrame.downloadOper = operation;
        @synchronized (dele.downloadUrlAr) {
            [dele.downloadUrlAr addObject:url];
        }
    }
    
    long long fileUploadedSize = self.m_cellFrame.fileUploadOrDownLoadManager.upDownSize;
    //
    if (fileUploadedSize > 0) {
        NSMutableURLRequest* mutableUrlReq = [request mutableCopy];
        NSString* requestRange = [NSString stringWithFormat:@"bytes=%llu-",fileUploadedSize];
        [mutableUrlReq setValue:requestRange forHTTPHeaderField:@"Range"];
        request = mutableUrlReq;
    }
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    self.m_cellFrame.contentPic = self;
    __weak ContentPic *wkSelf = self;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat fProgredss = (CGFloat)(totalBytesRead+fileUploadedSize) / (totalBytesExpectedToRead+fileUploadedSize);
        NSLog(@"is download：%f",fProgredss);
        if (wkSelf != nil) {
            ContentPic *strongSelf = wkSelf;
            strongSelf->m_progressView.progressView.progress = fProgredss;
        }
        wkSelf.m_cellFrame.fileUploadOrDownLoadManager.fProgress = fProgredss;
        /*
        operation.progressView.progress = fProgredss;
        SDDemoItemView* item = [self.m_cellFrame.contentPic getProgressView];
        item.progressView.progress = fProgredss;*/
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        wkSelf.m_cellFrame.image = [UIImage imageWithData:responseObject];
        wkSelf.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc = YES;
        //合并下载数据
        NSMutableData* data = [[NSMutableData data] initWithData: self.m_cellFrame.fileUploadOrDownLoadManager.upDownData];
        [data appendData:responseObject];
        wkSelf.m_cellFrame.fileUploadOrDownLoadManager.image = [[UIImage alloc] initWithData:data];
        [wkSelf setImage:self.m_cellFrame.fileUploadOrDownLoadManager.image];
        [wkSelf removeMask];
        
        @synchronized (dele.downloadUrlAr) {
            [dele.downloadUrlAr removeObject:url];
        }
        NSLog(@"下载成功");
        NSLog(@"download 数量：%ld",dele.downloadUrlAr.count);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @synchronized (dele.downloadUrlAr) {
            [dele.downloadUrlAr removeObject:url];
        }
        NSLog(@"下载失败");
    }];
    
    [operation start];
}

//设置本地图片
-(void)setLocalImage:(UIImage*)image{
    [self removeMask];
    [self setImage:image];
    
    @synchronized(self){
        if (self.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc == NO) {
            [self upload:image];
        }
    }
}

//设置服务器图片
-(void)setRemoteImage:(NSString*)url{
//    if (self.m_cellFrame.m_bIsUploadOrDownloadSuc == NO) {
    [self removeMask];
    @synchronized(self){
    if (self.m_cellFrame.fileUploadOrDownLoadManager.bIsSuc == NO) {
            [self download:url];
        }
        else{
            [self setImage:self.m_cellFrame.fileUploadOrDownLoadManager.image];
        }
    }
}

-(void)dealloc{
    NSLog(@"chatImageView dealloc");
}

-(id)getProgressView;{
    return self->m_progressView;
}

@end
