//
//  TYRealTimeSearchUtil.m
//  WJSQ
//
//  Created by TYRBL on 16/5/27.
//  Copyright © 2016年 Senro Wang. All rights reserved.
//

#import "TYRealTimeSearchUtil.h"
#import "YYClassInfo.h"

@interface TYRealTimeSearchUtil ()

@property (strong, nonatomic) id source;

@property (nonatomic,strong) NSArray *searchPropertys;

@property (nonatomic,copy) NSString *modelClassName;

@property (copy, nonatomic) RealtimeSearchResultsBlock resultBlock;


@property (nonatomic,weak) id target; //

@property (nonatomic) SEL selector; // 方法选择器

@property (nonatomic,assign) BOOL isSearchWithSelector; //是不是带有方法选择器的搜索


@property (nonatomic,copy) NSString *searchText;


/**
 *  当前搜索线程
 */
@property (strong, nonatomic) NSThread *searchThread;
/**
 *  搜索线程队列
 */
@property (strong, nonatomic) dispatch_queue_t searchQueue;


@end


@implementation TYRealTimeSearchUtil

+ (instancetype)shareRealTimeSearchUtil{
    
    
    static TYRealTimeSearchUtil *s_searchUtil = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        s_searchUtil = [[TYRealTimeSearchUtil alloc] init];
    });
    return s_searchUtil;
}


- (instancetype)init{
    
    if (self = [super init]) {
        
        _searchQueue = dispatch_queue_create("cn.TYRealtimeSearch.queue", NULL);

    }
    return self;
}




#pragma mark - public -

- (void)realtimeSearchWithSource:(id)source searchText:(NSString *)searchText searchPropertys:(NSArray *)searchPropertys modelClassName:(NSString *)modelClassName resultBlock:(RealtimeSearchResultsBlock)resultBlock{
    
    if (!source || !searchText || !searchText.length || !resultBlock) {
        if (resultBlock) {
            resultBlock(source);
        }
        return;
    }

    _isSearchWithSelector = NO;
    _source = [NSArray arrayWithArray:source];
    _modelClassName = modelClassName;
    _searchPropertys = [NSArray arrayWithArray:searchPropertys];
    _resultBlock = resultBlock;
    
    [self realtimeSearch:searchText];
    
    
    
    
}


- (void)realtimeSearchWithSourceIds:(id)source searchText:(NSString *)searchText target:(id)target collationElementSelector:(SEL)selector searchPropertys:(NSArray *)searchPropertys resultBlock:(RealtimeSearchResultsBlock)resultBlock{
    
    if (!source || !searchText || !searchText.length || !resultBlock || !target) {
        if (resultBlock) {
            resultBlock(source);
        }
        return;
    }
    _source = [NSArray arrayWithArray:source];
    _target= target;
    _selector = selector;
    _isSearchWithSelector = YES;
    _searchPropertys = [NSArray arrayWithArray:searchPropertys];
    _resultBlock = resultBlock;
    
    [self realtimeSearch:searchText];

    
}

/**
 * 结束搜索，只需要调用一次，在[realtimeSearchBegin...:]之后使用，主要用于释放资源
 */
- (void)realtimeSearchStop{
    
    [self.searchThread cancel];
}



#pragma mark -- private func ---

- (void)realtimeSearch:(NSString *)string
{
    [self.searchThread cancel];
    
    //开启新线程
    self.searchThread = [[NSThread alloc] initWithTarget:self selector:@selector(searchBegin:) object:string];
    [self.searchThread start];
}




- (void)searchBegin:(NSString *)string
{
    
    self.searchText =string ;
  
    if (self.isSearchWithSelector) {
        
        //需要通过 target 返回 数据模型进行匹配
        
        [self _searchModeWithSelector];
        
        
    }else{
        
        
        //source 中就是数据模型可直接进行检索
        [self _searchModeWtithoutSelector];
        
    }
    
    
    DLog(@"开始搜索");
    
}


// 带有  select 的搜索模式
- (void)_searchModeWithSelector{
    
    id object = [self.source firstObject];

    if ([object isKindOfClass:[NSString class]]) {
        
        //开始搜索
        
        [self _searchSubModeSelector_String];
        
    }else{
        
        DLog(@"这种搜索模式下 source 只能是 含有字符串元素的 数组");
        if (self.resultBlock) {
            
            self.resultBlock(self.source);
        }
        return ;
    }
    
}


//没有  select 的搜索模式
- (void)_searchModeWtithoutSelector{
    
    id object = [self.source firstObject];

    NSString *objClassName = NSStringFromClass([object class]);
    if (self.modelClassName && [self.modelClassName  isEqualToString: objClassName]) {
        
        //    按照模型那样搜索
        YYClassInfo *classInfo = [YYClassInfo classInfoWithClassName:objClassName];
        
        BOOL isIn = [self _judgeStringArray1:self.searchPropertys isInArray2:[classInfo.propertyInfos allKeys]];
        if (isIn) {
            
            //开始搜索
            
            [self _searchSubModeModelWithSource:self.source];
            
        }else{
            
            DLog(@"属性名数组输入有误");
            return ;
        }
        
        
    }else{
        
        if ([object isKindOfClass:[NSString class]]) {
            //按照字符串那样搜索
            
            [self _searchSubModeStringWithSource:self.source];
            
        }else if ([object isKindOfClass:[NSDictionary class]]) {
            //按照字典那样搜索
            BOOL isIn = [self _judgeStringArray1:self.searchPropertys isInArray2:[object allKeys]];
            if (isIn) {
                
                //开始搜索
                [self _searchSubModeDictionaryWithSource:self.source];
                
            }else{
                
                DLog(@"属性名数组输入有误");
                return ;
            }

            
        }else{
            
            //未定义的搜索方式 －
            DLog(@"数据源输入有误，source 元素应为 NSString NSDictionary 自定义模型");

            
        }
        
    }

}




