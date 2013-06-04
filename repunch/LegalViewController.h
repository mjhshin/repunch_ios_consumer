//
//  LegalViewController.h
//  repunch
//
//  Created by CambioLabs on 4/1/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegalViewController : UIViewController
{
    NSString *document;
    UIWebView *legalWebView;
}

@property (nonatomic, retain) NSString *document;
@property (nonatomic, retain) UIWebView *legalWebView;

@end
