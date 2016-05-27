//
//  WSResultViewController.m
//  RealtimeSearch
//
//  Created by 王燊 on 16/5/27.
//  Copyright © 2016年 王燊. All rights reserved.
//

#import "TYResultViewController.h"

static NSString *cellIdent = @"cellident";


@interface TYResultViewController ()<UITableViewDelegate,UITableViewDataSource>



@end

@implementation TYResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
}


#pragma mark ---- getter ----
- (UITableView *)tableView{
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        self.view.backgroundColor = [UIColor orangeColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
        
    }
    return _tableView;
}


#pragma mark ---- tableview dataSource ----

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.numberOfRowsInSectionCompletion) {
        
        self.numberOfRowsInSectionCompletion(tableView,section);
    }
    
    return self.dataSource.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.heightForRowAtIndexPathCompletion) {
        
       return  self.heightForRowAtIndexPathCompletion(tableView,indexPath);
    }else{
        
        return 44;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.cellForRowAtIndexPathCompletion) {
        
       return  self.cellForRowAtIndexPathCompletion(tableView,indexPath);
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
    
}


#pragma mark ---- tableview delegate ----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.didDeselectRowAtIndexPathCompletion) {
        
        self.didDeselectRowAtIndexPathCompletion(tableView,indexPath);
    }
    
    DLog(@"点击了第%zd行",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
