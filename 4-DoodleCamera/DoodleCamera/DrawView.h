//
//  DrawView.h
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>


// 落書きを描画、表示するViewクラスの定義
@interface DrawView : UIView {
  // 描画中の落書きのパス
  CGMutablePathRef currentPath; // (1)
  // 描画中の落書きを表示するレイヤー
  CALayer *drawLayer; // (2)
  
  // 描画済みの落書きを表示するレイヤー
  CALayer *backgroundLayer; // (3)
  
  // 描画済みの落書きが描かれているビットマップデータを保持しているCGBitmapContextオブジェクト
  CGContextRef bitmapContext; // (4)
  
  // 落書きの線の太さ
  CGFloat penWidth;
  // 落書きの線の色
  CGColorRef penColor;
  
}

// 落書きの線の色を設定するメソッド
- (void)setPenColor:(CGColorRef)color;
// 落書きの線の色を取得するメソッド
- (CGColorRef)penColor;
// 落書きの線の太さを設定するメソッド
- (void)setPenWidth:(CGFloat)width;

// 描画されている落書きをすべて消去するメソッド。落書きを消去して画面を初期状態に戻す
- (void)clearDrawing;
// 描画されている落書きからCGImageオブジェクトを取得するメソッド
- (CGImageRef)cgImage;

@end
