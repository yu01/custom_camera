//
//  ARLocalSearchAppDelegate.m
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "ARLocalSearchAppDelegate.h"
#import "JSON.h"
#import "ARGeoCoordinate.h"
#import "LocationTag.h"
#import "ARDetailViewController.h"

@implementation ARLocalSearchAppDelegate


@synthesize window=_window;

// UIApplicationDelegateプロトコルで定義されているメソッド。アプリケーションが起動したときに呼び出される
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // ステータスバーを非表示
  [[UIApplication sharedApplication]setStatusBarHidden:TRUE];
  
  // ARGeoViewControllerの作成
  geoViewController = [[ARGeoViewController alloc] init];
  geoViewController.delegate = self;
  geoViewController.locationDelegate = self;
  geoViewController.scaleViewsBasedOnDistance = NO;
  geoViewController.rotateViewsBasedOnPerspective = NO;  
  
  // 検索バーを追加
  searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,320,44)];
  searchBar.barStyle = UIBarStyleBlackTranslucent;
  searchBar.showsCancelButton = TRUE;
  [geoViewController.view addSubview:searchBar];
  searchBar.delegate = self;
  
  self.window.rootViewController = geoViewController;
  [self.window makeKeyAndVisible];
  
  // 現在位置の取得を開始
  [geoViewController startListening];
  [geoViewController.locationManager startUpdatingLocation];
  
  return YES;
}

// CLLocationManagerDelegateプロトコルで定義されているメソッド。現在位置が更新したときに呼びだされる
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  // 表示緯度経度を変更
  geoViewController.centerLocation = newLocation;
}

// 周辺の位置情報を検索するメソッド。緯度経度座標とキーワードから周辺の位置情報を検索する
- (NSArray*)searchLocationsByCoordinate:(CLLocationCoordinate2D)coordinate keyword:(NSString*)keyword {
  // 位置情報検索のURL文字列の組み立て
  NSMutableString *urlString = [NSMutableString stringWithString:@"http://ajax.googleapis.com/ajax/services/search/local?v=1.0&q="];
  [urlString appendString:[keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [urlString appendFormat:@"&sll=%f,%f",coordinate.latitude,coordinate.longitude];
  [urlString appendFormat:@"&sspn=0.02,0.02"];
  [urlString appendString:@"&lr=lang_ja&rsz=large"];
  
  // 一度に取得できるのは8件。最大32件になるまで検索
  NSMutableArray *results = [[NSMutableArray alloc]initWithCapacity:32];
  int currentIndex = 0;
  while ([results count] < 32) {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&start=%d",urlString,currentIndex]]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *res;
    NSError *err;
    // 同期通信によってリクエストし結果を取得
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&err];
    NSString *contents = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    // JSON Frameworkを利用して文字列をNSDictionaryとして取得
    NSDictionary *result = (NSDictionary*)[contents JSONValue];
    [contents release];
    
    // 結果を取得
    NSArray *pageResults = [[result objectForKey:@"responseData"]objectForKey:@"results"];
    [results addObjectsFromArray:pageResults];
    
    // 結果の総数
    if ([pageResults count]<8) {
      // 結果の総数に達した場合は、ループを抜ける
      break;
    }
    currentIndex+=[pageResults count];
  }
  return [results autorelease];
}

// 検索バーに入力された文字列と現在位置をキーにして検索を実行するメソッド。検索ボタンを選択したときに呼び出される
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
  // ソフトウェアキーボードを非表示にする
  [searchBar resignFirstResponder];
  // 現在位置を取得
  CLLocation *location = [geoViewController.locationManager location];
  if (location == nil) {
    return;
  }
  // 表示中のタグをすべて消す
  [geoViewController removeCoordinates:[NSArray arrayWithArray:geoViewController.coordinates]];
  for (UIView *curView in [geoViewController.view subviews]) {
    if (![curView isKindOfClass:[UISearchBar class]]) {
      [curView removeFromSuperview];
    }
  }
  // 現在位置と検索バーに入力された文字列をキーにして位置情報の検索を実行
  NSArray *result = [self searchLocationsByCoordinate:location.coordinate keyword:searchBar.text];
  NSMutableArray *newLocations = [[NSMutableArray alloc]init];
  for (NSDictionary *info in result) {
    // 検索結果から画面に表示する位置情報を作成
    NSString *title = [info objectForKey:@"titleNoFormatting"];
    NSString *url = [info objectForKey:@"url"];    
    CLLocation *tempLocation = [[CLLocation alloc]initWithLatitude:[[info objectForKey:@"lat"]doubleValue] longitude:[[info objectForKey:@"lng"]doubleValue]];
    ARGeoCoordinate* tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
    tempCoordinate.title = title;
    tempCoordinate.subtitle = url;
    [newLocations addObject:tempCoordinate];
    [tempLocation release];
  }
  [geoViewController addCoordinates:newLocations];
  [newLocations release];
}

// 検索バーの入力をキャンセルするメソッド。検索バーのキャンセルボタンを選択したときに呼び出される
- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
  // ソフトウェアキーボードを非表示にする
  [searchBar resignFirstResponder];
}

- (void)dealloc
{
  [_window release];
  [super dealloc];
}

// 撮影画面に表示する位置情報に該当するViewを表示するときに呼び出されるメソッド
- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
  // 現在位置を取得
  CLLocation *location = [geoViewController.locationManager location];
  // 距離を取得
  CLLocationDistance distance = [((ARGeoCoordinate*)coordinate).geoLocation distanceFromLocation:location];
  // タグを作成
  LocationTag *locationTag = [[LocationTag alloc]initWithARCoordinate:coordinate distance:distance];
  return [locationTag autorelease];
}

// WEBページを表示するメソッド。タイトルとURLを指定してWEBページを表示する
- (void)showDetail:(NSString*)title url:(NSString*)url {
  // xibファイルからUIViewControllerを読込
  ARDetailViewController *detailViewController = [[ARDetailViewController alloc]initWithNibName:@"ARDetailViewController" bundle:nil];
  detailViewController.title = title;
  detailViewController.urlString = url;
  // ナビゲーションコントローラに追加して表示
  [geoViewController.cameraController pushViewController:detailViewController animated:TRUE];
  [detailViewController release];
}

@end
