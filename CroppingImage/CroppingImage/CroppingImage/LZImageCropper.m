//
//  LZImageCropping.m
//  CroppingImage
//
//  Created by 刘志雄 on 2017/12/25.
//  Copyright © 2017年 刘志雄. All rights reserved.
//

#import "LZImageCropper.h"
@interface LZImageCropper ()<UIScrollViewDelegate>{
    CGFloat _selfHeight;
    CGFloat _selfWidth;
    CGRect _cropFrame;
}

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIImageView *cropImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *bottomLabel;
@property(nonatomic,strong)UIButton *cancleButton;
@property(nonatomic,strong)UIButton *sureButton;
@property(nonatomic,strong)UIView *overLayView;

@end

#define IOS11 [[UIDevice currentDevice].systemVersion floatValue] >= 11.0


@implementation LZImageCropper

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _selfWidth = self.view.frame.size.width;
    _selfHeight = self.view.frame.size.height;
    
    [self createUI];
    [self setupData];
    
    //绘制裁剪框
    if (self.isRound) {
        [self transparentCutRoundArea];
    }else{
        [self transparentCutSquareArea];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CGFloat scale,autoScale;
    CGFloat cropWHRatio = _cropSize.width/_cropSize.height;
    CGFloat viewWHRatio = CGRectGetWidth(self.view.frame)/CGRectGetHeight(self.view.frame);
    
    //计算最小缩放比例
    CGFloat  imageWHRatio = _image.size.width/_image.size.height;
    if (cropWHRatio > imageWHRatio) {
        scale = _cropSize.width/_imageView.frame.size.width;
    }else{
        scale = _cropSize.height/_imageView.frame.size.height;
    }
    
    //计算自动填充屏幕缩放比例
    if (viewWHRatio > imageWHRatio) {
        autoScale = CGRectGetWidth(self.view.frame)/_imageView.frame.size.width;
    }else{
        autoScale = CGRectGetHeight(self.view.frame)/_imageView.frame.size.height;
    }
    
    //自动缩放填满裁剪区域
    [self.scrollView setZoomScale:autoScale animated:YES];
    //设置刚好填充满裁剪区域的缩放比例，为最小缩放比例
    [self.scrollView setMinimumZoomScale:scale];
    self.scrollView.userInteractionEnabled = YES;
}

-(void)createUI{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.overLayView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.bottomLabel];
    [self.view addSubview:self.cancleButton];
    [self.view addSubview:self.sureButton];
    
    if ([self lz_isIPhoneX]) {
        [self.titleLabel setFrame:CGRectMake(0, 40, _selfWidth, 20)];
    }else{
        [self.titleLabel setFrame:CGRectMake(0, 20, _selfWidth, 20)];
    }
    CGFloat height = [UIFont systemFontOfSize:15].pointSize;
    CGFloat width = 40;
    [self.bottomLabel setFrame:CGRectMake(0, _selfHeight-44,_selfWidth, 44)];
    [self.cancleButton setFrame:CGRectMake(15, _selfHeight - 15 - height,width, height)];
    [self.sureButton setFrame:CGRectMake(_selfWidth - 15- width, _selfHeight-15-height, width, height)];
    
    [self.overLayView setFrame:self.view.frame];
    [self.scrollView setFrame:CGRectMake(0, 0, _selfWidth, _selfHeight)];
    [self.scrollView setContentSize:CGSizeMake(_selfWidth, _selfHeight)];
}

-(void)setupData{
    //如果是圆形的话，对给的cropSize进行容错处理
    if (self.isRound) {
        if (self.cropSize.width >= self.cropSize.height) {
            self.cropSize = CGSizeMake(self.cropSize.height, self.cropSize.height);
        }else{
            self.cropSize = CGSizeMake(self.cropSize.width, self.cropSize.width);
        }
    }
    
    //设置裁剪框区域
    _cropFrame = CGRectMake((self.view.frame.size.width-self.cropSize.width)/2,(self.view.frame.size.height-self.cropSize.height)/2,self.cropSize.width,self.cropSize.height);
    
    //设置图片
    [_imageView setImage:self.image];
    
    //此处是根据裁剪区域和图片大小，让图片的imageView正好卡在裁剪区域内。等viewDidAppear的时候再进行缩放填充满裁剪区域
    CGFloat cropWHRatio = _cropSize.width/_cropSize.height;
    CGFloat  imageWHRatio = _image.size.width/_image.size.height;
    CGFloat imageViewW,imageViewH,imageViewX,imageViewY;
    if (cropWHRatio> imageWHRatio) {
        imageViewW =  imageWHRatio*_cropSize.height;
        imageViewH = _cropSize.height;
        imageViewX = (_cropSize.width - imageViewW)/2 + (self.view.frame.size.width-_cropSize.width)/2;
        imageViewY = (self.view.frame.size.height- _cropSize.height)/2;
    }else{
        imageViewX = (self.view.frame.size.width-_cropSize.width)/2;
        imageViewW = _cropSize.width;
        imageViewH = _cropSize.height / imageWHRatio;
        imageViewY = (_cropSize.height - imageViewH)/2 + (self.view.frame.size.height-_cropSize.height)/2;
    }
    [_imageView setFrame:CGRectMake(imageViewX, imageViewY,imageViewW,imageViewH)];
}

