//
//  ZXTakePhotoController.m
//  Reconstruct
//
//  Created by 区振轩 on 16/8/4.
//  Copyright © 2016年 区振轩. All rights reserved.
//

#import "ZXTakePhotoController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SCCaptureSessionManager.h"
#import <CoreMotion/CoreMotion.h>

//#define SWidth ([UIScreen mainScreen].bounds.size.width)
//#define SHeight ([UIScreen mainScreen].bounds.size.height)

@interface ZXTakePhotoController ()
{
    int theSampleRoll;
    int photoNum;
}



@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong)       AVCaptureSession            * session;
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;
//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;
//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;
//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       UIBarButtonItem             * toggleButton;
//切换前后镜头的按钮
@property (nonatomic, strong)       UIButton                    * shutterButton;
//拍照按钮
@property (nonatomic, strong)       UIView                      * cameraShowView;
//放置预览图层的View
@property (nonatomic,assign) BOOL cameraAvaible;

@property (nonatomic, strong)       UIImageView                      * picShowView;

@property (nonatomic,strong) CMMotionManager * motionManager;//重力加速度计

@property (nonatomic,strong) NSMutableDictionary * dic;

@property (nonatomic,strong) UIView * compassView;          //对照的view

@property (nonatomic,strong) NSTimer * timer;

@property (nonatomic,strong) UIView * redAlertView;

@end

@implementation ZXTakePhotoController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    photoNum = 0 ;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(takePhotoTimerAction) userInfo:nil repeats:YES];
    [_timer setFireDate:[NSDate distantFuture]];
    
    theSampleRoll = -180;
    
    self.motionManager = [[CMMotionManager alloc]init];
    if (!self.motionManager.accelerometerAvailable) {
        NSLog(@"CMMotionManager unavailable");
    }
    self.motionManager.accelerometerUpdateInterval =0.1; // 数据更新时间间隔
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]withHandler:^(CMAccelerometerData *accelerometerData,NSError *error) {
        if (error) {
                NSLog(@"error");
        }
//        [self.motionManager startAccelerometerUpdates];
        double x = floor( accelerometerData.acceleration.x * 100);
        double y = floor( accelerometerData.acceleration.y * 100);
        double z = floor( accelerometerData.acceleration.z * 100);
        
//        if (fabs(x)>2.0 ||fabs(y)>2.0 ||fabs(z)>2.0) {
//            NSLog(@"检测到晃动");
//        }
        NSLog(@"CoreMotionManager, x: %f,y: %f, z: %f",x,y,z);
    }];
    
    _dic = [NSMutableDictionary dictionary];
    
    self.cameraShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    self.cameraShowView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_cameraShowView];
    
    
    
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    [manager configureWithParentLayer:self.cameraShowView previewRect:_previewRect];
    self.captureManager = manager;
    [_captureManager.session startRunning];
    
    
    
    _picShowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_picShowView];
    _picShowView.hidden = YES;
    
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake((SC_DEVICE_SIZE.width - 100)/2, SC_DEVICE_SIZE.height - 150, 100, 100)];
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.cornerRadius = 50;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(takeThePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 60, 40)];
    [backBtn setTitle:@"<" forState:UIControlStateNormal];
    [backBtn setTintColor:[UIColor blackColor]];
    [self.view addSubview:backBtn];
    backBtn.backgroundColor = [UIColor blackColor];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
//    _compassView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 100)];
//    _compassView.backgroundColor = [UIColor redColor];
//    _compassView.center = self.view.center;
//    [self.view addSubview:_compassView];
    
    _redAlertView = [[UIView alloc] initWithFrame:CGRectMake(SWidth/4.0, SHeight/4.0,SWidth/2, SHeight/2)];
    _redAlertView.layer.borderWidth = 2;
    _redAlertView.layer.borderColor = [UIColor redColor].CGColor;
    _redAlertView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_redAlertView];
    
    
}


