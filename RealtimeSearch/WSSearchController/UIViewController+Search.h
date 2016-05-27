//
//  UIViewController+Search.h
//  RealtimeSearch
//
//  Created by 王燊 on 16/5/27.
//  Copyright © 2016年 王燊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYResultViewController.h"


@interface UIViewController (Search)<UISearchResultsUpdating,UISearchBarDelegate,UISearchControllerDelegate>

@property (nonatomic,strong) UISearchController *ty_searchController;


//搜索框改变 -
@property (copy) void(^updateSearchResultsForSearchControllerBlock)(UISearchController *,NSString *);


@property (copy) void(^willDismissSearchControllerBlock)(UISearchController *);


@property (nonatomic,strong)  TYResultViewController *ty_resultViewControll;



- (void)ty_reloadResultViewControllerWithDataSource:(NSArray *)dataSource;

@end
