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
	PFObject *patronStore;
	UIActivityIndicatorView *spinner;
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
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = self.sendButton.frame;
	spinner.hidesWhenStopped = YES;
	[self.toolbar addSubview:spinner];
	
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patronStore = [sharedData getPatronStore:self.storeId];
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
        self.subject.text = [NSString stringWithFormat:@"Gift for %@", self.recepientName];
		self.bodyPlaceholder.text = @"Add a message with your gift!";
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

//limits subject to 50 characters
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{	
    NSUInteger newLength = textField.text.length + string.length - range.length;
    return (newLength > 50) ? NO : YES;
}

//limits body to 750 characters
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) //set behavior for done button
    {
        [self send];
    }
	
	NSUInteger newLength = textView.text.length + string.length - range.length;
    return (newLength > 750) ? NO : YES;
}

- (void)send
{
	if ([self.messageType isEqualToString:@"feedback"])
	{
		[self sendMessage];
    }
	else if ([self.messageType isEqualToString:@"gift"])
	{
		[self sendGift];
    }
	else if ([self.messageType isEqualToString:@"gift_reply"])
	{
        //[self sendGiftReply];
    }
}

- (void)sendMessage
{
	[self dismissKeyboard];
	
	if(self.body.text.length == 0) {
		[self showDialog:@"Your message is blank" withMessage:nil];
		return;
	}
	
	if(self.subject.text.length == 0) {
		self.subject.text = self.subject.placeholder;
	}
	
	self.sendButton.hidden = YES;
	[spinner startAnimating];
    
	NSString *senderName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
		
	NSDictionary *inputsArgs = [NSDictionary dictionaryWithObjectsAndKeys:
								patron.objectId,		@"patron_id",
								store.objectId,			@"store_id",
								self.body.text,			@"body",
								self.subject.text,		@"subject",
								senderName,				@"sender_name",
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

- (void)sendGift
{
	[self dismissKeyboard];
	
	if(self.body.text.length == 0) {
		[self showDialog:@"Your message is blank" withMessage:nil];
		return;
	}
	
	if(self.subject.text.length == 0) {
		self.subject.text = self.subject.placeholder;
	}
	
	self.sendButton.hidden = YES;
	[spinner startAnimating];
    
	NSString *senderName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
	
	NSDictionary *inputsArgs = [NSDictionary dictionaryWithObjectsAndKeys:
								patron.objectId,		@"patron_id",
								store.objectId,			@"store_id",
								patronStore.objectId,	@"patron_store_id",
								senderName,				@"sender_name",
								self.subject.text,		@"subject",
								self.body.text,			@"body",
								self.giftRecepientId,	@"recepient_id",
								self.giftTitle,			@"gift_title",
								self.giftDescription,	@"gift_description",
								[NSString stringWithFormat:@"%i", self.giftPunches],		@"gift_punches",
								nil];
	
	[PFCloud callFunctionInBackground:@"send_gift"
					   withParameters:inputsArgs
								block:^(NSString *result, NSError *error)
	 {
		 [spinner stopAnimating];
		 self.sendButton.hidden = NO;
		 
		 if (!error)
		 {
			 [self showDialog:@"Your gift has been sent!" withMessage:nil];
			 [self dismissViewControllerAnimated:YES completion:nil];
			 NSLog(@"send_gift result: %@", result);
		 }
		 else
		 {
			 [self showDialog:@"Send Failed"
				  withMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
			 NSLog(@"send_gift error: %@", error);
		 }
	 }];
}

- (void)sendGiftReply
{
	[self dismissKeyboard];
}

- (void)dismissKeyboard
{
    [self.subject resignFirstResponder];
    [self.body resignFirstResponder];
}

- (IBAction)sendButtonAction:(id)sender
{
    [self send];
}

- (IBAction)closeButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showDialog:(NSString*)title withMessage:(NSString*)message
{
	SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title
                                                 andMessage:message];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

@end
