//
//  DetailedViewController.m
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "DetailedViewController.h"
#import <UIImageView+AFNetworking.h>
#import "MediaCell.h"
#import "CommentCell.h"
#import "InstagramDataModel.h"
#import "LikesViewController.h"

@interface DetailedViewController ()

@property (nonatomic, copy) NSArray *comments;

@end

@implementation DetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table.rowHeight = UITableViewAutomaticDimension;
    
    self.comments = [[NSArray alloc]initWithArray:_media.comments];
    
    [[InstagramEngine sharedEngine]getCommentsOnMedia:_media withSuccess:^(NSArray *comments) {
        self.comments = comments;
        [self tableViewReloadData];
    } failure:^(NSError *error) {
        NSLog(@"Comments loading failed");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)likeButtonPressed:(id)sender {
    MediaCell *cell = (MediaCell*)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (_media.isLiked) {
        [[InstagramEngine sharedEngine] unlikeMedia:_media withSuccess:^{
            _media.isLiked = NO;
            _media.likesCount--;
            [cell.likeButton likeAnimation:NO];
            [cell.likeCounterLabel setText:[NSString stringWithFormat:@"%d", _media.likesCount]];
        } failure:^(NSError *error) {
            NSLog(@"Unlike failed");
        }];
    } else {
        [[InstagramEngine sharedEngine] likeMedia:_media withSuccess:^{
            _media.isLiked = YES;
            _media.likesCount++;
            [cell.likeButton likeAnimation:YES];
            [cell.likeCounterLabel setText:[NSString stringWithFormat:@"%d", _media.likesCount]];
        } failure:^(NSError *error) {
            NSLog(@"Like failed");
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"LikesSegue"]) {
        
        [(LikesViewController*)segue.destinationViewController setMedia:_media];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [self.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 430;
    } else {
        //immutable indexpath
        NSIndexPath *iPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        return [self getEstimatedCellHeightFromCache:iPath defaultHeight:60];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        MediaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaCell" forIndexPath:indexPath];
        [cell.authorAvatar setImageWithURL:_media.user.profilePictureURL];
        [cell.authorName setText:_media.user.username];
        [cell.mediaImageView setImageWithURL:_media.standardResolutionImageURL];
        [cell.commentsCounterLabel setText:[NSString stringWithFormat:@"Comments: %d", _media.commentCount]];
        [cell.likeCounterLabel setText:[NSString stringWithFormat:@"%d", _media.likesCount]];
        [cell.likeButton userHasLiked:_media.isLiked];
        return cell;
    } else {
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        [cell configureCellWithComment:[self.comments objectAtIndex:([self.comments count] - indexPath.row)]];
        if (![self isEstimatedRowHeightInCache:indexPath]) {
            CGSize cellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(self.view.frame.size.width, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:60.0];
            [self putEstimatedCellHeightToCache:indexPath height:cellSize.height];
        }
        return cell;
    }
}
@end
