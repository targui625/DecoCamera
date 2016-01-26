//
//  FrameViewController.m
//  DecoCamera
//
//  Created by Norimichi Takagi on 2016/01/18.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import "FrameViewController.h"
#import "ImageViewController.h"

@interface FrameViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *frameCollectionView;

@property (strong, nonatomic) NSArray *frameArray;
@property (strong, nonatomic) UIImage *editImage;

@end

@implementation FrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // フレーム初期化
    self.frameArray = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16];
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

// 配列が何個あるかの指定
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
// 配列の中のアイテム数の指定
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.frameArray count];
}

// フレームを１つずつコレクションビューに表示
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    // CollectionView上のUIImageViewをタグを用いて取得します。
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    NSString *imgName = [NSString stringWithFormat:@"frame_%02ld.png", (long)[self.frameArray[indexPath.row] integerValue]];
    UIImage *image = [UIImage imageNamed:imgName];
    imageView.image = image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // カメラが使用できるかどうか判定
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // カメラを生成
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        // デリゲートを自分自身に設定
        imagePickerController.delegate = self;
        
        // モードを写真にする
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // ずれ防止(iOSのバグ対応)
        imagePickerController.cameraViewTransform = CGAffineTransformTranslate(imagePickerController.cameraViewTransform, 0, 50);
        
        // 正方形に対応
        CGRect rect = imagePickerController.view.bounds;
        rect.size.height -= imagePickerController.navigationBar.bounds.size.height;
        CGFloat barHeight = (rect.size.height - rect.size.width) / 2;
        UIGraphicsBeginImageContext(rect.size);
        [[UIColor colorWithWhite:0 alpha:1] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, rect.size.width, barHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, rect.size.height - barHeight, rect.size.width, barHeight/1.48), kCGBlendModeNormal);
        UIImage *rimImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 画面上にフレームなどを置くための土台を作ります。
        UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        
        // 画面を隠す部分を準備します。
        UIImageView *rimView = [[UIImageView alloc] initWithFrame:rect];
        rimView.image = rimImage;
        [baseView addSubview:rimView];
        
        // フレームを準備します。
        NSString *imgName = [NSString stringWithFormat:@"frame_%02ld.png", (long)[self.frameArray[indexPath.row] integerValue]];
        UIImageView *frameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        frameView.frame = (CGRect){0, barHeight, rect.size.width, rect.size.width};
        [baseView addSubview:frameView];
        
        // 画面上にフレームなどを置きます。
        [imagePickerController setCameraOverlayView:baseView];
        
        // モーダルビューとしてカメラ画面を呼び出す
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // カメラを閉じる
    [picker dismissViewControllerAnimated:YES completion:nil];
    
// 今表示している画像の取得
    // キャプチャ対象をWindowへ変換
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // キャプチャするためのwindow
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 全てのwindowを統合
    for (UIWindow *aWindow in [UIApplication sharedApplication].windows) {
        [aWindow.layer renderInContext:context];
    }
    // 統合したものをUIImageとして受け取る
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    // 終わり
    UIGraphicsEndImageContext();

    //写真の部分を切り抜き
    CGRect rect = picker.view.bounds;
    rect.size.height -= picker.navigationBar.bounds.size.height;
    CGFloat barHeight = (rect.size.height - rect.size.width) / 2;
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    
    // 画像を描画します。
    [capturedImage drawAtPoint:CGPointMake(0, -barHeight)];
    capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画終了
    UIGraphicsEndImageContext();
    
    self.editImage = capturedImage;
    [self performSegueWithIdentifier:@"ImageView" sender:self];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Segueの特定
    if ( [[segue identifier] isEqualToString:@"ImageView"] ) {
        
        ImageViewController *nextViewController = [segue destinationViewController];
        nextViewController.editImage = self.editImage;
    }
}

@end
