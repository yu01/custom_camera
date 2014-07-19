//
//  BookScanAppDelegate.h
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
@class BookInfo;

@interface BookScanAppDelegate : NSObject <UIApplicationDelegate,ZBarReaderDelegate> {
  // バーコード撮影画面に対応するUIViewControllerクラスの継承クラス
  ZBarReaderViewController *zbarReaderViewController;
  // 階層状にViewを表示するViewController
  UINavigationController *navigationController;
  // 処理の進捗を表示
  UIActivityIndicatorView *activityIndicatorView;
  // Amazonよりダウンロードしたデータ
  NSMutableData *downloadData;
}

// 表示するウィンドウ
@property (nonatomic, retain) IBOutlet UIWindow *window;

// バーコードから書籍の検索を実行するメソッド。Amazonに通信でバーコードに該当する書籍の情報を問い合わせを実行する
- (void)searchBookInfoByBarcode:(NSString*)barcode barcodeType:(NSString*)barcodeType;
// 書籍の詳細情報から詳細画面を表示するメソッド
- (void)showBookInfo:(BookInfo*)bookInfo;

@end
