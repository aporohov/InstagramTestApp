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
#import "FeedHeader.h"
#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>
#import "InstagramDataModel.h"
#import "DetailedViewController.h"

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) InstagramPaginationInfo *paginationInfo;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *token = [[NSUserDefaults standardUserDefaults]objectForKey:@"AccessToken"];
    if (token) {
        [[InstagramEngine sharedEngine] setAccessToken:token];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![InstagramEngine sharedEngine].accessToken) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginPage = [sb instantiateViewControllerWithIdentifier:@"loginPage"];
        
        [self.navigationController presentViewController:loginPage animated:NO completion:nil];
    } else if (![InstagramDataModel sharedInstance].feedMediaArray.count) {
        [self reloadData];
    } else {
        [self.table reloadData];
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
    
    [[InstagramEngine sharedEngine] getSelfFeedWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [[InstagramDataModel sharedInstance].feedMediaArray removeAllObjects];
        [[InstagramDataModel sharedInstance].feedMediaArray addObjectsFromArray:media];
        self.paginationInfo = paginationInfo;
        
        [self.table reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"Reload data Failed");
        if (![[InstagramEngine sharedEngine] accessToken]) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginPage = [sb instantiateViewControllerWithIdentifier:@"loginPage"];
            
            [self.navigationController presentViewController:loginPage animated:YES completion:nil];
        }
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
        [self.table.infiniteScrollingView stopAnimating];
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
    if ([segue.identifier isEqualToString:@"DetailedSegue"]) {
        
        NSIndexPath *cellIndexPath = [self.table indexPathForCell:(UITableViewCell*)sender];
        
        InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:cellIndexPath.section];
        
        [(DetailedViewController*)segue.destinationViewController setMedia:media];
    }
}

- (IBAction)logOut:(id)sender {
    
}

- (IBAction)likeButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        FeedCell *cell = (FeedCell*)[self.table cellForRowAtIndexPath:indexPath];
        
        InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:indexPath.section];
        
        if (media.isLiked) {
            [[InstagramEngine sharedEngine] unlikeMedia:media withSuccess:^{
                media.isLiked = NO;
                media.likesCount--;
                [cell.likeButton likeAnimation:NO];
            } failure:^(NSError *error) {
                NSLog(@"Unlike failed");
            }];
        } else {
            [[InstagramEngine sharedEngine] likeMedia:media withSuccess:^{
                media.isLiked = YES;
                media.likesCount++;
                [cell.likeButton likeAnimation:YES];
            } failure:^(NSError *error) {
                NSLog(@"Like failed");
            }];
        }
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[InstagramDataModel sharedInstance].feedMediaArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FeedHeader *header = [tableView dequeueReusableCellWithIdentifier:@"FeedHeader"];
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:section];
    header.authorAvatar.image = nil;
    [header.authorAvatar setImageWithURL:media.user.profilePictureURL];
    header.authorName.text = media.user.username;
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:indexPath.section];
    
    [cell.activity startAnimating];
    
    [cell.likeButton userHasLiked:media.isLiked];
    cell.mediaImageView.image = nil;
    [cell.mediaImageView setImageWithURL:media.standardResolutionImageURL placeholderImage:nil];
    
    return cell;
}

@end
