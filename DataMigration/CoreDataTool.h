//
//  CoreDataTool.h
//  CoreDataDemo02
//
//  Created by Mac on 16/7/1.
//  Copyright © 2016年 Happy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  NSManagedObject;

typedef void(^InsertBlock)(id obj);

typedef void(^ErrorBlock)(NSError *error);

typedef void(^UpdateBlock)(NSArray *fetchedObjects);

@interface CoreDataTool : NSObject

//保存CoreData上下文
- (void)saveContext;

//单例的初始化方法
+ (instancetype)shareCoreDataTool;

//插入数据
- (BOOL)insertWith:(NSString *)tableName withData:(NSDictionary *)data;

//Block版本的插入数据，block体用于填写需要插入的数据
- (void)insertToTable:(NSString *)tableName WithBlock:(InsertBlock)block withError:(ErrorBlock)error;

//更新数据Block版本
- (void)updateToTable:(NSString *)tableName withPredicate:(NSPredicate *)predicate withUpdateBlock:(UpdateBlock)update;




@end
