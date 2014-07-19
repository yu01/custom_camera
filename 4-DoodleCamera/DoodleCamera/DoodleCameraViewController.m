//
//  DoodleCameraViewController.m
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "DoodleCameraViewController.h"
#import "CGUtil.h"

// 実装時にのみ使用するメソッドの定義
@interface DoodleCameraViewController(Private)
// 引数の向きに対応するAVCatpureDeviceインスタンスを取得するメソッド
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position;
// 引数のメディア種別に対応するAVCaptureConnectionインスタンスを取得するメソッド
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
@end

// 落書き画面と撮影中の画像を表示するViewに対応するUIViewControllerクラスの継承クラスの実装
@implementation DoodleCameraViewController
@synthesize previewView;

- (void)dealloc {
  [penStyleDataSource release];
  [stillImageOutput release];
  [previewView release];
  [super dealloc];
}

// 引数の向きに対応するAVCatpureDeviceインスタンスを取得するメソッド
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      return device;
    }
  }
  return nil;
}

// 引数のメディア種別に対応するAVCaptureConnectionインスタンスを取得するメソッド
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections {
  for ( AVCaptureConnection *connection in connections ) {
    for ( AVCaptureInputPort *port in [connection inputPorts] ) {
      if ( [[port mediaType] isEqual:mediaType] ) {
        return [[connection retain] autorelease];
      }
    }
  }
  return nil;
}

// xibファイルからViewの読込が完了した時に呼び出されるメソッド
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 正面に配置されているカメラを取得
  AVCaptureDevice *camera = [self cameraWithPosition:AVCaptureDevicePositionFront];
  if (camera == nil) {
    // 無い場合は、裏面に配置されているカメラを取得
    camera = [self cameraWithPosition:AVCaptureDevicePositionBack];
    frontCamera = FALSE;
  } else {
    frontCamera = TRUE;
  }
  // カメラからの入力を作成
  NSError *error = nil;
  AVCaptureDeviceInput *videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error] autorelease];
  
  // 画像への出力を作成
  stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  
  // 入力と出力からキャプチャーセッションを作成
  AVCaptureSession *session = [[AVCaptureSession alloc] init];
  [session addInput:videoInput];
  [session addOutput:stillImageOutput];
  
  // キャプチャーセッションから入力のプレビュー表示を作成
  AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
  [captureVideoPreviewLayer setFrame:CGRectMake(0,0,previewView.frame.size.width,previewView.frame.size.height)];
  [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  // レイヤーをViewに設定
  CALayer *viewLayer = previewView.layer;
  [viewLayer setMasksToBounds:YES];
  [viewLayer addSublayer:captureVideoPreviewLayer];
  [captureVideoPreviewLayer release];
  
  // 落書き画面を作成
  drawView = [[DrawView alloc]initWithFrame:CGRectMake(0,0,CGRectGetWidth(previewView.frame),CGRectGetHeight(previewView.frame))];
  [previewView addSubview:drawView];
  
  // ペンの色選択肢を作成
  penColorDataSource = [[PenColorDataSource alloc]initWithDrawView:drawView];
  // ペンの太さ選択肢を作成
  penStyleDataSource = [[PenStyleDataSource alloc]initWithDrawView:drawView];
  
  // セッションを開始
  [session startRunning];
  [session release];
}

// ペンの色選択肢を表示
-(IBAction)chooseColorAction:(id)sender {
  if (colorChooseView == nil) {
    // 選択肢のViewを作成
    colorChooseView = [[UIView alloc]initWithFrame:CGRectMake(0,240,320, 240)];
    colorChooseView.backgroundColor = [UIColor whiteColor];
    // UIPickerViewを作成
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0,40,320,200)];
    pickerView.showsSelectionIndicator = TRUE;
    // DataSourceは、PenColorDataSourceのインスタンス
    pickerView.dataSource = penColorDataSource;
    // Delegateは、PenColorDataSourceのインスタンス
    pickerView.delegate = penColorDataSource;  
    [colorChooseView addSubview:pickerView];
    [pickerView release];
    // 選択肢のViewの上部にツールバーを配置し、閉じるボタンを配置
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"閉じる" style:UIBarButtonItemStyleBordered target:self action:@selector(disappearColorChooseView:)];
    // 余白表示用のボタン
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // 閉じるボタンはツールバーの右端に配置する
    [toolBar setItems:[NSArray arrayWithObjects:flex,closeButton,nil]];
    [closeButton release];
    [flex release];
    [colorChooseView addSubview:toolBar];
    [toolBar release];
  }
  [self.view addSubview:colorChooseView];
  [self.view bringSubviewToFront:colorChooseView];
}

