//
//  GaussianFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "GaussianFilter.h"


@implementation GaussianFilter

- (id)init {
  if (self = [super init]) {
    title = @"ぼかし(ガウシアン)";
    // 設定可能な値の範囲は、1から100。初期値は5。
    self.minValue = [NSNumber numberWithFloat:1];
    self.maxValue = [NSNumber numberWithFloat:100];
    self.currentValue = [NSNumber numberWithFloat:5];
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
  // CGImageからIplImageを作成
  IplImage *srcImage = [self newIplImageFromCGImage:inImage];
  int param1 = [self.currentValue intValue];
  //param1は、奇数である必要がある。
  param1 = (param1 % 2 == 0)?param1+1:param1;
  // ぼかし処理を実行
  cvSmooth(srcImage, srcImage, CV_GAUSSIAN,param1,0,0,0);
  
  // IplImageからCGImageを作成
  CGImageRef effectedImage = [self newCGImageFromIplImage:srcImage];
  cvReleaseImage(&srcImage);
  
  return effectedImage;
}

@end
