//
//  MultiMonitorFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "MultiMonitorFilter.h"
#import "FilterCameraAppDelegate.h"

// マルチモニターフィルタの実装
@implementation MultiMonitorFilter

// 初期化メソッド
- (id)init {
    if (self = [super init]) {
        self.title = @"マルチモニター";
        // 設定可能な値の範囲は、1から4。初期値は2。分割数は、設定値のベキ乗になる。
        self.minValue = [NSNumber numberWithInt:1];
        self.maxValue = [NSNumber numberWithInt:4];
        self.currentValue = [NSNumber numberWithInt:2];
        
        
    }
    return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
    // CGImageからIplImageを作成
    IplImage *srcImage = [self newIplImageFromCGImage:inImage];
    
    int divideNum = [self.currentValue intValue];
    IplImage *dstImage = cvCreateImage(cvSize(srcImage->width/divideNum,srcImage->height/divideNum),IPL_DEPTH_8U,3);
    // パラメータに応じて画像を縮小
    cvResize(srcImage,dstImage,CV_INTER_LINEAR);
    cvReleaseImage(&srcImage);  
    CGImageRef smallImage = [self newCGImageFromIplImage:dstImage];
    cvReleaseImage(&dstImage);  

    // CGBitmapContextを作成
    CGContextRef context = [self createARGBBitmapContext:inImage];
    
    // 画像を等分割した画像ごとにフィルタを処理した画像を作成
    int counter = 0;
    for (int i = 0; i < divideNum; i++) {
        for (int j = 0; j < divideNum; j++) {
            // アプリに登録されているフィルタから選択
            FilterCameraAppDelegate *FilterCameraAppDelegate = [UIApplication sharedApplication].delegate;
            // 最後のフィルタは、このフィルタなので使用しない。使うと無限ループになりますので注意。
            int filterIndex = counter % ([[FilterCameraAppDelegate filters] count]-1);
            ImageFilterBase *filter = [[FilterCameraAppDelegate filters] objectAtIndex:filterIndex]; 

            // フィルタ処理を実行
            CGImageRef filteredImage = [filter filterImage:smallImage];
            
            // 描画する矩形座標を作成
            CGRect rect = CGRectMake(i*CGImageGetWidth(smallImage), j*CGImageGetHeight(smallImage),CGImageGetWidth(smallImage),CGImageGetHeight(smallImage));
            
            // フィルタ処理された画像を描画
            CGContextDrawImage(context, rect, filteredImage);
            CGImageRelease(filteredImage);
            counter++;
        }
    }
    CGImageRelease(smallImage);
    
    // 描画したビットマップデータからCGImageを作成
    CGImageRef effectedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return effectedImage;
}

@end
