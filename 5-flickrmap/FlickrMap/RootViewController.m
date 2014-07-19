//
//  RootViewController.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "RootViewController.h"

#import "RootViewController.h"
#import "FlickrAPI.h"
#import "PhotoAnnotation.h"
#import "ImageViewController.h"

// 地図画面を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation RootViewController
@synthesize mapView;
@synthesize progressView;
@synthesize progressBar;
@synthesize selectedannoation;

- (void)dealloc {
  [selectedannoation release];
  [progressView release];
  [progressBar release];
  [imageViewController release];
  [photoAnnotations release];
  [mapView release];
  [locationManager release];
  [super dealloc];
}

// xibファイルからViewの読込が完了した時に呼び出されるメソッド
- (void)viewDidLoad {
  [super viewDidLoad];
  // タイトルを設定
  self.title = @"FlickrMap";
  
  // 現在地取得を開始
  locationManager = [[CLLocationManager alloc]init];
  [locationManager startUpdatingLocation];
  // 地図の初期位置を設定
  double mapWidth = mapView.visibleMapRect.size.width / 1024;
  double mapHeight = mapView.visibleMapRect.size.height / 1024;
  MKMapPoint centerMapPoint = MKMapPointForCoordinate([locationManager location].coordinate);
  MKMapRect mapRect = MKMapRectMake(centerMapPoint.x-(mapWidth/2), centerMapPoint.y-(mapHeight/2),mapWidth,mapHeight);
  mapView.visibleMapRect = mapRect;
}

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 追加ボタンをナビゲーションバーの右に配置
  UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithTitle:@"追加" style:UIBarButtonItemStyleBordered target:self action:@selector(showImagePickerController:)];
  self.navigationItem.rightBarButtonItem = addButton;
  [addButton release];
  
  // 現在地ボタンをナビゲーションバーの左に配置
  UIBarButtonItem *updateLocationButton = [[UIBarButtonItem alloc]initWithTitle:@"現在地" style:UIBarButtonItemStyleBordered target:self action:@selector(updateLocationAction:)];
  self.navigationItem.leftBarButtonItem = updateLocationButton;
  [updateLocationButton release];
  // 地図表示範囲の写真を検索して表示
  [self updateAnnotations];
}

// 撮影画面を表示するメソッド。追加ボタンを選択したときに呼び出され、モーダルViewとして表示される
- (void)showImagePickerController:(id)sender {
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
  imagePickerController.allowsEditing = TRUE;
  imagePickerController.delegate = self;
  [self presentModalViewController:imagePickerController animated:YES];
  [imagePickerController release];
}

// UIImagePickerControllerDelegateプロトコルで定義されているメソッド。ユーザによって撮影が行われたときに呼び出される
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  // モーダルViewを非表示にする
  [self dismissModalViewControllerAnimated:TRUE];
  // 進捗を0に戻す
  [[[UIApplication sharedApplication]keyWindow]addSubview:progressView];
  progressBar.progress = 0;
  // 撮影画像で撮影された画像を取得
  UIImage *image = nil;
  if ([info objectForKey:UIImagePickerControllerEditedImage] != nil) {
    image = [info objectForKey:UIImagePickerControllerEditedImage];
  } else {
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
  }
  // 画像をアップロードする
  FlickrAPI *flickrAPI = [FlickrAPI instance];
  flickrAPI.delegate = self;
  [flickrAPI uploadPhoto:image];
}
// FlickrAPIDelegateプロトコルで定義されているメソッド。画像のアップロード中に呼び出される
- (void)uploadInProgress:(int)totalBytesWritten totalBytesExpectedToWrite:(int)totalBytesExpectedToWrite {
  // 進捗の割合を計算し、進捗を設定
  float progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
  [progressBar setProgress:progress];
}

// FlickrAPIDelegateプロトコルで定義されているメソッド。画像のアップロード完了時に呼び出される
- (void)uploadFinished:(NSString*)photoId {
  // 写真に緯度経度をつける
  [[FlickrAPI instance]setGeoTag:photoId lat:mapView.centerCoordinate.latitude lon:mapView.centerCoordinate.longitude];
  // 進捗を非表示にする
  [progressView removeFromSuperview];
  // 追加分を表示するために 地図表示範囲の写真を検索して表示
  [self updateAnnotations];
}

