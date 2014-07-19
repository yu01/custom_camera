//
//  FilterCameraAppDelegate.h
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>

@class FilterCameraViewController;

// UIApplicationDelegateプロトコルを実装するクラスの定義
@interface FilterCameraAppDelegate : NSObject <UIApplicationDelegate> {
  // 階層状にViewを表示するViewController
  UINavigationController *navigationController;
  // フィルタ配列
  NSArray *filters;
}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// 撮影画面のViewを表示するViewController
@property (nonatomic, retain) IBOutlet FilterCameraViewController *viewController;
// フィルタ配列を取得するメソッド。
- (NSArray*)filters;

@end
