//
//  FlickrAPI.h
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// Flickr API Key文字列
#define API_KEY @"【読者用のキー】"
// Flickr API Secret文字列
#define API_SECRET @"【読者用のキー】"

// FlickrAPIインスタンスからの通知を受け取るためのメソッドを定義するプロトコル
@protocol FlickrAPIDelegate<NSObject>
// アップロードの進捗を通知をされる時に呼び出されるメソッド。書き込んだバイト数と、全体の書き込み予定のバイト数を引数から、取得する
- (void)uploadInProgress:(int)totalBytesWritten totalBytesExpectedToWrite:(int)totalBytesExpectedToWrite;
// 写真のアップロードが完了した時に呼び出されるメソッド
- (void)uploadFinished:(NSString*)photoId;
// 写真の検索が完了した時に呼び出されるメソッド。引数の配列に検索結果の情報として、NSDictionaryのインスタンスが格納されている
- (void)photoSearchFinished:(NSArray*)photos;
@end

// FlickrのAPIを呼び出し、実行するクラスの定義
@interface FlickrAPI : NSObject {
  // frob文字列
  NSString *frob;
  // 認証トークン
  NSDictionary *tokenData;
  // 処理の結果の通知を行う先のインスタンス
  NSObject<FlickrAPIDelegate> *delegate;
}

@property (nonatomic,retain) NSDictionary *tokenData;
@property (nonatomic,retain) NSString *frob;
@property (nonatomic,assign) NSObject<FlickrAPIDelegate> *delegate;

// シングルトンインスタンスを取得するメソッド
+(FlickrAPI*)instance;

// Flickrからfrobを取得するメソッド
- (void)requestFrob;
// Flickrより認証トークンを取得するメソッド
- (void)requestAuthToken;
// Flickrサーバに写真をアップロードするメソッド
- (void)uploadPhoto:(UIImage*)photoImage;
// 指定の写真の位置情報の設定を行うメソッド
- (void)setGeoTag:(NSString*)photoId lat:(double)lat lon:(double)lon;
// 地図座標の範囲内の自分が登録した写真の検索を行うメソッド
- (void)searchPhotos:(CLLocationCoordinate2D)leftBottom rightTop:(CLLocationCoordinate2D)rightTop;
// アプリケーション認証用WEBページのURLの取得を行うメソッド
- (NSURL*)authURL;

@end
