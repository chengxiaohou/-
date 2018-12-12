//
//  Worker.h
//  ImagesetHandle
//
//  Created by fengyi on 2018/12/10.
//  Copyright © 2018 fengyi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Worker : NSObject


/** 【递归】获取路径下以及更深层次文件夹中的文件，仅文件 */
+ (NSArray *)getAllFilesByPath:(NSString *)path;
+ (NSArray *)getAllFilesByPath:(NSString *)path handle:(void (^)(NSString *name, NSString *path))handle;

/** 文件夹和文件递归 */
+ (NSArray *)getRecursiveFilesByPath:(NSString *)path;

/** 根据路径获取文件目录下所有文件（不递归） */
+ (NSArray *)getFileByPath:(NSString *)path;

/** 根据路径获取该路径下所有目录 */
+ (NSArray *)getFlodersByPath:(NSString *)path;

/** 重命名 */
+ (BOOL)renameFileName:(NSString *)oldName toNewName:(NSString *)newName floderPath:(NSString *)path;



@end

NS_ASSUME_NONNULL_END
