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
#import "InstagramDataModel.h"

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) InstagramPaginationInfo *paginationInfo;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"ACCESS TOKEN = %@", [InstagramEngine sharedEngine].accessToken);
    //[InstagramDataModel sharedInstance]
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
    
    [[InstagramDataModel sharedInstance].feedMediaArray removeAllObjects];
    
    [[InstagramEngine sharedEngine] getSelfFeedWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        
        [[InstagramDataModel sharedInstance].feedMediaArray addObjectsFromArray:media];
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
        [[InstagramDataModel sharedInstance].feedMediaArray addObjectsFromArray:media];
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

- (IBAction)likeButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        FeedCell *cell = (FeedCell*)[self.table cellForRowAtIndexPath:indexPath];
        
        InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:indexPath.row];
        
        if (media.isLiked) {
            [[InstagramEngine sharedEngine] unlikeMedia:media withSuccess:^{
                media.isLiked = NO;
                [cell.likeButton likeAnimation:NO];
            } failure:^(NSError *error) {
                NSLog(@"Unlike failed");
            }];
        } else {
            [[InstagramEngine sharedEngine] likeMedia:media withSuccess:^{
                media.isLiked = YES;
                [cell.likeButton likeAnimation:YES];
            } failure:^(NSError *error) {
                NSLog(@"Like failed");
            }];
        }
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[InstagramDataModel sharedInstance].feedMediaArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:indexPath.row];
    
    [cell.likeButton userHasLiked:media.isLiked];
    
    [cell.mediaImageView setImageWithURL:media.standardResolutionImageURL placeholderImage:nil];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Select row");
}

@end
