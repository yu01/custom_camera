//
//  BasicCameraViewController.h
//  BasicCamera
//
//  Created by 細谷 日出海 on 11/02/04.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>

// 撮影した画像を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface BasicCameraViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
}

// 撮影した画像を表示するView
@property(nonatomic,retain) IBOutlet UIImageView *imageView;
// [保存]ボタン
@property(nonatomic,retain) IBOutlet UIBarButtonItem *saveImageButton;

// カメラでの撮影画面を表示
- (IBAction)showCameraAction:(id)sender;
// 撮影した画像をiPhoneのアルバムに保存
- (IBAction)saveImageAction:(id)sender;

@end
