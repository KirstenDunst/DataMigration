//
//  ThirdViewController.m
//  DataMigration
//
//  Created by CSX on 2017/3/29.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "ThirdViewController.h"
#import "MigrationTool.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MigrationTool CreateIntilizeTable];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIButton *myCreateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCreateButton.frame = CGRectMake(0, 0, 100, 100);
    [myCreateButton setBackgroundColor:[UIColor orangeColor]];
    [myCreateButton setTitle:@"qianyi" forState:UIControlStateNormal];
    [myCreateButton addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCreateButton];
    
}

- (void)buttonChoose:(UIButton *)sender{
    NSString *DBPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.sqlite"];
    NSLog(@"%@",DBPath);
    //DBPath是要升级的数据库的地址
    // [NSBundle mainBundle]是保存数据库升级文件的位置 根据自己放文件的位置定 升级文件是什么下面会说
    FMDBMigrationManager * manager = [FMDBMigrationManager managerWithDatabaseAtPath:DBPath migrationsBundle:[NSBundle mainBundle]];
    
    MigrationTool * migration_1=[[MigrationTool alloc]initWithName:@"新增USer表" andVersion:1 andExecuteUpdateArray:@[@"create table User(name text,age integer,sex text,phoneNum text)"]];
    [manager addMigration:migration_1];
    
    MigrationTool * migration_2=[[MigrationTool alloc]initWithName:@"USer表新增字段email" andVersion:2 andExecuteUpdateArray:@[@"alter table User add email text"]];
    [manager addMigration:migration_2];
    
    //以后还想升级，在加入一个新的自定义对象，注意！！！版本号要保持递增
    MigrationTool * migration_3=[[MigrationTool alloc]initWithName:@"USer表新增字段address" andVersion:3 andExecuteUpdateArray:@[@"alter table User add address text"]];
    [manager addMigration:migration_3];
    
    
    BOOL resultState=NO;
    NSError * error=nil;
    if (!manager.hasMigrationsTable) {
        resultState=[manager createMigrationsTable:&error];
    }
    
    //UINT64_MAX 表示升级到最高版本
    resultState=[manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
