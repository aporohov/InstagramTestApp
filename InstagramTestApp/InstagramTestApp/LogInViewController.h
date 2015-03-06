//
//  ViewController.h
//  InstagramTestApp
//
//  Created by mac on 06.03.15.
//  Copyright (c) 2015 Artem Porohov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"

@interface LogInViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

