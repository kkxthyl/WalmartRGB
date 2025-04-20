/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : PropertyPopUp.m                                                 *
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

#import "PropertyPopUp.h"

@implementation PropertyPopUp

-(void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update:) name:VIEW_UPDATE_MESSAGE object:nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{

	[super initWithCoder:decoder];
	_actionCommand = nil;
	_propertyList = nil;
	
	[self setEnabled:NO];
	_lock = [[NSLock alloc] init];	
	return self;
}


-(void)dealloc
{
	[_actionCommand release];
	[_propertyList release];
	[_lock release];
	[super dealloc];
}

-(void)updateProperty:(EdsUInt32)value
{
	NSException * exception = nil;
	[_lock lock];
NS_DURING		NSString *string = [[_propertyList objectForKey:[NSNumber numberWithInt:value]] retain];
	
	if(string != nil)
	{
        dispatch_async(dispatch_get_main_queue(), ^{
            int index;

            index = (int)[self indexOfItemWithTitle:string];
            if(index == -1)
            {
                [self addItemWithTitle:string];
                index = (int)[self indexOfItemWithTitle:string];
            }
            else
            {
                [self selectItemAtIndex:index];
            }
        });
		[string release];
	}
NS_HANDLER
	exception = localException;
NS_ENDHANDLER
	[exception raise];
	[_lock unlock];	
}

-(void)updatePropertyDesc:(EdsPropertyDesc *)desc
{
	int i;
	NSString *string;
	NSString *selectedString;

	NSException * exception = nil;
	[_lock lock];
NS_DURING	
	selectedString = [self titleOfSelectedItem];
	[self removeAllItems];

	if(desc->numElements == 0)
	{
		if( selectedString )
			[self addItemWithTitle:selectedString];
		[self setEnabled:NO];
	} else {
	

		for(i = 0; i < desc->numElements; i++)
		{
			string = [[_propertyList objectForKey:[NSNumber numberWithInt:(desc->propDesc[i])]] retain];

			if(string != nil)
			{
				[self performSelectorOnMainThread:@selector( addItemWithTitle: )  withObject:string waitUntilDone:YES];
				[[self lastItem] setRepresentedObject:[NSNumber numberWithInt:(desc->propDesc[i])]];
				[string release];
			}
		
		}
	
		[self selectItemWithTitle:selectedString];
		[self setEnabled:YES];
	}
NS_HANDLER
	exception = localException;
NS_ENDHANDLER
	[exception raise];
	[_lock unlock];	
}

-(void)update:(NSNotification *)notification
{
}

-(void)setActionCommand:(NSString *)command
{
	[_actionCommand release];
	_actionCommand = [command retain];
}

-(void)fireEvent
{
	ActionEvent *event;
	NSString * selectedString;
	NSNumber * number;
	NSEnumerator * enumerator;
	NSDictionary * dict;

	selectedString = [self titleOfSelectedItem];
	NSNumber * selectedNumber = [[self selectedItem] representedObject];
	enumerator = [_propertyList keyEnumerator];
	while((number = [enumerator nextObject])  != nil)
	{
		if([selectedNumber compare:number] == NSOrderedSame)
		{
			break;
		}
	}
	
	if(number != nil)
	{
		event = [[ActionEvent alloc] init:_actionCommand withArgument:number];
		dict = [[NSDictionary alloc] initWithObjectsAndKeys: event,  @"action_event", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_PERFORMED_MESSAGE object:self userInfo:dict];
		[event release];
		[dict release];
	}
}

@end
