//
//  ncutil3 - network configuration utility, version 3
//  NCEntityPropertyHandlers
//
//  Property handlers for service entities.
//
//  Created by Jeffrey Frey on Mon Jun  6 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCPropertyHandler.h"
#import "NCDirectoryNode.h"

//
// Used to map property handler accessor functions to
// names -- protocol and interface types:
//
typedef NCPropertyHandler* (*NCEntityPropertyHandlerCallback)();

typedef struct {
  CFStringRef                     entityName;
  NCEntityPropertyHandlerCallback getPropertyHandler;
} NCPropertyHandlerMap;

NCPropertyHandler* NCAppleTalkEntityPropertyHandler();
NCPropertyHandler* NCDNSEntityPropertyHandler();
NCPropertyHandler* NCIP4EntityPropertyHandler();
NCPropertyHandler* NCIP6EntityPropertyHandler();
NCPropertyHandler* NCProxiesEntityPropertyHandler();
NCPropertyHandler* NCNetInfoEntityPropertyHandler();

NCPropertyHandler* NC6to4EntityPropertyHandler();
NCPropertyHandler* NCModemEntityPropertyHandler();
NCPropertyHandler* NCPPPEntityPropertyHandler();
NCPropertyHandler* NCL2TPEntityPropertyHandler();
NCPropertyHandler* NCFireWireEntityPropertyHandler();

NCPropertyHandler* NCGenericEntityPropertyHandler();
NCPropertyHandler* NCGenericInterfacePropertyHandler();
