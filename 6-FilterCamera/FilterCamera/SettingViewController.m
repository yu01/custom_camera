//
//  SettingViewController.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "SettingViewController.h"
#import "FilterCameraViewController.h"
#import "FilterCameraAppDelegate.h"
#import "ImageFilterBase.h"


@implementation SettingViewController

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // ナビゲーションバーのに表示されるタイトルを設定
  self.title = @"設定";
}

// UITableViewDataSourceプロトコルで定義されているメソッド。引数の行に該当するUITableViewCellを返す。
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *identifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc]initWithFrame:CGRectZero reuseIdentifier:identifier] autorelease];
  }
  
  // FilterCameraAppDelegateからフィルタを取得
  FilterCameraAppDelegate *FilterCameraAppDelegate = [UIApplication sharedApplication].delegate;
  ImageFilterBase *filter = [[FilterCameraAppDelegate filters] objectAtIndex:indexPath.row]; // (1)
  // 行にフィルタ名を表示
  cell.textLabel.text = filter.title;
  ImageFilterBase *currentFilter = ((FilterCameraViewController*)FilterCameraAppDelegate.viewController).filter;// (2)
  if (currentFilter == filter) {
    // 選択中のフィルターの場合は、チェックマークを表示
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  return cell;
}

// UITableViewDataSourceプロトコルで定義されているメソッド。該当セクションの行の総数を返す。
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  FilterCameraAppDelegate *FilterCameraAppDelegate = [UIApplication sharedApplication].delegate;
  // 選択可能なフィルタの数
  return [[FilterCameraAppDelegate filters] count]; // (3)
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FilterCameraAppDelegate *FilterCameraAppDelegate = [UIApplication sharedApplication].delegate;
  // 選択されたフィルタを取得
  ImageFilterBase *filter = [[FilterCameraAppDelegate filters] objectAtIndex:indexPath.row];
  // 撮影画面のフィルタを設定
  ((FilterCameraViewController*)FilterCameraAppDelegate.viewController).filter = filter;
  [self.navigationController popViewControllerAnimated:TRUE];
}

@end
