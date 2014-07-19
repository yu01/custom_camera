//
//  FaceFindFilter.h
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "ImageFilterBase.h"

// 顔検出フィルタクラスの定義
@interface FaceFindFilter : ImageFilterBase {
  // 顔検出アルゴリズム用メモリ領域
  CvMemStorage *storage;
  // 顔検出アルゴリズム
  CvHaarClassifierCascade *cascade;  
}

@end
