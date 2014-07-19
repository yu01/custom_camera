//
//  FlickrAPI.m
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "FlickrAPI.h"
// MD5を使用するためのヘッダー
#import <CommonCrypto/CommonDigest.h>
#import "JSON.h"

// リクエスト種別と受信データを格納する機能を拡張したNSURLConnectionの派生クラスの定義。FlickrAPIクラスで行うHTTP通信を実行する
@interface FlickrAPIURLConnection : NSURLConnection {
  // リクエスト種別
  NSString *requestType;
  //受信データ
  NSMutableData *receivedData;
}

@property (nonatomic,retain) NSString* requestType;
@property (nonatomic,retain) NSMutableData* receivedData;

@end

// リクエスト種別と受信データを格納する機能を拡張したNSURLConnectionの派生クラスの実装
@implementation FlickrAPIURLConnection
@synthesize requestType;
@synthesize receivedData;

- (void)dealloc {
  [receivedData release];
  [requestType release];
  [super dealloc];
}
@end


// FlickrのAPIを呼び出し、実行するクラスの実装
@implementation FlickrAPI
@synthesize tokenData;
@synthesize frob;
@synthesize delegate;

- (void)dealloc {
  [tokenData release];
  [frob release];
  [super dealloc];
}

// Flickr API仕様のリクエストパラメータを文字列を作成するクラスメソッド。アルファベット順にパラメータを並べかえてクエリー文字列のパラメータを作成する
+ (NSString*)createParams:(NSDictionary*)params {
  // キー文字列の配列を取得
  NSArray *allKeys = [params allKeys];
  // キー文字列をアルファベット順にソート
  [allKeys sortedArrayUsingComparator:^(id obj1, id obj2){
    return [obj1 compare:obj2];
  }];
  // キーと値を取得しクエリー文字列を作成
  NSMutableString *concatString = [[NSMutableString alloc]init];
  for (NSString *key in [params allKeys]) {
    if ([concatString length]!=0) {
      [concatString appendString:@"&"];
    }
    [concatString appendFormat:@"%@=%@",key,[params objectForKey:key]];
  }
  return [concatString autorelease];
}

// Flickr API仕様の署名文字列を作成するクラスメソッド。
+ (NSString*)createAPISig:(NSDictionary*)params {
  // キー文字列の配列を取得
  NSArray *allKeys = [params allKeys];
  // キー文字列をアルファベット順にソート
  allKeys = [allKeys sortedArrayUsingComparator:^(id obj1, id obj2){
    return [obj1 compare:obj2];
  }];
  // API Secretとキーと値を結合した文字列を作成
  NSMutableString *concatString = [NSMutableString stringWithFormat:@"%@",API_SECRET];
  for (NSString *key in allKeys) {
    [concatString appendFormat:@"%@%@",key,[params objectForKey:key]];
  }
  // MD5文字列にする
  const char *test_cstr = [concatString UTF8String];
  unsigned char md5_result[CC_MD5_DIGEST_LENGTH];
  
  CC_MD5(test_cstr, strlen(test_cstr), md5_result);
  // 16進表記で文字列を作成
  NSMutableString *result = [NSMutableString string];
  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [result appendFormat:@"%02X", md5_result[i]];
  }
  return [result lowercaseString];  
}

// シングルトンインスタンスを取得するメソッド
+ (FlickrAPI*)instance {
  static id singleton = nil;
  @synchronized(self) {
    if (!singleton) {
      singleton = [[self alloc] init];
    }
  }
  return singleton;
}

// Flickrからfrobを取得するメソッド
- (void)requestFrob {
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:@"flickr.auth.getFrob" forKey:@"method"];
  [params setObject:API_KEY forKey:@"api_key"];
  [params setObject:@"json" forKey:@"format"];
  [params setObject:@"1" forKey:@"nojsoncallback"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  // リクエストパラメータ文字列を作成
  NSString *paramString = [FlickrAPI createParams:params];
  // リクエストURL文字列を作成
  NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/rest/?%@&api_sig=%@",paramString,apiSig];
  NSError *error = nil;
  // JSON文字列をFlickrから取得
  NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
  // JSONからfrob文字列を抽出
  NSDictionary *json = (NSDictionary*)[result JSONValue];
  NSDictionary *frobDict = [json objectForKey:@"frob"];
  if (frob != nil) {
    [frob release];
  }
  frob = [[frobDict objectForKey:@"_content"]retain];
}

