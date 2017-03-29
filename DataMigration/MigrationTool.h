//
//  MigrationTool.h
//  DataMigration
//
//  Created by CSX on 2017/3/29.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDBMigrationManager.h>

@interface MigrationTool : NSObject<FMDBMigrating>

//创建初始的数据库，也就是将要进行升级操作的数据库
+ (void)CreateIntilizeTable;


- (instancetype)initWithName:(NSString *)name andVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray;//自定义方法

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;



@end
