//
//  PenStyleDataSource.m
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "PenStyleDataSource.h"

// 選択肢の行の幅
#define ROW_WIDTH 220
// 選択肢の行の高さ
#define ROW_HEIGHT 44

// ペンの太さを指定して横線を表示するViewクラスの定義。線の色、太さを指定して横線を表示する
@interface PenStyleView : UIView {
  // 線の太さ
  CGFloat penWidth;
  // 線の色
  CGColorRef penColor;
}
@property (nonatomic,assign) CGFloat penWidth;
@end

// ペンの太さを指定して横線を表示するViewクラスの実装
@implementation PenStyleView

@synthesize penWidth;

// 初期化メソッド。線の太さを指定してインスタンスの初期化を行う
- (id)initWithWidth:(CGFloat)aPenWidth {
  // 行の幅、高さを指定してUIViewの初期化メソッドで初期化
  if (self = [super initWithFrame:CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT)]) {
    // 線の太さ
    penWidth = aPenWidth;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // 背景は透過
    self.backgroundColor = [UIColor clearColor];
    // 初期状態で線の色は、赤色
    penColor = (CGColorRef)[(id)[[UIColor redColor]CGColor]retain];
  }
  return self;
}

- (void)dealloc {
  CGColorRelease(penColor);
  [super dealloc];
}

// 選択肢の線の色を設定するメソッド
- (void)setPenColor:(CGColorRef)color {
  if (penColor != nil) {
    CGColorRelease(penColor);
  }
  penColor = CGColorRetain(color);
  [self setNeedsDisplay];
}

// UIViewクラスの描画を行うメソッド。横線を描画する。
- (void)drawRect:(CGRect)rect {
  // 描画対象のCGContextを取得
  CGContextRef context = UIGraphicsGetCurrentContext();
  // 横線のパスを作成
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path,NULL,20,ROW_HEIGHT/2);
  CGPathAddLineToPoint(path,NULL,ROW_WIDTH-20,ROW_HEIGHT/2);
  
  // 線の太さを設定
  CGContextSetLineWidth(context,penWidth);
  // 両端と角は丸くする
  CGContextSetLineCap(context,kCGLineCapRound);
  CGContextSetLineJoin(context, kCGLineJoinRound);
  // 線の色を設定
  CGContextSetStrokeColorWithColor(context,penColor);
  // 現在描画中のパスを追加
  CGContextAddPath(context,path);
  // 線を描画
  CGContextStrokePath(context);

  CGPathRelease(path);
}
@end

// ペンの太さの選択肢を格納し、ペンの太さの選択結果を落書き画面に反映するクラスの実装
@implementation PenStyleDataSource
// 初期化メソッド。選択結果を反映するDrawViewを指定してインスタンスの初期化を行う。
-(id)initWithDrawView:(DrawView*)aDrawView {
  if (self = [super init]) {
    // 引数のDrawViewインスタンスをメンバー変数に格納
    drawView = [aDrawView retain];
    // 選択肢を格納する配列を作成
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];    
    // 線の太さの選択肢は、4ピクセルから36ピクセルまで、8ピクセルの差で作成。
    for (int i = 4; i <= 36; i+=8) {
      // 選択肢の太さで描画された横線の行を表示するViewを作成
      PenStyleView *penStyleView = [[PenStyleView alloc]initWithWidth:i];
      [penStyleView setNeedsDisplay];
      [viewArray addObject:penStyleView];
      [penStyleView release];
    }
    
    styles = [viewArray retain];
    [viewArray release];
  }
  return self;
}

- (void)dealloc {
  [drawView release];
  [styles release];
  [super dealloc];
}

// 選択肢の線の色を設定するメソッド
- (void)setPenColor:(CGColorRef)color {
  for (PenStyleView *penStyleView in styles) {
    [penStyleView setPenColor:color];
  }
}

// UIPickerViewDelegateプロトコルで定義されているメソッド。選択肢の行の幅を返す
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  return ROW_WIDTH;
}

// UIPickerViewDelegateプロトコルで定義されているメソッド。選択肢の行の高さを返す
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return ROW_HEIGHT;
}

// UIPickerViewDataSourceプロトコルで定義されているメソッド。選択肢の行の総数を返す
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return [styles count];
}

// UIPickerViewDataSourceプロトコルで定義されているメソッド。選択肢の項目数を返す
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// UIPickerViewDataSourceプロトコルで定義されているメソッド。選択肢の内容を表示するViewを返す
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
  return [styles objectAtIndex:row];
}

// UIPickerViewDelegateプロトコルで定義されているメソッド。選択肢がユーザにより選択された時に呼び出される
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  [drawView setPenWidth:((PenStyleView*)[styles objectAtIndex:row]).penWidth];
}

@end