// Flickrより認証トークンを取得するメソッド
- (void)requestAuthToken {
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:@"flickr.auth.getToken" forKey:@"method"];
  [params setObject:API_KEY forKey:@"api_key"];
  [params setObject:frob forKey:@"frob"];
  [params setObject:@"json" forKey:@"format"];
  [params setObject:@"1" forKey:@"nojsoncallback"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  // リクエストパラメータ文字列を作成
  NSString *paramString = [FlickrAPI createParams:params];
  NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/rest/?%@&api_sig=%@",paramString,apiSig];
  NSError *error = nil;
  // JSON文字列をFlickrから取得
  NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
  if (tokenData != nil) {
    [tokenData release];
    tokenData = nil;
  }
  // JSONからtoken文字列を抽出
  NSDictionary *resultTokenData = [result JSONValue];
  if ([[[resultTokenData objectForKey:@"auth"]objectForKey:@"token"]objectForKey:@"_content"]==nil) {
    return;
  }
  // 認証トークンを保管
  tokenData = [(NSDictionary*)[result JSONValue]retain];
}

// 取得済みの認証トークン文字列を取得するメソッド
- (NSString*)authToken {
  return [[[tokenData objectForKey:@"auth"]objectForKey:@"token"]objectForKey:@"_content"];
}

// Flickrサーバに写真をアップロードするメソッド
- (void)uploadPhoto:(UIImage*)photoImage {
  // 写真のタイトルは、日付を使用
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  NSString *title = [dateFormatter stringFromDate:[NSDate date]];  // (1)
  [dateFormatter release];
  
  // マルチパートでパラメータと画像データをPOSTデータを送信
  NSString *BOUNDARY = @"0xKhTmLbOuNdArY";
  NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/upload/"]];
  [req setHTTPMethod:@"POST"];
  [req setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY] forHTTPHeaderField:@"Content-Type"];
  
  // POST
  NSMutableData *postData = [[NSMutableData alloc] init];
  [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
  
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:API_KEY forKey:@"api_key"];
  [params setObject:[self authToken] forKey:@"auth_token"];
  [params setObject:frob forKey:@"frob"];
  [params setObject:title forKey:@"title"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  
  // パラメータをPOSTデータに追加
  for (NSString *key in [params allKeys]) { // (2)
    NSString *value = [params objectForKey:key];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key,value]dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  // API SIG
  // 署名文字列をPOSTデータに追加
  [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"api_sig\"\r\n\r\n%@", apiSig]dataUsingEncoding:NSUTF8StringEncoding]];
  [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
  
  // 画像データをPOSTデータに追加
  // PNGフォーマットで画像データを作成
  NSData *pngData = UIImagePNGRepresentation(photoImage);// (3)
  NSString *fileName = @"photoImage.png";
  [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", fileName] dataUsingEncoding:NSUTF8StringEncoding]];
  [postData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"image/png"] dataUsingEncoding:NSUTF8StringEncoding]];
  [postData appendData:pngData];
  [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", BOUNDARY]dataUsingEncoding:NSUTF8StringEncoding]];
  
  // リクエストにフォームデータを設定
  [req setHTTPBody:postData];
  [postData release];
  
  // 写真をアップロード
  FlickrAPIURLConnection *conn = [[FlickrAPIURLConnection alloc]initWithRequest:req delegate:self startImmediately:FALSE]; // (4)
  conn.requestType = @"uploadPhoto";
  [conn start];
}

// 指定の写真の位置情報の設定を行うメソッド
- (void)setGeoTag:(NSString*)photoId lat:(double)lat lon:(double)lon {
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:@"flickr.photos.geo.setLocation" forKey:@"method"];
  [params setObject:API_KEY forKey:@"api_key"];
  [params setObject:frob forKey:@"frob"];
  [params setObject:[self authToken] forKey:@"auth_token"];
  [params setObject:photoId forKey:@"photo_id"];
  [params setObject:[NSNumber numberWithDouble:lat] forKey:@"lat"];
  [params setObject:[NSNumber numberWithDouble:lon] forKey:@"lon"];
  [params setObject:@"json" forKey:@"format"];
  [params setObject:@"1" forKey:@"nojsoncallback"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  // リクエストパラメータ文字列を作成
  NSString *paramString = [FlickrAPI createParams:params];
  // リクエストURL文字列を作成
  NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/rest/?%@&api_sig=%@",paramString,apiSig];
  NSError *error = nil;
  // Flickrにリクエストを送信
  NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
}

