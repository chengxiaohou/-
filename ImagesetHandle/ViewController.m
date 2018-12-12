//
//  ViewController.m
//  ImagesetHandle
//
//  Created by fengyi on 2018/8/21.
//  Copyright © 2018年 fengyi. All rights reserved.
//

#import "ViewController.h"
#import "ComepareVC.h"
#import "Worker.h"
@interface ViewController ()

//=========== 两个数组图片对照 ===========
@property (strong, nonatomic) NSMutableArray *listA;
@property (strong, nonatomic) NSMutableArray *listB;

//=========== === ===========

@end

typedef NS_ENUM (NSUInteger, CellRow) {
    Row0 = 0,
    Row1 = 1,
    Row2 = 2,
};


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CellRow i = 0;
    switch (i) {
        case Row0:
            
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
//    [self onCompare:nil]; // 功能一 图片可视化对比
//    [self compareImageset];// 功能二 图片对比输出或重命名
}

- (IBAction)onCompare:(id)sender {
    
    [self  compareImageNamesFromTwoFloder];
}

#pragma mark 对比两个文件夹下的图片名
- (void)compareImageNamesFromTwoFloder
{
    /**
     
     * widget新的切图存在大量命名不一致的问题
     * 写程序用于对比widget新旧两组图片
     * 在工程和沙盒路径中同时存放新旧两组图
     * 先遍历原图片库路径下的图片名称，存入listA
     * 实现文件夹递归查询
     * 再遍历新图片库路径下的图片名，每次从listB查询是否有同名文件
     * 在-enumerate遍历中如果想要移除元素，必须用NSEnumerationReverse的Options来反向遍历，否则虽然能成功，但可能产生意外的结果
     * 有同名图片则移除listA和listB中的该名字。无同名不处理
     * 完成后将listA和listB中的图片并列展示两列，显示名称
     * 设置右边一列拖动排序功能
     * 人工比对，相同的图并列排序，排序完成后输出键值对，作为新的替换关系字典
     * 在不改变图片命名的前提下，利用swizzle和替换关系字典，正确的展示图片
     */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documePath = [paths objectAtIndex:0];
    NSLog(@"CXHLog:%@", documePath);
    _listA = [NSMutableArray new];
    _listB = [NSMutableArray new];
    // 旧图
    NSString *oldPath = [NSString stringWithFormat:@"%@/image",documePath];
    NSArray *tempA = [[Worker getAllFilesByPath:oldPath] mutableCopy];
    tempA = [tempA sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    for (NSString *name in tempA) {
        if (![name containsString:@"DS_Store"])
        {
            NSRange range = [name rangeOfString:@"@"];
            if (range.location != NSNotFound)
            {
                NSString *newName = [name substringToIndex:range.location];
                if (![_listA containsObject:newName])
                {
                    [_listA addObject:newName];
                }
            }
            else
            {
                NSLog(@"CXHLog:%@ 不是图片哦", name);
            }
        }
    }

    
    // 新图
    NSString *newPath = [NSString stringWithFormat:@"%@/iOS_WidgetImage",documePath];
    NSArray *tempB = [[Worker getAllFilesByPath:newPath] mutableCopy];
    tempB = [tempB sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSString *name in tempB) {
        if (![name containsString:@"DS_Store"])
        {
            NSRange range = [name rangeOfString:@"@"];
            if (range.location != NSNotFound)
            {
                NSString *newName = [name substringToIndex:range.location];
                if (![_listB containsObject:newName])
                {
                    [_listB addObject:newName];
                }
            }
            else
            {
                NSLog(@"CXHLog:%@ 不是图片哦", name);
            }
        }
    }
    
    // 对比
    [_listB enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *name = (NSString *)obj;

        // 存在同名
        if ([self.listA containsObject:name]) {
            [self.listA removeObject:obj];
            [self.listB removeObject:obj];
            
        }
    }];
    

    
//    NSLog(@"CXHLog: _listA \n %@", _listA);
//    NSLog(@"CXHLog: _listB \n %@", _listB);
    
    [ComepareVC showWithLeft:_listA right:_listB oldVC:self];
}





//========================== === ==========================

#pragma mark 查找图片名不一致的Imageset
- (void)compareImageset
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documePath = [paths objectAtIndex:0];
    
    // 全局搜索项目中的.imageset，把搜索结果放入到一个文件夹，起名为xxx，再把文件夹拖入模拟器的如下位置，即可开始查找
    NSString *xxxPath = [NSString stringWithFormat:@"%@/xxx",documePath];
    NSArray *xxxFloder = [Worker getFlodersByPath:xxxPath];
    
    NSMutableDictionary *badGuysDic = [NSMutableDictionary new];
    
    for (NSString *imageset in xxxFloder)
    {
        NSArray *imagesetFloder = [Worker getFileByPath:[NSString stringWithFormat:@"%@/xxx/%@",documePath, imageset]];
        NSString *imagesetName = [imageset stringByReplacingOccurrencesOfString:@".imageset" withString:@""];
        
        
        BOOL equal = NO;
        NSString *imageNamePre = nil;
        for (NSString *imageName in imagesetFloder) {
            NSRange range = [imageName rangeOfString:@"@"];
            if (range.location == NSNotFound) {
                continue;
            }
            imageNamePre = [imageName substringToIndex:range.location];
            // 图片名 == imageset的名字
            if ([imageNamePre isEqualToString:imagesetName]) {
                equal = YES;
                break;
            }
            // 不一致且有@，则确认是一张图片，标记为不一致
            else if ([imageName containsString:@"@"])
            {
                equal = NO;
                // 可选自动重命名
                if (0) {
                    NSMutableString *newName = [imageName mutableCopy];
                    [newName replaceCharactersInRange:NSMakeRange(0, range.location) withString:imagesetName];
//                    NSLog(@"CXHLog:%@ -> %@", imageName, newName);
//                    NSLog(@"\n");
                    NSString *floderPath = [NSString stringWithFormat:@"%@/%@.imageset",xxxPath, imagesetName];
                    [Worker renameFileName:imageName toNewName:newName floderPath:floderPath];
                    continue;
                }
                break;
            }
        }
        // 不一致
        if (!equal) {
            
            [badGuysDic setValue:imageNamePre forKey:imagesetName];
        }
    }
    
    NSArray *temp = [[badGuysDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSLog(@"CXHLog:以下分别是 项目使用名 : 实际名字 \n");
    for (NSString *key in temp) {
        NSString *value = badGuysDic[key];


        NSLog(@" @\"%@\" : @\"%@\", ", key, value);
    }
    //    NSLog(@"CXHLog:%@", badGuysDic);
    NSLog(@"总共 %ld", badGuysDic.allKeys.count);
}





@end
