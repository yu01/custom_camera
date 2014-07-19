//
//  DoodleCameraAppDelegate.h
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//
#import <UIKit/UIKit.h>

@class DoodleCameraViewController;

// UIApplicationDelegateプロトコルを実装するクラスの定義
@interface DoodleCameraAppDelegate : NSObject <UIApplicationDelegate> {

}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// 表示するViewに対するUIViewControllerクラスの派生クラス
@property (nonatomic, retain) IBOutlet DoodleCameraViewController *viewController;

@end