#pragma mark ---- 四种搜索方式 （字符串 ， 模型 ，字典  ， 以及selctor） ----

- (void)_searchSubModeStringWithSource:(NSArray *)source{
    
    NSMutableArray *resultArray = @[].mutableCopy;
    for (NSString *string in self.source) {
        
        BOOL isIn = [self _realtimeSearchString:self.searchText fromString:string];
        if (isIn) {
            
            [resultArray addObject:string];
        }
    }
    
    if (self.resultBlock) {
        
        self.resultBlock(resultArray);
    }
    
    
    
}

- (void)_searchSubModeModelWithSource:(NSArray *)source{
    
    NSMutableArray *resultArray = @[].mutableCopy;

    for (id obj in self.source) {
        
        
            BOOL isIn = NO;
            for (NSString *key in self.searchPropertys) {
                
                NSString *value = [obj valueForKey:key];
                
                if ([self _realtimeSearchString:self.searchText fromString:value]) {
                    
                    isIn = YES;
                    break ;
                }
            }

        if (isIn) {
            
            [resultArray addObject:obj];
        }
        
    }
    
    
    
    if (self.resultBlock) {
        
        self.resultBlock(resultArray);
    }

}


- (void)_searchSubModeDictionaryWithSource:(NSArray *)source{
    
    NSMutableArray *resultArray = @[].mutableCopy;
    for (NSDictionary *dictionary in source) {
        
        BOOL isIn = NO;
        for (NSString *key in self.searchPropertys) {
            
            NSString *value = [dictionary objectForKey:key];
            
            if ([self _realtimeSearchString:self.searchText fromString:value]) {
                
                isIn = YES;
                break ;
            }
        }
        
        if (isIn) {
            
            [resultArray addObject:dictionary];
        }

    }
    
    if (self.resultBlock) {
        
        self.resultBlock(resultArray);
    }

}

- (void)_searchSubModeSelector_String{
    
    NSMutableArray *resultArray = @[].mutableCopy;

    for (NSString *string in self.source) {
        
        if([self.target respondsToSelector:self.selector]){
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          id object =   [self.target performSelector:self.selector withObject:string];
#pragma clang diagnostic pop

            BOOL isIN = NO;
            if ([object isKindOfClass:[NSString class]]) { //字符串
                
                isIN = [self _realtimeSearchString:self.searchText fromString:object];
                if (isIN) {
                    
                    [resultArray addObject:string];
                 }
            
                continue ;
                
                
            }else if([object isKindOfClass:[NSDictionary class]]){ //字典
                BOOL isIN = NO;

                for (NSString *key in self.searchPropertys) {
                    
                    NSString *value = [object objectForKey:key];
                    
                    if ([self _realtimeSearchString:self.searchText fromString:value]) {
                        
                        isIN = YES;
                        break ;
                    }
                }
                
                if (isIN) {
                    
                    [resultArray addObject:string];
                }
                
                continue ;
            }else{  //模型
                
                
                BOOL isIN = NO;
                
                for (NSString *key in self.searchPropertys) {
                    
                    NSString *value = [object valueForKey:key];
                    
                    if ([self _realtimeSearchString:self.searchText fromString:value]) {
                        
                        isIN = YES;
                        break ;
                    }
                }
                
                if (isIN) {
                    
                    [resultArray addObject:string];
                }

                
            }
            
        }else{
            
            DLog(@"没有实现 selector ");
            return ;
        }
        
    }
    
    
    
    if (self.resultBlock) {
        
        self.resultBlock(resultArray);
    }

}












/**
 *  从fromString中搜索是否包含searchString
 *
 *  @param searchString 要搜索的字串
 *  @param fromString   从哪个字符串搜索
 *
 *  @return 是否包含字串
 */
- (BOOL)_realtimeSearchString:(NSString *)searchString fromString:(NSString *)fromString
{
    if (!searchString || !fromString || !searchString.length || (fromString.length == 0 && searchString.length != 0)) {
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchString.lowercaseString];
   return   [predicate evaluateWithObject:fromString];
    
    
//    NSUInteger location = [[fromString lowercaseString] rangeOfString:[searchString lowercaseString]].location;
//    return (location == NSNotFound ? NO : YES);
}


//判断某一个数组中的元素 是不是  包含在 另一个数组中 （元素为字符串）
- (BOOL )_judgeStringArray1:(NSArray *)array1 isInArray2:(NSArray *)array2{
    
    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"SELF in %@",array2];
    NSArray *resultArray = [array1 filteredArrayUsingPredicate:thePredicate];
    
    //如果不等的话  说明  数组一中的某些元素不在数组二 中
    return resultArray.count == array1.count;

}
@end