- (void)takePhotoTimerAction{
    NSLog(@"lalalal");
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - 0);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    
    [_captureManager takePicture:^(UIImage *stillImage) {
        //       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //         UIImageWriteToSavedPhotosAlbum(stillImage, nil, nil, nil);//存至本机
        //       });
        
        
        NSData * ImageData = UIImagePNGRepresentation(stillImage);
        
        //        [[NSUserDefaults standardUserDefaults] setObject:ImageData forKey:@"TheImage"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Pic/image%d",photoNum++]];   // 保存文件的名称
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:photoNum] forKey:@"PhotoNum"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL result = [ImageData writeToFile: filePath    atomically:YES]; // 保存成功会返回YES
        
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        //
        //        double delayInSeconds = 2.f;
        //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ////            sender.userInteractionEnabled = YES;
        ////            [weakSelf_SC showCameraCover:NO];
        //            _picShowView.image = stillImage;
        //            _picShowView.hidden = NO;
        //        });
        
        //your code 0
        //        SCNavigationController *nav = (SCNavigationController*)weakSelf_SC.navigationController;
        //        if ([nav.scNaigationDelegate respondsToSelector:@selector(didTakePicture:image:)]) {
        //            [nav.scNaigationDelegate didTakePicture:nav image:stillImage];
        //        }
    }];
}

- (bool) createDirInCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];   // 保存文件的名称
    
    NSString * imageDir = [NSString stringWithFormat:@"%@/Pic",filePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isCreated = false;
    bool isDeleted = false;//是否删除成功
    if (existed) {
        //删除目录下的文件。
        isDeleted = [fileManager removeItemAtPath:imageDir error:nil];
        if (isDeleted) {
            existed = false;
        }
    }
    
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return isCreated||existed;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

//拍照
- (void)takeThePhoto{
    bool haveDir = [self createDirInCache];
    
    if (haveDir) {
        [_timer setFireDate:[NSDate distantPast]];
    }
    
//    _compassView.transform = CGAffineTransformMakeTranslation(10, 0);
    
    return;
    
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self isSuppostCamera];
    
//    [self startmotion];
//    [self setUpCameraLayer];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.session) {
        [self.session startRunning];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
    
    NSLog(@"%@",_dic);
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (self.motionManager) {
        
        [self.motionManager stopGyroUpdates];
        self.motionManager = nil;
    }
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)isSuppostCamera
{
    // 首先查看当前设备是否支持拍照
    //    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        
        NSLog(@"没有访问权限");
        _cameraAvaible = NO;
    }else{
        _cameraAvaible = YES;
    }

}

//开始手机磁罗盘校准
#pragma mark 手机磁罗盘进行校准
- (void)startmotion
{
    
    
    
    //手机磁罗盘校准
//    self.motionManager = [[CMMotionManager alloc] init];
//    
//    if ([self.motionManager isAccelerometerAvailable])
//    {
//        
//        self.motionManager.accelerometerUpdateInterval =0.1; // 数据更新时间间隔
//        
//        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            [self.motionManager startAccelerometerUpdates];
//            
//            CMAccelerometerData * xixi = self.motionManager.accelerometerData;
//            double x=  xixi.acceleration.x;
//            double y=  xixi.acceleration.y;
//            double z=  xixi.acceleration.z;
//            
////            double heh = data.acceleration.x
//            NSLog(@"x  =%f,y   =%f,z   =%f",x,y,z);
//        }];
    
        
        
        
        
        
//        [self.motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMGyroData *gyroData, NSError *error) {
//            
//            [self.motionManager startDeviceMotionUpdates];
//            
//            
//            double roll =  self.motionManager.deviceMotion.attitude.roll * 180 / M_PI;
//            
//            double pitch =  self.motionManager.deviceMotion.attitude.pitch* 180 / M_PI;;
//            double yaw =  self.motionManager.deviceMotion.attitude.yaw* 180 / M_PI;;
//            
//            NSString * TheRoll = [NSString stringWithFormat:@"%d", (int)floor(roll)] ;
////TheRoll - theSampleRoll
//
//            
////            if (![_dic objectForKey:TheRoll]) {
////                NSDate * now = [NSDate date];
////                [_dic setObject:now forKey:TheRoll];
////
//////                [self takeThePhoto];
////            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//            _compassView.transform = CGAffineTransformMakeTranslation((int)floor(roll) + theSampleRoll, 0);
////                _compassView.transform = CGAffineTransformTranslate(_compassView.transform, ((int)floor(roll) - theSampleRoll)/2, 0); //实现的是平移
//                
//            });
//            
//            
//            
////            NSLog(@"root=%f,pitch=%f,yaw=%f",roll,pitch,yaw);
////            NSLog(@"root=%f",roll);
////            NSLog(@"pitch=%f",pitch);
//            NSLog(@"yaw=%f",yaw);
//        
//            
//        }];
        
        
        
//    }
}


@end
