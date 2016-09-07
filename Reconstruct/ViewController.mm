//
//  ViewController.m
//  Reconstruct
//
//  Created by 区振轩 on 16/8/4.
//  Copyright © 2016年 区振轩. All rights reserved.
//

#import "ViewController.h"
#import "ZXTakePhotoController.h"
#import "GrabCutManager.h"
#import "ShowPhotoController.h"

@interface ViewController ()

@property (nonatomic,strong) UIImageView * showImageView;

@property (nonatomic, strong) GrabCutManager* grabcut;

@property (nonatomic, strong) UIImage* resizedImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _grabcut = [[GrabCutManager alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    btn.titleLabel.text = @"拍照";
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(pushToTakePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btn1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 250, 100, 100)];
    btn1.backgroundColor = [UIColor greenColor];
    btn1.titleLabel.text = @"展示";
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(pushToShowView) forControlEvents:UIControlEventTouchUpInside];
    

    _showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300, 300, 300)];
    [self.view addSubview:_showImageView];
    
}

- (void) pushToShowView{
    ShowPhotoController * vc = [[ShowPhotoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

#pragma mark - 抠图操作
-(void) doGrabcut:(UIImage *)originalImage{
    //    [self showLoadingIndicatorView];
    
//    originalImage = [UIImage imageNamed:@"test"];
    
    CGRect grabRect = CGRectMake(90, 166, 375/2.0, 667/2.0);
    CGSize sizeM = CGSizeMake(375, 667);
    
    originalImage = [self resizeImage:originalImage size:sizeM];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        
        
        
        UIImage* resultImage= [weakSelf.grabcut doGrabCut:originalImage foregroundBound:grabRect iterationCount:5];
        
        //        [weakSelf.resultImageView setImage:resultImage];
        resultImage = [weakSelf masking:originalImage mask:[weakSelf resizeImage:resultImage size:originalImage.size]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
                _showImageView.image = resultImage;
        });
        
        
        //        dispatch_async(dispatch_get_main_queue(), ^(void) {
        //            [weakSelf.resultImageView setImage:resultImage];
        //            [weakSelf.imageView setAlpha:0.0];
        //
        ////            [weakSelf hideLoadingIndicatorView];
        //
        //
        //
        //        });
        
        
//        NSData * ImageData = UIImagePNGRepresentation(resultImage);
//        
//        
//        [[NSUserDefaults standardUserDefaults] setObject:ImageData forKey:@"TheImage"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    });
}


-(UIImage*) resizeImage:(UIImage*)image size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage *) masking:(UIImage*)sourceImage mask:(UIImage*) maskImage{
    //Mask Image
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([sourceImage CGImage], mask);
    CGImageRelease(mask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
    
    return maskedImage;
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden = NO;
    
    NSData * imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheImage"];
    UIImage * image =  [UIImage imageWithData:imageData];
    
    _showImageView.image = image;
    
    
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)pushToTakePhoto{
    ZXTakePhotoController * vc = [[ZXTakePhotoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)doOpenCV{
    if (_showImageView.image) {
        
        [self doGrabcut:_showImageView.image];
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
