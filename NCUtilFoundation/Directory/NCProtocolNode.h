//
//  ncutil3 - network configuration utility, version 3
//  NCProtocolNode
//
//  Concrete directory node class that represents a specific
//  protocol for a service.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

@class NCRootDirectory,NCServiceDirectory;

/*!
  @class NCProtocolNode
  A subclass of <TT>NCDirectoryNode</TT> that represents a network protocol
  configuration entity.
  <BR>
  A protocol node has no children associated with it.
*/
@interface NCProtocolNode : NCDirectoryNode
{
  SCNetworkProtocolRef    _networkProtocol;
}

/*!
  @method protocolNodeWithRootDirectory:andNetworkProtocol:
  Invoking this method allows the class to choose appropriate subclasses that will
  present custom property handlers, etc, necessary for network protocols that are
  attached to a <TT>SCNetworkService</TT>.
*/
+ (NCProtocolNode*) protocolNodeWithRootDirectory:(NCRootDirectory*)root andNetworkProtocol:(SCNetworkProtocolRef)theProtocol;
/*!
  @method airPortProtocolNodeWithRootDirectory:andService:
  For some reason Apple doesn't return AirPort protocol dictionaries...so we've
  gotta do it ourselves!
*/
+ (NCDirectoryNode*) airPortProtocolNodeWithRootDirectory:(NCRootDirectory*)root andService:(NCServiceDirectory*)theService;
    
/*!
  @method networkProtocol
  Returns a reference to the <TT>SCNetworkProtocol</TT> associated with the
  receiver.
*/
- (SCNetworkProtocolRef) networkProtocol;

@end
