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

@interface DetailedViewController ()

@end

@implementation DetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table.estimatedRowHeight = 60.0;
    self.table.rowHeight = UITableViewAutomaticDimension;
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

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [_media.comments count];
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
        [cell configureCellWithComment:[_media.comments objectAtIndex:indexPath.row - 1]];
        return cell;
    }
    
}

@end
