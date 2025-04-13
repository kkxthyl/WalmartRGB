/******************************************************************************
 *                                                                             *
 *   PROJECT : Eos Digital camera Software Development Kit EDSDK               *
 *                                                                             *
 *   Description: This is the Sample code to show the usage of EDSDK.          *
 *                                                                             *
 *                                                                             *
 *******************************************************************************
 *                                                                             *
 *   Written and developed by Canon Inc.                                       *
 *   Copyright Canon Inc. 2018 All Rights Reserved                             *
 *                                                                             *
 *******************************************************************************/

import Foundation

class FileCounterCommand : Command{
    
    //Count the files in the specified volume.
    func countImages(_ camera : EdsCameraRef, volumeIndex : EdsUInt32, targetFileName : inout String, outCount : inout Int, outItem : inout EdsBaseRef?, outImageItems: inout Array<EdsDirectoryItemRef>)->EdsError{
        
        var volumeCount = 0 as EdsUInt32
        var error = EdsGetChildCount(camera, &volumeCount)
        
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        if(volumeCount <= volumeIndex){
            return EdsError(EDS_ERR_DIR_NOT_FOUND)
        }
        
        var volume : EdsBaseRef? = nil
        error = EdsGetChildAtIndex(camera, EdsInt32(volumeIndex), &volume)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        var itemCount = 0 as EdsUInt32
        error = EdsGetChildCount(volume, &itemCount)
        if (error != EdsError(EDS_ERR_OK)){
            return error
        }
        
        for itemIndex in 0..<itemCount{
            var dirItem : EdsBaseRef? = nil
            error = EdsGetChildAtIndex(volume, EdsInt32(itemIndex), &dirItem)
            if (error != EdsError(EDS_ERR_OK)){
                continue
            }
            
            var dirItemInfo = EdsDirectoryItemInfo()
            error = EdsGetDirectoryItemInfo(dirItem, &dirItemInfo)
            if (error != EdsError(EDS_ERR_OK)){
                return error
            }
            
            let itemName = withUnsafePointer(to: &dirItemInfo.szFileName) {
                String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
            }
            
            if(itemName == targetFileName && dirItemInfo.isFolder == 1){
                outItem = dirItem!
                break
            }
            
            if(dirItem != nil){
                EdsRelease(dirItem)
            }
        }
        
        var dirCount = 0 as EdsUInt32
        error = EdsGetChildCount(outItem, &dirCount)
        
        for dirIndex in 0..<dirCount{
            var dirItem : EdsDirectoryItemRef? = nil
            error = EdsGetChildAtIndex(outItem, EdsInt32(dirIndex), &dirItem)
            if (error != EdsError(EDS_ERR_OK)){
                continue
            }
            
            var fileCount = 0 as EdsUInt32
            error = EdsGetChildCount(dirItem, &fileCount)
            if (error != EdsError(EDS_ERR_OK)){
                return error
            }
            outCount += Int(fileCount)
            
            for fileIndex in 0..<fileCount{
                var item : EdsDirectoryItemRef? = nil
                error = EdsGetChildAtIndex(dirItem, EdsInt32(fileIndex), &item)
                if (error != EdsError(EDS_ERR_OK)){
                    continue
                }
                outImageItems.append(item!)
            }
        }
        return error
    }
    
    func changeTargetFileName(targetFileName : inout String){
        if (targetFileName == "DCIM"){
            targetFileName = "XFVC"
        }
        else if (targetFileName == "XFVC"){
            targetFileName = ""
        }
    }
}
