//
//  DataAutoTool.h
//  DataMigration
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataAutoTool : NSObject

//创造单例
+ (instancetype)shareMyFMDB;

- (void)qianyiAuto;

@end
