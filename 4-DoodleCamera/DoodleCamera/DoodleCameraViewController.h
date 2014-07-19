//
//  DoodleCameraViewController.h
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//
#import <AVFoundation/AVFoundation.h>
#import "DrawView.h"
#import "PenStyleDataSource.h"
#import "PenColorDataSource.h"

// 落書き画面と撮影中の画像を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface DoodleCameraViewController : UIViewController {
  // 撮影中の画像を表示するView
  UIView *previewView; // (1)
  // 落書き画面
  DrawView *drawView; // (2)
  // 撮影中のセッションの情報を画像として出力
  AVCaptureStillImageOutput *stillImageOutput; // (3)
  
  // ペンの色選択肢を表示するView
  UIView *colorChooseView; // (4)
  // ペンの色選択肢のDataSource
  PenColorDataSource *penColorDataSource;
  
  // ペンの太さ選択肢を表示するView
  UIView *styleChooseView; // (5)
  // ペンの太さ選択肢のDataSource
  PenStyleDataSource *penStyleDataSource;
  
  BOOL frontCamera;
}

@property (nonatomic,retain) IBOutlet UIView *previewView;

// 落書き画面と撮影画面を合成して保存
-(IBAction)takePhotoAction:(id)sender;
// 落書きを消去
-(IBAction)clearAction:(id)sender;
// ペンの色選択肢を表示
-(IBAction)chooseColorAction:(id)sender;
// ペンの太さ選択肢を表示
-(IBAction)choosePenStyleAction:(id)sender;
@end
