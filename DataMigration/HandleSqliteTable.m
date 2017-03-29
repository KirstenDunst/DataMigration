//
//  HandleSqliteTable.m
//  DataMigration
//
//  Created by CSX on 2017/3/28.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//




/*
 *
 *
 *数据库的迁移无非是：
 1.新增数据库（没有路径的情况）
 2.新增表
 3.增加字段
 4.删除字段（sqlit3不支持字段的删除）
 *
 *
 */



#import "HandleSqliteTable.h"
#import <objc/runtime.h>


@implementation HandleSqliteTable

//-----------------------数据库语句的拼接.m文件

//数据库拼接
- (NSString *)sqliteStingWithTableName:(NSString *)tableName model:(NSObject *)model{
    
    NSMutableDictionary *tempDic = [self AllPropertyAndTypeDicWithModel:model];
    NSArray *_ivarsArray = [tempDic allKeys];
    
    NSArray *_typeArray = [tempDic allValues];
    
    return  [self complatSqiteAttribiteA:_ivarsArray typeA:_typeArray tableName:tableName];
}

/**
 *  获取 model 中的所有属性数组
 *  model      需要缓存的对象
 */
- (NSArray *)ivarsArrayWithModel:(NSObject *)model{
    ///存储所有的属性名称
    NSMutableArray *allNames = [[NSMutableArray alloc] init];
    ///存储属性的个数
    unsigned int propertyCount = 0;
    ///通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([model class], &propertyCount);
    //把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        ///取出第一个属性
        objc_property_t property = propertys[i];
        const char * propertyName = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    //释放
    free(propertys);
    return allNames;
}


- (NSString *)complatSqiteAttribiteA:(NSArray *)attribiteA typeA:(NSArray *)typeA tableName:(NSString *)tableName{
    NSString *string = [NSString stringWithFormat:@"CREATE TABLE %@ (id integer PRIMARY KEY NOT NULL",tableName];
    NSString *beginString = @"";
    for (int i = 0; i < attribiteA.count;i ++) {
        NSString *atAndType = [self sqiteStringAttribite:(NSString *)attribiteA[i] type:(NSString *)typeA[i]];
        beginString = [beginString stringByAppendingString:atAndType];
    }
    return [NSString stringWithFormat:@"%@ %@)",string,beginString];
}


/**
 *  数据库语句拼接
 */

- (NSString *)sqiteStringAttribite:(NSString *)attribite type:(NSString *)type{
    
    return [NSString stringWithFormat:@", %@ %@ ",attribite,type];
    
}


/*
 
 *获取属性的类型,并转化为c的类型,并进行拼接
 
 *返回数组包含字符串样式 ：字段名 类型
 
 */
- (NSArray *)attribleArray:(NSArray *)attribleArray model:(NSObject *)model{
    NSMutableDictionary *nameTypeDic = [self AllPropertyAndTypeDicWithModel:model];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSString *string in attribleArray) {
        [tempArr addObject:[NSString stringWithFormat:@"%@ %@",string,nameTypeDic[string]]];
    }
    return tempArr;
}

/**
 *  获取 model 中的所有属性类型数组
 *  model      需要缓存的对象
 */
- (NSMutableDictionary *)AllPropertyAndTypeDicWithModel:(NSObject *)model{
    uint propertyCount;
    objc_property_t *ps = class_copyPropertyList([model class], &propertyCount);
    NSMutableDictionary* results = [[NSMutableDictionary alloc]initWithCapacity:propertyCount];
    for (uint i = 0; i < propertyCount; i++) {
        objc_property_t property = ps[i];
        const char *propertyAttributes = property_getAttributes(property);
        const char *propertyName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        NSString* type = [NSString stringWithUTF8String:propertyAttributes];
        NSLog(@">>>>>>>>>>>>>>类型的初始状态:%@",type);
        
        type = [self repleaceStringWithCSting:[[[[type componentsSeparatedByString:@"T"] lastObject] componentsSeparatedByString:@","] firstObject]];
        NSLog(@"<<<<<<<<<<<<<转换后的类型输出：%@",type);
        [results setValue:type forKey:name];
    }
    return results;
}

- (NSString *)repleaceStringWithCSting:(NSString *)cSting{
    
    if (![cSting isEqualToString:@""]) {
        
        if ([cSting isEqualToString:@"i"]) {
            
            return @"int";
            
        }else if([cSting isEqualToString:@"q"]){
            
            return @"double";
            
        }else if([cSting isEqualToString:@"f"]){
            
            return @"float";
            
        }else if([cSting isEqualToString:@"d"]){
            
            return @"double";
            
        }else if([cSting isEqualToString:@"B"]){
            
            return @"int";
            
        }else if([cSting containsString:@"NSString"]){
            
            return @"text";
            
        }else if([cSting containsString:@"NSNumber"]){
            
            return @"long";
            
        }
        
        NSAssert(1, @"handleSqliteTable类中 model的属性状态不对导致数据库状态不对，请核对后再拨");
        
        return @"未知";
        
    }else return nil;
    
}

@end
