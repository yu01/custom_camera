//
//  MosaicFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "MosaicFilter.h"


@implementation MosaicFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    title = @"モザイク";
    // 設定可能な値の範囲は、1から20。初期値は4。
    self.minValue = [NSNumber numberWithFloat:1];
    self.maxValue = [NSNumber numberWithFloat:20];
    self.currentValue = [NSNumber numberWithFloat:4];
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
  // 入力画像からCGBitmapContextを作成
  CGContextRef cgctx = [self createARGBBitmapContext:inImage];
  size_t w = CGImageGetWidth(inImage);
  size_t h = CGImageGetHeight(inImage);
  
  // ビットマップデータのポインタアドレスを取得
  unsigned char *data = CGBitmapContextGetData (cgctx);
  int mosaicSize = [self.currentValue intValue];
  // モザイクの大きさでピクセルを探査
  for (int y = 0; y < h; y+=mosaicSize) {
    for (int x = 0; x < w; x+=mosaicSize) {
      float totalR = 0;
      float totalG = 0;
      float totalB = 0;
      // ピクセルからモザイクのサイズ分探査
      for (int i = y; i < y+mosaicSize; i++) {
        for (int j = x; j < x+mosaicSize; j++) {
          if (i >= h || j >= w) {
            continue;
          }
          // R,G,Bの値をそれぞれ加算
          //ARGBだから4バイトずつ移動
          int destIndex = (i * w + j)*4;
          totalR += data[destIndex+1];
          totalG += data[destIndex+2];
          totalB += data[destIndex+3];
        }
      }
      // R,G,Bの値それぞれの平均値を計算
      unsigned char averageR = [self normalizeToChar:totalR / (mosaicSize*mosaicSize)];
      unsigned char averageG = [self normalizeToChar:totalG / (mosaicSize*mosaicSize)];
      unsigned char averageB = [self normalizeToChar:totalB / (mosaicSize*mosaicSize)];
      
      for (int i = y; i < y+mosaicSize; i++) {
        for (int j = x; j < x+mosaicSize; j++) {
          if (i >= h || j >= w) {
            continue;          
          }
          int destIndex = (i * w + j)*4;
          data[destIndex+0] = 255;
          // R,G,Bの値の平均値を画素値として設定
          data[destIndex+1] = averageR;
          data[destIndex+2] = averageG;
          data[destIndex+3] = averageB;
        }
      }
    }
  }
  // CGBitmapContextからCGImageを作成
  CGImageRef effectedImage = CGBitmapContextCreateImage(cgctx);
  CGContextRelease(cgctx); 
  
  free(data);
  return effectedImage;
}

@end
