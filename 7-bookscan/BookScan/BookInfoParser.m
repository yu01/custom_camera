//
//  BookInfoParser.m
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BookInfoParser.h"

#import "BookInfoParser.h"
#import "BookInfo.h"

// 検索結果のXMLフォーマットのデータをパースするクラスの実装
@implementation BookInfoParser

// 初期化メソッド。引数のNSDataに格納されているXMLをパースする
- (id)initWithData:(NSData*)data {
  if (self = [super init]) {
    NSLog(@"%@",[NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding]);
    // XMLをパースするインスタンス
    NSXMLParser *xmlParser = [[NSXMLParser alloc]initWithData:data];
    // パースの処理をデリゲート
    xmlParser.delegate = self;
    // パースを実行
    [xmlParser parse];
    [xmlParser release];
  }
  return self;
}

- (void)dealloc {
  [currentString release];
  [bookInfo release];
  [super dealloc];
}

// NSXMLParserDelegateプロトコルで定義されているメソッド。パース処理時にXMLの要素が開始したときに呼び出される
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"Item"]) {
    // パース結果を格納するインスタンス
    bookInfo = [[BookInfo alloc]init];
  } else if ([elementName isEqualToString:@"LargeImage"]) {
    isLargeImageElement = TRUE;
  } else if ([elementName isEqualToString:@"ItemAttributes"]) {
    isItemAttributesElement = TRUE;
  }
  if (currentString != nil) {
    [currentString release];
  }
  // 要素内の文字列を格納用に初期化
  currentString = [[NSMutableString alloc]init];
}

// NSXMLParserDelegateプロトコルで定義されているメソッド。パース処理時にXMLの要素が終了したときに呼び出される
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"DetailPageURL"]) {
    // 書籍のAmazonでのURL
    bookInfo.detailPageURL = currentString;
  } else if ([elementName isEqualToString:@"LargeImage"]) {
    // 書籍の画像URLの要素を判定
    isLargeImageElement = FALSE;
  } else if ([elementName isEqualToString:@"URL"]) {
    if (isLargeImageElement) {
      // 書籍の画像URL
      bookInfo.imageURL = currentString;
    }
  } else if ([elementName isEqualToString:@"ItemAttributes"]) {
    // 書籍の属性情報要素を判定
    isItemAttributesElement = FALSE;
  } else if ([elementName isEqualToString:@"Author"]) {
    if (isItemAttributesElement) {
      // 著者
      bookInfo.author = currentString;
    }
  } else if ([elementName isEqualToString:@"Manufacturer"]) {
    if (isItemAttributesElement) {
      // 出版社
      bookInfo.manufacturer = currentString;
    }
  } else if ([elementName isEqualToString:@"Title"]) {
    if (isItemAttributesElement) {
      // タイトル
      bookInfo.title = currentString;
    }
  } else if ([elementName isEqualToString:@"PublicationDate"]) {
    if (isItemAttributesElement) {
      // 出版日
      bookInfo.publicationDate = currentString;
    }
  }
  [currentString release];currentString = nil;
}

// NSXMLParserDelegateプロトコルで定義されているメソッド。要素内で文字列を検出したときに呼び出される
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  [currentString appendString:string];
}

// パース結果の書籍詳細情報
- (BookInfo*)bookInfo {
  return [[bookInfo retain]autorelease];
}

@end
