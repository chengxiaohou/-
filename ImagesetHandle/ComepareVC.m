//
//  ComepareVC.m
//  ImagesetHandle
//
//  Created by fengyi on 2018/8/28.
//  Copyright © 2018年 fengyi. All rights reserved.
//

#import "ComepareVC.h"
#import "CompareCell.h"
@interface ComepareVC ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableViewLeft;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRight;

@property (strong, nonatomic) NSMutableArray *listLeft;
@property (strong, nonatomic) NSMutableArray *listRigth;
/** 两列同时滚动 */
@property (assign, nonatomic) BOOL scrollTogether;
@property (weak, nonatomic) IBOutlet UIButton *scrollBtn;
@end

@implementation ComepareVC

#pragma mark show方法
+ (void)showWithLeft:(NSMutableArray *)datasLeft right:(NSMutableArray *)datasRigth oldVC:(UIViewController *)oldVC
{
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ComepareVC *vc = [SB instantiateViewControllerWithIdentifier:@"ComepareVC"];
    vc.listLeft = datasLeft;
    vc.listRigth = datasRigth;
    [oldVC presentViewController:vc animated:1 completion:nil];
}

static NSString *const kScrollTogether = @"scrollTogether";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:kScrollTogether options:NSKeyValueObservingOptionNew context:nil];

    [_tableViewRight setEditing:1 animated:1];
    [_tableViewLeft setEditing:1 animated:1];
    
    self.scrollTogether = NO;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([keyPath isEqualToString:kScrollTogether]){
        
        NSString *title = _scrollTogether ? @"同步滚动" : @"单独滚动";
        [_scrollBtn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kScrollTogether];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ......::::::: UITableViewDataSource :::::::......

#pragma mark TV段数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark TV行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_tableViewLeft]) {
        return _listLeft.count;
    }
    else
    {
        return _listRigth.count;
    }
}

#pragma mark ［配置TV单元格］
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    CompareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CompareCell" forIndexPath:indexPath];
    NSArray *temp = nil;
    if ([tableView isEqual:_tableViewLeft]) {
        temp = _listLeft;
    }
    else
    {
        temp = _listRigth;
    }
    
    NSString *name = temp[row];
    [cell.lb setText:name];

//    NSRange range = [name rangeOfString:@"@"];
//    name = [name substringToIndex:range.location];
    [cell.imgView setImage:[UIImage imageNamed:name]];
    return cell;
}

#pragma mark TV单元格点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark 选择编辑模式，添加模式很少用,默认是删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *temp = nil;
    if ([tableView isEqual:_tableViewLeft]) {
        temp = _listLeft;
    }
    else
    {
        temp = _listRigth;
    }
    // 取出要拖动的模型数据
    NSString *name = temp[sourceIndexPath.row];
    //删除之前行的数据
    [temp removeObject:name];
    // 插入数据到新的位置
    [temp insertObject:name atIndex:destinationIndexPath.row];
}


//========================== 同步滚动相关 ==========================
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_scrollTogether) {
        if ([scrollView isEqual:_tableViewRight])
        {
            _tableViewLeft.contentOffset = scrollView.contentOffset;
        }
        else
        {
            _tableViewRight.contentOffset = scrollView.contentOffset;
        }
    }
}
//========================== === ==========================
- (IBAction)onPrint:(id)sender {
    
    int i = 0;
    for (NSString *leftName in _listLeft) {
        
        NSString *rightName;
        if (_listRigth.count > i)
        {
            rightName = _listRigth[i];
        }
        else
        {
            rightName = @"???";
        }
        
        NSLog(@" @\"%@\" : @\"%@\", ", leftName, rightName);
        i++;
    }
}

- (IBAction)onScrollBtn:(id)sender {
    self.scrollTogether = !_scrollTogether;
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
