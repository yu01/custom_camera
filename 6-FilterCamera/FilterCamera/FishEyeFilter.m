//
//  FishEyeFilter.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "FishEyeFilter.h"


@implementation FishEyeFilter

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    title = @"魚眼レンズ";
    // 設定可能な値の範囲は、1から60。初期値は40。
    self.minValue = [NSNumber numberWithFloat:1];
    self.maxValue = [NSNumber numberWithFloat:60];
    self.currentValue = [NSNumber numberWithFloat:40];
  }
  return self;
}

// フィルタ処理を実行するメソッド。ImageFilterBaseクラスをオーバーライドする。
- (CGImageRef)filterImage:(CGImageRef)inImage {
  // 入力画像からCGBitmapContextを作成
  CGContextRef srcCgctx = [self createARGBBitmapContext:inImage];
  int w = CGImageGetWidth(inImage);
  int h = CGImageGetHeight(inImage);
  
  // レンズのパラメータ
  int weight = [self.currentValue intValue];
  double r = (w > h ? w : h)/2;
  
  // 入力画像のビットマップデータのポインタアドレスを取得
  unsigned char *srcData = CGBitmapContextGetData (srcCgctx);
  
  // 入力画像から出力結果用のCGBitmapContextを作成
  CGContextRef destCgctx = [self createARGBBitmapContext:inImage];// (1)
  // 出力結果用のビットマップデータのポインタアドレスを取得
  unsigned char *destData = CGBitmapContextGetData (destCgctx);
  
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      // レンズのパラメータから変更元の座標を算出
      double rp = sqrt(pow(weight,2)+pow((double)x-w/2,2)+pow((double)y-h/2,2));
      
      int dx = (int)((rp * (x - w / 2)) / r + w / 2);
      int dy = (int)((rp * (y - h / 2)) / r + h / 2);
      
      if(dx >= 0 && dx < w && dy >= 0 && dy < h){
        int srcIndex = (w *dy + dx)*4;
        int destIndex = (w * y  + x)*4;
        destData[destIndex] = srcData[srcIndex];
        // 変更元の画素値で差し替え
        destData[destIndex+1] = srcData[srcIndex+1]; 
        destData[destIndex+2] = srcData[srcIndex+2]; 
        destData[destIndex+3] = srcData[srcIndex+3]; 
      }
    }
  }
  // CGBitmapContextからCGImageを作成
  CGImageRef effectedImage = CGBitmapContextCreateImage(destCgctx);
  CGContextRelease(srcCgctx); 
  CGContextRelease(destCgctx); 
  
  free(srcData);
  free(destData);
  return effectedImage;
}

@end
