//
//  RootViewController.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FlickrAPI.h"

@class PhotoAnnotation;
@class ImageViewController;

// 地図画面を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface RootViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,MKMapViewDelegate,FlickrAPIDelegate> {
  // 現在地を取得を行うインスタンス
  CLLocationManager *locationManager;
  
  // 地図上に表示されている情報の配列
  NSArray *photoAnnotations;
  
  // 画像表示を行うUIViewControllerクラスの継承クラス
  ImageViewController *imageViewController;
  
  // 検索を時間差で行うためのタイマー
  NSTimer *updateTimer;
  
}

// 地図を表示するView
@property (nonatomic,retain) IBOutlet MKMapView *mapView;
// アップロードの進捗を表示を行うView
@property (nonatomic,retain) IBOutlet UIView *progressView;
// アップロードの進捗を表示
@property (nonatomic,retain) IBOutlet UIProgressView *progressBar;
// 選択中の写真の情報
@property (nonatomic,retain) PhotoAnnotation *selectedannoation;

// 地図上に表示する情報を地図の範囲に合わせて更新するメソッド
- (void)updateAnnotations;
@end
