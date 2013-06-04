//
//  InboxViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Message.h"
#import "InboxViewController.h"
#import "InboxDetailViewController.h"
#import "NSDate+whenString.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

@synthesize inboxData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Inbox";
    
    UIImage *editImage = [UIImage imageNamed:@"btn-edit"];
    UIImage *editBtnImage = [editImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [self.editButtonItem setBackgroundImage:editBtnImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImage *inboxBackImage = [UIImage imageNamed:@"btn-back-inbox"];
    UIImage *barBackBtnImg = [inboxBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self loadMessages];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // TODO: rather than load messages everytime, just do a quick check -- need to check message count, update time for replies
    // or rely on push?
    [self loadMessages];
}

- (void)loadMessages
{
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    
    PFRelation *inbox = [pfuser objectForKey:@"inbox"];
    [[inbox query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            
        // if message count doesn't match, load from parse
        if ([inboxData count] != [objects count]){
            
            for (PFObject *message in objects){
                
                Message *newMessage = [Message MR_findFirstByAttribute:@"objectId" withValue:[message objectId]];
                
                if (newMessage == nil) {
                    newMessage = [Message MR_createInContext:localContext];
                }                
                
                [newMessage setFromParse:message];
                [newMessage setUser:localUser];
                [localContext MR_saveToPersistentStoreAndWait];
                
            }
        }        
        
        inboxData = [(NSMutableArray *)[localUser.messages allObjects] retain];
        [self sortMessages];
        
    }];
}

-(void) sortMessages
{
    inboxData = [(NSMutableArray *)[inboxData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sent_time" ascending:NO]]] retain];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [inboxData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Message *thisMessage = [inboxData objectAtIndex:indexPath.row];
    
    UIView *messageCellView;
    
    UIImageView *messageTypeImageView;
    UILabel *messageFromLabel;
    UILabel *messageSubjectLabel;
    UILabel *messagePreviewLabel;
    UILabel *messageSentLabel;
    
#define MESSAGECELLVIEW_TAG 4
    
#define MESSAGETYPEIMAGEVIEW_TAG 0
#define MESSAGEFROMLABEL_TAG 1
#define MESSAGEPREVIEWLABEL_TAG 2
#define MESSAGESENTLABEL_TAG 3
#define MESSAGESUBJECTLABEL_TAG 5
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        messageCellView = [[[UIView alloc] initWithFrame:cell.contentView.frame] autorelease];
        [messageCellView setTag:MESSAGECELLVIEW_TAG];
        [cell.contentView addSubview:messageCellView];
        
        messageTypeImageView = [[[UIImageView alloc] init] autorelease];
        [messageTypeImageView setTag:MESSAGETYPEIMAGEVIEW_TAG];
        [messageCellView addSubview:messageTypeImageView];
        
        messageFromLabel = [[[UILabel alloc] init] autorelease];
        [messageFromLabel setTag:MESSAGEFROMLABEL_TAG];
        [messageCellView addSubview:messageFromLabel];
        
        messageSubjectLabel = [[[UILabel alloc] init] autorelease];
        [messageSubjectLabel setTag:MESSAGESUBJECTLABEL_TAG];
        [messageCellView addSubview:messageSubjectLabel];
        
        messagePreviewLabel = [[[UILabel alloc] init] autorelease];
        [messagePreviewLabel setTag:MESSAGEPREVIEWLABEL_TAG];
        [messageCellView addSubview:messagePreviewLabel];
        
        messageSentLabel = [[[UILabel alloc] init] autorelease];
        [messageSentLabel setTag:MESSAGESENTLABEL_TAG];
        [messageCellView addSubview:messageSentLabel];
        
    } else {
        messageCellView = (UIView *)[cell.contentView viewWithTag:MESSAGECELLVIEW_TAG];
        
        messageTypeImageView = (UIImageView *)[messageCellView viewWithTag:MESSAGETYPEIMAGEVIEW_TAG];
        messageFromLabel = (UILabel *)[messageCellView viewWithTag:MESSAGEFROMLABEL_TAG];
        messageSubjectLabel = (UILabel *)[messageCellView viewWithTag:MESSAGESUBJECTLABEL_TAG];
        messagePreviewLabel = (UILabel *)[messageCellView viewWithTag:MESSAGEPREVIEWLABEL_TAG];
        messageSentLabel = (UILabel *)[messageCellView viewWithTag:MESSAGESENTLABEL_TAG];
    }
    
    // Configure the cell...
    
    UIImage *typeImage = nil;
    if ([thisMessage.type isEqualToString:@"info"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_info"];
        [messageFromLabel setText:thisMessage.retailer_name];
        
    } else if ([thisMessage.type isEqualToString:@"gift"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_gift"];
        [messageFromLabel setText:thisMessage.gift_sender_name];
        
    } else if ([thisMessage.type isEqualToString:@"coupon"]) {
        
        typeImage = [UIImage imageNamed:@"ico_message_coupon"];
        [messageFromLabel setText:thisMessage.retailer_name];
        
    } else if ([thisMessage.type isEqualToString:@"reply"]) {
        
        // would this get called? does the type change when a reply is added? or do we just check for reply body/sent time
        typeImage = [UIImage imageNamed:@"ico_message_reply"];
        
    }
    
    [messageTypeImageView setImage:typeImage];
    [messageTypeImageView setFrame:CGRectMake(7, 7, typeImage.size.width, typeImage.size.height)];
//    [messageTypeImageView setBackgroundColor:[UIColor redColor]];
    
    [messageFromLabel setFrame:CGRectMake(45, 7, 190, 20)];
    [messageFromLabel setFont:[UIFont boldSystemFontOfSize:16]];
//    [messageFromLabel setBackgroundColor:[UIColor greenColor]];
    
    [messageSubjectLabel setFont:[UIFont systemFontOfSize:13]];
    [messageSubjectLabel setText:thisMessage.subject];
    [messageSubjectLabel setFrame:CGRectMake(45, messageFromLabel.frame.origin.y + messageFromLabel.frame.size.height, self.view.frame.size.width - 60, 15)];
//    [messageSubjectLabel setBackgroundColor:[UIColor purpleColor]];
    
    [messagePreviewLabel setNumberOfLines:2];
    [messagePreviewLabel setFont:[UIFont systemFontOfSize:12]];
    [messagePreviewLabel setText:thisMessage.body];
    [messagePreviewLabel setFrame:CGRectMake(45, messageSubjectLabel.frame.origin.y + messageSubjectLabel.frame.size.height, self.view.frame.size.width - 60, 30)];
//    [messagePreviewLabel setBackgroundColor:[UIColor blueColor]];
    [messagePreviewLabel setTextColor:[UIColor darkGrayColor]];
    [messagePreviewLabel sizeToFit];
    
    [messageSentLabel setFrame:CGRectMake(messageFromLabel.frame.origin.x + messageFromLabel.frame.size.width + 5, 7, self.view.frame.size.width - messageFromLabel.frame.origin.x - messageFromLabel.frame.size.width - 15, 20)];
    [messageSentLabel setFont:[UIFont systemFontOfSize:13]];
    [messageSentLabel setTextColor:[UIColor colorWithRed:217/255.f green:109/255.f blue:28/255.f alpha:1]];
//    [messageSentLabel setBackgroundColor:[UIColor grayColor]];
    [messageSentLabel setTextAlignment:NSTextAlignmentRight];
    
    [messageSentLabel setText:[thisMessage.sent_time whenString]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [inboxData removeObjectAtIndex:indexPath.row];
        
//        PFObject *message = nil;
//        [[[PFUser currentUser] objectForKey:@"inbox"] removeObject:message];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (!editing) {
        UIImage *editImage = [UIImage imageNamed:@"btn-edit"];
        UIImage *editBtnImage = [editImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [self.editButtonItem setBackgroundImage:editBtnImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    } else {
        UIImage *doneImage = [UIImage imageNamed:@"btn-done"];
        UIImage *doneBtnImage = [doneImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [self.editButtonItem setBackgroundImage:doneBtnImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    InboxDetailViewController *idvc = [[InboxDetailViewController alloc] init];
    [idvc setMessage:[inboxData objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:idvc animated:YES];
    [idvc release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
