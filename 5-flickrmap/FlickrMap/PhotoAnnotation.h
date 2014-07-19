//
//  PhotoAnnotation.h
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>


#import <MapKit/MapKit.h>

// 検索結果を地図上に表示する情報を格納するクラスの定義
// MKAnnotationプロトコルを実装
@interface PhotoAnnotation : NSObject<MKAnnotation> {
  // 写真の属性情報
  NSDictionary *photoRecord;
  // 緯度経度
  CLLocationCoordinate2D coordinate;
}

// 初期化メソッド。写真の属性情報を指定してインスタンスの初期化を行う
- (id)initWithPhotoRecord:(NSDictionary*)photoRecord;
// 小さい画像のURLを取得するメソッド
- (NSURL*)smallImageURL;
// 画像のURLを取得するメソッド
- (NSURL*)mediumImageURL;
@end
