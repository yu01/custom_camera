//
//  SepiaFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "SepiaFilter.h"


@implementation SepiaFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    title = @"セピア";
    // 設定可能な値の範囲は、-255から255。初期値は0。
    self.minValue = [NSNumber numberWithFloat:-255];
    self.maxValue = [NSNumber numberWithFloat:+255];
    self.currentValue = [NSNumber numberWithFloat:0];
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
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      //ARGBだから4バイトずつ移動
      int index = (y * w + x)*4;
      // RGBの画素値を取得
      unsigned char r = data[index+1];
      unsigned char g = data[index+2];
      unsigned char b = data[index+3];
      
      // 加重平均でグレースケール化
      CGFloat Y = 0.298912*r + 0.586611*g + 0.114477*b;
      Y = Y+ [self.currentValue intValue];
      // セピア化して画素値を差し替え
      data[index+1] = [self normalizeToChar:Y + 20.01];
      data[index+2] = [self normalizeToChar:Y - 2.46];
      data[index+3] = [self normalizeToChar:Y - 41.28];
      
    }
  }
  // CGBitmapContextからCGImageを作成
  CGImageRef effectedImage = CGBitmapContextCreateImage(cgctx);
  CGContextRelease(cgctx); 
  free(data);
  return effectedImage;
}

@end
