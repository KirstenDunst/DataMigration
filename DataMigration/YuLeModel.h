//
//  yule.h
//  DataMigration
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YuLeModel : NSObject
@property(copy , nonatomic)NSString *name;
@property(assign , nonatomic)int age;
@property(assign , nonatomic)double salary;
@property(strong , nonatomic)NSNumber *ranke;
@end
