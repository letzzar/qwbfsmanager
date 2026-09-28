/****************************************************************************
**
** 		Created using Monkey Studio IDE v1.8.4.0 (1.8.4.0)
** Authors   : Filipe Azevedo aka Nox P@sNox <pasnox@gmail.com>
** Project   : Fresh Library
** FileName  : pPartitionModel_mac.cpp
** Date      : 2011-02-20T00:41:35
** License   : LGPL v3
** Home Page : http://bettercodes.org/projects/fresh
** Comment   : Fresh Library is a Qt 4 extension library providing set of new core & gui classes.
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU Leser General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** This package is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU Lesser General Public License for more details.
**
** You should have received a copy of the GNU Lesser General Public License
** along with this program. If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/
#include "pPartitionModel.h"

/*
http://www.datarecovery.com/hexcodes.asp
http://stackoverflow.com/questions/1515068/list-all-drives-partitions-and-get-dev-rdisc-device-with-cocoa
*/

#import <DiskArbitration/DiskArbitration.h>

#include <sys/param.h>
#include <sys/mount.h>

#include <FreshCore/pMacHelpers>

#include <QStringList>
#include <QFile>
#include <QDebug>

class DADisksSession
{
public:
	DADisksSession( pPartitionModel* model )
	{
		mModel = model;
		
		// init session
		mSession = DASessionCreate( kCFAllocatorDefault );
		DARegisterDiskAppearedCallback( mSession, 0/*all disks*/, diskAppeared, mModel );
		DARegisterDiskDescriptionChangedCallback( mSession, 0/*all disks*/, 0/*all keys*/, diskChanged, mModel );
		DARegisterDiskDisappearedCallback( mSession, 0/*all disks*/, diskDisappeared, mModel );
		DASessionScheduleWithRunLoop( mSession, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
	}
	
	virtual ~DADisksSession()
	{
		// deinit session
		DASessionUnscheduleFromRunLoop( mSession, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
		CFRelease( mSession );
	}
	
	static int fileSystemId( const QString& kind )
	{
		const QString k = kind.toLower();
		
		if ( k == "msdos" ) {
			return 0x0C; // FAT32 (LBA)
		}
		else if ( k == "ntfs" || k == "exfat" ) {
			return 0x07;
		}
		
		return 0xAF; // HFS / HFS+ / APFS and others, as the Carbon API reported
	}
	
	static pPartition createPartition( DADiskRef disk )
	{
		const CFDictionaryRef dict = DADiskCopyDescription( disk );
		QVariantMap properties = pMacHelpers::toQVariantMap( dict );
		pPartition partition;
		
		CFRelease( dict );
		
		// set properties on partitions only
		if ( !properties.value( "DAMediaWhole" ).toBool() ) {
			const QString devicePath = QString( "/dev/%1" ).arg( properties.value( "DAMediaBSDName" ).toString() );
			
			if ( pPartition::isWBFSPartition( devicePath ) ) {
				properties[ "DAVolumeKindId" ] = 0x25;
				properties[ "DAVolumeKind" ] = pPartition::fileSystemIdToString( 0x25 );
			}
			
			qint64 total = properties.value( "DAMediaSize", -1 ).toLongLong();
			qint64 free = -1;
			
			// get volume infos (total bytes, free bytes...) of mounted volumes
			// (FSGetVolumeForDADisk/FSGetVolumeInfo Carbon APIs are deprecated since 10.8)
			const QString volumePath = properties.value( "DAVolumePath" ).toString();
			
			if ( properties[ "DAVolumeKindId" ] != 0x25 && !volumePath.isEmpty() ) {
				struct statfs stats;
				
				if ( statfs( QFile::encodeName( volumePath ).constData(), &stats ) == 0 ) {
					total = (qint64)stats.f_blocks *(qint64)stats.f_bsize;
					free = (qint64)stats.f_bavail *(qint64)stats.f_bsize;
				}
				
				properties[ "DAVolumeKindId" ] = fileSystemId( properties.value( "DAVolumeKind" ).toString() );
			}
			
			partition.setProperties( properties );
			partition.updateSizes( total, free );
		}
		
		return partition;
	}
	
	static void diskAppeared( DADiskRef disk, void* context )
	{
		pPartitionModel* model = static_cast<pPartitionModel*>( context );
		model->updatePartition( createPartition( disk ) );
	}
	
	static void diskChanged( DADiskRef disk, CFArrayRef keys, void* context )
	{
		Q_UNUSED( keys );
		pPartitionModel* model = static_cast<pPartitionModel*>( context );
		model->updatePartition( createPartition( disk ) );
	}
	
	static void diskDisappeared( DADiskRef disk, void* context )
	{
		pPartitionModel* model = static_cast<pPartitionModel*>( context );
		model->removePartition( QString( "/dev/%1" ).arg( DADiskGetBSDName( disk ) ) );
	}

protected:
	pPartitionModel* mModel;
	DASessionRef mSession;
};

void pPartitionModel::platformInit()
{
	emit layoutAboutToBeChanged();
	mData = new DADisksSession( this );
	emit layoutChanged();
}

void pPartitionModel::platformDeInit()
{
	delete (DADisksSession*)mData;
}

void pPartitionModel::platformUpdate()
{
	// Code commented as the mac implementation has the concept of live auto update, thanks Disk Arbitration framework :)
	/*const QStringList partitions = customPartitions();
	
	emit layoutAboutToBeChanged();
	delete (DADisksSession*)mData;
	mPartitions.clear();
	foreach ( const QString& partition, partitions ) {
		mPartitions << pPartition( partition );
	}
	mData = new DADisksSession( this );
	emit layoutChanged();*/
}
