//
//  FeedViewController.h
//  InstagramTestApp
//
//  Created by mac on 06.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData+MagicalRecord.h>
#import <InstagramKit.h>
#import "CellHeightCacheViewController.h"

@interface FeedViewController : CellHeightCacheViewController <UITableViewDelegate, UITableViewDataSource>

- (IBAction)logOut:(id)sender;

@end
