//
//  DataBaseTool.h
//  DataBaseMigrate
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataBaseTool : NSObject

+ (void)createTable;

//创造单例
+ (instancetype)shareMyFMDB;

- (void)qianyi;
@end
