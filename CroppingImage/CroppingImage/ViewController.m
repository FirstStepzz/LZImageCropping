//
//  ViewController.m
//  CroppingImage
//
//  Created by 刘志雄 on 2017/12/25.
//  Copyright © 2017年 刘志雄. All rights reserved.
//

#import "ViewController.h"
#import "LZImageCropping.h"

@interface ViewController ()<LZImageCroppingDelegate>
@property(nonatomic,strong)UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *button = [[UIButton alloc]init];
    [button setBounds:CGRectMake(0, 0, 50, 20)];
    [button setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 50)];
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 100, 200, 200)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.imageView];
}

-(void)buttonClick:(UIButton *)sender{
    LZImageCropping *imageBrowser = [[LZImageCropping alloc]init];
    //设置代理
    imageBrowser.delegate = self;
    //设置自定义裁剪区域大小
    imageBrowser.cropSize = CGSizeMake(self.view.frame.size.width - 60, (self.view.frame.size.width-60));
    //设置图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_1121"  ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [imageBrowser setImage:image];
    //是否需要圆形- - - - - -
    imageBrowser.isRound = YES;
    [self presentViewController:imageBrowser animated:YES completion:nil];
}

-(void)lzImageCropping:(LZImageCropping *)cropping didCropImage:(UIImage *)image{
    [self.imageView setImage:image];
}

@end
