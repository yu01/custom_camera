//
//  BookInfo.m
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "BookInfo.h"


// 書籍の詳細情報を格納するクラスの実装
@implementation BookInfo
@synthesize imageURL;
@synthesize detailPageURL;
@synthesize author;
@synthesize manufacturer;
@synthesize title;
@synthesize publicationDate;

- (void)dealloc {
  [imageURL release];
  [detailPageURL release];
  [author release];
  [manufacturer release];
  [title release];
  [publicationDate release];
  [super dealloc];
}

@end
