//
//  MigrationTool.m
//  DataMigration
//
//  Created by CSX on 2017/3/29.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "MigrationTool.h"
#import <FMDB.h>
#import <FMDBMigrationManager.h>


static FMDatabase *__db;
static NSString *_DBPath;

@interface MigrationTool ()

@property(nonatomic,copy)NSString * myName;
@property(nonatomic,assign)uint64_t myVersion;
@property(nonatomic,strong)NSArray * updateArray;
@end

@implementation MigrationTool

+ (void)CreateIntilizeTable{
    _DBPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    __db = [FMDatabase databaseWithPath:_DBPath];
    if ([__db open]) {
       [__db executeUpdate:@"create table if not exists qianyi(id integer primary key autoincrement,problem text not null,adress text not null,date text not null,isRead text not null);"];
    }
    [__db close];
    
}


- (instancetype)initWithName:(NSString *)name andVersion:(uint64_t)version andExecuteUpdateArray:(NSArray *)updateArray
{
    if (self=[super init]) {
        _myName=name;
        _myVersion=version;
        _updateArray=updateArray;
    }
    return self;
}

- (NSString *)name
{
    return _myName;
}

- (uint64_t)version
{
    return _myVersion;
}

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error
{
    for(NSString * updateStr in _updateArray)
    {
        [database executeUpdate:updateStr];
    }
    return YES;
}





@end
