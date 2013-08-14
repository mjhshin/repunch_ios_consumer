//
//  ComposeMessageViewController.m
//  Repunch
//
//  Copyright (c) 2013 Repunch. All rights reserved.
//

#import "ComposeMessageViewController.h"

@implementation ComposeMessageViewController
{
	DataManager *sharedData;
	PFObject *store;
	PFObject *patron;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CAGradientLayer *bgLayer = [GradientBackground orangeGradient];
	bgLayer.frame = _toolbar.bounds;
	[_toolbar.layer insertSublayer:bgLayer atIndex:0];
	
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patron = [sharedData patron];

    self.storeName.text = [store objectForKey:@"store_name"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
	//self.subject.delegate = self;
    self.body.delegate = self;
    
    if ([self.messageType isEqualToString:@"feedback"])
	{
        self.subject.placeholder = [NSString stringWithFormat:@"Feedback for %@", [store objectForKey:@"store_name"]];
		self.bodyPlaceholder.text = @"How can we improve?";
    }
	else if ([self.messageType isEqualToString:@"gift"])
	{
        self.subject.text = [NSString stringWithFormat:@"Add a message with your gift!"];
		[self.subject setEnabled:FALSE];
    }
	else if ([self.messageType isEqualToString:@"gift_reply"])
	{
        self.subject.text = [NSString stringWithFormat:@"Say thanks!"];
		[self.subject setEnabled:FALSE];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField;
{
	[textField resignFirstResponder];
	[self.body becomeFirstResponder];
	
	return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //Has Focus
	[self.bodyPlaceholder setHidden:TRUE];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0)
	{
		[self.bodyPlaceholder setHidden:FALSE];
	}
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self sendMessage];
    }
    return YES;
}

-(void)sendMessage
{
	[self dismissKeyboard];
	
	if(self.body.text.length == 0) {
		[self showDialog:@"Your message is blank" withMessage:nil];
		return;
	}
	
	if(self.subject.text.length == 0) {
		self.subject.text = self.subject.placeholder;
	}
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.sendButton.frame;
	[self.toolbar addSubview:spinner];
	self.sendButton.hidden = YES;
	spinner.hidesWhenStopped = YES;
	[spinner startAnimating];
    
    if ([self.messageType isEqualToString:@"feedback"])
	{
		NSString *senderName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
		
        NSDictionary *inputsArgs = [NSDictionary dictionaryWithObjectsAndKeys:
									[patron objectId], @"patron_id",
									[store objectId], @"store_id",
									self.body.text, @"body",
									self.subject.text, @"subject",
									senderName, @"sender_name",
									nil];
        
        [PFCloud callFunctionInBackground:@"send_feedback"
						   withParameters:inputsArgs
									block:^(NSString *result, NSError *error)
		{
			[spinner stopAnimating];
			self.sendButton.hidden = NO;
			
            if (!error)
			{
                [self showDialog:@"Thanks for your feedback!" withMessage:nil];
				[self dismissViewControllerAnimated:YES completion:nil];
                NSLog(@"send_feedback result: %@", result);
            }
            else
			{
				[self showDialog:@"Send Failed"
					 withMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
				NSLog(@"send_feedback error: %@", error);
			}
        }];
    }
    else if ([self.messageType isEqualToString:@"gift"])
	{
		/*
        NSDictionary *inputsArgs = [NSDictionary dictionaryWithObjectsAndKeys:
									[_sendParameters valueForKey:@"store_id"], @"store_id",
									[_sendParameters valueForKey:@"patron_store_id"], @"patron_store_id",
									[localUser patronId], @"patron_id",
									[localUser fullName], @"sender_name",
									subjectText, @"subject",
									[_body text], @"body",
									[_recipient objectId], @"recepient_id",
									[_sendParameters valueForKey:@"gift_title"],@"gift_title",
									[_sendParameters valueForKey:@"gift_description"], @"gift_description",
									[_sendParameters valueForKey:@"gift_punches"], @"gift_punches",
									nil];

        [PFCloud callFunctionInBackground:@"send_gift" withParameters:functionParameters block:^(id object, NSError *error) {
           if (!error){
               
               [spinner stopAnimating];
               [greyedOutView removeFromSuperview];
               
               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Sent!" andMessage:[NSString stringWithFormat:@"You sent %@ to %@", [_sendParameters valueForKey:@"gift_title"], [_recipient valueForKey:@"first_name"]]];
               [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                   [[self modalDelegate] didDismissPresentedViewController];
               }];
               
               [alertView show];
                

           }
           else {
               
               [spinner stopAnimating];
               [greyedOutView removeFromSuperview];
               
               SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Error!" andMessage:[NSString stringWithFormat:@"Sorry, an error occured"]];
               [alertView addButtonWithTitle:@"Okay" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
               }];

               NSLog(@"%@", error);
               
               [alertView show];
                


           }
        }];
        [[self modalDelegate] didDismissPresentedViewController];
		 */
    }    
    else if ([self.messageType isEqualToString:@"gift_reply"])
	{
		/*
        NSDictionary *functionParameters = [[NSDictionary alloc] initWithObjectsAndKeys:[_sendParameters valueForKey:@"message_id"], @"message_id", [localUser patronId], @"patron_id", [localUser fullName], @"sender_name", [_body text], @"body", nil];
        
        [PFCloud callFunctionInBackground:@"reply_to_gift" withParameters:functionParameters block:^(id object, NSError *error) {
            //
        }];
        [[self modalDelegate] didDismissPresentedViewController];
		 */
    }
}

- (void)dismissKeyboard
{
    [self.subject resignFirstResponder];
    [self.body resignFirstResponder];
}

- (IBAction)sendButtonAction:(id)sender
{
    [self sendMessage];
}

- (IBAction)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDialog:(NSString*)title withMessage:(NSString*)message
{
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title
                                                 andMessage:message];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert show];
}

@end
