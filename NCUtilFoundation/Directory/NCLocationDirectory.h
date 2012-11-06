//
//  ncutil3 - network configuration utility, version 3
//  NCLocationDirectory
//
//  Concrete directory node class that represents a location
//  in the preference tree.
//
//  Created by Jeffrey Frey on Sat Jun  4 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

@class NCServiceDirectory,NCInterfaceNode;

/*!
  @class NCLocationDirectory
  A subclass of <TT>NCDirectoryNode</TT> that represents a network set --
  classically called a location.
  <BR>
  A location node has the following kinds of children associated with it:
  <UL>
    <LI>
      Each network service defined for it, as <TT>NCServiceDirectory</TT>
      instances.
    </LI>
    <LI>
      A global NetInfo configuration entity, as a <TT>NCGlobalNetInfoNode</TT>
      instance.
    </LI>
  </UL>
  Starting in 10.5 (Leopard) NetInfo is deprecated and no NetInfo entities
  are processed by ncutil.
*/
@interface NCLocationDirectory : NCDirectoryNode
{
  SCNetworkSetRef     _networkSet;
  NCPropertyHandler*  _propertyHandler;
  CFArrayRef          _serviceOrderByName;
  CFDictionaryRef     _serviceIDsByName;
}

/*!
  @method initWithRootDirectory:andNetworkSet:
  Designated initializer, initializes the location directory and all of its
  subdirectories.
*/
- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkSet:(SCNetworkSetRef)theSet;

/*!
  @method networkSet
  Return a reference to the <TT>SCNetworkSet</TT> associated with the receiver.
*/
- (SCNetworkSetRef) networkSet;
/*!
  @method setAsCurrentLocation
  Make the receiver the current location.  Note that the root node of a directory
  tree maintains the name of the current location as one of its properties.  If you
  invoke this method directly, you should also invoke the <TT>refresh</TT> method on
  the root directory node to account for this change.  The <TT>refresh</TT> is not
  done automatically since an <TT>NCRootDirectory</TT> instance calls this method
  itself when committing the current location found in its property cache.
*/
- (void) setAsCurrentLocation;
/*!
  @method removeLocation
  Removes the network set referenced by the receiver from the preference store.
  The receiver itself is detached from the directory tree and released; all subdirectories
  are released and their directory IDs deallocated, as well.
*/
- (void) removeLocation;

/*!
  @method addServiceWithName:andInterface:
  Attempts to create and add a new network service to this location.  If the name
  supplied for the service is not unique to this location the service will not be
  created.  The network interface should be one of the templates retrieved via
  the <TT>SCNetworkInterfaceCopyAll()</TT> function.  Interface template nodes in
  a <TT>NCRootDirectory</TT> directory tree (under the "Interfaces" subdirectory)
  are initialized via these <TT>NetworkInterface</TT>s and can be used:
<PRE>
//  Assume 'root' is a valid NCRootDirectory
NCLocationDirectory*   locationNode = [root locationWithName:CFSTR("Default")];
NCInterfaceNode*       interfaceTmpl = [root searchForNodeWithPath:
                                CFSTR("/Interfaces/Built-in Ethernet")];
if (locationNode && interfaceTmpl) {
  [locationNode addServiceWithName:CFSTR("Built-in Ethernet (DHCP)")
      andInterface:networkInterface];
}
</PRE>
*/
- (BOOL) addServiceWithName:(CFStringRef)name andInterface:(NCInterfaceNode*)interface;

/*!
  @method serviceWithName:
  Convenience method that does a shallow search from the receiver, looking for a
  node descended from <TT>NCServiceDirectory</TT> with <TT>serviceName</TT>
  as it's directory name.
*/
- (NCServiceDirectory*) serviceWithName:(CFStringRef)serviceName;
/*!
  @method serviceWithID:
  Convenience method that does a shallow search from the receiver, looking for a
  node descended from <TT>NCServiceDirectory</TT> with <TT>serviceID</TT>
  as it's network service ID.
*/
- (NCServiceDirectory*) serviceWithID:(CFStringRef)serviceID;

@end
