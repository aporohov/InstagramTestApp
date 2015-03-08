//
//  DetailedViewController.h
//  InstagramTestApp
//
//  Created by mac on 08.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <InstagramKit.h>

@interface DetailedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) InstagramMedia *media;

@property (weak, nonatomic) IBOutlet UITableView *table;

@end
