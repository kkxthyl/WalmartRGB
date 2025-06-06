﻿#pragma once

#include <map>
#include <iostream>
#include <iterator>
#include <list>
#include <regex>
#include <string>
#include <vector>
#include <thread>
#include <memory>
#include <cstring>
#include <sstream>
#include <filesystem>
#include "EDSDK.h"
#include "EDSDKTypes.h"

namespace fs = std::filesystem;
using namespace std::chrono_literals;

class CameraModel // : public Observable
{
protected:
	struct _EVF_DATASET
	{
		EdsStreamRef stream; // JPEG stream.
		EdsUInt32 zoom;
		EdsRect zoomRect;
		EdsPoint imagePosition;
		EdsUInt32 histogram[256 * 4]; //(YRGB) YRGBYRGBYRGBYRGB....
		EdsSize sizeJpegLarge;
	};

	EdsCameraRef _camera;
	EdsFlashRef _flash;

	// Count of UIlock
	int _lockCount;

	// Model name
	EdsChar _modelName[EDS_MAX_NAME];
	EdsUInt32 _bodyID;

	// Taking a picture parameter
	EdsUInt32 _saveTo;
	EdsUInt32 _AEMode;
	EdsUInt32 _Av;
	EdsUInt32 _Tv;
	EdsUInt32 _Iso;
	EdsUInt32 _MeteringMode;
	EdsUInt32 _ExposureCompensation;
	EdsUInt32 _ImageQuality;
	EdsUInt32 _AvailableShot;
	EdsUInt32 _evfMode;
	EdsUInt32 _evfOutputDevice;
	EdsUInt32 _evfDepthOfFieldPreview;
	EdsUInt32 _evfZoom;
	EdsPoint _evfZoomPosition;
	EdsRect _evfZoomRect;
	EdsUInt32 _evfAFMode;

	EdsFocusInfo _focusInfo;

	// List of value in which taking a picture parameter can be set
	EdsPropertyDesc _AEModeDesc;
	EdsPropertyDesc _AvDesc;
	EdsPropertyDesc _TvDesc;
	EdsPropertyDesc _IsoDesc;
	EdsPropertyDesc _MeteringModeDesc;
	EdsPropertyDesc _ExposureCompensationDesc;
	EdsPropertyDesc _ImageQualityDesc;
	EdsPropertyDesc _evfAFModeDesc;

