//
//  AuthWebViewController.h
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>


// アプリケーション認証用WEBページを表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface AuthWebViewController : UIViewController {
    
}

// Webページを表示するView
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@end