// 閉じるボタンを押したときに呼び出されるメソッド
- (void)disappearColorChooseView:(id)sender {
  // Viewを画面から削除
  [colorChooseView removeFromSuperview];
}

// ペンの太さ選択肢を表示
-(IBAction)choosePenStyleAction:(id)sender {
  if (styleChooseView == nil) {
    // 選択肢のViewを作成
    styleChooseView = [[UIView alloc]initWithFrame:CGRectMake(0,240,320, 240)];
    styleChooseView.backgroundColor = [UIColor whiteColor];
    // UIPickerViewを作成
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0,40,320,200)];
    pickerView.showsSelectionIndicator = TRUE;
    // DataSourceは、PenStyleDataSourceのインスタンス
    pickerView.dataSource = penStyleDataSource;
    // Delegateは、PenStyleDataSourceのインスタンス
    pickerView.delegate = penStyleDataSource;  
    [styleChooseView addSubview:pickerView];
    [pickerView release];
    // 選択肢のViewの上部にツールバーを配置し、閉じるボタンを配置
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"閉じる" style:UIBarButtonItemStyleBordered target:self action:@selector(disappearStyleChooseView:)];
    // 余白表示用のボタン
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    // 閉じるボタンはツールバーの右端に配置する
    [toolBar setItems:[NSArray arrayWithObjects:flex,closeButton,nil]];
    [closeButton release];
    [flex release];
    [styleChooseView addSubview:toolBar];
    [toolBar release];
  }
  [penStyleDataSource setPenColor:[drawView penColor]];
  [self.view addSubview:styleChooseView];
  [self.view bringSubviewToFront:styleChooseView];
}

// 閉じるボタンを押したときに呼び出されるメソッド
- (void)disappearStyleChooseView:(id)sender {
  [styleChooseView removeFromSuperview];
}

// 落書き画面と撮影画面を合成して保存
-(IBAction)takePhotoAction:(id)sender {
  // ビデオ入力のAVCaptureConnectionを取得
  AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[stillImageOutput connections]];
  // ビデオ入力から画像を非同期で取得。ブロックで定義されている処理が呼び出され、画像データが引数から取得する
  [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                  if (imageDataSampleBuffer != NULL) {
                                                    // 入力された画像データからJPEGフォーマットとしてデータを取得
                                                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                    // JPEGデータからUIImageを作成
                                                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                    // 落書き画像とビデオ入力の画像を重ね合わせする
                                                    // ビデオ入力は横向きなので、90度回転
                                                    CGImageRef cgImage = [CGUtil rotateImage:[image CGImage] mirrored:frontCamera];
                                                    // CGBitmapContextを作成
                                                    CGContextRef context = [CGUtil newBitmapContextFromCGImage:cgImage];
                                                    // 落書き画像をビデオ入力から作成した画像の上に描画
                                                    CGContextDrawImage(context, CGRectMake(0,0,CGImageGetWidth(cgImage),CGImageGetHeight(cgImage)), drawView.cgImage);
                                                    CGImageRef drawedImage = CGBitmapContextCreateImage(context);
                                                    CGContextRelease(context);
                                                    // 合成された画像からUIImageを作成
                                                    UIImage *newImage = [UIImage imageWithCGImage:drawedImage];
                                                    CGImageRelease(drawedImage);
                                                    // iPhoneのアルバムに画像を保存
                                                    UIImageWriteToSavedPhotosAlbum(newImage,self,nil,nil);
                                                    [image release];
                                                  }
                                                }];
}

// 落書きを消去
-(IBAction)clearAction:(id)sender {
  [drawView clearDrawing];
  [drawView setNeedsDisplay];
}

@end
