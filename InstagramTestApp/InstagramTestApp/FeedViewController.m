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
#import "CommentCell.h"
#import "FeedHeader.h"
#import <UIScrollView+SVInfiniteScrolling.h>
#import <UIScrollView+SVPullToRefresh.h>
#import "InstagramDataModel.h"
#import "DetailedViewController.h"

@interface FeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) InstagramPaginationInfo *paginationInfo;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableDictionary *estimatedRowHeightCache;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *token = [SSKeychain passwordForService:@"InstagramService" account:@"com.instagramTestApp.keychain"];
    if (token) {
        [[InstagramEngine sharedEngine] setAccessToken:token];
        [[InstagramDataModel sharedInstance] fetchEntities];
    }
    //self.table.estimatedRowHeight = 50;
    //self.table.rowHeight = UITableViewAutomaticDimension;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![InstagramEngine sharedEngine].accessToken) {
        [self openLoginPageWithAnimation:NO];
        return;
    } else if (!self.paginationInfo) {
        [self reloadData];
    } else {
        //[self.table reloadData];
        [self tableViewReloadData];
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

- (void)openLoginPageWithAnimation:(BOOL)animated {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginPage = [sb instantiateViewControllerWithIdentifier:@"loginPage"];
    
    [self.navigationController presentViewController:loginPage animated:animated completion:nil];
}

- (void)reloadData {
    
    [[InstagramEngine sharedEngine] getSelfFeedWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        
        [[InstagramDataModel sharedInstance]updateFeedWithMedia:media];
        
        self.paginationInfo = paginationInfo;
        
        //[self.table reloadData];
        [self tableViewReloadData];
    } failure:^(NSError *error) {
        NSLog(@"Reload data Failed");
        if (![[InstagramEngine sharedEngine] accessToken]) {
            [self openLoginPageWithAnimation:YES];
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
        //[self.table reloadData];
        [self tableViewReloadData];
    } failure:^(NSError *error) {
        [self.table.infiniteScrollingView stopAnimating];
        NSLog(@"Pagination Failed");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(id)sender {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    [InstagramEngine sharedEngine].accessToken = nil;
    [SSKeychain deletePasswordForService:@"InstagramService" account:@"com.instagramTestApp.keychain"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.paginationInfo = nil;
    
    [[InstagramDataModel sharedInstance]removeAllFeedMedia];
    
    [self openLoginPageWithAnimation:YES];
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
                [cell.countLabel setText:[NSString stringWithFormat:@"Comments:%d Likes:%d", media.commentCount, media.likesCount]];
            } failure:^(NSError *error) {
                NSLog(@"Unlike failed");
            }];
        } else {
            [[InstagramEngine sharedEngine] likeMedia:media withSuccess:^{
                media.isLiked = YES;
                media.likesCount++;
                [cell.likeButton likeAnimation:YES];
                [cell.countLabel setText:[NSString stringWithFormat:@"Comments:%d Likes:%d", media.commentCount, media.likesCount]];
            } failure:^(NSError *error) {
                NSLog(@"Like failed");
            }];
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"DetailedSegue"]) {
        
        NSIndexPath *cellIndexPath = [self.table indexPathForCell:(UITableViewCell*)sender];
        
        InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:cellIndexPath.section];
        
        [(DetailedViewController*)segue.destinationViewController setMedia:media];
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
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:section];
    
    if (media.commentCount > 3) {
        return 4;
    } else {
        return 1 + media.commentCount;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 370;
    } else {
        //immutable indexpath
        NSIndexPath *iPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        return [self getEstimatedCellHeightFromCache:iPath defaultHeight:50];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FeedHeader *header = [tableView dequeueReusableCellWithIdentifier:@"FeedHeader"];
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:section];
    header.authorAvatar.image = nil;
    [header.authorAvatar setImageWithURL:media.user.profilePictureURL];
    header.authorName.text = media.user.username;
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstagramMedia *media = [[InstagramDataModel sharedInstance].feedMediaArray objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        FeedCell *cell = (FeedCell*)[tableView dequeueReusableCellWithIdentifier:@"FeedCell" forIndexPath:indexPath];
        
        [cell.activity startAnimating];
        [cell.countLabel setText:[NSString stringWithFormat:@"Comments:%d Likes:%d", media.commentCount, media.likesCount]];
        [cell.likeButton userHasLiked:media.isLiked];
        cell.mediaImageView.image = nil;
        [cell.mediaImageView setImageWithURL:media.standardResolutionImageURL placeholderImage:nil];
        
        return cell;
    } else {
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCommentCell" forIndexPath:indexPath];
        [cell configureCellWithComment:[media.comments objectAtIndex:indexPath.row - 1]];
        if (![self isEstimatedRowHeightInCache:indexPath]) {
            CGSize cellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(self.view.frame.size.width, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:50.0];
            [self putEstimatedCellHeightToCache:indexPath height:cellSize.height];
        }
        return cell;
    }
}

#pragma mark - estimated height cache methods

// put height to cache
- (void) putEstimatedCellHeightToCache:(NSIndexPath *) indexPath height:(CGFloat) height {
    [self initEstimatedRowHeightCacheIfNeeded];
    [self.estimatedRowHeightCache setObject:[[NSNumber alloc] initWithFloat:height] forKey:indexPath];
}

// get height from cache
- (CGFloat) getEstimatedCellHeightFromCache:(NSIndexPath *) indexPath defaultHeight:(CGFloat) defaultHeight {
    [self initEstimatedRowHeightCacheIfNeeded];
    NSNumber *estimatedHeight = [self.estimatedRowHeightCache objectForKey:indexPath];
    if (estimatedHeight != nil) {
        return [estimatedHeight floatValue];
    }
    return defaultHeight;
}

// check if height is on cache
- (BOOL) isEstimatedRowHeightInCache:(NSIndexPath *) indexPath {
    if ([self getEstimatedCellHeightFromCache:indexPath defaultHeight:0] > 0) {
        return YES;
    }
    return NO;
}

// init cache
-(void) initEstimatedRowHeightCacheIfNeeded {
    if (self.estimatedRowHeightCache == nil) {
        self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    }
}

// custom [self.tableView reloadData]
-(void) tableViewReloadData {
    // clear cache on reload
    self.estimatedRowHeightCache = [[NSMutableDictionary alloc] init];
    [self.table reloadData];
}

@end
