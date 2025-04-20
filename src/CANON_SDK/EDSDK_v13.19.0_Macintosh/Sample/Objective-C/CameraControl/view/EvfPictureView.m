/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : EvfPictureView.h                                                *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2007-2010 All Rights Reserved                        *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/

#import "EvfPictureView.h"
#import "cameraEvent.h"
#import "cameraModel.h"
#import "EDSDK.h"
#import "CameraEvfData.h"


#define EVF_VIEW_UPDATE_MESSAGE @"EVF_VIEW_UPDATE_MESSAGE"

@interface EvfPictureView (Local)
-(void)updateView:(NSNotification *)notification;
//-(void)setFocusRect:(NSPoint)point withArgument:(NSSize)sizeJpegLarge;
@end

@implementation EvfPictureView
- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
	
	_active = NO;	
	_actionCommand = @"download_evf";
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:EVF_VIEW_UPDATE_MESSAGE object:nil];
	[self setImageFrameStyle:NSImageFramePhoto];
    [self setImageScaling:NSImageScaleAxesIndependently];

	[self setImage: nil];
	_lock = [[NSLock alloc] init];
	memset(&_afFrameInfo, 0, sizeof(_afFrameInfo));
	return self;
}

-(void)dealloc
{
	[_lock release];
	[_actionCommand release];
	[super dealloc];
}

-(void)update:(NSNotification *)notification
{
	CameraEvent * event;
	NSString * command;
	NSDictionary * sendDict;
	EdsUInt32 device;
	EdsUInt32 propertyID;
	CameraModel * model = [notification object];
	NSNumber * number;
	
	event = [[notification userInfo] objectForKey:@"event"];
	if(event == nil)
	{
		return ;
	}

	command = [event getEvent];
	if([command isEqualToString:@"EvfDataChanged"])
	{
		sendDict = [[NSDictionary alloc] initWithObjectsAndKeys: [event retain], @"camera_event", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:EVF_VIEW_UPDATE_MESSAGE object:self userInfo:sendDict];
		[event release];
		[sendDict release];
		//Get AF Frame
		[self getAFFrameInfo];
		
		// Download image data.
		[self fireEvent];
	}
	
	if([command isEqualToString:@"PropertyChanged"])
	{
		number = [event getArg];
		propertyID = [number intValue];
		if(propertyID  == kEdsPropID_Evf_OutputDevice)
		{
			device = [model evfOutputDevice];

			// PC live view has started.
			if(!_active && (device & kEdsEvfOutputDevice_PC) != 0)
			{
				_active = YES;
				// Start download of image data.
				[self fireEvent];
			}
			
			// PC live view has ended.
			if(_active && (device & kEdsEvfOutputDevice_PC) == 0)
			{
				_active = NO;
			}
		}
		if(propertyID == kEdsPropID_FocusInfo)
		{
			EdsFocusInfo afFrameInfo = [model focusInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                float xRatio = 1;
                float yRatio = 1;
                NSRect windowRect = [self bounds];
                EdsUInt32 i;

                _afFrameInfo = afFrameInfo;
                xRatio = (float)(windowRect.size.width)/(float)(_afFrameInfo.imageRect.size.width);
                yRatio = (float)(windowRect.size.height)/(float)(_afFrameInfo.imageRect.size.height);
                for( i = 0; i < _afFrameInfo.pointNumber; i++)
                {
                    _afFrameInfo.focusPoint[i].rect.size.width = (EdsUInt32)(_afFrameInfo.focusPoint[i].rect.size.width * xRatio);
                    _afFrameInfo.focusPoint[i].rect.size.height = (EdsUInt32)(_afFrameInfo.focusPoint[i].rect.size.height * yRatio);
                    _afFrameInfo.focusPoint[i].rect.point.x = (EdsUInt32)(_afFrameInfo.focusPoint[i].rect.point.x * xRatio);
                    _afFrameInfo.focusPoint[i].rect.point.y = windowRect.size.height - (EdsUInt32)(_afFrameInfo.focusPoint[i].rect.point.y * yRatio) - _afFrameInfo.focusPoint[i].rect.size.height;
                }
            });
		}
		if(propertyID == kEdsPropID_Evf_AFMode)
		{
			_afMode = [model evfAFMode];
		}		
	}
}

-(void)fireEvent
{
	ActionEvent * event;
	NSDictionary * dict;

	event = [[[ActionEvent alloc] init:_actionCommand withArgument:nil]autorelease];//
	dict = [[NSDictionary alloc] initWithObjectsAndKeys: event, @"action_event", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_PERFORMED_MESSAGE object:self userInfo:dict];
    [dict release];
}