	// private properties
	const EdsUInt32 PropID_DC_Zoom = kEdsPropID_DC_Zoom;
	const EdsUInt32 PropID_DC_Strobe = kEdsPropID_DC_Strobe;
	const EdsUInt32 PropID_LensBarrelStatus = kEdsPropID_LensBarrelStatus;
	const EdsUInt32 PropID_UTCTime = kEdsPropID_UTCTime;
	const EdsUInt32 PropID_TimeZone = kEdsPropID_TimeZone;
	const EdsUInt32 PropID_SummerTimeSetting = kEdsPropID_SummerTimeSetting;
	const EdsUInt32 PropID_ManualWhiteBalanceData = kEdsPropID_ManualWhiteBalanceData;
	const EdsUInt32 PropID_TempStatus = kEdsPropID_TempStatus;
	const EdsUInt32 PropID_MirrorLockUpState = kEdsPropID_MirrorLockUpState;
	const EdsUInt32 PropID_FixedMovie = kEdsPropID_FixedMovie;
	const EdsUInt32 PropID_MovieParam = kEdsPropID_MovieParam;
	const EdsUInt32 PropID_Aspect = kEdsPropID_Aspect;
	const EdsUInt32 PropID_MirrorUpSetting = kEdsPropID_MirrorUpSetting;
	const EdsUInt32 PropID_FocusShiftSetting = kEdsPropID_FocusShiftSetting;
	const EdsUInt32 PropID_AutoPowerOffSetting = kEdsPropID_AutoPowerOffSetting;
	const EdsUInt32 PropID_MovieHFRSetting = kEdsPropID_MovieHFRSetting;
	const EdsUInt32 PropID_RegisterFocusEdge = kEdsPropID_RegisterFocusEdge;
	const EdsUInt32 PropID_DriveFocusToEdge = kEdsPropID_DriveFocusToEdge;
	const EdsUInt32 PropID_FocusPosition = kEdsPropID_FocusPosition;
	const EdsUInt32 PropID_StillMovieDivideSetting = kEdsPropID_StillMovieDivideSetting;
	const EdsUInt32 PropID_CardExtension = kEdsPropID_CardExtension;
	const EdsUInt32 PropID_MovieCardExtension = kEdsPropID_MovieCardExtension;
	const EdsUInt32 PropID_StillCurrentMedia = kEdsPropID_StillCurrentMedia;
	const EdsUInt32 PropID_MovieCurrentMedia = kEdsPropID_MovieCurrentMedia;
	const EdsUInt32 PropID_ApertureLockSetting = kEdsPropID_ApertureLockSetting;
	const EdsUInt32 PropID_LensIsSetting = kEdsPropID_LensIsSetting;
	const EdsUInt32 PropID_ScreenDimmerTime = kEdsPropID_ScreenDimmerTime;
	const EdsUInt32 PropID_ScreenOffTime = kEdsPropID_ScreenOffTime;
	const EdsUInt32 PropID_ViewfinderOffTime = kEdsPropID_ViewfinderOffTime;
	const EdsUInt32 PropID_Evf_ClickWBCoeffs = kEdsPropID_Evf_ClickWBCoeffs;
	const EdsUInt32 PropID_Evf_RollingPitching = kEdsPropID_EVF_RollingPitching;
	const EdsUInt32 PropID_Evf_VisibleRect = kEdsPropID_Evf_VisibleRect;
	const EdsUInt32 PropID_MovieRecVolume_IntMic = kEdsPropID_MovieRecVolume_IntMic;
	const EdsUInt32 PropID_MovieRecVolume_ExtMic = kEdsPropID_MovieRecVolume_ExtMic;
	const EdsUInt32 PropID_MovieRecVolume_Acc = kEdsPropID_MovieRecVolume_Acc;
	const EdsUInt32 PropID_MovieParamEx = kEdsPropID_MovieParamEx;
	const EdsUInt32 PropID_SlowFastMode = kEdsPropID_SlowFastMode;




public:
	// Constructor
	CameraModel(EdsCameraRef camera, EdsUInt32 bodyID, EdsSaveTo saveto) : _camera(camera),
																		   _bodyID(bodyID),
																		   _saveTo(saveto)
	{
		_lockCount = 0;
		EdsFlashRef* __flash = new EdsFlashRef;
		memset(&_focusInfo, 0, sizeof(_focusInfo));
		EdsCreateFlashSettingRef(camera, (EdsFlashRef*)__flash);
		_flash = *__flash;
	}

	// Acquisition of Camera Object
	EdsCameraRef getCameraObject() const { return _camera; }


	// Acquisition of Flash Object
	EdsFlashRef getFlashObject() const { return _flash; }


	// Property
public:
	// Taking a picture parameter
	void setsaveTo(EdsUInt32 value) { _saveTo = value; }
	void setbodyID(EdsUInt32 value) { _bodyID = value; }
	void setAEMode(EdsUInt32 value) { _AEMode = value; }
	void setTv(EdsUInt32 value) { _Tv = value; }
	void setAv(EdsUInt32 value) { _Av = value; }
	void setIso(EdsUInt32 value) { _Iso = value; }
	void setMeteringMode(EdsUInt32 value) { _MeteringMode = value; }
	void setExposureCompensation(EdsUInt32 value) { _ExposureCompensation = value; }
	void setImageQuality(EdsUInt32 value) { _ImageQuality = value; }
	void setEvfMode(EdsUInt32 value) { _evfMode = value; }
	void setEvfOutputDevice(EdsUInt32 value) { _evfOutputDevice = value; }
	void setEvfDepthOfFieldPreview(EdsUInt32 value) { _evfDepthOfFieldPreview = value; }
	void setEvfZoom(EdsUInt32 value) { _evfZoom = value; }
	void setEvfZoomPosition(EdsPoint value) { _evfZoomPosition = value; }
	void setEvfZoomRect(EdsRect value) { _evfZoomRect = value; }
	void setModelName(EdsChar *modelName) { strcpy(_modelName, modelName); }
	void setEvfAFMode(EdsUInt32 value) { _evfAFMode = value; }
	void setFocusInfo(EdsFocusInfo value) { _focusInfo = value; }

