//
//  ARDetailViewController.h
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>

// 位置情報の詳細情報を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface ARDetailViewController : UIViewController<UIWebViewDelegate> {

}

// WEBページを表示
@property (nonatomic,retain) IBOutlet UIWebView *webView;
// 通信中を表示
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
// WEBページのURL文字列
@property (nonatomic,retain) NSString *urlString;

@end
