//
//  ImageFilterBase.h
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "opencv/cv.h"

// フィルタ処理を行うクラスの基底クラスの定義
@interface ImageFilterBase : NSObject {
  // フィルタ名
  NSString *title; // (1)
  // フィルタで設定可能な値の最小値
  NSNumber *minValue; // (2)
  // フィルタで設定可能な値の最大値
  NSNumber *maxValue;  // (3)
  // フィルタの設定中の値
  NSNumber *currentValue; // (4)
}
@property (retain) NSString *title;
@property (retain) NSNumber *minValue;
@property (retain) NSNumber *maxValue;
@property (retain) NSNumber *currentValue;

// floatの値をunsigned charの範囲に最適化するメソッド。
- (unsigned char)normalizeToChar:(CGFloat)value;

// フィルタ処理を実行するメソッド。引数のCGImageに対してフィルタ処理を実行し、返り値でフィルタ処理されたCGImageを返す。
- (CGImageRef)filterImage:(CGImageRef)image;
// CGImageからCGBitmapContextを作成するメソッド。引数のCGImageからCGBitmapContextを作成する。
- (CGContextRef)createARGBBitmapContext:(CGImageRef) inImage;

// CGImageをOpenCVの画像データに変換するメソッド。
- (IplImage *)newIplImageFromCGImage:(CGImageRef)image;

// OpenCVの画像データをCGImageに変換するメソッド。
- (CGImageRef)newCGImageFromIplImage:(IplImage *)image;

@end
