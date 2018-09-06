//
//  ViewController.m
//  CroppingImage
//
//  Created by 刘志雄 on 2017/12/25.
//  Copyright © 2017年 刘志雄. All rights reserved.
//

#import "ViewController.h"
#import "LZImageCropper.h"

@interface ViewController ()<LZImageCroppingDelegate>
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)    LZImageCropper * cropper;
@end

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
static const CGFloat kBottomHeight = 44;
static const CGFloat kBaseTag = 200;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cropper= [[LZImageCropper alloc]init];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupUI];
}

-(void)setupUI{
    
    //按钮
    NSArray *titlesArray = @[@"圆形裁剪",@"矩形裁剪"];
    for (int i = 0; i<2; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2*i, SCREEN_HEIGHT-kBottomHeight, SCREEN_WIDTH/2, kBottomHeight)];
        [button setTag:kBaseTag+i];
        [button setBackgroundColor:[UIColor blackColor]];
        [button setTitle:titlesArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    //图片显示区域
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, 100, 300, 300)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.imageView];
}

-(void)buttonClick:(UIButton *)sender{
    self.cropper= [[LZImageCropper alloc]init];
    //设置代理
    self.cropper.delegate = self;
    //设置图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_3209"  ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    self.cropper.image = image;
    //设置自定义裁剪区域大小
    self.cropper.cropSize = CGSizeMake(self.view.frame.size.width - 60, (self.view.frame.size.width-60)*960/1280);
    self.cropper.isRound = sender.tag-kBaseTag == 0;
    [self presentViewController:self.cropper animated:YES completion:nil];
}

#pragma mark - Delegate
-(void)lzImageCropping:(LZImageCropper *)cropping didCropImage:(UIImage *)image{
    [self.imageView setImage:image];
}

@end
