//
//  PhotoAnnotation.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "PhotoAnnotation.h"


// 検索結果を地図上に表示する情報を格納するクラスの実装
@implementation PhotoAnnotation
@synthesize coordinate;

// 初期化メソッド。写真の属性情報を指定してインスタンスの初期化を行う
- (id)initWithPhotoRecord:(NSDictionary*)aPhotoRecord {
  if (self = [super init]) {
    photoRecord = [aPhotoRecord retain];
    // 属性から緯度経度を抽出し設定する
    coordinate.latitude = [[photoRecord objectForKey:@"latitude"]doubleValue];
    coordinate.longitude = [[photoRecord objectForKey:@"longitude"]doubleValue];
  }
  return self;
}

- (void)dealloc {
  [photoRecord release];
  [super dealloc];
}

// MKAnnotationプロトコルで定義されているメソッド。地図上に表示したときに表示されるタイトルを返す
- (NSString *)title {
  return [photoRecord objectForKey:@"title"];
}

// 小さい画像のURLを取得するメソッド
- (NSURL*)smallImageURL {
  // URL文字列を作成
  NSString *imageURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
                              [photoRecord objectForKey:@"farm"],
                              [photoRecord objectForKey:@"server"],  
                              [photoRecord objectForKey:@"id"],  
                              [photoRecord objectForKey:@"secret"]];
  return [NSURL URLWithString:imageURLString];
}

// 画像のURLを取得するメソッド
- (NSURL*)mediumImageURL {
  // URL文字列を作成
  NSString *imageURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg",
                              [photoRecord objectForKey:@"farm"],
                              [photoRecord objectForKey:@"server"],  
                              [photoRecord objectForKey:@"id"],  
                              [photoRecord objectForKey:@"secret"]];
  return [NSURL URLWithString:imageURLString];
}

@end
