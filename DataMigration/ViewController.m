//
//  ViewController.m
//  DataMigration
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ViewController.h"
#import "DataBaseTool.h"
#import <FMDBMigrationManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //创建表
    [DataBaseTool createTable];
    
    UIButton *myCreateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCreateButton.frame = CGRectMake(0, 0, 100, 100);
    [myCreateButton setBackgroundColor:[UIColor grayColor]];
    [myCreateButton setTitle:@"qianyi" forState:UIControlStateNormal];
    [myCreateButton addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCreateButton];
    
    
}
- (void)buttonChoose:(UIButton *)sender{
    //1.fmdb数据库迁移添加字段
    DataBaseTool *tool = [DataBaseTool shareMyFMDB];
    [tool qianyi];
    
    
    //2.FMDBMigrationManager数据库迁移
    //    [self FMDBMigrationManagerSqlite];
}
- (void)FMDBMigrationManagerSqlite{
        NSString *pathStr = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    
        FMDBMigrationManager *manager = [FMDBMigrationManager managerWithDatabaseAtPath:pathStr migrationsBundle:[NSBundle mainBundle]];
        BOOL resultState = NO;
        NSError *error = nil;
        if (!manager.hasMigrationsTable) {
            resultState = [manager createMigrationsTable:&error];
        }
        //UINT64_MAX把数据库迁移到最大版本
        resultState = [manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];//迁移函数
        NSLog(@"Has `schema_migrations` table?: %@", manager.hasMigrationsTable ? @"YES" : @"NO");
        NSLog(@"Origin Version: %llu", manager.originVersion);
        NSLog(@"Current version: %llu", manager.currentVersion);
        NSLog(@"All migrations: %@", manager.migrations);
        NSLog(@"Applied versions: %@", manager.appliedVersions);
        NSLog(@"Pending versions: %@", manager.pendingVersions);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
