# LZImageCropping
自定义裁剪区域的图片裁剪器

帮到的话，别忘了给个星星✨啊，兄弟们。 

![image](https://upload-images.jianshu.io/upload_images/2572565-5e47e557168c8a3a.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/260/format/webp)  

使用方法：

    LZImageCropping *imageBrowser = [[LZImageCropping alloc]init];
    //设置代理
    imageBrowser.delegate = self;
    //设置自定义裁剪区域大小
    imageBrowser.cropSize = CGSizeMake(self.view.frame.size.width - 60, (self.view.frame.size.width-60));
    //设置图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_1121"  ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    cropper.image = image;
    //是否需要圆形
    imageBrowser.isRound = YES;
    [self presentViewController:imageBrowser animated:YES completion:nil];
