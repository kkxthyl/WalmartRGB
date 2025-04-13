/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : Processor.m                                                     *
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


#import "Processor.h"

@interface Processor (Local)
-(CameraCommand *)takeCommand;
@end

@implementation Processor

-(id)init
{
	[super init];
	_queue = [[NSMutableArray alloc] init];
		
	return self;
}

-(void)dealloc
{
	_isStop = YES;
	[_queue release];
	[super dealloc];
}


// コマンドを投入する
-(void)postCommand:(NSObject *)object
{
	if(_isStop)
	{
		return;
	}

	[_thread_lock lock];

	[_queue addObject:object];
	
	if(!_isActive)
	{
		[NSThread detachNewThreadSelector:@selector(threadProc:) toTarget:self withObject:nil];
	}
	
	[_thread_lock unlock];
}

-(void)run:(id)obj
{
	NSAutoreleasePool* pool;
	CameraCommand *  command;
	
	while(_isActive)
	{
		pool = [[NSAutoreleasePool alloc] init];

		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
		command = [[self takeCommand] retain];
		if(command != nil)
		{
			if(![command execute])
			{
				//If commands that were issued fail ( because of DeviceBusy or other reasons )
				// and retry is required , note that some cameras may become unstable if multiple 
				// commands are issued in succession without an intervening interval.
				//Thus, leave an interval of about 500 ms before commands are reissued.
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
				[self postCommand:command];
			}
		}
        [command release];

		[pool release];
	}
}

@end

@implementation Processor (Local)

//The command is taken out of the que
-(CameraCommand *)takeCommand
{
	CameraCommand *command = nil;
	
	[_thread_lock lock];
	if([_queue count] > 0)
	{
		command = [[[_queue objectAtIndex:0] retain] autorelease];
		[_queue removeObjectAtIndex:0];
	}

	[_thread_lock unlock];
	
	return command;
}

@end
