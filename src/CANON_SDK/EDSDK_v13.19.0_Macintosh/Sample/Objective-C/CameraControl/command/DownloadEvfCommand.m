/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : DownloadEvfCommand.m                                            *
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


#import "DownloadEvfCommand.h"
#import "cameraEvent.h"
#import "CameraEvfData.h"

@implementation DownloadEvfCommand

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	CameraEvent * event;
	
	EdsEvfImageRef imageRef = NULL;
	EdsStreamRef streamRef = NULL;
	EdsUInt32 zoom;
	EdsRect zoomRect;
	EdsPoint zoomPosition;
	EdsPoint imagePosition;
//	EdsUInt32 histogram[256*4];
	EdsSize sizeJpegLarge;
	EdsUInt64 bufferSize = 2 * 1024 * 1024;
	CameraEvfData *evfData;
	NSNumber * number;

	// Exit unless during live view.
	if( ([_model evfOutputDevice] & kEdsEvfOutputDevice_PC) == 0)
	{
		return YES;
	}

    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];

	// Create memory stream.
	error = EdsCreateMemoryStream(bufferSize, &streamRef);

	// Create EvfImageRef.
	if(error == EDS_ERR_OK)
	{
		error = EdsCreateEvfImageRef(streamRef, &imageRef);
	}

	// Download live view image data.
	if(error == EDS_ERR_OK)
	{
		error = EdsDownloadEvfImage([_model camera], imageRef);
	}

	// Get meta data for live view image data.
	if(error == EDS_ERR_OK)
	{
		evfData = [[CameraEvfData alloc] init];
		[evfData setStream: streamRef];
		
		// Get magnification ratio (x1, x5, or x10).
		EdsGetPropertyData(imageRef, kEdsPropID_Evf_Zoom, 0, sizeof(zoom), &zoom);
		[evfData setZoom:zoom];
		
		EdsGetPropertyData(imageRef, kEdsPropID_Evf_ZoomRect, 0, sizeof(zoomRect), &zoomRect);
		[evfData setZoomRect:zoomRect];

		// Get position of the focus border.
		// Upper left coordinate of the focus border using JPEG Large size as a reference.
		EdsGetPropertyData(imageRef, kEdsPropID_Evf_ZoomPosition, 0, sizeof(zoomPosition), &zoomPosition);
		[evfData setZoomPosition:zoomPosition];
		
		// Get position of image data. (when enlarging)
		// Upper left coordinate using JPEG Large size as a reference.
		EdsGetPropertyData(imageRef, kEdsPropID_Evf_ImagePosition, 0, sizeof(imagePosition), &imagePosition);
		[evfData setImagePosition:imagePosition];
		
//		// Get histogram (RGBY).
//		EdsGetPropertyData(imageRef, kEdsPropID_Evf_Histogram, 0,  sizeof(histogram), histogram);
//		[evfData setHistogram:histogram];
		
		// Set the size of Jpeg Large.
		EdsGetPropertyData(imageRef, kEdsPropID_Evf_CoordinateSystem, 0,  sizeof(sizeJpegLarge), &sizeJpegLarge);
		[evfData setSizeJpeglarge:sizeJpegLarge];
					
		// Set to model.
		[_model setEvfZoom:zoom];
		[_model setEvfZoomPosition:zoomPosition];
	
		// Live view image transfer complete notification.
		if(error == EDS_ERR_OK)
		{
			event = [[CameraEvent alloc] init:@"EvfDataChanged" withArg: evfData];
			[_model notifyObservers:event];
            [event release];
		}
        [evfData release];

//		if(imageRef != NULL)
//		{
			EdsRelease(imageRef);
//		}
	}
	
//	if(streamRef != NULL)
//	{
		EdsRelease(streamRef);
//	}
//	if(imageRef != NULL)
//	{
		EdsRelease(imageRef);
//	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		
		// Retry getting image data if EDS_ERR_OBJECT_NOTREADY is returned
		// when the image data is not ready yet.
		if(error == EDS_ERR_OBJECT_NOTREADY)
		{
			return NO;
		}
		
		// It retries it at device busy
		if(error == EDS_ERR_DEVICE_BUSY)
		{	
			number = [[NSNumber alloc] initWithInt:error];
			event = [[CameraEvent alloc] init:@"DeviceBusy" withArg: number];
			[_model notifyObservers:event];	
			[event release];
			[number release];	
			return NO;
		}
		
		number = [[NSNumber alloc] initWithInt:error];
		event = [[CameraEvent alloc] init:@"error" withArg: number];
		[_model notifyObservers:event];	
		[event release];
		[number release];	
		return NO;
	}

	return YES;
}

@end
