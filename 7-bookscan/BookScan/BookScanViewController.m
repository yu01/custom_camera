//
//  BookScanViewController.m
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BookScanViewController.h"


// 書籍詳細情報を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation BookScanViewController
@synthesize imageView;
@synthesize bookInfo;

- (void)dealloc {
  [imageView release];
  [tableView release];
  [bookInfo release];
  [super dealloc];
}

// xibファイルからViewの読込が完了した時に呼び出されるメソッド
- (void)viewDidLoad {
  [super viewDidLoad];
  // ナビゲーションバーに表示されるタイトルを設定
  self.title = bookInfo.title;
  
  // 戻るボタンを作成
  UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
  // ナビゲーションバーの戻るボタンに設定
  [self.navigationItem setBackBarButtonItem:backBarButtonItem];
  [backBarButtonItem release];
  
  // Safariボタンを作成
  UIBarButtonItem *safariButton = [[UIBarButtonItem alloc]initWithTitle:@"Safariで表示" style:UIBarButtonItemStyleBordered target:self action:@selector(launchSafari:)];
  // ナビゲーションバーの右に配置
  self.navigationItem.rightBarButtonItem = safariButton;
  [safariButton release];
  
  // 書籍画像を表示
  imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bookInfo.imageURL]]];
  // 表示中のViewを変更
  currentView = imageView;
  
  // 詳細情報表示用テーブル
  tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,320,460) style:UITableViewStyleGrouped];
  // タッチによって画像とテーブルを切り替えるので、テーブルのユーザ操作は無効にしておく
  tableView.userInteractionEnabled = FALSE;
  // テーブルの情報は、同じインスタンスから取得
  tableView.dataSource = self;
}

// UITableViewDataSourceプロトコルで定義されているメソッド。セクションの総数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // 表示する属性の数は4
  return 4;
}

// UITableViewDataSourceプロトコルで定義されているメソッド。該当セクションの行の総数を返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // セクション毎に属性を表示するので行の数は1
  return 1;
}

// UITableViewDataSourceプロトコルで定義されているメソッド。引数の行に該当するUITableViewCellを返す
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  // 属性の文字列をセルに表示
  if (indexPath.section == 0) {
    // タイトル
    cell.textLabel.text = bookInfo.title;
  } else if (indexPath.section == 1) {
    // 著者
    cell.textLabel.text = bookInfo.author;
  } else if (indexPath.section == 2) {
    // 出版社
    cell.textLabel.text = bookInfo.manufacturer;
  } else if (indexPath.section == 3) {
    // 出版日
    cell.textLabel.text = bookInfo.publicationDate;
  }
  return cell;
}

// UITableViewDataSourceプロトコルで定義されているメソッド。引数のセクションに該当するヘッダーに表示する文字列を返す
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  // セクションのヘッダに属性の名称を表示
  if (section == 0) {
    return @"タイトル";
  } else if (section == 1) {
    return @"著者";
  } else if (section == 2) {
    return @"出版社";
  } else if (section == 3) {
    return @"出版日";
  }
  return nil;
}

// ユーザによりViewへのタッチが開始したときに呼び出されるメソッド
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // 画面をタッチしたときにアニメーションで画像ViewとテーブルViewの表示を切り替え
  [UIView animateWithDuration:0.5 animations:^(void){
    if (currentView == tableView) {// (1)
      [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView: self.view cache: TRUE];
      // テーブルViewを削除
      [tableView removeFromSuperview];
      // 画像Viewを追加
      [self.view addSubview:imageView];
      currentView = imageView;
    } else {
      [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView: self.view cache: TRUE];
      // テーブルViewを追加
      [imageView removeFromSuperview];
      // 画像Viewを削除
      [self.view addSubview:tableView];
      currentView = tableView;
    }
  }];
}

// SafariアプリでAmazonの書籍ページを表示
-(void)launchSafari:(id)sender {
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:bookInfo.detailPageURL]];
}

@end
