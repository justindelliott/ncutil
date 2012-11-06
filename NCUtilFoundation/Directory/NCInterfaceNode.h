//
//  ncutil3 - network configuration utility, version 3
//  NCInterfaceNode
//
//  Concrete directory node class that represents a specific
//  interface for a service.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

/*!
  @class NCInterfaceNode
  A subclass of <TT>NCDirectoryNode</TT> that represents a network interface.
  Network interfaces may be layered (e.g. PPP on top of Ethernet), so each
  interface node will have at most one child, which will also be a
  <TT>NCInterfaceNode</TT> descendant.
*/
@interface NCInterfaceNode : NCDirectoryNode
{
  SCNetworkInterfaceRef   _networkInterface;
  CFArrayRef              _supportedLayers;
}

/*!
  @method interfaceNodeWithRootDirectory:andNetworkInterface:
  Invoking this method allows the class to choose appropriate subclasses that will
  present custom property handlers, etc, necessary for network interfaces that are
  attached to a <TT>SCNetworkService</TT>.  For template network interfaces use the
  <TT>templateInterfaceNodeWithRootDirectory:andNetworkInterface:</TT> method to create an
  instance.
*/
+ (NCInterfaceNode*) interfaceNodeWithRootDirectory:(NCRootDirectory*)root andNetworkInterface:(SCNetworkInterfaceRef)theInterface;
/*!
  @method templateInterfaceNodeWithRootDirectory:andNetworkInterface:
  Invoking this method creates bare-bones interface objects that are appropriate when
  used to represent a network interface returned by the <TT>SCNetworkInterfaceCopyAll()</TT>
  function -- i.e. an instance of <TT>SCNetworkInterface</TT> that has no configuration data
  associated with it.  Typically, the BSD device name and/or MAC address will still be
  associated with these objects and will thus be visible via <TT>NCDirectoryNode</TT> methods.
  Template nodes are locked by default.
*/
+ (NCInterfaceNode*) templateInterfaceNodeWithRootDirectory:(NCRootDirectory*)root andNetworkInterface:(SCNetworkInterfaceRef)theInterface;
/*!
  @method networkInterface
  Returns a reference to the <TT>SCNetworkInterfaceRef</TT> associated with the
  receiver.
*/
- (SCNetworkInterfaceRef) networkInterface;
/*!
  @method networkInterfaceType
  Returns the type string for the receiver's interface.
*/
- (CFStringRef) networkInterfaceType;
/*!
  @method isInterfaceTemplate
  Returns <TT>YES</TT> if the receiver is meant to be used as an interface template.
*/
- (BOOL) isInterfaceTemplate;

/*!
  @method createNetworkService
  Creates a new network service using the receiver as the template.  Note that this
  method only works for instances that are locked.
*/
- (SCNetworkServiceRef) createNetworkService;

/*!
  @method supportedInterfaceTypes
  Returns an array of the interface types that may be layered on top of the
  receiver's interface.
*/
- (CFArrayRef) supportedInterfaceTypes;

@end
