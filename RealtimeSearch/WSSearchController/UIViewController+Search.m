//
//  UIViewController+Search.m
//  RealtimeSearch
//
//  Created by 王燊 on 16/5/27.
//  Copyright © 2016年 王燊. All rights reserved.
//

#import "UIViewController+Search.h"
#import <objc/runtime.h>

static const char searchControllerKey;
static const char resultViewControllerKey;
static const char updateSearchResultsForSearchControllerBlockKey;
static const char willDismissSearchControllerBlockKey;

@implementation UIViewController (Search)


- (void)setTy_searchController:(UISearchController *)ty_searchController{
    
    objc_setAssociatedObject(self, &searchControllerKey, ty_searchController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (UISearchController *)ty_searchController{
    
    UISearchController *sc = objc_getAssociatedObject(self, &searchControllerKey);
    if (!sc) {
        
       sc = [[UISearchController alloc] initWithSearchResultsController:self.ty_resultViewControll];
       sc.searchResultsUpdater = self;
        sc.searchBar.delegate = self;
       sc.delegate = self;
        sc.searchBar.placeholder = @"搜索";
        self.ty_searchController = sc;

    }
    
    return sc;
}

- (void)setTy_resultViewControll:(TYResultViewController *)ty_resultViewControll{
    
        objc_setAssociatedObject(self, &resultViewControllerKey, ty_resultViewControll, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TYResultViewController *)ty_resultViewControll{
    
    TYResultViewController *rc = objc_getAssociatedObject(self, &resultViewControllerKey);
    if (!rc) {
        
        rc = [[TYResultViewController alloc] init];
        self.ty_resultViewControll = rc;
    }
    return rc;

}

- (void)setUpdateSearchResultsForSearchControllerBlock:(void (^)(UISearchController *, NSString *))updateSearchResultsForSearchControllerBlock{
    
     objc_setAssociatedObject(self, &updateSearchResultsForSearchControllerBlockKey, updateSearchResultsForSearchControllerBlock, OBJC_ASSOCIATION_COPY);
}


- (void (^)(UISearchController *, NSString *))updateSearchResultsForSearchControllerBlock{
    
  return  objc_getAssociatedObject(self, &updateSearchResultsForSearchControllerBlockKey);
}

- (void)setWillDismissSearchControllerBlock:(void (^)(UISearchController *))willDismissSearchControllerBlock{
    
     objc_setAssociatedObject(self, &willDismissSearchControllerBlockKey, willDismissSearchControllerBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UISearchController *))willDismissSearchControllerBlock{
    
    return  objc_getAssociatedObject(self, &willDismissSearchControllerBlockKey);

}


#pragma mark ---- public func ----
- (void)ty_reloadResultViewControllerWithDataSource:(NSArray *)dataSource{
    
    
    self.ty_resultViewControll.dataSource = [NSMutableArray arrayWithArray:dataSource];
     [self.ty_resultViewControll.tableView reloadData];
    
    
}


#pragma mark ---- UISearchResultsUpdating ----
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   
    if (self.updateSearchResultsForSearchControllerBlock) {
        
        self.updateSearchResultsForSearchControllerBlock(searchController,searchController.searchBar.text);
    }
}


//将要消失
- (void)willDismissSearchController:(UISearchController *)searchController{
    
    if (self.willDismissSearchControllerBlock) {
        
        self.willDismissSearchControllerBlock(searchController);
    }
    
}


@end
