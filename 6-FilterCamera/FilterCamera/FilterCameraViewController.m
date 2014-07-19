//
//  FilterCameraViewController.m
//  FilterCamera
//
//  Created by 細谷 日出海 on 11/02/07.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//
#import "FilterCameraViewController.h"
#import "SettingViewController.h"
#import "ImageFilterBase.h"
#import "FilterCameraAppDelegate.h"

// 撮影画面を表示するViewに対応するUIViewControllerクラスの派生クラスの実装
@implementation FilterCameraViewController

@synthesize imageView;
@synthesize activityIndicatorView;
@synthesize slider;
@synthesize filter;
@synthesize filterButton;

- (void)dealloc {
  [filterButton release];
  [slider release];
  [filter release];
  [imageView release];
  [activityIndicatorView release];
  [super dealloc];
}

// xibファイルからViewの読込が完了した時に呼び出されるメソッド。
- (void)viewDidLoad {
  [super viewDidLoad];
  // ナビゲーションバーに表示されるタイトルを設定
  self.title = @"Filter Camera";
}

// Viewが表示される前に呼び出されるメソッド
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // ナビゲーションバーの右側にフィルタ選択画面表示用ボタンを配置
  self.navigationItem.rightBarButtonItem = filterButton;
  // 処理中を表示
  [activityIndicatorView startAnimating];// (1)
  if (filter == nil) {
    // 未指定の場合は、一件目のフィルタを使用。
    self.filter = [((FilterCameraAppDelegate*)[UIApplication sharedApplication].delegate).filters objectAtIndex:0];
  }
}

// Viewの表示方向に対応しているか否かを返すメソッド。引数の表示方向に対応している場合はYESを返す。
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  // ホームボタンが右側にある表示方向に対応
  return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

// Viewが表示された後に呼び出されるメソッド
- (void)viewDidAppear:(BOOL)animated {
  if (session == nil) {
    NSError *error = nil;
    // 入力と出力からキャプチャーセッションを作成
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium; // (1)
    
    // カメラからの入力を作成
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];// (2)
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [session addInput:input];
    
    // ビデオへの出力を作成
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [session addOutput:output];
    
    // ビデオ出力のキャプチャの画像情報のキューを設定
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);//(3)
    [output setAlwaysDiscardsLateVideoFrames:TRUE];
    [output setSampleBufferDelegate:self queue:queue];
    
    dispatch_release(queue);
    
    // ビデオへの出力の画像は、BGRAで出力
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]; 
    
    // 1秒あたり4回画像をキャプチャ
    output.minFrameDuration = CMTimeMake(1, 4); // (4)
  }
  
  if (!session.running) {
    // セッションを開始
    [session startRunning]; // (5)
  }  
}

// キャプチャしたフレームからCGImageに変換するメソッド。
- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CVPixelBufferLockBaseAddress(imageBuffer,0);
  
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
  size_t width = CVPixelBufferGetWidth(imageBuffer); 
  size_t height = CVPixelBufferGetHeight(imageBuffer); 
  
  // RGBの色空間
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
  
  // キャプチャしたフレームの画像情報が格納されているアドレス
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  // キャプチャしたフレームの画像情報からCGBitmapContextを作成
  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
  // CGBitmapContextからCGImageを作成
  CGImageRef cgImage = CGBitmapContextCreateImage(newContext);
  
  CGContextRelease(newContext);
  CGColorSpaceRelease(colorSpace);
  
  CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
  return cgImage;
}

// AVCaptureVideoDataOutputSampleBufferDelegateプロトコルのメソッド。新しいキャプチャの情報が追加されたときに呼び出される。
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection { 
  // キャプチャしたフレームからCGImageを作成
  CGImageRef inImage = [self imageFromSampleBuffer:sampleBuffer];
  CGImageRef filteredImage;
  if (filter != nil) {
	  // 選択中のフィルタでフィルタ処理を実行
    filteredImage = [filter filterImage:inImage];
  } else {
    filteredImage = CGImageRetain(inImage);
  }
  // CGImageをUIImageに変換
  UIImage *displayImage = [UIImage imageWithCGImage:filteredImage];
  CGImageRelease(filteredImage);
  CGImageRelease(inImage);
  
  if ([activityIndicatorView isAnimating]) { // (1)
    // 処理中の表示を非表示に
    [activityIndicatorView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:TRUE];
  }
  // 画像を画面に表示
  [imageView performSelectorOnMainThread:@selector(setImage:) withObject:displayImage waitUntilDone:TRUE];// (2)
}


// フィルタ選択画面を表示
- (IBAction)showConfigAction:(id)sender {
  // フィルタ選択画面のViewControllerを作成
  SettingViewController *settingViewController = [[SettingViewController alloc]initWithStyle:UITableViewStylePlain];
  // ナビゲーションコントローラに追加して表示
  [self.navigationController pushViewController:settingViewController animated:TRUE];
  [settingViewController release];
}

// フィルタ処理に使用するフィルタを設定
- (void)setFilter:(ImageFilterBase *)aFilter {
  if (filter != nil) {
    [filter release];
  }
  filter = [aFilter retain];
  // スライダーで設定可能な範囲と値を設定
  [slider setMinimumValue:[filter.minValue floatValue]];
  [slider setMaximumValue:[filter.maxValue floatValue]];
  [slider setValue:[filter.currentValue floatValue]];
}

// スライダーの値が変更されたときに呼び出されるメソッド。
- (void)sliderValueChangedAction:(id)sender {
  // フィルタの設定値を変更。
  [filter setCurrentValue:[NSNumber numberWithFloat:slider.value]];
}

// 撮影画面に表示されている画像をアルバムに保存
- (IBAction)takePhotoAction:(id)sender {
  // iPhoneのアルバムに保存
  UIImageWriteToSavedPhotosAlbum(imageView.image,self,nil,nil);
}

@end