-(void)getAFFrameInfo
{
	ActionEvent * event;
	NSDictionary * dict;
	NSString * command = @"get_Property";
	NSNumber * arg = [NSNumber numberWithInt:kEdsPropID_FocusInfo];

	event = [[[ActionEvent alloc] init:command withArgument:arg] autorelease];
	dict = [[[NSDictionary alloc] initWithObjectsAndKeys: event, @"action_event", nil] autorelease];
	[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_PERFORMED_MESSAGE object:self userInfo:dict];
}

@end

@implementation EvfPictureView (Local)
-(void)updateView:(NSNotification *)notification
{
	NSImage * image;
	CameraEvfData * evfData;
	CameraEvent * event;
	unsigned char *pImage;
	EdsUInt64	imageSize;
	NSData *data;
	
[_lock lock];
	event = [[[notification userInfo] objectForKey:@"camera_event"] retain];
	evfData = [event getArg];
	if(evfData == nil)
	{
		[event release];
	}
	else{
		// Get image (JPEG) pointer.
		EdsGetPointer([evfData stream], (EdsVoid **)&pImage);
		if(pImage == nil)
		{
			[event release];
		}
		else{
			EdsGetLength([evfData stream], &imageSize);

			zoom = [evfData zoom];
			// Display the focus border if displaying the entire image.
			if(zoom == 1)
			{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setZoomRect:NSMakeRect([evfData zoomRect].point.x, [evfData zoomRect].point.y, [evfData zoomRect].size.width, [evfData zoomRect].size.height)
                         withArgument:NSMakeSize([evfData sizeJpeglarge].width, [evfData sizeJpeglarge].height)];
                });
			}

			data = [[NSData alloc] initWithBytes:pImage length:imageSize];
			image = [[NSImage alloc] initWithData:data];
			[data release];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSImageView * imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 379, 279)];
                // Display image data.
                [self setImage:image];
                [self addSubview:imageView];

                [imageView release];
            });
			[image release];
			[event release];
		}
	}
[_lock unlock];
}


-(void)setZoomRect:(NSRect)rect withArgument:(NSSize)sizeJpegLarge
{
    // The zoomPosition is given by the coordinates of the upper left of the focus border using Jpeg Large size as a reference.
    
    // The size of the focus border is one fifth the size of Jpeg Large.
    // Because the image fills the entire window, the height and width to be drawn is one fifth of the window size.
    
    double imageWidth = sizeJpegLarge.width;
    double imageHeight = sizeJpegLarge.height;
    NSRect windowRect = [self bounds];
    
    // width coordinate to be drawn.
    focusRect.size.width = rect.size.width * windowRect.size.width / imageWidth;
    // height coordinate to be drawn.
    focusRect.size.height = rect.size.height * windowRect.size.height / imageHeight;
    
    // Lower left coordinate to be drawn.
    focusRect.origin.x = rect.origin.x * windowRect.size.width / imageWidth;
    focusRect.origin.y = windowRect.size.height - rect.origin.y * windowRect.size.height / imageHeight;
    focusRect.origin.y -= focusRect.size.height;
}

-(void)drawRect:(NSRect)rect
{		
	[super drawRect:rect];
	[NSBezierPath setDefaultLineWidth:1.5];
	if(zoom == 1)
	{
		// Draw Zoom Rect
		if(_afMode!=2)
		{
			[[NSColor whiteColor] set];
			[NSBezierPath strokeRect:focusRect];
		}

		// Draw AF Frames
		EdsUInt32	i;
		for(i = 0; i < _afFrameInfo.pointNumber; i++)
		{
			if(_afFrameInfo.focusPoint[i].valid==1) {
				// Selecte Just Focus Pen
				if(_afFrameInfo.focusPoint[i].justFocus&1) {
					[[NSColor greenColor] set];
				} else {
					[[NSColor whiteColor] set];
				}
				if(_afFrameInfo.focusPoint[i].selected!=1)
				{
					[[NSColor grayColor] set];
				}
				// Set Frame Rect
				NSRect frame = {0};
				frame.origin.x = _afFrameInfo.focusPoint[i].rect.point.x;
				frame.origin.y = _afFrameInfo.focusPoint[i].rect.point.y;
				frame.size.width = _afFrameInfo.focusPoint[i].rect.size.width;
				frame.size.height = _afFrameInfo.focusPoint[i].rect.size.height;
				[NSBezierPath strokeRect:frame];
			}
		}
	}
}

@end
