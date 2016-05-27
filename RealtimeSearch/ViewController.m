//
//  ViewController.m
//  RealtimeSearch
//
//  Created by 王燊 on 16/5/27.
//  Copyright © 2016年 王燊. All rights reserved.
//

#import "ViewController.h"
#import "StudentModel.h"
#import "UIViewController+Search.h"
#import "TYRealTimeSearchUtil.h"

static NSString *cellIdent = @"cellident";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *resultArray;



@property (nonatomic,strong) NSArray *modelIds;


@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.dataSource = @[].mutableCopy;
        self.resultArray = @[];
        self.modelIds = @[].mutableCopy;
        
        //搜索普通字符串
        
//        for (NSInteger i = 0; i < 20; i ++ ) {
//            
//            NSString *string = [NSString stringWithFormat:@"%zd",i];
//            [self.dataSource addObject:string];
//        }
        
        //搜索 模型
        
        StudentModel *s1 = [[StudentModel alloc] init];
        s1.num = @"1000";
        s1.name = @"jack";
        s1.zone = @"hangzhou";
        
        StudentModel *s2 = [[StudentModel alloc] init];
        s2.num = @"1001";
        s2.name = @"tom";
        s2.zone = @"zhengzhou";
        
        StudentModel *s3 = [[StudentModel alloc] init];
        s3.num = @"1002";
        s3.name = @"rose";
        s3.zone = @"beijing";
        
        StudentModel *s4 = [[StudentModel alloc] init];
        s4.num = @"1003";
        s4.name = @"john";
        s4.zone = @"hefei";
        
        StudentModel *s5 = [[StudentModel alloc] init];
        s5.num = @"1004";
        s5.name = @"jack";
        s5.zone = @"hangzhou";
        
        StudentModel *s6 = [[StudentModel alloc] init];
        s6.num = @"1005";
        s6.name = @"xiaohong";
        s6.zone = @"kuniing";
        
        StudentModel *s7 = [[StudentModel alloc] init];
        s7.num = @"1006";
        s7.name = @"xiaoming";
        s7.zone = @"nanjing";
        
        StudentModel *s8 = [[StudentModel alloc] init];
        s8.num = @"1007";
        s8.name = @"runfa";
        s8.zone = @"hongkong";
        
        self.dataSource = [NSMutableArray arrayWithObjects:s1,s2,s3,s4,s5,s6,s7,s8, nil];
        
        //target action 设置搜索的 model
        self.modelIds = [NSMutableArray arrayWithObjects:s1.num,s2.num,s3.num,s4.num,s5.num,s6.num,s7.num,s8.num, nil];
        
        
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.ty_searchController.searchBar;
    self.navigationItem.title = @"RealtimeSearch";
    
    [self _configSearch];
}


#pragma mark ---- getter ----
- (UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        
    }
    return _tableView;
}

#pragma mark ---- private ----
- (void)_configSearch{
    
    
    __weak ViewController *weakSelf = self;
    
    [self setUpdateSearchResultsForSearchControllerBlock:^(UISearchController *searchController, NSString *text) {
//        [weakSelf ws_reloadResultViewControllerWithDataSource:self.dataSource];
        DLog(@"%@",text);
        //搜索普通字符串
//        [[TYRealTimeSearchUtil shareRealTimeSearchUtil] realtimeSearchWithSource:weakSelf.dataSource searchText:text searchPropertys:@[] modelClassName:nil resultBlock:^(NSArray *results) {
//            
//            weakSelf.resultArray = results;
//            [weakSelf ty_reloadResultViewControllerWithDataSource:results];
//            
//        }];
        
        //搜索模型
//        [[TYRealTimeSearchUtil shareRealTimeSearchUtil] realtimeSearchWithSource:weakSelf.dataSource searchText:text searchPropertys:@[@"num",@"name",@"zone"] modelClassName:@"StudentModel" resultBlock:^(NSArray *results) {
//            
//                weakSelf.resultArray = results;
//                [weakSelf ty_reloadResultViewControllerWithDataSource:results];
//        }];
        
        //target action 设置搜索的 model

        [[TYRealTimeSearchUtil shareRealTimeSearchUtil] realtimeSearchWithSourceIds:weakSelf.modelIds searchText:text target:weakSelf collationElementSelector:@selector(modelById:) searchPropertys:@[@"zo"] resultBlock:^(NSArray *results) {
            
                            weakSelf.resultArray = results;
                            [weakSelf ty_reloadResultViewControllerWithDataSource:results];

        }];
        
    }];
    
    [self setWillDismissSearchControllerBlock:^(UISearchController *searchController) {
        
        [[TYRealTimeSearchUtil shareRealTimeSearchUtil] realtimeSearchStop];
    }];
    
    
    [self.ty_resultViewControll setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
        
        static NSString *ident = @"searchCell";
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:ident];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
        }
        //搜索 字符串
//        cell.textLabel.text = weakSelf.resultArray[indexPath.row];
        
        //搜索模型
//        StudentModel *model = weakSelf.resultArray[indexPath.row];
        
//        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@-%@",model.num,model.name,model.zone];
        
        //通过 target action 实现 -
        
        NSString *string = weakSelf.resultArray[indexPath.row];
        StudentModel *model = [weakSelf modelById:string];
        cell.textLabel.text = [NSString stringWithFormat:@"%@-%@-%@",model.num,model.name,model.zone];

        

        return cell;
        return nil;
    }];
    
}


#pragma mark ---- Action ----

//通过  target action 搜索 要实现这个方法
- (StudentModel *)modelById:(NSString *)Id{
    
    StudentModel *model = [[StudentModel alloc] init];
    
    for (StudentModel  *temp in self.dataSource) {
        
        if ([temp.num isEqualToString:Id]) {
            
            model = temp;
            break ;
        }
        
    }
    return model;
}
#pragma mark ---- tableview dataSource ----
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    //显示普通字符串
//    cell.textLabel.text = self.dataSource[indexPath.row];
    
    //显示模型
    
    StudentModel *model = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@-%@",model.num,model.name,model.zone];
    
    
    return cell;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