// 地図座標の範囲内の自分が登録した写真の検索を行うメソッド。検索範囲を左下の緯度経度座標と右上の緯度経度座標を引数で指定し、検索結果をデリゲートメソッドで取得する
- (void)searchPhotos:(CLLocationCoordinate2D)leftBottom rightTop:(CLLocationCoordinate2D)rightTop {
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:@"flickr.photos.search" forKey:@"method"];
  [params setObject:API_KEY forKey:@"api_key"];
  [params setObject:@"me" forKey:@"user_id"];
  [params setObject:frob forKey:@"frob"];
  [params setObject:[self authToken] forKey:@"auth_token"];
  [params setObject:@"owner_name,geo" forKey:@"extras"];
  [params setObject:@"json" forKey:@"format"];
  [params setObject:@"1" forKey:@"nojsoncallback"];
  [params setObject:[NSString stringWithFormat:@"%f,%f,%f,%f",leftBottom.longitude,leftBottom.latitude,rightTop.longitude,rightTop.latitude] forKey:@"bbox"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  // リクエストパラメータ文字列を作成
  NSString *paramString = [FlickrAPI createParams:params];
  // リクエストURL文字列を作成
  NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/rest/?%@&api_sig=%@",paramString,apiSig];
  // リクエスト種別を指定して検索のリクエストを実行
  FlickrAPIURLConnection *conn = [[FlickrAPIURLConnection alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] delegate:self startImmediately:FALSE];
  conn.requestType = @"searchPhotos";
  [conn start];
}

// NSURLConnectionインスタンスがデータを受信したときに呼び出されるメソッド
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
  // FlickrAPIURLConnectionに受信データを追加
  FlickrAPIURLConnection *connection = (FlickrAPIURLConnection*)aConnection;
  if (connection.receivedData == nil) {
    connection.receivedData = [NSMutableData data];
  }
  [connection.receivedData appendData:data];
}

// NSURLConnectionインスタンスがデータの送信したときに呼び出されるメソッド
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  // 画像のアップロードの進捗を通知する
  [delegate uploadInProgress:totalBytesWritten totalBytesExpectedToWrite:(int)totalBytesExpectedToWrite];
}

// NSURLConnectionインスタンスがデータの通信が完了したときに呼び出されるメソッド
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
  FlickrAPIURLConnection *connection = (FlickrAPIURLConnection*)aConnection;
  if (connection.receivedData == nil) {
    NSLog(@"Fail to request");
    return;
  }
  // リクエスト種別によって処理を分ける
  if ([connection.requestType isEqualToString:@"searchPhotos"]) {
    // 写真の検索結果はJSON文字列
    NSString *resultString = [[NSString alloc]initWithData:connection.receivedData encoding:NSUTF8StringEncoding];
    // JSON文字列をパースしてNSDictionaryとして取得
    NSDictionary *result = [resultString JSONValue];
    [resultString release];
    // 検索結果を通知
    [delegate photoSearchFinished:(NSArray*)[[result objectForKey:@"photos"]objectForKey:@"photo"]];
  } else if ([connection.requestType isEqualToString:@"uploadPhoto"]) {
    // アップロードの検索結果はXML文字列
    NSString *resultString = [[NSString alloc]initWithData:connection.receivedData encoding:NSUTF8StringEncoding];
    // photoIdタグの中の文字列を抽出
    NSRange startRange = [resultString rangeOfString:@"<photoid>"];
    NSRange endRange = [resultString rangeOfString:@"</photoid>"];
    NSRange photoIdRange;
    photoIdRange.location = startRange.location+startRange.length;
    photoIdRange.length = endRange.location-photoIdRange.location;
    NSString *photoId = [resultString substringWithRange:photoIdRange];
    [resultString release];
    // アップロード完了を通知
    [delegate uploadFinished:photoId];
  }
}

// アプリケーション認証用WEBページのURLの取得を行うメソッド
- (NSURL*)authURL {
  // パラメータを設定
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:API_KEY forKey:@"api_key"];
  // 書き込み権限を設定
  [params setObject:@"write" forKey:@"perms"];
  [params setObject:frob forKey:@"frob"];
  // 署名文字列を作成
  NSString *apiSig = [FlickrAPI createAPISig:params];
  // リクエストパラメータ文字列を作成
  NSString *paramString = [FlickrAPI createParams:params];
  // リクエストURL文字列を作成
  NSString *urlString = [NSString stringWithFormat:@"http://flickr.com/services/auth/?%@&api_sig=%@",paramString,apiSig];
  return [NSURL URLWithString:urlString];
}

@end
