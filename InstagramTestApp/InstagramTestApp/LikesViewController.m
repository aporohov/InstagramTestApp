//
//  LikesViewController.m
//  InstagramTestApp
//
//  Created by mac on 09.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import "LikesViewController.h"
#import <InstagramKit.h>
#import "LikedUserCell.h"
#import <UIImageView+AFNetworking.h>

@interface LikesViewController () <UITableViewDataSource>

@property (nonatomic, copy) NSArray *likes;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.likes = [NSArray array];
    
    [[InstagramEngine sharedEngine]getLikesOnMedia:_media withSuccess:^(NSArray *likedUsers) {
        self.likes = likedUsers;
        [self.table reloadData];
    } failure:^(NSError *error) {
        self.likes = _media.likes;
        [self.table reloadData];
        NSLog(@"Likes loading failed");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.likes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LikedUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LikeCell" forIndexPath:indexPath];
    
    InstagramUser *likedUser = [self.likes objectAtIndex:indexPath.row];
    [cell.userName setText:likedUser.username];
    cell.userAvatar.image = nil;
    [cell.userAvatar setImageWithURL:likedUser.profilePictureURL];
    
    return cell;
}

@end
