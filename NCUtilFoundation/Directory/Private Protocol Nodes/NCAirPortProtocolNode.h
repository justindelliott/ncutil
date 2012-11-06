//
//  ncutil3 - network configuration utility, version 3
//  NCProtocolNode
//
//  Concrete directory node class that represents the oddly-missing
//  AirPort protocol entity -- SCNetworkConfiguration doesn't pass
//  these along to us for some reason.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"

/*!
  @class NCAirPortProtocolNode
  A subclass of <TT>NCDirectoryNode</TT> that represents an AirPort
  protocol entity within a preference store.  SCNetworkConfiguration does
  not pass these along to us, for some reason, so we're forced to make
  it a special case.<BR>
  <BR>
  Essentially all this subclass does is implement a <TT>propertyHandler</TT>
  class method to return a non-dynamic handler and set a SystemConfiguration
  dictionary path at which to read/write property data.
*/
@interface NCAirPortProtocolNode : NCDirectoryNode
{
}

/*!
  @method initWithRootDirectory:andPath:
  Designated initializer, initializes the node and sets the <TT>preferencesPath</TT>
  dictionary path to <TT>scPath</TT>.
*/
- (id) initWithRootDirectory:(NCRootDirectory*)root andPath:(CFStringRef)scPath;

@end
