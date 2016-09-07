//
//  ShowPhotoController.m
//  Reconstruct
//
//  Created by 区振轩 on 16/9/6.
//  Copyright © 2016年 区振轩. All rights reserved.
//

#import "ShowPhotoController.h"

@interface ShowPhotoController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * imageTabelView;
@property (nonatomic,strong) NSMutableArray * imageArray ;

@end

@implementation ShowPhotoController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    _imageArray  = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *filePath = [paths objectAtIndex:0];   // 保存文件的名称
    
    NSString * imageDir = [NSString stringWithFormat:@"%@/Pic",filePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    
    if (existed) {
        //读取文件
        int photonum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PhotoNum"] intValue];
        
        if (photonum > 0) {
            for (int i = 0; i<photonum; i++) {
                NSString * path = [NSString stringWithFormat:@"%@/image%d",imageDir,i];
                
//                UIImage * imageData = [UIImage imageWithContentsOfFile:path];
                [_imageArray addObject:path];
            }
        }
        
    }
    
    
    
    
    _imageTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    [self.view addSubview:_imageTabelView];
    
    _imageTabelView.dataSource = self;
    _imageTabelView.delegate = self;
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageCell"];
        
    }
    
    NSString * path = _imageArray[indexPath.row];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _imageArray.count;
}


@end
