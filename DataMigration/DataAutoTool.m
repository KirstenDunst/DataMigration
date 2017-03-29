//
//  DataAutoTool.m
//  DataMigration
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//


/*
 *
 *
 *
 *数据库自动更新迭代
 *
 *
 *
 */


#import "DataAutoTool.h"
#import "HandleSqliteTable.h"
#import "CeShiModel.h"
#import "YuLeModel.h"
#import <FMDB.h>

@interface DataAutoTool ()
{
    HandleSqliteTable *handel;
}
@property(strong , nonatomic)NSMutableArray *modelArray;
@end

static FMDatabase *__db;

@implementation DataAutoTool

- (NSMutableArray *)modelArray{
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}


+ (instancetype)shareMyFMDB{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)qianyiAuto{
    CeShiModel *modelceshi = [[CeShiModel alloc]init];
    YuLeModel *modelyule = [[YuLeModel alloc]init];
    [self.modelArray addObject:modelceshi];
    [self.modelArray addObject:modelyule];
    handel = [[HandleSqliteTable alloc]init];
    
    
    
    
    NSString *kCacheDBPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    __db = [FMDatabase databaseWithPath:kCacheDBPath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:kCacheDBPath]) {
        __db = [FMDatabase databaseWithPath:kCacheDBPath];
        //原始最初的数据库
        if ([__db open]) {
            [__db executeUpdate:@"create table if not exists qianyi(id integer primary key autoincrement,problem text not null,adress text not null,date text not null,isRead text not null);"];
        }
        [__db close];

        //需要迭代升级的话可以在这里掉自己的方法
    }else if([self needUpdateTabelArray:self.modelArray]) {
        
        NSLog(@"数据库已经存在路径,但需要新增数据库表:%@",kCacheDBPath);
        //需要更新的表的名字
        NSArray *tabelName = [self needUpdateTable:self.modelArray];
        
        //新建数据表
        [self createNewTable:tabelName];
        
        //需要迭代升级的话可以在这里掉自己的方法
    }else if ([self needChangeTableColumnWithArr:self.modelArray]){
        NSLog(@"数据库已存在，表格也已存在，但是字段需要更新");
       //查询表里面的字段是否有新的字段添加
        for (NSObject *obj in _modelArray) {
            //获取现有model的所有属性string
            NSArray *array = [handel ivarsArrayWithModel:obj];
            //对比数据库和现有的属性sting
           [self addNewColumnWithUpdateTable:obj newAttribe:array];
        }
        
        //需要迭代升级的话可以在这里掉自己的方法
    }else{
        
        NSLog(@"数据库已经存在路径,不需要新增数据库表:%@",kCacheDBPath);
    }
}

- (NSArray *)needUpdateTable:(NSMutableArray *)dataArr{
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSObject *obj in dataArr) {
        if (![self needUpdateTabel:NSStringFromClass([obj class])]) {
            [tempArr addObject:NSStringFromClass([obj class])];
        }
    }
    return tempArr;
}

//多个表是不是要更新
- (BOOL)needUpdateTabelArray:(NSArray *)array{
    for (NSObject *obj in array) {
        NSString *string = NSStringFromClass([obj class]);
        if(![self needUpdateTabel:string]) {
            return YES;
        }
    }
    return NO;
}

//检查数据库的表是否存在  返回no表示需要数据库中插入新表，证明数据库里面没有这个表
- (BOOL)needUpdateTabel:(NSString *)tableName{
    
    BOOL need = NO;
    if ([__db open]) {
        //得到所有的表表名
        FMResultSet *rs = [__db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next])
        {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            NSLog(@"isTableOK %ld", (long)count);
            if (0 == count)
            {
                need = NO;
            }
            else
            {
                need = YES;
            }
        }
        [rs close];
        [__db close];
    }
    return need;
}

//表不存在就
//新增表
- (void)createNewTable:(NSArray *)array{
 
    for (NSObject *obj in self.modelArray ){
        
        NSString *string = NSStringFromClass([obj class]);
 
        if ([array containsObject:string]) {
            
            NSString * tableSqilet = [handel sqliteStingWithTableName:NSStringFromClass([obj class]) model:obj];
            
            [self createATable:tableSqilet];
            
        }
    }    
}
- (void)createATable:(NSString *)sqliteStr{
    if ([__db open]) {
        [__db executeUpdate:sqliteStr];
    }
    [__db close];
}



