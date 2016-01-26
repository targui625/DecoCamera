//
//  ImageViewController.m
//  DecoCamera
//
//  Created by Norimichi Takagi on 2016/01/18.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import "ImageViewController.h"
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>


@interface ImageViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *resizeImageView;
@property (weak, nonatomic) IBOutlet UIImage *lastImage;
@property (strong, nonatomic) IBOutlet UIImage *saveImage;
@property (weak, nonatomic) IBOutlet UIButton *grayButton;
@property (weak, nonatomic) IBOutlet UIView *saveArea;
@property (assign, nonatomic) BOOL isGray;
- (IBAction)saveButtonAction:(id)sender;
- (IBAction)grayButtonAction:(id)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)pinch:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation ImageViewController;

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pinch:(UIPinchGestureRecognizer *)sender {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    //NSLog(@"OK");
    _imageView.transform = CGAffineTransformMakeScale(factor,factor);
    //NSLog(@"%f",factor);
    //CGFloat resize = factor;
    //CGFloat x = _imageView.image.size.width;
    //CGFloat y = _imageView.image.size.height;
    //CGFloat xScale = 0.00001*factor*x;
    //CGFloat yScale = 0.00001*factor*y;
    //_imageView.transform = CGAffineTransformScale(_imageView.transform,resize,resize);
    // NSLog(@"%f",resize);
}


- (IBAction)lightSlider:(UISlider*)slider{
    // 輝度変更
    UIImage *inputImage = _editImage;
    CIImage *ciImage = [[CIImage alloc] initWithImage:inputImage];
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIColorControls"keysAndValues:kCIInputImageKey, ciImage,
                          @"inputBrightness",[NSNumber numberWithFloat:_slider.value],nil];
    CIImage* brightImage = [ciFilter outputImage];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef imgRef = [ciContext createCGImage:brightImage fromRect:[brightImage extent]];
    UIImage *resultImage = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:UIImageOrientationUp];
    CGImageRelease(imgRef);
    _lastImage = resultImage;
    // グレー維持
    if (self.isGray) {
        [self convertGray];
    }
    _imageView.image = _lastImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _lastImage = self.editImage;
    _imageView.image = _lastImage;
    _isGray = NO;
    [_slider addTarget:self action:@selector(lightSlider:) forControlEvents:UIControlEventValueChanged];
    _resizeImageView.transform = _imageView.transform;
    // スクロールビュー拡大縮小
    /*
    _scrollView.maximumZoomScale = 4.0;
    _scrollView.minimumZoomScale = 0.4;
    _scrollView.delegate = self;
    */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveButtonAction:(id)sender {
    // imageViewをsaveImageへ
    [self captureAction];
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    //画像を保存する
    UIImageWriteToSavedPhotosAlbum(_saveImage, self, selector, NULL);
    if(_saveImage == NULL){
        NSLog(@"ダメです");
    }
    else{NSLog(@"OK!!!!");
    }
}

-(void)captureAction{
 
    // 描画領域の設定
    NSLog(@"capture");
    UIGraphicsBeginImageContext(_saveArea.bounds.size);
    NSLog(@"cview1.bounds: %@", NSStringFromCGRect(_saveArea.bounds));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_saveArea.layer renderInContext:context];
    _saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    /*
    CGSize size = CGSizeMake(self.imageView.frame.size.width , self.imageView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    // グラフィックスコンテキスト取得
    CGContextRef context = UIGraphicsGetCurrentContext();
    // コンテキストの位置を切り取り開始位置に合わせる
    CGPoint point = self.imageView.frame.origin;
    CGAffineTransform affineMoveLeftTop = CGAffineTransformMakeTranslation(-(int)point.x ,-(int)point.y );
    CGContextConcatCTM(context , affineMoveLeftTop );
    // viewから切り取る
    [(CALayer*)self.view.layer renderInContext:context];
    // 切り取った内容をUIImageとして取得
    _saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageWriteToSavedPhotosAlbum(_saveImage, nil, nil, NULL);
    // コンテキスト終了
    UIGraphicsEndImageContext();
    */
    }

//画像保存完了時のセレクタ
- (void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"保存完了" message:@"画像を保存しました" preferredStyle:UIAlertControllerStyleAlert];
    
    // addActionした順に左から右にボタンが配置されます
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // ボタンを押した際に処理が必要ならここに書きます。
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 画像拡大縮小スクロールビュー
/* - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
*/
/*
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateImageCenter];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale
{
    [self updateImageCenter];
}
- (void)updateImageCenter
{
    // 画像の表示サイズを取得
    CGSize imageSize = self.imageView.image.size;
    imageSize.width *= self.scrollView.zoomScale;
    imageSize.height *= self.scrollView.zoomScale;
    
    // サブスクロールビューのサイズを取得
    CGRect  bounds = self.scrollView.bounds;
    
    // イメージビューの中央の座標を計算
    CGPoint point;
    point.x = imageSize.width / 2;
    if (imageSize.width < bounds.size.width) {
        point.x += (bounds.size.width - imageSize.width) / 2;
    }
    point.y = imageSize.height / 2;
    if (imageSize.height < bounds.size.height) {
        point.y += (bounds.size.height - imageSize.height) / 2;
    }
    self.imageView.center = point;
} */

//グレイボタン
- (IBAction)grayButtonAction:(id)sender {
    self.isGray = !self.isGray;
    // Garyボタンを押すと
    if (self.isGray) {
        [self.grayButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self convertGray];
    // Resetボタンを押すと
    } else {
        self.grayButton.titleLabel.text = @"Gray";
        [self.grayButton setTitle:@"Gray" forState:UIControlStateNormal];
        self.imageView.image = _editImage;
        // 輝度を維持する
        [self lightSlider:_slider];
        _lastImage = _imageView.image;
    }
}

// グレイ化メソッド
-(void)convertGray{
    UIImage *image = _lastImage;
    CGRect imageRect = (CGRect){0.0, 0.0, image.size.width, image.size.height};
    // モノクロ色空間
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    // サイズと色空間の設定
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    // 画像を描画
    CGContextDrawImage(context, imageRect, [image CGImage]);
    // 描画された画像を取得
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    // 取得した画像からUIImageを作る
    UIImage *grayImage = [UIImage imageWithCGImage:imageRef];
    // メモリ解放
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    // UIImageViewに画像を描画
    _lastImage = grayImage;
    _imageView.image = _lastImage;
}

@end