	// Taking a picture parameter
	EdsUInt32 getsaveTo() const { return _saveTo; }
	EdsUInt32 getbodyID() const { return _bodyID; }
	EdsUInt32 getAEMode() const { return _AEMode; }
	EdsUInt32 getTv() const { return _Tv; }
	EdsUInt32 getAv() const { return _Av; }
	EdsUInt32 getIso() const { return _Iso; }
	EdsUInt32 getMeteringMode() const { return _MeteringMode; }
	EdsUInt32 getExposureCompensation() const { return _ExposureCompensation; }
	EdsUInt32 getImageQuality() const { return _ImageQuality; }
	EdsUInt32 getEvfMode() const { return _evfMode; }
	EdsUInt32 getEvfOutputDevice() const { return _evfOutputDevice; }
	EdsUInt32 getEvfDepthOfFieldPreview() const { return _evfDepthOfFieldPreview; }
	EdsUInt32 getEvfZoom() const { return _evfZoom; }
	EdsPoint getEvfZoomPosition() const { return _evfZoomPosition; }
	EdsRect getEvfZoomRect() const { return _evfZoomRect; }
	EdsUInt32 getEvfAFMode() const { return _evfAFMode; }
	EdsChar *getModelName() { return _modelName; }
	EdsFocusInfo getFocusInfo() const { return _focusInfo; }

	// List of value in which taking a picture parameter can be set
	EdsPropertyDesc getAEModeDesc() const { return _AEModeDesc; }
	EdsPropertyDesc getAvDesc() const { return _AvDesc; }
	EdsPropertyDesc getTvDesc() const { return _TvDesc; }
	EdsPropertyDesc getIsoDesc() const { return _IsoDesc; }
	EdsPropertyDesc getMeteringModeDesc() const { return _MeteringModeDesc; }
	EdsPropertyDesc getExposureCompensationDesc() const { return _ExposureCompensationDesc; }
	EdsPropertyDesc getImageQualityDesc() const { return _ImageQualityDesc; }
	EdsPropertyDesc getEvfAFModeDesc() const { return _evfAFModeDesc; }

	// List of value in which taking a picture parameter can be set
	void setAEModeDesc(const EdsPropertyDesc *desc) { _AEModeDesc = *desc; }
	void setAvDesc(const EdsPropertyDesc *desc) { _AvDesc = *desc; }
	void setTvDesc(const EdsPropertyDesc *desc) { _TvDesc = *desc; }
	void setIsoDesc(const EdsPropertyDesc *desc) { _IsoDesc = *desc; }
	void setMeteringModeDesc(const EdsPropertyDesc *desc) { _MeteringModeDesc = *desc; }
	void setExposureCompensationDesc(const EdsPropertyDesc *desc) { _ExposureCompensationDesc = *desc; }
	void setImageQualityDesc(const EdsPropertyDesc *desc) { _ImageQualityDesc = *desc; }
	void setEvfAFModeDesc(const EdsPropertyDesc *desc) { _evfAFModeDesc = *desc; }

public:
	// Setting of taking a picture parameter(UInt32)
	void setPropertyUInt32(EdsUInt32 propertyID, EdsUInt32 value)
	{
		switch (propertyID)
		{
		case kEdsPropID_AEModeSelect:
			setAEMode(value);
			break;
		case kEdsPropID_Tv:
			setTv(value);
			break;
		case kEdsPropID_Av:
			setAv(value);
			break;
		case kEdsPropID_ISOSpeed:
			setIso(value);
			break;
		case kEdsPropID_MeteringMode:
			setMeteringMode(value);
			break;
		case kEdsPropID_ExposureCompensation:
			setExposureCompensation(value);
			break;
		case kEdsPropID_ImageQuality:
			setImageQuality(value);
			break;
		case kEdsPropID_Evf_Mode:
			setEvfMode(value);
			break;
		case kEdsPropID_Evf_OutputDevice:
			setEvfOutputDevice(value);
			break;
		case kEdsPropID_Evf_DepthOfFieldPreview:
			setEvfDepthOfFieldPreview(value);
			break;
		case kEdsPropID_Evf_AFMode:
			setEvfAFMode(value);
			break;
		}
	}

	// Setting of taking a picture parameter(String)
	void setPropertyString(EdsUInt32 propertyID, EdsChar *str)
	{
		switch (propertyID)
		{
		case kEdsPropID_ProductName:
			setModelName(str);
			break;
		}
	}

	void setProeprtyFocusInfo(EdsUInt32 propertyID, EdsFocusInfo info)
	{
		switch (propertyID)
		{
		case kEdsPropID_FocusInfo:
			setFocusInfo(info);
			break;
		}
	}

