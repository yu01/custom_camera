//
//  DrawView.m
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <QuartzCore/QuartzCore.h>
#import "DrawView.h"
#import "CGUtil.h"

// 落書きを描画、表示するViewクラスの実装
@implementation DrawView
// 初期化メソッド
- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // 背景色を透過色に設定
    self.backgroundColor = [UIColor clearColor];
    // 落書きをビットマップに描画するための背景色が透過のCGBitmapContextオブジェクトを作成
    bitmapContext = [CGUtil newTransparentBitmapContext:CGSizeMake(CGRectGetWidth(frame),CGRectGetHeight(frame))];
    CGContextRetain(bitmapContext);
    // 初期状態では、何も描画されていない画像を作成
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    // 背景に表示するレイヤーを作成
    backgroundLayer = [CALayer layer];
    backgroundLayer.frame = CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame));
    // 背景に何も描画されていない画像を表示
    backgroundLayer.contents = (id)cgImage;
    CGImageRelease(cgImage);
    [backgroundLayer retain];
    
    // ドラッグによる落書きの描画を表示するためのレイヤーを作成
    drawLayer = [CALayer layer];
    drawLayer.frame = CGRectMake(0,0,CGRectGetWidth(frame),CGRectGetHeight(frame));
    [drawLayer retain];
    
    // 背景のレイヤーを裏側に描画の為のレイヤーを前面にして表示を設定
    [self.layer addSublayer:backgroundLayer];
    [self.layer addSublayer:drawLayer];
    
    // 初期状態での線の太さ
    penWidth = 4;
    // 初期状態の色を作成
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    // 赤色
    const CGFloat myColor[] = {1.0,0.0,0.0, 1.0};
    penColor = CGColorCreate(rgb, myColor);
    CGColorSpaceRelease(rgb);
  }
  return self;
}

- (void)dealloc {
  CGContextRelease(bitmapContext);
  [drawLayer release];
  [backgroundLayer release];
  [super dealloc];
}

// 落書きの線の色を取得するメソッド
- (CGColorRef)penColor {
  return (CGColorRef)[[(id)penColor retain]autorelease];
}

// 落書きの線の色を設定するメソッド
- (void)setPenColor:(CGColorRef)color {
  if (penColor != nil) {
    CGColorRelease(penColor);
  }
  penColor = CGColorRetain(color);
}
// 落書きの線の太さを設定するメソッド
- (void)setPenWidth:(CGFloat)width {
  penWidth = width;
}

// ユーザによりViewへのタッチが開始したときに呼び出されるメソッド
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  // ユーザがタッチした座標を取得
  CGPoint point = [((UITouch*)[touches anyObject])locationInView:self];
  // ユーザがドラッグした座標を格納する為のパスを作成
  currentPath = CGPathCreateMutable();
  // 始点の座標はタッチを開始した座標
  CGPathMoveToPoint(currentPath,NULL,point.x,point.y);
}

// ユーザがドラッグしたときに呼び出されるメソッド
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  // ユーザがドラッグした座標を取得
  CGPoint point = [((UITouch*)[touches anyObject])locationInView:self];
  // 座標をパスに追加
  CGPathAddLineToPoint(currentPath, nil,point.x,point.y);
  drawLayer.delegate = self;
  
  // レイヤーに対して再描画を要求
  [drawLayer setNeedsDisplay];
}

// 描画中のパスを描画するメソッド
- (void)drawCurrentPath:(CGContextRef)context {
  if (currentPath != nil) {
    // 描画色は、設定されている落書きの色
    CGContextSetStrokeColorWithColor(context,penColor);
    // パスの開始
    CGContextBeginPath(context);
    // 現在描画中のパスを追加
    CGContextAddPath(context,currentPath);
    
    // 線の太さは、設定されている落書きの線の色
    CGContextSetLineWidth(context,penWidth);
    // 両端と角は丸くする
    CGContextSetLineCap(context,kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    // 線を描画
    CGContextStrokePath(context);
  }
}

// CALayerインスタンスのデリゲートメソッド。レイヤーを描画するメソッドで、CGContextオブジェクトに対して描画を行うとレイヤーに描画が行われる
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
  // ドラッグによって描画中の落書きを描画
  [self drawCurrentPath:context];
}

// ユーザがタッチを終了したときに呼び出されるメソッド
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  // ユーザがドラッグを終了した座標を取得
  CGPoint point = [((UITouch*)[touches anyObject])locationInView:self];
  // 座標をパスに追加
  CGPathAddLineToPoint(currentPath, nil,point.x,point.y);
  
  // ビットマップデータにドラッグで描いた落書きを描画
  [self drawCurrentPath:bitmapContext];
  
  // ドラッグで描いた落書きのパスを解放
  CGPathRelease(currentPath);
  currentPath = nil;
  
  // ビットマップデータからCGImageオブジェクトを作成し背景に表示
  CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
  backgroundLayer.contents = (id)cgImage;
  CGImageRelease(cgImage);
}

// 描画されている落書きからCGImageオブジェクトを取得するメソッド
- (CGImageRef)cgImage {
  return (CGImageRef)backgroundLayer.contents;
}

// 描画されている落書きをすべて消去するメソッド。落書きを消去して画面を初期状態に戻す
- (void)clearDrawing {
  // ドラッグで描いた落書きのパスを解放
  CGPathRelease(currentPath);
  currentPath = nil;
  // ビットマップデータを解放
  CGContextRelease(bitmapContext);
  
  // 背景色が透明のビットマップデータを再作成
  bitmapContext = [CGUtil newTransparentBitmapContext:CGSizeMake(CGRectGetWidth(self.frame),CGRectGetHeight(self.frame))];
  CGContextRetain(bitmapContext);
  // 背景に表示する画像も再作成し差し替え
  CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
  backgroundLayer.contents = (id)cgImage;
  CGImageRelease(cgImage);
  
  // 落書き画面を再描画
  [drawLayer setNeedsDisplay];
}

@end