#pragma mark -
//矩形裁剪区域
- (void)transparentCutSquareArea{
    //圆形透明区域
    UIBezierPath *alphaPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _selfWidth, _selfHeight)];
    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRect:_cropFrame];
    [alphaPath appendPath:squarePath];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = alphaPath.CGPath;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    self.overLayView.layer.mask = shapeLayer;
    
    //裁剪框
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithRect:CGRectMake(_cropFrame.origin.x-1, _cropFrame.origin.y-1, _cropFrame.size.width+2, _cropFrame.size.height+2)];
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    cropLayer.path = cropPath.CGPath;
    cropLayer.fillColor = [UIColor whiteColor].CGColor;
    cropLayer.strokeColor = [UIColor whiteColor].CGColor;
    [self.overLayView.layer addSublayer:cropLayer];
}

//圆形裁剪区域
-(void)transparentCutRoundArea{
    CGFloat arcX = _cropFrame.origin.x + _cropFrame.size.width/2;
    CGFloat arcY = _cropFrame.origin.y + _cropFrame.size.height/2;
    CGFloat arcRadius;
    if (_cropSize.height > _cropSize.width) {
        arcRadius = _cropSize.width/2;
    }else{
        arcRadius  = _cropSize.height/2;
    }
    
    //圆形透明区域
    UIBezierPath *alphaPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, _selfWidth, _selfHeight)];
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcX, arcY) radius:arcRadius startAngle:0 endAngle:2*M_PI clockwise:NO];
    [alphaPath appendPath:arcPath];
    CAShapeLayer  *layer = [CAShapeLayer layer];
    layer.path = alphaPath.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    self.overLayView.layer.mask = layer;
    
    //裁剪框
    UIBezierPath *cropPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcX, arcY) radius:arcRadius+1 startAngle:0 endAngle:2*M_PI clockwise:NO];
    CAShapeLayer *cropLayer = [CAShapeLayer layer];
    cropLayer.path = cropPath.CGPath;
    cropLayer.strokeColor = [UIColor whiteColor].CGColor;
    cropLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.overLayView.layer addSublayer:cropLayer];
}

-(UIImage *)getSubImage{
    //图片大小和当前imageView的缩放比例
    CGFloat scaleRatio = self.image.size.width/_imageView.frame.size.width ;
    //scrollView的缩放比例，即是ImageView的缩放比例
    CGFloat scrollScale = self.scrollView.zoomScale;
    //裁剪框的 左上、右上和左下三个点在初始ImageView上的坐标位置（注意：转换后的坐标为原始ImageView的坐标计算的，而非缩放后的）
    CGPoint leftTopPoint =  [self.view  convertPoint:_cropFrame.origin toView:_imageView];
    CGPoint rightTopPoint = [self.view convertPoint:CGPointMake(_cropFrame.origin.x + _cropSize.width, _cropFrame.origin.y) toView:_imageView];
    CGPoint leftBottomPoint =[self.view convertPoint:CGPointMake(_cropFrame.origin.x, _cropFrame.origin.y+_cropSize.height) toView:_imageView];
    
    //计算三个点在缩放后imageView上的坐标
    leftTopPoint = CGPointMake(leftTopPoint.x * scrollScale, leftTopPoint.y*scrollScale);
    rightTopPoint = CGPointMake(rightTopPoint.x * scrollScale, rightTopPoint.y*scrollScale);
    leftBottomPoint = CGPointMake(leftBottomPoint.x * scrollScale, leftBottomPoint.y*scrollScale);
    
    //计算裁剪区域在原始图片上的位置
    CGFloat width = (rightTopPoint.x - leftTopPoint.x )* scaleRatio;
    CGFloat height = (leftBottomPoint.y - leftTopPoint.y) *scaleRatio;
    CGRect myImageRect = CGRectMake(leftTopPoint.x * scaleRatio, leftTopPoint.y*scaleRatio, width, height);
    
    //裁剪图片
    CGImageRef imageRef = self.image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    UIGraphicsBeginImageContextWithOptions(myImageRect.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(0, 0, myImageRect.size.width, myImageRect.size.height), subImageRef);
    UIImage *subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    
    //是否需要圆形图片
    if (self.isRound) {
        //将图片裁剪成圆形
        subImage = [self clipCircularImage:subImage];
    }
    return subImage;
}

