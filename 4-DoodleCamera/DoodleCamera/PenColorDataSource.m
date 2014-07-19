//
//  PenColorDataSource.m
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import "PenColorDataSource.h"


// 選択肢の行の幅
#define ROW_WIDTH 220
// 選択肢の行の高さ
#define ROW_HEIGHT 44

// ペンの色の選択肢を格納し、ペンの色の選択結果を落書き画面に反映するクラスの実装
@implementation PenColorDataSource
// 初期化メソッド。選択結果を反映するDrawViewを指定してインスタンスの初期化を行う
-(id)initWithDrawView:(DrawView*)aDrawView {
  if (self = [super init]) {
    // 引数のDrawViewインスタンスをメンバー変数に格納
    drawView = [aDrawView retain];
    // 選択肢を格納する配列を作成
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    
    NSArray *colors = [NSArray arrayWithObjects:[UIColor redColor],
                       [UIColor blueColor],
                       [UIColor yellowColor],
                       [UIColor greenColor],
                       [UIColor brownColor],
                       [UIColor whiteColor],
                       [UIColor blackColor],nil];
    for (UIColor *color in colors) {
      // 選択肢の色で塗りつぶされた行を表示するViewを作成
      UIView *colorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ROW_WIDTH, ROW_HEIGHT)];
      colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      colorView.backgroundColor = color;
      [viewArray addObject:colorView];
      [colorView release];
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
  [drawView setPenColor:[[((UIView*)[styles objectAtIndex:row])backgroundColor]CGColor]];
}

@end
