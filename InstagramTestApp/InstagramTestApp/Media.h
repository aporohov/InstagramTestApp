//
//  MediaManagedObject.h
//  InstagramTestApp
//
//  Created by mac on 09.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Media : NSManagedObject

@property (nonatomic, strong) NSData *info;
@property (nonatomic, strong) NSDate *createdDate;

@end
