//
//  ImageViewController.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "ImageViewController.h"


// 画像を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation ImageViewController

@synthesize imageView;
@synthesize image;

- (void)dealloc {
  [image release];
  [imageView release];
  [super dealloc];
}

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // 表示する画像をViewに設定
  imageView.image = image;
}

@end