//将图片裁剪成圆形
-(UIImage *)clipCircularImage:(UIImage *)image{
    CGFloat arcCenterX = image.size.width/ 2;
    CGFloat arcCenterY = image.size.height / 2;
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextAddArc(context, arcCenterX, arcCenterY, image.size.width/2, 0.0, 2*M_PI, NO);
    CGContextClip(context);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}

#pragma mark - UIScrollViewDelegate(Zoom)
// 返回要在ScrollView中缩放的控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    //等比例放大图片以后，让放大后的ImageView保持在ScrollView的中央
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) *0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) *0.5 : 0.0;
    _imageView.center =CGPointMake(scrollView.contentSize.width *0.5 + offsetX,scrollView.contentSize.height *0.5 + offsetY);

    //设置scrollView的contentSize，最小为self.view.frame
    CGFloat scrollW = scrollView.contentSize.width >= _selfWidth?scrollView.contentSize.width:_selfWidth;
    CGFloat scrollH = scrollView.contentSize.height >= _selfHeight?scrollView.contentSize.height:_selfHeight;
    [scrollView setContentSize:CGSizeMake(scrollW, scrollH)];
    
    //设置scrollView的contentInset
    CGFloat imageWidth = _imageView.frame.size.width;
    CGFloat imageHeight = _imageView.frame.size.height;
    CGFloat cropWidth = _cropSize.width;
    CGFloat cropHeight = _cropSize.height;
    
    CGFloat leftRightInset = 0.f,topBottomInset = 0.f;
    
    //imageview的大小和裁剪框大小的三种情况，保证imageview最多能滑动到裁剪框的边缘
    if (imageWidth<= cropWidth) {
        leftRightInset = 0;
    }else if (imageWidth >= cropWidth && imageWidth <= _selfWidth){
        leftRightInset =(imageWidth - cropWidth)*0.5;
    }else{
        leftRightInset = (_selfWidth-_cropSize.width)*0.5;
    }
    
    if (imageHeight <= cropHeight) {
        topBottomInset = 0;
    }else if (imageHeight >= cropHeight && imageHeight <= _selfHeight){
        topBottomInset = (imageHeight - cropHeight)*0.5;
    }else {
        topBottomInset = (_selfHeight-_cropSize.height)*0.5;
    }
    [self.scrollView setContentInset:UIEdgeInsetsMake(topBottomInset, leftRightInset, topBottomInset, leftRightInset)];
}

#pragma mark - Click Event
-(void)cancleButtonClick{
    if ([self.delegate respondsToSelector:@selector(lzImageCroppingDidCancle:)]) {
        [self.delegate lzImageCroppingDidCancle:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sureButtonClick{
    if ([self.delegate respondsToSelector:@selector(lzImageCropping:didCropImage:)]) {
        [self.delegate lzImageCropping:self didCropImage:[self getSubImage]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - lazyLoad
-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        //设置缩放的最大比例和最小比例
        _scrollView.maximumZoomScale = 10;
        _scrollView.minimumZoomScale = 1;
        //初始缩放比例为1
        [_scrollView setZoomScale:1 animated:YES];
        [_scrollView setFrame:CGRectMake(0, 0, _selfWidth, _selfHeight)];
        if(IOS11){
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [_imageView setUserInteractionEnabled:YES];
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _imageView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setText:@"通过移动缩放来选择"];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

-(UIButton *)cancleButton{
    if (!_cancleButton) {
        _cancleButton = [[UIButton alloc]init];
        [_cancleButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_cancleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_cancleButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

-(UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [[UIButton alloc]init];
        [_sureButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_sureButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

-(UILabel *)bottomLabel{
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc]init];
        [_bottomLabel setFont:[UIFont systemFontOfSize:14]];
        [_bottomLabel setTextColor:[UIColor whiteColor]];
        [_bottomLabel setText:@"选取有效区域"];
        [_bottomLabel setTextAlignment:NSTextAlignmentCenter];
        [_bottomLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _bottomLabel;
}

//用于展示裁剪框的视图
-(UIView *)overLayView{
    if (!_overLayView) {
        _overLayView = [[UIView alloc]init];
        _overLayView.userInteractionEnabled = NO;
        _overLayView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    }
    return _overLayView;
}

- (BOOL)lz_isIPhoneX {
    return [UIScreen mainScreen].bounds.size.width == 812;
}

@end
