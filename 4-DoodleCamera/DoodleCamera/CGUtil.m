//
//  CGUtil.m
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "CGUtil.h"


@implementation CGUtil

// 何も描画されていない状態のCGBitmapContextオブジェクトを作成するメソッド。引数sizeの構造体CGSizeの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef)newBlankBitmapContext:(CGSize)size {
  CGContextRef    context = NULL;
  CGColorSpaceRef colorSpace;
  void *          bitmapData;
  int             bitmapByteCount;
  int             bitmapBytesPerRow;
  
  // 画素値はA,R,G,Bの4バイトなので、ビットマップデータの1行あたりのバイト数は、画像幅 x 4バイト
  bitmapBytesPerRow   = ((int)size.width * 4);
  // 全体でのビットマップデータのバイト数は、1行あたりのバイト数 x 画像高さ
  bitmapByteCount     = (bitmapBytesPerRow * (int)size.height);
  
  // 色空間は、ARGBで作成
  colorSpace = CGColorSpaceCreateDeviceRGB();
  // ビットマップデータのメモリを確保
  bitmapData = malloc( bitmapByteCount );
  // CGBitmapContextオブジェクトを作成
  context = CGBitmapContextCreate (bitmapData,
                                   (int)size.width,
                                   (int)size.height,
                                   8,
                                   bitmapBytesPerRow,
                                   colorSpace,
                                   kCGImageAlphaPremultipliedFirst);
  CGColorSpaceRelease( colorSpace );
  return context;
}

// CGImageからCGBitmapContextオブジェクトを作成するメソッド。引数inImageのCGImageオブジェクトが描画された状態でCGImageの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef) newBitmapContextFromCGImage:(CGImageRef) inImage {
  // 何も描画されていないCGBitmapContextオブジェクトを画像の大きさで作成
  CGContextRef context = [CGUtil newBlankBitmapContext:
                          CGSizeMake(CGImageGetWidth(inImage),
                                     CGImageGetHeight(inImage))];
  // 作成したビットマップデータに画像を描画
  CGContextDrawImage(context, CGRectMake(0,0,CGImageGetWidth(inImage),CGImageGetHeight(inImage)), inImage); 
  return context;
}

// 背景色が透過色ののCGBitmapContextオブジェクトを作成するメソッド。引数sizeの構造体CGSizeの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef)newTransparentBitmapContext:(CGSize)size{
  // 何も描画されていないCGBitmapContextオブジェクトを作成
  CGContextRef context = [CGUtil newBlankBitmapContext:size];
  // 塗りつぶし色を透過色に設定
  CGContextSetRGBFillColor (context, 0, 0, 0, 0);
  // 全体を塗りつぶし
  CGContextFillRect (context, CGRectMake (0, 0, size.width,size.height));
  // 描画時の座標系を上下反転させておく
  CGContextTranslateCTM(context,0,size.height);
  CGContextScaleCTM( context,1.0,-1.0 );
  return context;
}

// 画像を90度回転させたCGImageオブジェクトを作成するメソッド
+(CGImageRef)rotateImage:(CGImageRef)image mirrored:(BOOL)mirrored {
  int width = CGImageGetWidth(image);
  int height = CGImageGetHeight(image);
  // CGBtimapCotnextオブジェクトを作成。90度回転させるので、結果的に幅と高さを入れ替える
  CGContextRef context = [CGUtil newBlankBitmapContext:CGSizeMake(height,width)];

  // 90度回転した座標系に設定
  if (mirrored) {
    CGContextTranslateCTM(context, height, width);
    CGContextScaleCTM( context,-1.0,1.0 );
  } else {
    CGContextTranslateCTM(context, 0, width);
  }
  CGContextRotateCTM(context, -M_PI/2);
  // 画像を描画
  CGContextDrawImage(context,CGRectMake(0,0,width,height),image);
  
  // CGBitmapContextからCGImageオブジェクトを作成
  CGImageRef cgImage = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  return (CGImageRef)[(id)cgImage autorelease];
}

@end
