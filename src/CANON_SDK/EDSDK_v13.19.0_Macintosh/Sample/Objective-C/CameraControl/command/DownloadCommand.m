/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : DownloadCommand.m                                               *
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


#import "DownloadCommand.h"
#import "cameraEvent.h"

@interface DownloadCommand (Local)
static EdsError EDSCALLBACK ProgressFunc(EdsUInt32 inPercent, EdsVoid *inContext, EdsBool *outCancel);
@end

@implementation DownloadCommand

-(id)init:(CameraModel *)camera withDirectoryItem:(EdsDirectoryItemRef)directoryItem
{
	[super initWithCameraModel:camera];
	_directoryItem = directoryItem;
	return self;
}

-(void)dealloc
{
	if(_directoryItem != NULL)
	{
		EdsRelease(_directoryItem);
		_directoryItem = NULL;
	}
	
	[super dealloc];
}

-(BOOL)execute
{
	EdsError error = EDS_ERR_OK;
	EdsStreamRef  stream = NULL;
	EdsDirectoryItemInfo directoryItemInfo;
	CameraEvent * event;
	NSNumber * number;
	
    NSString *slash = @"/";
    NSString *path = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, true);
    NSString *downPath = [[path objectAtIndex:0] stringByAppendingString:slash];
//    NSString *downPath = [path stringByAppendingString:slash];
    
	//Acquisition of the downloaded image information
	error = EdsGetDirectoryItemInfo(_directoryItem, &directoryItemInfo);
	
	// Forwarding beginning notification	
	if(error == EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt:0];
		event = [[CameraEvent alloc] init:@"DownloadStart" withArg:number];
		[_model notifyObservers:event];
		[event release];
		[number release];
	}
    
    NSString *fName = [NSString stringWithCString: directoryItemInfo.szFileName encoding:NSUTF8StringEncoding];
    NSString *downFileName = [downPath stringByAppendingString:fName];
    
    EdsChar *FileName = (EdsChar *) [downFileName UTF8String];
    
	//Make the file stream at the forwarding destination
	if(error == EDS_ERR_OK)
	{
		error = EdsCreateFileStream(FileName, kEdsFileCreateDisposition_CreateAlways, kEdsAccess_ReadWrite, &stream);
	}

	//Set Progress
	if(error == EDS_ERR_OK)
	{
		error = EdsSetProgressCallback(stream, ProgressFunc, kEdsProgressOption_Periodically, (EdsVoid *)self);
	}
	
	//Download image
	if(error == EDS_ERR_OK)
	{
		error = EdsDownload(_directoryItem, directoryItemInfo.size, stream);
	}

	//Forwarding completion
	if(error == EDS_ERR_OK)
	{
		error = EdsDownloadComplete(_directoryItem);
	}
	
	//Release stream
//	if(stream != NULL)
//	{
		EdsRelease(stream);
//		stream = NULL;
//	}
	
	// Forwarding completion notification
	if(error == EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt:0];
		event = [[CameraEvent alloc] init:@"DownloadCompleted" withArg:number];
		[_model notifyObservers:event];
		[event release];
		[number release];
	}
	
	//Notification of error
	if(error != EDS_ERR_OK)
	{
		number = [[NSNumber alloc] initWithInt:error];
		event = [[CameraEvent alloc] init:@"error" withArg: number];
		[_model notifyObservers:event];
		[event release];
		[number release];
	}

	return YES;
}

@end

@implementation DownloadCommand (Local)

static EdsError EDSCALLBACK ProgressFunc(EdsUInt32 inPercent, EdsVoid *inContext, EdsBool *outCancel)
{
	EdsError error = EDS_ERR_OK;
	CameraCommand *command;
	CameraEvent *event;
	NSNumber * number = [[NSNumber alloc] initWithInt:inPercent];
	
	command  = (CameraCommand *)inContext;
	event  =[[CameraEvent alloc] init:@"ProgressReport" withArg: number ];
	[[command cameraModel] notifyObservers:event];
    [event release];
	[number release];

	return error;
}

@end
