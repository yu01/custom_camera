//
//  LocationTag.h
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARGeoCoordinate.h"

// 位置情報のタグを表示するViewクラスの定義
@interface LocationTag : UIView {
  ARCoordinate *arCoordinate;
}
// 初期化メソッド。位置情報と距離からLocationTagインスタンスの初期化を行う
- (id)initWithARCoordinate:(ARCoordinate *)coordinate distance:(CLLocationDistance)distance;

@end
