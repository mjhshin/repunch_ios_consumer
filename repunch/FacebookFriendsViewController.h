//
//  FacebookFriendsViewController.h
//  RepunchConsumer
//
//  Created by Michael Shin on 8/22/13.
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@class FacebookFriendsViewController;

@protocol FacebookFriendsDelegate <NSObject>
- (void)onFriendSelected:(FacebookFriendsViewController *)controller
			 forFriendId:(NSString *)friendId
				withName:(NSString *)name;
@end

@interface FacebookFriendsViewController : FBFriendPickerViewController <FBFriendPickerDelegate>

@property (nonatomic, weak) id <FacebookFriendsDelegate> myDelegate;

@property (weak, nonatomic) IBOutlet UIView *spinnerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mySpinner;

@end
