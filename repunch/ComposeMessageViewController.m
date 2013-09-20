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
	UIBarButtonItem *sendButton;
	CGFloat keyboardTop;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [super initWithNibName:nibName bundle:bundle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_exit.png"]
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(closeButton:)];
	
	sendButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_send.png"]
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(sendButtonAction:)];
	self.navigationItem.leftBarButtonItem = exitButton;
	self.navigationItem.rightBarButtonItem = sendButton;
	
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.hidesWhenStopped = YES;
	
	sharedData = [DataManager getSharedInstance];
	store = [sharedData getStore:self.storeId];
	patronStore = [sharedData getPatronStore:self.storeId];
	patron = [sharedData patron];
	
	self.navigationItem.title = [store objectForKey:@"store_name"];
    
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
        self.subject.text = [NSString stringWithFormat:@"To: %@", self.recepientName];
		self.bodyPlaceholder.text = @"Thanks for the gift!";
		[self.subject setEnabled:FALSE];
    }

	keyboardTop = [[UIScreen mainScreen] applicationFrame].size.height - 310; //216 is height of keyboard in iOS7
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
    [self.bodyPlaceholder setHidden:YES];
	[self scrollTextViewAboveKeyboard:textView];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if(textView.text.length == 0)
	{
		[self.bodyPlaceholder setHidden:NO];
	}
	self.scrollView.contentOffset = CGPointMake(0, 0);
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
	
	[self scrollTextViewAboveKeyboard:textView];
	
	NSUInteger newLength = textView.text.length + string.length - range.length;
    return (newLength > 750) ? NO : YES;
}

- (void)scrollTextViewAboveKeyboard:(UITextView *)textView
{
	CGFloat textViewOrigin = textView.frame.origin.y;
	CGRect cursorFrame = [textView caretRectForPosition:textView.selectedTextRange.start];
	CGFloat cursorPosition = cursorFrame.origin.y;
	if(cursorPosition + textViewOrigin > keyboardTop) {
		self.scrollView.contentOffset = CGPointMake(0, cursorPosition + textViewOrigin - keyboardTop);
	}
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
        [self sendGiftReply];
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
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
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
		self.navigationItem.rightBarButtonItem = sendButton;
		[self dismissViewControllerAnimated:YES completion:nil];
		
		if (!error)
		{
			[self showDialog:@"Thanks for your feedback!" withMessage:nil];
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
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
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
		 self.navigationItem.rightBarButtonItem = sendButton;
		 [self dismissViewControllerAnimated:YES completion:nil];
		 
		 if (!error)
		 {
			 if([result isEqualToString:@"insufficient"])
			 {
				 [self showDialog:@"Sorry, not enough punches" withMessage:nil];
			 }
			 else
			 {
				 int punches = [[patronStore objectForKey:@"punch_count"] intValue];
				 NSNumber *newPunches = [NSNumber numberWithInt:punches - self.giftPunches];
				 [patronStore setObject:newPunches forKey:@"punch_count"];
				 punches -= self.giftPunches;
				 
				 [self showDialog:@"Your gift has been sent!" withMessage:nil];
				 [[NSNotificationCenter defaultCenter] postNotificationName:@"Punch" object:self];
			 }
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
	
	if(self.body.text.length == 0) {
		[self showDialog:@"Your message is blank" withMessage:nil];
		return;
	}
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	[spinner startAnimating];
    
	NSString *senderName = [NSString stringWithFormat:@"%@ %@", [patron objectForKey:@"first_name"], [patron objectForKey:@"last_name"]];
	
	NSDictionary *inputsArgs = [NSDictionary dictionaryWithObjectsAndKeys:
								self.giftReplyMessageId,		@"message_id",
								senderName,						@"sender_name",
								self.body.text,					@"body",
								nil];
	
	[PFCloud callFunctionInBackground:@"reply_to_gift"
					   withParameters:inputsArgs
								block:^(PFObject *reply, NSError *error)
	 {
		 [spinner stopAnimating];
		 self.navigationItem.rightBarButtonItem = sendButton;
		 [self dismissViewControllerAnimated:YES completion:nil];
		 
		 if (!error)
		 {			 
			 [self showDialog:@"Your reply has been sent!" withMessage:nil];
			 PFObject *originalMessage = [[sharedData getMessage:self.giftMessageStatusId] objectForKey:@"Message"];
			 [originalMessage setObject:reply forKey:@"Reply"];
			 
			 [self.delegate giftReplySent:self];
			 NSLog(@"send_gift result: %@", reply);
		 }
		 else
		 {
			 [self showDialog:@"Send Failed"
				  withMessage:@"There was a problem connecting to Repunch. Please check your connection and try again."];
			 NSLog(@"send_gift error: %@", error);
		 }
	 }];
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
