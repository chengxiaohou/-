//
//  Worker.m
//  ImagesetHandle
//
//  Created by fengyi on 2018/12/10.
//  Copyright © 2018 fengyi. All rights reserved.
//

#import "Worker.h"

@implementation Worker

//#pragma mark 【递归】获取路径下以及更深层次文件夹中的文件，仅文件
+ (NSArray *)getAllFilesByPath:(NSString *)path
{
    return [self getAllFilesByPath:path handle:nil];
}

+ (NSArray *)getAllFilesByPath:(NSString *)path handle:(void (^)(NSString *name, NSString *path))handle
{
    NSMutableArray *floders = [[self getFlodersByPath:path] mutableCopy];
    NSMutableArray *files = [[self getFileByPath:path] mutableCopy];
    
    [files removeObjectsInArray:floders];
    
    // 对每个文件做某项操作
    if (handle) {
        for (NSString *fileName in files) {
            handle(fileName, path);
        }
    }
    
    for (NSString *subFloder in floders) {
        NSString *subPath = [NSString stringWithFormat:@"%@/%@",path, subFloder];
        [files addObjectsFromArray:[self getAllFilesByPath:subPath handle:handle]];
    }
    
    return files;
}

#pragma mark 文件夹和文件递归
+ (NSArray *)getRecursiveFilesByPath:(NSString *)path
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSArray *array = [defaultManager subpathsOfDirectoryAtPath:path error:nil];
    return array;
}

// 根据路径获取文件目录下所有文件（不递归）
+ (NSArray *)getFileByPath:(NSString *)path
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSArray *array = [defaultManager contentsOfDirectoryAtPath:path error:nil];
    return array;
}

// 根据路径获取该路径下所有目录
+ (NSArray *)getFlodersByPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray * fileAndFloderArr = [self getFileByPath:path];
    
    NSMutableArray *dirArray = [[NSMutableArray alloc] init];
    BOOL isDir = NO;
    //在上面那段程序中获得的fileList中列出文件夹名
    for (NSString * file in fileAndFloderArr){
        
        NSString *paths = [path stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:paths isDirectory:(&isDir)];
        if (isDir) {
            [dirArray addObject:file];
        }
        isDir = NO;
    }
    return dirArray;
}


+ (BOOL)renameFileName:(NSString *)oldName toNewName:(NSString *)newName floderPath:(NSString *)path
{
    
    BOOL result = NO;
    NSError * error = nil;
    result = [[NSFileManager defaultManager] moveItemAtPath:[path stringByAppendingPathComponent:oldName] toPath:[path stringByAppendingPathComponent:newName] error:&error];
    
    if (error){
        NSLog(@"重命名失败：%@",[error localizedDescription]);
    }
    else
    {
        NSLog(@"重命名成功：%@ -> %@", oldName, newName);
    }
    
    return result;
    
    /**
     作者：CrazySteven
     链接：https://www.jianshu.com/p/a08cf375043a
     來源：简书
     简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
     */
}


@end
