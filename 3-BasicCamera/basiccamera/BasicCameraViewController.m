//
//  BasicCameraViewController.m
//  BasicCamera
//
//  Created by 細谷 日出海 on 11/02/04.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BasicCameraViewController.h"

// 撮影した画像を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation BasicCameraViewController
@synthesize imageView;
@synthesize saveImageButton;

- (void)dealloc {
  [imageView release];
  [saveImageButton release];
  [super dealloc];
}

// カメラでの撮影画面を表示するメソッド
- (IBAction)showCameraAction:(id)sender {
  // 画像を選択を行うためのインスタンスを作成
  UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
  imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera; // (1)
  imagePickerController.delegate = self; // (2)
  imagePickerController.allowsEditing = TRUE; // (3)
  [self presentModalViewController:imagePickerController animated:TRUE];// (4)
  [imagePickerController release];
}

// 撮影した画像をiPhoneのアルバムに保存するメソッド
- (IBAction)saveImageAction:(id)sender {
  // 表示されている画像を取得
  UIImage *image = imageView.image;
  // iPhoneのアルバムに画像を保存
  UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
  // 保存ボタンを選択不可に変更
  saveImageButton.enabled = FALSE;
}

// UIImagePickerControllerDelegateプロトコルで定義されているメソッド。ユーザによって画像が選択、あるいは撮影されたときに呼び出される
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  // ユーザが選択した範囲の画像を取得
  UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
  // 画像を画面に表示
  imageView.image = image;
  // 保存ボタンを選択可能に変更
  saveImageButton.enabled = TRUE;
  // 撮影画面を非表示にする
  [self dismissModalViewControllerAnimated:TRUE];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Viewの表示方向に対応しているか否かを返すメソッド。引数の表示方向に対応している場合はYESを返す
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // すべての方向に対応するため常にYESを返す
  return YES;
}

@end
