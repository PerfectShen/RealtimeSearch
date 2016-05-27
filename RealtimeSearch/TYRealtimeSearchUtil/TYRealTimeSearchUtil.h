//
//  TYRealTimeSearchUtil.h
//  WJSQ
//
//  Created by TYRBL on 16/5/27.
//  Copyright © 2016年 Senro Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RealtimeSearchResultsBlock)(NSArray *results);


@interface TYRealTimeSearchUtil : NSObject


/**
 *  实时搜索单例实例化
 *
 *  @return 实时搜索单例
 */

+ (instancetype)shareRealTimeSearchUtil;





/**
 *  开始搜索，与[realtimeSearchStop]配套使用
 *
 *  @param source      要搜索的数据源 (一组模型 ，字典 ，或者字符串)
 *  @param searchText  要搜索的字符串
 *  @param searchPropertys    要进行匹配的属性名
 *  @param modelClassName 数组中的模型名
 *  @param resultBlock 回调方法，返回搜索结果
 */
- (void)realtimeSearchWithSource:(id)source searchText:(NSString *)searchText searchPropertys:(NSArray *)searchPropertys modelClassName:(NSString *)modelClassName resultBlock:(RealtimeSearchResultsBlock)resultBlock;




/**
 *  开始搜索，与[realtimeSearchStop]配套使用
 *
 *  @param source      要搜索的数据源 (一组模型的id数组)
 *  @param target       获得 target (这个类实现返回模型的方法)
 *  @param searchText  要搜索的字符串
 *  @param modelClassName 要进行匹配的属性名
 *  @param selector    获取某一个元素的方法
 *  @param resultBlock 回调方法，返回搜索结果
 */
- (void)realtimeSearchWithSourceIds:(id)source searchText:(NSString *)searchText target:(id)target collationElementSelector:(SEL)selector searchPropertys:(NSArray *)searchPropertys resultBlock:(RealtimeSearchResultsBlock)resultBlock;


/**
 * 结束搜索，只需要调用一次，在[realtimeSearchBegin...:]之后使用，主要用于释放资源
 */
- (void)realtimeSearchStop;

@end
