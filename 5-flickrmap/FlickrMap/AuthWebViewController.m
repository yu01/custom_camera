//
//  AuthWebViewController.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "AuthWebViewController.h"
#import "FlickrAPI.h"

// アプリケーション認証用WEBページを表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation AuthWebViewController

@synthesize webView;

- (void)dealloc {
  [webView release];
  [super dealloc];
}

// xibファイルからViewの読込が完了した時に呼び出されるメソッド
- (void)viewDidLoad {
  [super viewDidLoad];
  // タイトルを設定
  self.title = @"Flickr認証";
}

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  // 完了ボタンを作成しナビゲーションバーの右に配置
  UIBarButtonItem *finishButton = [[UIBarButtonItem alloc]initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(finishAuthAction:)];
  self.navigationItem.rightBarButtonItem = finishButton;
  [finishButton release];
  // FROBを取得
  FlickrAPI *flickrAPI = [FlickrAPI instance];
  [flickrAPI requestFrob];
  // 認証ページのURL
  NSURL *authURL = [flickrAPI authURL];
  // WEBページを表示
  [webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}

// アプリケーションの認証完了し、地図画面に移動するメソッド
- (void)finishAuthAction:(id)sender {
  // AUTH TOKENを取得します
  FlickrAPI *flickrAPI = [FlickrAPI instance];
  // 認証トークンを取得
  [flickrAPI requestAuthToken];
  NSDictionary *tokenData = flickrAPI.tokenData;
  if (tokenData != nil) {
    NSString *frob = flickrAPI.frob;  
    // 認証トークンとfrob文字列をファイルに保存
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tokenData forKey:@"tokenData"];
    [defaults setObject:frob forKey:@"frob"];
    // 地図画面に移動
    [self.navigationController popViewControllerAnimated:TRUE];
  }
}

@end
