#import "EvfZoomButton.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"

#define EVF_VIEW_UPDATE_MESSAGE @"EVF_VIEW_UPDATE_MESSAGE"

@implementation EvfZoomButton

-(void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
}

-(void)update:(NSNotification *)notification
{
	CameraEvent * event;
	CameraModel * model = [notification object];
	NSDictionary* dict = [notification userInfo];
	NSString * command;
	NSNumber * number;

	event = [dict objectForKey:@"event"];
	if(event == nil)
	{
		return ;
	}

	command = [event getEvent];
	number = [event getArg];
	//Update property
	if([command isEqualToString:@"PropertyChanged"])
	{
		if([number intValue] == kEdsPropID_Evf_AFMode)
		{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setEnabled:[model getPropertyUInt32:[number intValue]]!=2];
            });
		}
	}
}

@end