// 地図の表示位置を現在地に移動するメソッド
- (void) updateLocationAction:(id)sender {
  // CLLocationManagerから現在位置を取得し、MapViewの中心緯度経度を変更
  mapView.centerCoordinate = [locationManager location].coordinate;
}

- (void)updateAnnotations {
  // 既に検索が実行されているときは、停止させる
  if (updateTimer != nil) {
    [updateTimer invalidate];
    [updateTimer release];
    updateTimer = nil;
  }
  // 表示座標に該当する写真の検索を2秒後に実行する
  updateTimer = [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateAnnotationsTask:) userInfo:nil repeats:NO]retain];
}

// 表示座標に該当する写真の検索を行うメソッド。タイマーにより呼び出される。検索結果は、FlickrAPIDelegateのメソッドに通知される
- (void)updateAnnotationsTask:(NSTimer*)timer {
  FlickrAPI *flickrAPI = [FlickrAPI instance];
  flickrAPI.delegate = self;
  // 地図の左下と右上の座標を取得
  MKMapPoint leftBottom = MKMapPointMake(MKMapRectGetMinX(mapView.visibleMapRect),MKMapRectGetMaxY(mapView.visibleMapRect));
  MKMapPoint rightTop = MKMapPointMake(MKMapRectGetMaxX(mapView.visibleMapRect),MKMapRectGetMinY(mapView.visibleMapRect));
  // 検索を実行
  [flickrAPI searchPhotos:MKCoordinateForMapPoint(leftBottom) rightTop:MKCoordinateForMapPoint(rightTop)];
}

// FlickrAPIDelegateプロトコルで定義されているメソッド。写真の検索が完了した時に呼び出される。引数の配列に検索結果の情報として、NSDictionaryのインスタンスが格納されている
- (void)photoSearchFinished:(NSArray*)photos {
  // 地図上に表示する写真の情報を作成
  NSMutableArray *newAnnotations = [[NSMutableArray alloc]initWithCapacity:[photos count]];
  for (NSDictionary *photo in photos) {
    [newAnnotations addObject:[[[PhotoAnnotation alloc]initWithPhotoRecord:photo]autorelease]];
  }
  if (photoAnnotations != nil) {
    // 既に表示されている情報を削除
    [mapView removeAnnotations:photoAnnotations];
    [photoAnnotations release];
    photoAnnotations = nil;
  }
  // 地図に写真の情報を表示
  [mapView addAnnotations:newAnnotations];
  photoAnnotations = [newAnnotations retain];
  [newAnnotations release];
}

// MKMapViewDelegateプロトコルで定義されているメソッド。地図の表示範囲が変更されたときに呼び出される
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  // 表示範囲の写真の検索を実行
  [self updateAnnotations];
}

// MKMapViewDelegateプロトコルで定義されているメソッド。引数のMKAnnotationに該当する地図上に表示するViewを描画をする時に呼び出される
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if (![annotation isMemberOfClass:[PhotoAnnotation class]]) {
    return nil;
  }
  // 地図上にピンを表示
  MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"myAnnotationView"];
  if (annotationView == nil) {
    annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnnotationView"];
    // ポップアップの詳細ボタンを選択したときに、写真表示画面を表示する
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [calloutButton addTarget:self action:@selector(showImageView:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = calloutButton;
    annotationView.canShowCallout = YES;
    // ポップアップの左にアイコンを表示させるためのView
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,32,32)];
    annotationView.leftCalloutAccessoryView = imageView;
    [imageView release];
  }
  annotationView.annotation = annotation;
  
  return annotationView;
}

// MKMapViewDelegateプロトコルで定義されているメソッド。ユーザが地図上のアイコンを選択したときに呼び出される
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  // ポップアップに表示する小さい画像を取得して、設定する
  self.selectedannoation = view.annotation;
  ((UIImageView*)view.leftCalloutAccessoryView).image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.selectedannoation smallImageURL]]];
}

// 写真表示画面を表示するメソッド。ポップアップの詳細ボタンを選択したときに呼び出される
- (void)showImageView:(id)sender {
  // 画像を取得
  UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.selectedannoation mediumImageURL]]];
  if (imageViewController == nil) {
    imageViewController = [[ImageViewController alloc]initWithNibName:@"ImageViewController" bundle:nil];
  }
  // 画像を設定
  imageViewController.image = image;
  // タイトルを写真の名前に設定
  imageViewController.title = [self.selectedannoation title];
  [self.navigationController pushViewController:imageViewController animated:TRUE];
}

@end
