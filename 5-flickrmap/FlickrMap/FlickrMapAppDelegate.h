//
//  FlickrMapAppDelegate.h
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//
#import <UIKit/UIKit.h>

// UIApplicationDelegateプロトコルを実装するクラスの定義
@interface FlickrMapAppDelegate : NSObject <UIApplicationDelegate> {

}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// 階層状にViewを表示するViewController
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
