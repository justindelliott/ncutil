//
//  ncutil3 - network configuration utility, version 3
//  NCServiceDirectory
//
//  Concrete directory node class that represents a service
//  in the preference tree.
//
//  Created by Jeffrey Frey on Sat Jun  4 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

@class NCServiceDirectory,NCProtocolNode,NCInterfaceNode;

/*!
  @class NCServiceDirectory
  A subclass of <TT>NCDirectoryNode</TT> that represents a network service.
  <BR>
  A service node has the following kinds of children associated with it:
  <UL>
    <LI>
      A network interface to which the service's configuration applies, as
      a descendant of <TT>NCInterfaceNode</TT>
    </LI>
    <LI>
      Various networking protocol configuration nodes, each as a descendent
      of <TT>NCProtocolNode</TT>
    </LI>
  </UL>
*/
@interface NCServiceDirectory : NCDirectoryNode
{
  SCNetworkServiceRef   _networkService;
}

/*!
  @method initWithRootDirectory:andNetworkService:
  Designated initializer, initializes the service directory and all of its
  subdirectories.
*/
- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkService:(SCNetworkServiceRef)theService;
/*!
  @method initWithRootDirectory:andNewNetworkService:
  Initializes a newly-created service directory and adds all default protocols
  to it.
*/
- (id) initWithRootDirectory:(NCRootDirectory*)root andNewNetworkService:(SCNetworkServiceRef)theService;

/*!
  @method networkService
  Return a reference to the <TT>SCNetworkService</TT> associated with the receiver.
*/
- (SCNetworkServiceRef) networkService;
/*!
  @method networkServiceID
  Returns the receiver's unique network service ID string.
*/
- (CFStringRef) networkServiceID;
/*!
  @method removeService
  Remove the receiver's network service from it's parent (which is a network
  set).
*/
- (void) removeService;

/*!
  @method pushInterfaceLayerOfType:
  Attempts to layer an interface on top of the service's existing interface.
*/
- (BOOL) pushInterfaceLayerOfType:(CFStringRef)type;
/*!
  @method popInterfaceLayer
  Attempts to remove the top-most interface layer.  Fails if only one layer
  exists.
*/
- (BOOL) popInterfaceLayer;

/*!
  @method searchForProtocol:
  Convenience method that does a shallow search from the receiver, looking for a
  node descended from <TT>NCProtocolNode</TT> with <TT>protocolName</TT>
  as it's directory name.
*/
- (NCProtocolNode*) searchForProtocol:(CFStringRef)protocolName;
/*!
  @method topLevelInterface
  Returns the top-level interface (as a descendent of <TT>NCInterfaceNode</TT>)
  for the receiver.
*/
- (NCInterfaceNode*) topLevelInterface;
/*!
  @method baseLevelInterface
  Returns the interface (as a descendent of <TT>NCInterfaceNode</TT>) at the
  bottom of the interface stack for the receiver.
*/
- (NCInterfaceNode*) baseLevelInterface;
/*!
  @method searchForInterface:
  Convenience method that does a deep search from the receiver, looking for a
  node descended from <TT>NCInterfaceNode</TT> with <TT>interfaceName</TT>
  as it's directory name.
*/
- (NCInterfaceNode*) searchForInterface:(CFStringRef)interfaceName;
/*!
  @method protocolChain
  Returns the first protocol node in the chain of protocols for this service.
*/
- (NCProtocolNode*) protocolChain;

@end
