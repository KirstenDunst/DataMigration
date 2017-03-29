//
//  CoreDataTool.m
//  CoreDataDemo02
//
//  Created by Mac on 16/7/1.
//  Copyright © 2016年 Happy. All rights reserved.
//




//创建工程的时候不勾选CoreData，生成此文件，我们这里用来高仿生成类似CoreData工程（这个CoreDataTool是把之前自动生成的AppDelegate里面的CoreData代码粘过来的）


//newFile----ios-----CoreData------DataModel----文件名（这里命名为CoreDataDemo02）----（这里就生成了：CoreDataDemo02.xcdatamodeld）







#import "CoreDataTool.h"
#import <objc/runtime.h>
//1.导入coreData文件
#import <CoreData/CoreData.h>

@interface CoreDataTool ()
//2.把三个属性写好
//上下文对象
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//数据模型对象
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//持久化存储区
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation CoreDataTool


- (void)updateToTable:(NSString *)tableName withPredicate:(NSPredicate *)predicate withUpdateBlock:(UpdateBlock)update {
    if (!tableName) {
        return;
    }
    //断言(只要不满足条件就会崩溃)
    NSAssert(predicate != nil, @"predicate参数不能为空");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects) {
        if (update) {
            update(fetchedObjects);
        }
    }
    
    [self saveContext];
    
}


- (void)insertToTable:(NSString *)tableName WithBlock:(InsertBlock)block withError:(ErrorBlock)error {
    if (tableName == nil||block == nil ) {
        return;
    }else {
        NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
        
        block(obj);
//        [self saveContext];
        NSError *myError = nil;
        [self.managedObjectContext save:&myError];
        
        if (error && myError) {
            error(myError);
        }
        
    }
}



- (BOOL)insertWith:(NSString *)tableName withData:(NSDictionary *)data {
    
    if (!tableName || !data) {
        return NO;
    }
    
    //1.获得实体
    NSManagedObject *objc = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    //2.给对象赋值
    [objc setValuesForKeysWithDictionary:data];
    
    
    //3.保存上下文
    [self saveContext];
    
    return YES;
}





static CoreDataTool *_coreDataTool;
#pragma mark----单例的初始化方法
+ (instancetype)shareCoreDataTool {

   static dispatch_once_t  onceToken;
    
    dispatch_once(&onceToken, ^{
        _coreDataTool = [[CoreDataTool alloc]init];
    });
    
    return _coreDataTool;
}

+ (instancetype)alloc {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreDataTool = [super alloc];
    });
    return _coreDataTool;
}





//3.把需要配置好的属性和方法配置好
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.qp.PredicateDemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataMigrate" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"People.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *optionsDictionary = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES};
    //NSMigratePersistentStoresAutomaticallyOption   设为YES表示支持版本迁移
    //NSInferMappingModelAutomaticallyOption         设为YES表示支持版本迁移映射
    /*
     *参数options在修改版本迁移的时候填入optionsDictionary
     *之前用coredata创建数据库的时候 参数没有写入设为nil
     */
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}







@end
