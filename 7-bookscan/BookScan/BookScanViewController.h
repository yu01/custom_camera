//
//  BookScanViewController.h
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>
#import "BookInfo.h"

// 書籍詳細情報を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface BookScanViewController : UIViewController<UITableViewDataSource> {
  // 属性文字列を表示するテーブルView
  UITableView *tableView;
  // 表示中のView
  UIView *currentView;
}

// 書籍詳細情報
@property (nonatomic,retain) BookInfo *bookInfo;
// 書籍画像を表示するView
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@end
