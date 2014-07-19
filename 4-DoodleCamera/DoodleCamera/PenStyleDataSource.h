//
//  PenStyleDataSource.h
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>
#import "DrawView.h"


// ペンの太さの選択肢を格納し、ペンの太さの選択結果を落書き画面に反映するクラスの定義
// UIPickerViewDataSource,UIPickerViewDelegateプロトコルのメソッドを実装
@interface PenStyleDataSource : NSObject<UIPickerViewDataSource, UIPickerViewDelegate> {
  // 選択肢を格納する配列
  NSArray *styles;
  // 選択結果を反映する落書き画面
  DrawView *drawView;
}

// 初期化メソッド。選択結果を反映するDrawViewを指定してインスタンスの初期化を行う
-(id)initWithDrawView:(DrawView*)drawView;

// 選択肢の線の色を設定するメソッド
-(void)setPenColor:(CGColorRef)color;
@end
