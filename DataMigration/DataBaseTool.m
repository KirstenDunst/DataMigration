//
//  DataBaseTool.m
//  DataBaseMigrate
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//



/*
 *
 *
 *
 *
 *手动更新数据库
 *
 *
 *
 *
 *
 */



#import "DataBaseTool.h"

#import <FMDatabase.h>

static  FMDatabase *__db;

#define kCurrentSqliteVersion 3  //当前数据库的版本号，这里用作声明一个，实际中可应用本地存储一个

@interface DataBaseTool ()
@property(copy , nonatomic)NSString *dbPath;
@end


@implementation DataBaseTool

+ (void)createTable{
    NSString *pathStr = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    
    __db = [FMDatabase databaseWithPath:pathStr];
    if ([__db open]) {
        [__db executeUpdate:@"create table if not exists qianyi(id integer primary key autoincrement,problem text not null,adress text not null,date text not null,isRead text not null);"];
    }
    [__db close];
}


+ (instancetype)shareMyFMDB{
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        
        instance = [self new];
    });
    
    return instance;
}

- (void)qianyi{
    //依次类推
     self.dbPath =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    NSInteger oldSqliteVer = 1;
    [self upgrade:oldSqliteVer];    //更新数据库内容
}




//然后用递归的方式更新
- (void)upgrade:(NSInteger)oldVersion{
   
    
    if (oldVersion >= kCurrentSqliteVersion) {
        return;
    }
    switch (oldVersion) {
        case 0:
            [self upgradeFrom0To1];
            [self insertSqliteVersion:kCurrentSqliteVersion];   //版本号更新需要放在更新数据库内容之后，在没有版本号的数据库版本中，需要在upgrade的地方去创建version表
            break;
            
        case 1: //从1版本升级到2版本
            [self upgradeFrom1To2];
            [self insertSqliteVersion:kCurrentSqliteVersion];   //版本号更新需要放在更新数据库内容之后，在没有版本号的数据库版本中，需要在upgrade的地方去创建version表
            break;
            
        case 2: //版本拓展：以后若有增加则持续增加
            [self upgradeFrom2To3];
            [self insertSqliteVersion:kCurrentSqliteVersion];   //版本号更新需要放在更新数据库内容之后，在没有版本号的数据库版本中，需要在upgrade的地方去创建version表
            break;
            
        case 3: //版本拓展：以后若有增加则持续增加            
            [self upgradeFrom3To4];
            [self insertSqliteVersion:kCurrentSqliteVersion];   //版本号更新需要放在更新数据库内容之后，在没有版本号的数据库版本中，需要在upgrade的地方去创建version表
            break;
            
        default:
            
            break;
    }
    oldVersion ++;
    // 递归判断是否需要升级：保证老版本从最低升级到当前
    [self upgrade:oldVersion];
}
- (void)insertSqliteVersion:(NSInteger)currentSqliteVersion{
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",currentSqliteVersion] forKey:@"sqliteVer"];
}
- (void)upgradeFrom0To1{
    NSLog(@"从0版本升级到1版本");
}
- (void)upgradeFrom1To2 {
    //这里执行Sql语句 执行版本1到版本2的更新
//    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    
    NSNumber *userId = @1;
//    [NSNumber numberWithLongLong:[UserManeger shareInstance].currentUser.uid];
    
    if ([__db open]) {
        //添加字段以及默认值属性 如果存在这个字段则返回no添加不了，如果返回yes则证明没有这个字段并且添加字段成功
        NSString* SysMessageSql = [NSString stringWithFormat:@"alter table qianyi add SysMessageSql1 int default %@",userId];
        //
        NSString* importSql = [NSString stringWithFormat:@"alter table qianyi rename column importSql to importSql2;"];
        NSString* importChatSql = [NSString stringWithFormat:@"ALTER TABLE qianyi DROP COLUMN importChatSql;"];
        BOOL resSysMessage = [__db executeUpdate:SysMessageSql];
        if (resSysMessage) {
            NSLog(@"更新方法resSysMessage成功");
        }else{
            NSLog(@"更新方法resSysMessage失败");
        }
        BOOL res = [__db executeUpdate:importSql];
        if (res) {
            NSLog(@"更新方法res成功");
        }else{
            NSLog(@"更新方法res失败");
        }
        BOOL resChat = [__db executeUpdate:importChatSql];
        if (resChat) {
            NSLog(@"更新方法resChat成功");
        }else{
            NSLog(@"更新方法resChat失败");
        }
        [__db close];
    }
    
     NSLog(@"从1版本升级到2版本");
}
- (void)upgradeFrom2To3{
     NSLog(@"从2版本升级到3版本");
}
- (void)upgradeFrom3To4{
     NSLog(@"从3版本升级到4版本");
}

@end
