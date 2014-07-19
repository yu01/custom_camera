//
//  BrightnessFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BrightnessFilter.h"


@implementation BrightnessFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    title = @"輝度";
    // 設定可能な値の範囲は、-255から255。初期値は0。
    self.minValue = [NSNumber numberWithFloat:-255];
    self.maxValue = [NSNumber numberWithFloat:+255];
    self.currentValue = [NSNumber numberWithFloat:0];
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする
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
      unsigned char r = data[index+1];
      unsigned char g = data[index+2];
      unsigned char b = data[index+3];
      
      // RGBからYUVを求める
      CGFloat Y = 0.299*r + 0.587*g + 0.114*b;
      CGFloat U = -0.169*r - 0.331*g + 0.5*b;
      CGFloat V = 0.5*r - 0.419*g - 0.081*b;
      // 輝度値を変更
      Y = Y+ [self.currentValue intValue];
      // YUV => RGBに変換
      data[index+1] = [self normalizeToChar:Y + 1.402*V];
      data[index+2] = [self normalizeToChar:Y - 0.344*U - 0.714*V];
      data[index+3] = [self normalizeToChar:Y + 1.772*U];
    }
  }
  // CGBitmapContextからCGImageを作成
  CGImageRef effectedImage = CGBitmapContextCreateImage(cgctx);
  CGContextRelease(cgctx); 
  free(data);
  return effectedImage;
}

@end
