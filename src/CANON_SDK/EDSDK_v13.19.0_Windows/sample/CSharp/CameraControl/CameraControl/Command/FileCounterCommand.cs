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

using System;
using System.CodeDom;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace CameraControl
{
    class FileCounterCommand : Command
    {
        public FileCounterCommand(ref CameraModel model, ref IntPtr volume) : base(ref model) { _volume = volume; }

        public struct FileNumber
        {
            public IntPtr DirItem;
            public int dirnum;
            public int[] filenum;

            public FileNumber(int p1)
            {
                DirItem = IntPtr.Zero;
                dirnum = p1;
                filenum = new int[dirnum];
            }
        }

        private IntPtr _volume;

        public uint CountDirectory(IntPtr camera, ref IntPtr directoryItem, ref string targetFolderName, out int directory_count)
        {
            uint err = EDSDKLib.EDSDK.EDS_ERR_OK;
            int item_count = 0;
            directory_count = 0;

            // Get any folder
            IntPtr dirItem;
            EDSDKLib.EDSDK.EdsDirectoryItemInfo dirItemInfo;
            dirItemInfo.szFileName = "";
            dirItemInfo.Size = 0;

            err = EDSDKLib.EDSDK.EdsGetChildCount(_volume, out item_count);
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
            {
                return err;
            }

            for (int i = 0; i < item_count; ++i)
            {
                // Get the ith item under the specifed volume
                err = EDSDKLib.EDSDK.EdsGetChildAtIndex(_volume, i, out dirItem);
                if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
                {
                    continue;
                }

                // Get retrieved item information
                err = EDSDKLib.EDSDK.EdsGetDirectoryItemInfo(dirItem, out dirItemInfo);
                if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
                {
                    return err;
                }

                // Indicates whether or not the retrieved item is a DCIM or XFVC folder.
                if (dirItemInfo.szFileName == targetFolderName && dirItemInfo.isFolder == 1)
                {
                    directoryItem = dirItem;
                    break;
                }

                // Release retrieved item
                if (dirItem != IntPtr.Zero)
                {
                    EDSDKLib.EDSDK.EdsRelease(dirItem);
                }
            }

            // Get number of directory
            return err = EDSDKLib.EDSDK.EdsGetChildCount(directoryItem, out directory_count);

        }

        // Due to the addition of XFVC specifications, a function is provided to change the target folder.
        public void ChangeTargetFolderName(ref string targetFolderName)
        {
            if (targetFolderName == "DCIM")
            {
                targetFolderName = "XFVC";
            }
            else if (targetFolderName == "XFVC")
            {
                targetFolderName = "";
            }
        }

        public uint CountImages(IntPtr camera, ref IntPtr directoryItem, ref int directory_count, ref int fileCount, ref FileNumber fileNumber, ref List<IntPtr> imageItems)
        {
            uint err = EDSDKLib.EDSDK.EDS_ERR_OK;

            // Get the number of camera volumes
            fileCount = 0;

            // Get retrieved item information

            for (int i = 0; i < directory_count; ++i)
            {
                int count = 0;
                err = CountImagesByDirectory(ref directoryItem, i, ref count, ref imageItems);
                if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
                {
                    return err;
                }
                fileCount += count;
                fileNumber.filenum[i] = count;
            }
            return EDSDKLib.EDSDK.EDS_ERR_OK;
        }

        private uint CountImagesByDirectory(ref IntPtr directoryItem, int directoryNo, ref int image_count, ref List<IntPtr> imageItems)
        {
            int item_count = 0;

            IntPtr directoryfiles;
            IntPtr fileitem;
            EDSDKLib.EDSDK.EdsDirectoryItemInfo dirItemInfo;

            uint err = EDSDKLib.EDSDK.EdsGetChildAtIndex(directoryItem, directoryNo, out directoryfiles);
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
            {
                return err;
            }

            // Get retrieved item information
            // Get item name
            err = EDSDKLib.EDSDK.EdsGetDirectoryItemInfo(directoryfiles, out dirItemInfo);
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
            {
                return err;
            }

            int index = 0, filecount = 0;
            err = EDSDKLib.EDSDK.EdsGetChildCount(directoryfiles, out item_count);
            if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
            {
                return err;
            }
            for (index = 0; index < item_count; ++index)
            {
                err = EDSDKLib.EDSDK.EdsGetChildAtIndex(directoryfiles, index, out fileitem);
                if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
                {
                    return err;
                }

                // Get retrieved item information
                err = EDSDKLib.EDSDK.EdsGetDirectoryItemInfo(fileitem, out dirItemInfo);
                if (err != EDSDKLib.EDSDK.EDS_ERR_OK)
                {
                    return err;
                }
                if (dirItemInfo.isFolder == 0)
                {
                    imageItems.Add(fileitem);
                    filecount += 1;
                }

            }
            image_count = filecount;

            return EDSDKLib.EDSDK.EDS_ERR_OK;
        }


    }

}
