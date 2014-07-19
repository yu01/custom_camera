//
//  EdgeFindFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "EdgeFindFilter.h"


@implementation EdgeFindFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    title = @"エッジ検出";
    // 設定可能な値の範囲は、1から200。初期値は50。
    self.minValue = [NSNumber numberWithFloat:1];
    self.maxValue = [NSNumber numberWithFloat:200];
    self.currentValue = [NSNumber numberWithFloat:50];
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
  // CGImageからIplImageを作成
  IplImage *srcImage = [self newIplImageFromCGImage:inImage];
  
  //グレースケール画像に変換  (1)
  IplImage *grayScaleImage = cvCreateImage( cvGetSize(srcImage),IPL_DEPTH_8U,1);
  cvCvtColor(srcImage, grayScaleImage, CV_BGR2GRAY);  
  
  // 出力用IplImageを作成
  IplImage *destImage = cvCreateImage(cvGetSize(grayScaleImage),IPL_DEPTH_8U,1);
  int minThreshold = [self.currentValue intValue];
  // エッジ検出画像を作成
  cvCanny(grayScaleImage,destImage,minThreshold,200,3);
  
  // CGImage用にIplImageを作成
	IplImage *colorImage = cvCreateImage( cvGetSize(srcImage),IPL_DEPTH_8U,3);
  // CGImage用にBGRに変換 (2)
  cvCvtColor(destImage, colorImage, CV_GRAY2BGR);
  
  // IplImageからCGImageを作成
  CGImageRef effectedImage = [self newCGImageFromIplImage:colorImage];
  
  cvReleaseImage(&srcImage);
  cvReleaseImage(&grayScaleImage);  
  cvReleaseImage(&destImage);  
  cvReleaseImage(&colorImage);    
  
  return effectedImage;
}


@end
