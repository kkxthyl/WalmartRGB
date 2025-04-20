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
*   Copyright Canon Inc. 2007-2008 All Rights Reserved                             *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/

#import <Cocoa/Cocoa.h>
#import "observer.h"
#import "ActionSource.h"
#import "EDSDK.h"

@interface EvfPictureView : NSImageView <observer, ActionSource>{
	BOOL _active;
	NSRect focusRect;
	EdsUInt32 zoom;
	NSRect zoomRect;
	NSString * _actionCommand;
	NSLock * _lock;
	EdsFocusInfo	_afFrameInfo;
	EdsUInt32		_afMode;
}
-(void)getAFFrameInfo;

@end
