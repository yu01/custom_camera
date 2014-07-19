//
//  ARDetailViewController.m
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "ARDetailViewController.h"

// 位置情報の詳細情報を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation ARDetailViewController
@synthesize webView;
@synthesize activityIndicatorView;
@synthesize urlString;

- (void)dealloc {
  [urlString release];
  [webView release];
  [activityIndicatorView release];
  [super dealloc];
}

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  // ナビゲーションバーの色を黒に設定
  [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  // ナビゲーションバーを表示
  [self.navigationController setNavigationBarHidden:FALSE];
  // 通信中を表示
  [activityIndicatorView startAnimating];
  // WEBページを非同期で表示
  [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];  
}

// UIWebViewDelegateプロトコルで定義されているメソッド。WEBページの読みこみが完了した時に呼び出される
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  // 通信中を非表示に設定
  [activityIndicatorView stopAnimating];
}

@end
