//
//  ncutil3 - network configuration utility, version 3
//  NCGlobalNetInfoNode
//
//  Directory node subclass that handles the location-global
//      information.
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

/*!
  @class NCGlobalNetInfoNode
  A subclass of <TT>NCDirectoryNode</TT> that represents a global NetInfo protocol
  configuration entity.  The entity is global since it is associated with an entire
  location and not a specific network service for that location.
*/
@interface NCGlobalNetInfoNode : NCDirectoryNode
{
}

/*!
  @method initWithRootDirectory:andNetworkSet:
  Designated initializer.
*/
- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkSet:(SCNetworkSetRef)theSet;

@end