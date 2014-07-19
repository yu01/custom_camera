//
//  ARLocalSearchAppDelegate.h
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>

#import "ARGeoViewController.h"

// UIApplicationDelegateプロトコルを実装するクラスの定義
@interface ARLocalSearchAppDelegate : NSObject <UIApplicationDelegate,UISearchBarDelegate,CLLocationManagerDelegate,ARViewDelegate> {
  // 検索バー。検索文字列を入力する
  UISearchBar *searchBar;
  // 表示するViewに対応するUIViewControllerクラスの継承クラス
  ARGeoViewController *geoViewController;
}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// 周辺の位置情報を検索するメソッド。緯度経度座標とキーワードから周辺の位置情報を検索する
- (NSArray*)searchLocationsByCoordinate:(CLLocationCoordinate2D)coordinate keyword:(NSString*)keyword;
// WEBページを表示するメソッド。タイトルとURLを指定してWEBページを表示する
- (void)showDetail:(NSString*)title url:(NSString*)url;

@end
