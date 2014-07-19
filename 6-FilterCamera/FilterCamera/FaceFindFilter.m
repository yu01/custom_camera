//
//  FaceFindFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "FaceFindFilter.h"


@implementation FaceFindFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    self.title = @"顔検出";
    // 設定可能な値の範囲は、20から100。初期値は50。
    self.minValue = [NSNumber numberWithInt:20];
    self.maxValue = [NSNumber numberWithInt:100];
    self.currentValue = [NSNumber numberWithInt:50];
    
    // 検出パターンファイルをバンドルから読み込み
    NSString *xmlPath = [NSString stringWithFormat:@"%@/haarcascade_frontalface_default.xml",[[NSBundle mainBundle]resourcePath]];
    // 顔検出アルゴリズムに検出パターンファイルを読込
    cascade = (CvHaarClassifierCascade*)cvLoad([xmlPath cStringUsingEncoding:NSASCIIStringEncoding],0,0,0);
    storage = cvCreateMemStorage(0);
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
  // CGImageからIplImageを作成
  IplImage *srcImage = [self newIplImageFromCGImage:inImage];
  
  //グレースケール用画像確保
  IplImage *grayScaleImage = cvCreateImage( cvGetSize(srcImage),IPL_DEPTH_8U,1);
  
  //グレースケール画像に変換  
  cvCvtColor(srcImage, grayScaleImage, CV_BGR2GRAY);
  
  // ヒストグラムを均一化
  cvEqualizeHist(grayScaleImage,grayScaleImage);
  
  cvClearMemStorage(storage);
  
  // 検出するサイズの最小は、設定から取得
  int minSize = [self.currentValue intValue];
  // 顔検出を実行
  CvSeq *objects = cvHaarDetectObjects(grayScaleImage,cascade,storage,1.2,2,CV_HAAR_DO_CANNY_PRUNING|CV_HAAR_FIND_BIGGEST_OBJECT,cvSize(minSize,minSize));
  cvReleaseImage(&grayScaleImage);
  cvReleaseImage(&srcImage);
  
  CGImageRef effectedImage; 
  // 検出結果を探査
  if (objects != 0 && objects->total != 0) {
    CvRect *r = (CvRect*)cvGetSeqElem(objects,0);
    int buffer = minSize/2;
    CGRect targetBox = CGRectInset(CGRectMake(r->x,r->y,r->width,r->height),-buffer,-buffer);
    // 検出範囲の画像を切り出し。（1）
    effectedImage = CGImageCreateWithImageInRect(inImage,targetBox);
  } else {
    effectedImage = inImage;
    CGImageRetain(effectedImage);
  }
  
  return effectedImage;
}

@end
