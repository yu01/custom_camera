//
//  FilterCameraViewController.h
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <AVFoundation/AVFoundation.h>

@class ImageFilterBase;

// 撮影画面を表示するViewに対応するUIViewControllerクラスの派生クラスの定義
@interface FilterCameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
  // キャプチャーセッション
  AVCaptureSession *session; //  (1)
}

// フィルタ処理された画像を表示するView
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
// 処理の進捗を表示
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
// フィルタ設定値の変更用スライダー
@property (nonatomic,retain) IBOutlet UISlider *slider; // (3)
// フィルタ選択画面表示用ボタン
@property (nonatomic,retain) IBOutlet UIBarButtonItem *filterButton;
// 選択中のフィルタ
@property (nonatomic,retain) ImageFilterBase *filter;

// 撮影画面に表示されている画像をアルバムに保存
- (IBAction)takePhotoAction:(id)sender;

// フィルタ設定値の変更用スライダーの値が変更されたときに呼び出されるメソッド （4）
- (IBAction)sliderValueChangedAction:(id)sender;

// フィルタ選択画面を表示
- (IBAction)showConfigAction:(id)sender;

@end