//检查表里边的字段需不需要更新，去现在有的model的属性和数据库中的比较找出需要更新的字段
//自动更新机制 表的对应的model变化，需要对表做相应的增加和删除操做
- (BOOL)needChangeTableColumnWithArr:(NSArray *)dataArr{
    BOOL isneed = NO;
    for (NSObject *obj in _modelArray) {
        //获取现有model的所有属性string
        NSArray *array = [handel ivarsArrayWithModel:obj];
        //对比数据库和现有的属性sting
        if ([self checkAndUpdateTable:obj newAttribe:array]) {
            isneed = YES;
        }
    }
    return isneed;
}



//判断新老表中有没有新增字段    yes表示有，no表示没有
- (BOOL)checkAndUpdateTable:(NSObject*)objName newAttribe:(NSArray *)newAttribe{
    
    //数据库中现有的字段
    NSMutableArray *sqliteArray = [NSMutableArray array];
    NSString *tableName = NSStringFromClass([objName class]);
    if ([__db open]) {
        
        NSString * sql = [NSString stringWithFormat:@"select * from %@",tableName] ;
        
        FMResultSet * rs = [__db executeQuery:sql];
        
        NSDictionary * dict =   [rs columnNameToIndexMap];
        
        [sqliteArray addObjectsFromArray:[dict allKeys]];
        
        [__db close];
        
    }
    
    //需要更新的字段
    NSMutableArray *needUpdateName =[NSMutableArray array];
    
    for (NSString *string in newAttribe) {
        //字符串的uppercaseString、lowercaseString、capitalizedString属性来访问一个字符串的大写/小写/首字母大写
        NSString * lowercaseString = [string lowercaseString];
        
        if (![sqliteArray containsObject:lowercaseString]) {
            
            [needUpdateName addObject:string];
            
        }
        
    }
    
    if (needUpdateName.count>0) {
        return YES;
    }else{
        return NO;
    }
}

//增加新的表字段
- (void)addNewColumnWithUpdateTable:(NSObject*)objName newAttribe:(NSArray *)newAttribe{
    //数据库中现有的字段
    NSMutableArray *sqliteArray = [NSMutableArray array];
    NSString *tableName = NSStringFromClass([objName class]);
    if ([__db open]) {
        
        NSString * sql = [NSString stringWithFormat:@"select * from %@",tableName] ;
        
        FMResultSet * rs = [__db executeQuery:sql];
        
        NSDictionary * dict =   [rs columnNameToIndexMap];
        
        [sqliteArray addObjectsFromArray:[dict allKeys]];
        
        [__db close];
        
    }
    
    //需要更新的字段
    
    NSMutableArray *needUpdateName =[NSMutableArray array];
    
    for (NSString *string in newAttribe) {
        
        NSString * lowercaseString = [string lowercaseString];
        
        if (![sqliteArray containsObject:lowercaseString]) {
            
            [needUpdateName addObject:string];
            
        }
        
    }
    
    if (needUpdateName.count > 0) {
        
        NSArray *array = [handel attribleArray:needUpdateName model:objName];
        //更新
        [self updateTabelupdateString:array tableName:tableName];
        
    }
    
}
- (void)updateTabelupdateString:(NSArray *)updateArray tableName:(NSString *)tableName{
    
    if ([__db open]) {
        
        for (NSString *updateString in updateArray) {
            
            NSString* SysMessageSql = [NSString stringWithFormat:@"alter table %@ add %@",tableName,updateString];
            
            BOOL resSysMessage = [__db executeUpdate:SysMessageSql];
            
            if (resSysMessage) {
                
                NSLog(@"新增%@表字段%@成功",tableName,updateString);
                
            }else{
                
                NSLog(@"新增%@表字段%@失败",tableName,updateString);
                
            }
            
        }
        
        [__db close];
        
    }
    
}




//这就完成了9成的更新功能。

//还有一成更新表的增删改查语句。同样的道理更新数据库语句.......

@end
