//
//  ImageFilterBase.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "ImageFilterBase.h"

// フィルタ処理を行うクラスの基底クラスの実装
@implementation ImageFilterBase
@synthesize title;
@synthesize minValue;
@synthesize maxValue;
@synthesize currentValue;

// 初期化メソッド
- (id)init {
  if (self = [super init]) {
    // フィルタの名称
    title = @"なし";
    // 設定可能な値の最小値を0に設定
    self.minValue = [NSNumber numberWithFloat:0];
    // 設定可能な値の最大値を100に設定
    self.maxValue = [NSNumber numberWithFloat:100];
    // 設定中の値を50に設定
    self.currentValue = [NSNumber numberWithFloat:50];
  }
  return self;
}

- (void)dealloc {
  [title release];
  [minValue release];
  [maxValue release];
  [currentValue release];
  [super dealloc];
}

// フィルタ処理を実行するメソッド。引数のCGImageに対してフィルタ処理を実行し、返り値でフィルタ処理されたCGImageを返す。
- (CGImageRef)filterImage:(CGImageRef)image {
  // 基底クラスではフィルタ処理は何もしない。
  CGImageRetain(image);
  return image;
}

// floatの値をunsigned charの範囲に最適化するメソッド。
- (unsigned char)normalizeToChar:(CGFloat)value {
  // 0 - 255の範囲に設定
  return value<0?0:value>255?255:value;
}

// CGImageからCGBitmapContextを作成するメソッド。引数のCGImageからCGBitmapContextを作成する。
-(CGContextRef) createARGBBitmapContext:(CGImageRef) inImage {
  CGContextRef    context = NULL;
  CGColorSpaceRef colorSpace;
  void *          bitmapData;
  int             bitmapByteCount;
  int             bitmapBytesPerRow;
  
  size_t pixelsWidth = CGImageGetWidth(inImage);
  size_t pixelsHight = CGImageGetHeight(inImage);
  
  // 色空間は、ARGBで作成
  colorSpace = CGColorSpaceCreateDeviceRGB();
  // 画素値はA,R,G,Bの4バイトなので、ビットマップデータの1行あたりのバイト数は、画像幅 x 4バイト
  bitmapBytesPerRow   = (pixelsWidth * 4);
  // 全体でのビットマップデータのバイト数は、1行あたりのバイト数 x 画像高さ
  bitmapByteCount     = (bitmapBytesPerRow * pixelsHight);
  // ビットマップデータのメモリを確保
  bitmapData = malloc( bitmapByteCount );
  // CGBitmapContextオブジェクトを作成
  context = CGBitmapContextCreate (bitmapData,
                                   pixelsWidth,
                                   pixelsHight,
                                   8,      // bits per component
                                   bitmapBytesPerRow,
                                   colorSpace,
                                   kCGImageAlphaPremultipliedFirst);
  CGColorSpaceRelease( colorSpace );
  // CGImageを描画
  CGContextDrawImage(context, CGRectMake(0,0,pixelsWidth,pixelsHight), inImage); 
  
  return context;
}

// CGImageをOpenCVの画像データに変換するメソッド。
- (IplImage *)newIplImageFromCGImage:(CGImageRef)image {
  // RGB色空間を作成
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  // 一時的なIplImageを作成
  IplImage *iplimage = cvCreateImage(cvSize(CGImageGetWidth(image),CGImageGetHeight(image)), IPL_DEPTH_8U, 4);
  
  // CGBitmapContextをIplImageのビットマップデータのポインタから作成
  CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,iplimage->depth, iplimage->widthStep,colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
  // CGImageをCGBitmapContextに描画
  CGContextDrawImage(contextRef,CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)),image);
  CGContextRelease(contextRef);
  CGColorSpaceRelease(colorSpace);
  
  // 最終的なIplImageを作成
  IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
  cvCvtColor(iplimage, ret, CV_RGBA2RGB);// (1)
  cvReleaseImage(&iplimage);
  //戻り値のIplImageは利用後にcvReleaseImageで解放する必要があります。
  return ret;
}

// OpenCVの画像データをCGImageに変換するメソッド。
- (CGImageRef)newCGImageFromIplImage:(IplImage *)image {
  // RGB色空間
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  // IplImageのビットマップデータのポインタアドレスからNSDataを作成
  NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
  
  // CGImageを作成
  CGImageRef cgImage = CGImageCreate(image->width, image->height,image->depth, image->depth * image->nChannels, image->widthStep,colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,provider, NULL, false, kCGRenderingIntentDefault);
  return cgImage;
}

@end
