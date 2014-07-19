//
//  CGUtil.h
//  DoodleCamera
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <Foundation/Foundation.h>


// CoreGraphics関連のユーティリティクラス。インスタンスを作成せずにクラスメソッドとしてメソッドを実装
@interface CGUtil : NSObject {
    
}

// 何も描画されていない状態のCGBitmapContextオブジェクトを作成するメソッド。引数sizeの構造体CGSizeの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef)newBlankBitmapContext:(CGSize)size;
// CGImageからCGBitmapContextオブジェクトを作成するメソッド。引数inImageのCGImageオブジェクトが描画された状態でCGImageの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef)newBitmapContextFromCGImage:(CGImageRef)inImage;
// 背景色が透過色ののCGBitmapContextオブジェクトを作成するメソッド。引数sizeの構造体CGSizeの大きさのCGBitmapContextオブジェクトを作成
+(CGContextRef)newTransparentBitmapContext:(CGSize)size;
// 画像を90度回転させたCGImageオブジェクトを作成するメソッド
+(CGImageRef)rotateImage:(CGImageRef)image mirrored:(BOOL)mirrored;


@end
