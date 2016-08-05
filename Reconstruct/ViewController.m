//
//  ViewController.m
//  Reconstruct
//
//  Created by 区振轩 on 16/8/4.
//  Copyright © 2016年 区振轩. All rights reserved.
//

#import "ViewController.h"
#import "ZXTakePhotoController.h"

@interface ViewController ()

@property (nonatomic,strong) UIImageView * showImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    

    _showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300, 300, 300)];
    [self.view addSubview:_showImageView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    NSData * imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"TheImage"];
    UIImage * image =  [UIImage imageWithData:imageData];
    
    _showImageView.image = image;
    
    
}

- (void)pushToTakePhoto{
    ZXTakePhotoController * vc = [[ZXTakePhotoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
