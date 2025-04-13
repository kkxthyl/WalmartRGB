/******************************************************************************
*                                                                             *
*   PROJECT : EOS Digital Software Development Kit EDSDK                      *
*      NAME : CameraEvfData.m                                                 *
*                                                                             *
*   Description: This is the Sample code to show the usage of EDSDK.          *
*                                                                             *
*                                                                             *
*******************************************************************************
*                                                                             *
*   Written and developed by Camera Design Dept.53                            *
*   Copyright Canon Inc. 2007 All Rights Reserved                             *
*                                                                             *
*******************************************************************************
*   File Update Information:                                                  *
*     DATE      Identify    Comment                                           *
*   -----------------------------------------------------------------------   *
*   06-03-22    F-001        create first version.                            *
*                                                                             *
******************************************************************************/


#import "CameraEvfData.h"


@implementation CameraEvfData

- (id) init 
{
	[super init];
	
	_stream = NULL;
	_zoom = 1;
	return self;
}

-(void)dealloc
{
	if(_stream != NULL)
	{
		EdsRelease(_stream);
	}
	[super dealloc];
}

-(void)setStream:(EdsStreamRef)stream
{
	_stream = stream;
//	EdsCopyData(stream, sizeof(stream), _stream);
}

-(void)setZoom:(EdsInt32)zoom
{
	_zoom = zoom;
}

-(void)setZoomRect:(EdsRect)zoomRect
{
	_zoomRect = zoomRect;
}

-(void)setZoomPosition:(EdsPoint)zoomPosition
{
	_zoomPosition = zoomPosition;
}

-(void)setImagePosition:(EdsPoint)imagePosition
{
	_imagePosition = imagePosition;
}

-(void)setHistogram:(EdsUInt32 *)histogram
{
    memcpy(_histogram, histogram, sizeof(EdsUInt32) * 256 * 4);
}

-(void)setSizeJpeglarge:(EdsSize)sizeJpeglarge
{
	_sizeJpeglarge = sizeJpeglarge;
}

-(EdsStreamRef)stream
{
	return _stream;
}

-(EdsUInt32)zoom
{
	return _zoom;
}

-(EdsRect)zoomRect
{
	return _zoomRect;
}

-(EdsPoint)zoomPosition
{
	return _zoomPosition;
}

-(EdsPoint)imgaePosition
{
	return _imagePosition;
}

-(EdsUInt32 *)histogram
{
	return _histogram;
}

-(EdsSize)sizeJpeglarge
{
	return _sizeJpeglarge;
}

@end
