//
//  BookInfo.h
//  BookScan
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>


// 書籍の詳細情報を格納するクラスの定義
@interface BookInfo : NSObject {

}

// 画像URL
@property (nonatomic,retain) NSString *imageURL;
// 書籍のAmazonでのURL
@property (nonatomic,retain) NSString *detailPageURL;
// 著者名
@property (nonatomic,retain) NSString *author;
// 著者名
@property (nonatomic,retain) NSString *manufacturer;
// タイトル
@property (nonatomic,retain) NSString *title;
// 出版日
@property (nonatomic,retain) NSString *publicationDate;
@end
