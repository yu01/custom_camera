//
//  BookScanAppDelegate.m
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BookScanViewController.h"
#import <CommonCrypto/CommonHMAC.h>
#import "GTMStringEncoding.h"
#import "BookInfoParser.h"

// AWS Access Key ID
#define AMAZON_ACCESS_KEY_ID @"【AWS Access Key ID】"
// AWS Secret Access Key
#define AMAZON_SECRET_KEY @"【AWS Secret Access Key】"


#import "BookScanAppDelegate.h"

@implementation BookScanAppDelegate


@synthesize window=_window;

// UIApplicationDelegateプロトコルで定義されているメソッド。アプリケーションが起動したときに呼び出される
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // ステータスバーを非表示
  [UIApplication sharedApplication].statusBarHidden = TRUE;
  
  // バーコード撮影画面用ViewControllerを作成
  zbarReaderViewController = [[ZBarReaderViewController alloc]init];
  zbarReaderViewController.readerDelegate = self;
  zbarReaderViewController.showsZBarControls = FALSE;// (1)
  zbarReaderViewController.tracksSymbols = TRUE;// (2)
  zbarReaderViewController.title = @"BookScan";
  
  // バーコード撮影画面用をルートにして階層状にViewを表示するViewControllerを作成
  navigationController = [[UINavigationController alloc]initWithRootViewController:zbarReaderViewController];
  // ナビゲーションバーの色を半透明の黒
  [navigationController.navigationBar setBarStyle:UIBarStyleBlack];
  self.window.rootViewController = navigationController;
  [self.window makeKeyAndVisible];
  
  // 進捗表示用View
  activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  // 停止中は非表示
  activityIndicatorView.hidesWhenStopped = TRUE;
  activityIndicatorView.center = self.window.center;
  [self.window addSubview:activityIndicatorView];
  
  return YES;
}


- (void)dealloc
{
  [_window release];
  [zbarReaderViewController release];
  [navigationController release];
  [activityIndicatorView release];
  [downloadData release];
  [super dealloc];
}

// バーコード画像を検出した時に呼び出されるメソッド。引数のNSDictionaryから検出結果を取得する
- (void) imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info {
  // 検出結果を取得
  id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
	
  ZBarSymbol *result = nil;
  // 検出結果を探査
  for(ZBarSymbol *sym in results) {
    // ISBNのみを検出
    if (sym.type == ZBAR_EAN13 && ([[sym.data substringWithRange:NSMakeRange(0,3)]compare:@"978"]==NSOrderedSame || [[sym.data substringWithRange:NSMakeRange(0,3)]compare:@"979"]==NSOrderedSame)) { // (1)
      // ISBNは、978もしくは979から始まるEAN-13
      result = sym;
    }
  }
  if (result != nil) {
    // 書籍情報の検索を実行
    [self searchBookInfoByBarcode:result.data barcodeType:@"ISBN"];
  }
}

// 署名文字列を生成するメソッド。リクエストパラメータからAWSへの署名文字列を作成する
- (NSString*)makeSignature:(NSString*)requestString {
  unsigned char HMAC[CC_SHA256_DIGEST_LENGTH];
  const char *key = [AMAZON_SECRET_KEY cStringUsingEncoding:NSASCIIStringEncoding];
  const char *data = [requestString cStringUsingEncoding:NSASCIIStringEncoding];
  // 署名データを作成
  CCHmac(kCCHmacAlgSHA256, key, strlen(key), data, strlen(data), HMAC);
  NSData *hmacData = [[NSData alloc] initWithBytes:HMAC length:sizeof(HMAC)];
  // 署名データをBase64文字列に変換
  GTMStringEncoding *base64Encoder = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
  NSString *signature = [base64Encoder encode:hmacData];
  return signature;
}

