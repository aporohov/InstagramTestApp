//
//  CellHeightCacheViewController.h
//  InstagramTestApp
//
//  Created by mac on 09.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellHeightCacheViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *table;

- (void) putEstimatedCellHeightToCache:(NSIndexPath *) indexPath height:(CGFloat) height;
- (CGFloat) getEstimatedCellHeightFromCache:(NSIndexPath *) indexPath defaultHeight:(CGFloat) defaultHeight;
- (BOOL) isEstimatedRowHeightInCache:(NSIndexPath *) indexPath;
- (void) tableViewReloadData;

@end
