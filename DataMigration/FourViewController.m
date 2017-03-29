//
//  FourViewController.m
//  DataMigration
//
//  Created by CSX on 2017/3/29.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//




/*
 步骤：1.先创建.xcdatamodeld文件，创建一个table以及column
 2.自定义的coredata准备（这里也可以使用xcode自带的）
 3.如果是自定义的记得在appdelegte.m的applicationWillTerminate:(UIApplication *)application方法里添加[[CoreDataTool new]saveContext];保存上下文
 4.insert最初的元素，添加数据库文件
 
 5.选中创建的.xcdatamodeld文件。点击Editor选择Add Model Version创建一个新的版本文件，（命名一般是原来的名字加上数字版本）这个版本生成的时候会是之前版本一样的字段column，自己添加新的字段和类型，然后选中原来创建的先创建.xcdatamodeld文件，在右边的属性栏选择第一个文件类型的图标，在Model Version模块。选择自己新建的版本model。
 6. 在自定义的coredata里面的if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {这里
      把options后面穿的参数nil修改为optionsDictionary
     添加类型条件NSDictionary *optionsDictionary = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES};
       //NSMigratePersistentStoresAutomaticallyOption   设为YES表示支持版本迁移
       //NSInferMappingModelAutomaticallyOption         设为YES表示支持版本迁移映射
       
 7.编就重新运行

 */
//参考链接http://blog.csdn.net/SoundsGood/article/details/49365491



#import "FourViewController.h"
#import "CoreDataTool.h"

@interface FourViewController ()

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    
     [[CoreDataTool shareCoreDataTool] insertWith:@"People" withData:@{@"name":@"赵云",@"age":@4800,@"adress":@"七进七出"}];
   
    UIButton *myCreateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCreateButton.frame = CGRectMake(0, 0, 100, 100);
    [myCreateButton setBackgroundColor:[UIColor grayColor]];
    [myCreateButton setTitle:@"qianyi" forState:UIControlStateNormal];
    [myCreateButton addTarget:self action:@selector(buttonChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCreateButton];
    
    
}
- (void)buttonChoose:(UIButton *)sender{
    [[CoreDataTool shareCoreDataTool] insertWith:@"People" withData:@{@"sex":@YES}];
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
