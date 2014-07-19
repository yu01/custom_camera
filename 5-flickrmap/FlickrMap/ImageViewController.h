//
//  ImageViewController.h
//  FlickrMap
//
//  Created by 細谷 日出海 on 11/02/05.
//  Copyright(c) 2011 SOFTBANK Creative Corp., Hidemi Hosoya
//

#import <UIKit/UIKit.h>


// 画像を表示するViewに対応するUIViewControllerクラスの継承クラスの定義
@interface ImageViewController : UIViewController {

}

// 画像を表示するView
@property (nonatomic,retain) IBOutlet UIImageView *imageView;
// 画像
@property (nonatomic,retain) UIImage *image;

@end
