//
//  FilterCameraAppDelegate.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "FilterCameraAppDelegate.h"
#import "FilterCameraViewController.h"
#import "ImageFilterBase.h"
#import "BrightnessFilter.h"
#import "GrayScaleFilter.h"
#import "SepiaFilter.h"
#import "MosaicFilter.h"
#import "FishEyeFilter.h"
#import "GaussianFilter.h"
#import "EdgeFindFilter.h"
#import "FaceFindFilter.h"
#import "MultiMonitorFilter.h"

// UIApplicationDelegateプロトコルを実装するクラスの実装
@implementation FilterCameraAppDelegate

@synthesize window =_window;
@synthesize viewController=_viewController;

// UIApplicationDelegateプロトコルで定義されているメソッド。アプリケーションが起動したときに呼び出される。
- (BOOL)application: ( UIApplication * )application didFinishLaunchingWithOptions: ( NSDictionary * )launchOptions {
  // ステータスバーを隠す
  application.statusBarHidden = TRUE;
  
  // 階層状にViewを表示するViewController
  navigationController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
  // ナビゲーションバーの色を半透明の黒に設定
  navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
  
  self.window.rootViewController = navigationController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)dealloc {
  [navigationController release];
  [filters release];
  [_viewController release];
  [_window release];
  [super dealloc];
}

// フィルタ配列を取得するメソッド。
- (NSArray *)filters {
  if (filters == nil) {
    NSMutableArray *newFilters = [[NSMutableArray alloc]init];
    // ここにフィルタを追加 
    [newFilters addObject:[[[ImageFilterBase alloc]init]autorelease]]; // (1)
    [newFilters addObject:[[[BrightnessFilter alloc]init]autorelease]];
    [newFilters addObject:[[[GrayScaleFilter alloc]init]autorelease]];
    [newFilters addObject:[[[SepiaFilter alloc]init]autorelease]];
    [newFilters addObject:[[[MosaicFilter alloc]init]autorelease]];
    [newFilters addObject:[[[FishEyeFilter alloc]init]autorelease]];
    [newFilters addObject:[[[GaussianFilter alloc]init]autorelease]];
    [newFilters addObject:[[[EdgeFindFilter alloc]init]autorelease]];
    [newFilters addObject:[[[FaceFindFilter alloc]init]autorelease]];
    [newFilters addObject:[[[MultiMonitorFilter alloc]init]autorelease]];
    
    filters = [newFilters retain];
    [newFilters release];
  }
  return [[filters retain]autorelease];
}

@end
