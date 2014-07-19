//
//  LocationTag.m
//  ARLocalSearch
//
//  Created by 細谷 日出海 on 11/02/08.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "LocationTag.h"
#import <QuartzCore/QuartzCore.h>
#import "ARLocalSearchAppDelegate.h"


@implementation LocationTag

// 初期化メソッド。位置情報と距離からLocationTagインスタンスの初期化を行う
- (id)initWithARCoordinate:(ARCoordinate *)coordinate distance:(CLLocationDistance)distance {
  arCoordinate = coordinate;
  [arCoordinate retain];
  
  // 表示するフォントと文字列からタグの大きさを計算
  UIFont *font = [UIFont systemFontOfSize:12];
  CGSize size = [arCoordinate.title sizeWithFont:font];
  
  if (size.width > 140) {
    size.width = 140;
  } else if (size.width < 50) {
    size.width = 50;
  }
  // タイトルラベルを作成
  UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,size.width+4,size.height+4)];
  titleLabel.text = arCoordinate.title;
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.shadowColor = [UIColor blackColor];
  titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
  titleLabel.font = font;
  
  // 距離表示ラベルを作成
  UILabel *distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,titleLabel.frame.size.height,titleLabel.frame.size.width,14)];
  distanceLabel.font = font;
  distanceLabel.text = [NSString stringWithFormat:@"%d[m]",(int)distance];
  distanceLabel.textAlignment = UITextAlignmentRight;
  distanceLabel.backgroundColor = [UIColor clearColor];
  distanceLabel.textColor = [UIColor whiteColor];
  distanceLabel.shadowColor = [UIColor blackColor];
  
  if ((self = [super initWithFrame:CGRectMake(0,0,titleLabel.frame.size.width,titleLabel.frame.size.height+distanceLabel.frame.size.height)])) {
    [self addSubview:titleLabel];
    [self addSubview:distanceLabel];
    [titleLabel release];
    [distanceLabel release];
    // 背景を半透明にする
    self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9];
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius  = 2;
  }
  return self;
}

- (void)dealloc {
  [arCoordinate release];
  [super dealloc];
}

// ユーザがタッチを終了したときに呼び出されるメソッド
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  ARLocalSearchAppDelegate *appDelegate = (ARLocalSearchAppDelegate *)[[UIApplication sharedApplication] delegate];
  // タグをタッチしたときに該当するWEBページを表示
  [appDelegate showDetail:arCoordinate.title url:arCoordinate.subtitle];
}

@end