	// Setting of value list that can set taking a picture parameter
	void setPropertyDesc(EdsUInt32 propertyID, const EdsPropertyDesc *desc)
	{
		switch (propertyID)
		{
		case kEdsPropID_AEModeSelect:
			setAEModeDesc(desc);
			break;
		case kEdsPropID_Tv:
			setTvDesc(desc);
			break;
		case kEdsPropID_Av:
			setAvDesc(desc);
			break;
		case kEdsPropID_ISOSpeed:
			setIsoDesc(desc);
			break;
		case kEdsPropID_MeteringMode:
			setMeteringModeDesc(desc);
			break;
		case kEdsPropID_ExposureCompensation:
			setExposureCompensationDesc(desc);
			break;
		case kEdsPropID_ImageQuality:
			setImageQualityDesc(desc);
			break;
		case kEdsPropID_Evf_AFMode:
			setEvfAFModeDesc(desc);
			break;
		}
	}

	// Acquisition of value list that can set taking a picture parameter
	EdsPropertyDesc getPropertyDesc(EdsUInt32 propertyID)
	{
		EdsPropertyDesc desc = {0};
		switch (propertyID)
		{
		case kEdsPropID_AEModeSelect:
			desc = getAEModeDesc();
			break;
		case kEdsPropID_Tv:
			desc = getTvDesc();
			break;
		case kEdsPropID_Av:
			desc = getAvDesc();
			break;
		case kEdsPropID_ISOSpeed:
			desc = getIsoDesc();
			break;
		case kEdsPropID_MeteringMode:
			desc = getMeteringModeDesc();
			break;
		case kEdsPropID_ExposureCompensation:
			desc = getExposureCompensationDesc();
			break;
		case kEdsPropID_ImageQuality:
			desc = getImageQualityDesc();
			break;
		case kEdsPropID_Evf_AFMode:
			desc = getEvfAFModeDesc();
			break;
		}
		return desc;
	}

	// Access to camera
public:
	EdsError UILock();
	EdsError UIUnLock();
	bool OpenSessionCommand();
	bool CloseSessionCommand();
	EdsError TakePicture(EdsShutterButton shuttertype);
	EdsError PressShutter(EdsUInt32 _status);
	EdsError SendCommand(EdsUInt32 _command, EdsUInt32 _status);
	bool DoEvfAFCommand(EdsUInt32 _status);
	EdsError StartEvfCommand();
	EdsError DownloadEvfCommand();
	EdsError EndEvfCommand();
	EdsError GetPropertyvalue(EdsPropertyID propertyID);
	EdsError GetProperty(EdsPropertyID propertyID, std::map<EdsUInt32, const char*> table);
	EdsError GetPropertyEx(EdsPropertyID propertyID, std::map<EdsUInt64, const char*> table);
	EdsError GetPropertyDesc(EdsPropertyID propertyID, std::map<EdsUInt32, const char*> prop_table);
	EdsError GetPropertyDescEx(EdsPropertyID propertyID, std::map<EdsUInt64, const char*> prop_table);
	EdsError SetPropertyValue(EdsPropertyID propertyID, std::string str);
	EdsError SetPropertyValue(EdsPropertyID propertyID, const EdsVoid* data);
	EdsError SetPropertyValueFlash(EdsPropertyID propertyID, const EdsVoid* data);
	EdsError SetProperty(EdsPropertyID propertyID, EdsInt32 data, std::map<EdsUInt32, const char *> prop_table);
	EdsError SetPropertyEx(EdsPropertyID propertyID, EdsInt32 data, std::map<EdsUInt64, const char*> prop_table);
	EdsError SetPropertyValue_NoSizeChk(EdsPropertyID propertyID, const EdsVoid* data);
	EdsError SetApertureLock(const EdsApertureLockSetting* data, std::map<EdsUInt32, const char*> prop_table);
	EdsError SetMovieFileName(EdsPropertyID propertyID, std::string data);
	EdsError TakePictureTimeInterval(EdsUInt32 times, EdsUInt32 interval);
	EdsError RecModeOn();
	EdsError RecModeOff();
	EdsError RecStart();
	EdsError RecEnd();
	EdsUInt32 GetVolume();
	EdsError FormatVolume(EdsUInt32 volume);
	EdsError SetCapacity(EdsCapacity _capacity);
	EdsError CreateFolder(); 
	EdsError ZoomToTele();
	EdsError ZoomToWide();
	EdsError ZoomStop();
	EdsError GetZoomPosition();
};
