//
//  BookInfoParser.h
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>


@class BookInfo;

// 検索結果のXMLフォーマットのデータをパースするクラスの定義
@interface BookInfoParser : NSObject<NSXMLParserDelegate> {
  // パース結果
  BookInfo *bookInfo;
  // LargeImage要素判定で使用
  BOOL isLargeImageElement;
  // ItemAttributes要素判定で使用
  BOOL isItemAttributesElement;
  // 要素内の文字列を格納
  NSMutableString *currentString;
}

// 初期化メソッド。引数のNSDataに格納されているXMLをパースする
- (id)initWithData:(NSData*)data;

// パース結果の書籍詳細情報
- (BookInfo*)bookInfo;
@end
