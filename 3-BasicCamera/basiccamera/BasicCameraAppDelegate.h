//
//  BasicCameraAppDelegate.h
//  BasicCamera
//
//  Created by 細谷 日出海 on 11/02/04.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>

@class BasicCameraViewController;

// UIApplicationDelegateプロトコルを実装するクラスの定義
@interface BasicCameraAppDelegate : NSObject <UIApplicationDelegate> {

}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// 表示するViewに対応するUIViewControllerクラスの派生クラス
@property (nonatomic, retain) IBOutlet BasicCameraViewController *viewController;

@end
