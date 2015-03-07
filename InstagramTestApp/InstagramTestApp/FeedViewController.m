//
//  FeedViewController.m
//  InstagramTestApp
//
//  Created by mac on 06.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "FeedViewController.h"
#import "LogInViewController.h"
#import <UIKit+AFNetworking.h>
#import "FeedCell.h"
#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *mediaArray;
@property (nonatomic, strong) InstagramPaginationInfo *paginationInfo;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mediaArray = [NSMutableArray new];
    
    //NSLog(@"ACCESS TOKEN = %@", [InstagramEngine sharedEngine].accessToken);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([InstagramEngine sharedEngine].accessToken) {
        [self reloadData];
    } else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginPage = [sb instantiateViewControllerWithIdentifier:@"loginPage"];
        
        [self.navigationController presentViewController:loginPage animated:NO completion:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.table addInfiniteScrollingWithActionHandler:^{
        
        if (weakSelf.paginationInfo) {
            [weakSelf paginationRequest:weakSelf.paginationInfo];
        } else {
            weakSelf.table.showsInfiniteScrolling = NO;
        }
        
    }];
    
    [self.table addPullToRefreshWithActionHandler:^{
        [weakSelf reloadData];
        [weakSelf.table.pullToRefreshView stopAnimating];
        weakSelf.table.showsInfiniteScrolling = YES;
        
    }];
}

- (void)reloadData {
    
    [self.mediaArray removeAllObjects];
    
    [[InstagramEngine sharedEngine] getSelfFeedWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        
        [self.mediaArray addObjectsFromArray:media];
        self.paginationInfo = paginationInfo;
        
        [self.table reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Reload data Failed");
    }];
}

- (void)paginationRequest:(InstagramPaginationInfo *)pInfo
{
    [[InstagramEngine sharedEngine] getPaginatedItemsForInfo:self.paginationInfo withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        NSLog(@"%ld more media in Pagination",(unsigned long)media.count);
        [self.table.infiniteScrollingView stopAnimating];
        self.paginationInfo = paginationInfo;
        [self.mediaArray addObjectsFromArray:media];
        [self.table reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Pagination Failed");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)logOut:(id)sender {
    
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mediaArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    
    InstagramMedia *media = [self.mediaArray objectAtIndex:indexPath.row];
    
    [cell.mediaImageView setImageWithURL:media.standardResolutionImageURL placeholderImage:nil];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f %f ", scrollView.contentInset.top, scrollView.contentOffset.y);
}

@end