// 書籍検索用URLを作成するメソッド。引数のバーコードとバーコード種別からAWSの書籍検索用のURLを作成する
- (NSURL*) createRequestURL:(NSString*)barcode barcodeType:(NSString*)barcodeType{
  NSString *host = @"webservices.amazon.co.jp";
  NSString *path = @"/onca/xml";
  NSString *operation = @"ItemLookup";
  NSString *responseGroup = @"Medium";
  NSString *searchIndex = @"Books";
  NSString *service = @"AWSECommerceService";
  NSString *version = @"2009-11-01";
  
  // パラメータに設定する日付文字列を作成
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
  NSString *timestamp = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[dateFormatter stringFromDate:[NSDate date]], NULL, CFSTR (";,/?:@&=+$#"), kCFStringEncodingUTF8);
  
  // 検索パラメータ文字列を作成
  NSMutableString *queryString = [NSMutableString stringWithFormat:@"AWSAccessKeyId=%@",AMAZON_ACCESS_KEY_ID];
  [queryString appendFormat:@"&IdType=%@",barcodeType];
  [queryString appendFormat:@"&ItemId=%@",barcode];
  [queryString appendFormat:@"&Operation=%@",operation];
  [queryString appendFormat:@"&ResponseGroup=%@",responseGroup];	
  [queryString appendFormat:@"&SearchIndex=%@",searchIndex];
  [queryString appendFormat:@"&Service=%@",service];	
  [queryString appendFormat:@"&Timestamp=%@",timestamp];
  [queryString appendFormat:@"&Version=%@",version];
  [timestamp release];
  
  // シークレットキーを使って署名文字列を作成
  NSString *requestString = [NSString stringWithFormat:@"GET\n%@\n%@\n%@",host,path,queryString];
  NSString *signature = [self makeSignature:requestString];
  
  // リクエストするURL文字列
  NSString *urlString = [NSString stringWithFormat:@"http://%@%@?%@&Signature=%@",host,path,queryString,signature];
  NSLog(@"%@",urlString);
  NSURL *requestURL = [NSURL URLWithString:urlString];
  
  return requestURL;
}

// バーコードから書籍の検索を実行するメソッド。Amazonに通信でバーコードに該当する書籍の情報を問い合わせを実行する
- (void) searchBookInfoByBarcode:(NSString*)barcode barcodeType:(NSString*)barcodeType{
  // 検索URLを作成
  NSURL *requestURL = [self createRequestURL:barcode barcodeType:barcodeType]; 
  
  // 通信中を表示
  [activityIndicatorView startAnimating];// (1)
  // 非同期でデータを取得
  [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:requestURL] delegate:self];
}

// NSURLConnectionインスタンスが通信結果を受信したときに呼び出されるメソッド
- (void) connection : (NSURLConnection *) connection didReceiveResponse : (NSURLResponse *) response {
  // 受信データを格納するNSDataを作成
  downloadData = [[NSMutableData alloc]init];
}

// NSURLConnectionインスタンスがデータを受信したときに呼び出されるメソッド
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  // 受信データを追加
  [downloadData appendData:data];
}

// NSURLConnectionインスタンスがデータの通信が完了したときに呼び出されるメソッド
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
  if (downloadData == nil) {
    return ;
  }
  
  // 受信データのXMLをパース
  BookInfoParser *bookInfoParser = [[BookInfoParser alloc]initWithData:downloadData];
  [downloadData release];
  downloadData = nil;
  
  // パースした結果の書籍の詳細情報を詳細画面に表示
  [self showBookInfo:bookInfoParser.bookInfo];  
  [bookInfoParser release];
  // 通信中を非表示
  [activityIndicatorView stopAnimating];// (2)
}

// 書籍の詳細情報から詳細画面を表示するメソッド
- (void)showBookInfo:(BookInfo*)bookInfo {
  // xibファイルからUIViewControllerを読込
  BookScanViewController *bookScanViewController = [[BookScanViewController alloc]initWithNibName:@"BookScanViewController" bundle:nil];
  // 書籍の詳細情報を設定
  bookScanViewController.bookInfo = bookInfo;
  // 詳細画面を表示
  [navigationController pushViewController:bookScanViewController animated:TRUE];
  [bookScanViewController release];
}


@end
