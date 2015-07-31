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

#import "NCServiceDirectory.h"
#import "NCLocationDirectory.h"
#import "NCProtocolNode.h"
#import "NCInterfaceNode.h"

static CFStringRef NCServiceDirectory_Name = NULL;

@interface NCServiceDirectory(NCPrivateServiceDirectory)

- (void) setupInterfaceNodesWithRoot:(NCRootDirectory*)root doConfiguration:(BOOL)doConfig;
- (void) setupProtocolNodesWithRoot:(NCRootDirectory*)root doConfiguration:(BOOL)doConfig;

- (void) addStandardProtocols;

@end

@implementation NCServiceDirectory(NCPrivateServiceDirectory)

  - (void) setupInterfaceNodesWithRoot:(NCRootDirectory*)root
    doConfiguration:(BOOL)doConfig
  {
    SCNetworkInterfaceRef   networkInterface = SCNetworkServiceGetInterface(_networkService);
    
    if (networkInterface) {
      NCInterfaceNode*    newNode = [NCInterfaceNode interfaceNodeWithRootDirectory:root andNetworkInterface:networkInterface];
      
      if (newNode) {
        if (doConfig)
          [newNode setDefaultProperties];
        [self appendChild:newNode];
      }
    }
  }
  
//

struct __NCServiceProtocolSearchContext {
  CFStringRef   protocolName;
  BOOL          available;
};

void
__NCServiceProtocolSearch(
  const void*   value,
  void*         context
)
{
  #define VALUE ((SCNetworkProtocolRef)value)
  #define CONTEXT ((struct __NCServiceProtocolSearchContext*)context)
  
  if (CFStringCompare(SCNetworkProtocolGetProtocolType(VALUE),CONTEXT->protocolName,0) == kCFCompareEqualTo)
    CONTEXT->available = YES;
  
  #undef CONTEXT
  #undef VALUE
}

  - (void) setupProtocolNodesWithRoot:(NCRootDirectory*)root
    doConfiguration:(BOOL)doConfig
  {
    //  Populate with protocols:
    CFArrayRef      networkProtocols = SCNetworkServiceCopyProtocols(_networkService);
    CFArrayRef      protocolTypes = SCNetworkInterfaceGetSupportedProtocolTypes([[self topLevelInterface] networkInterface]);
    
    struct __NCServiceProtocolSearchContext context;
    
    if (networkProtocols && protocolTypes) {
      CFIndex       i = 0,iMax = CFArrayGetCount(networkProtocols);
      CFIndex       j = 0,jMax = CFArrayGetCount(protocolTypes);
      CFRange       srchRange = CFRangeMake(0,iMax);
      
      //  See if all of the valid protocols are there; any that do not
      //  exist in the store should be created now:
      while ( j < jMax ) {
        context.protocolName = CFArrayGetValueAtIndex(protocolTypes,j++);
        context.available = NO;
        CFArrayApplyFunction(networkProtocols,srchRange,__NCServiceProtocolSearch,&context);
        if (!context.available)
          SCNetworkServiceAddProtocolType(_networkService,context.protocolName);
      }
      //
      //  Now we can go ahead and manufacture all of them after
      //  getting the protocol list again:
      //
      CFRelease(networkProtocols);
      iMax = CFArrayGetCount(networkProtocols = SCNetworkServiceCopyProtocols(_networkService));
      while ( i < iMax ) {
        SCNetworkProtocolRef  theProtocol = CFArrayGetValueAtIndex(networkProtocols,i++);
        NCProtocolNode*       newNode = [NCProtocolNode protocolNodeWithRootDirectory:root andNetworkProtocol:theProtocol];
        
        if (newNode) {
          if (doConfig)
            [newNode setDefaultProperties];
          [self appendChild:newNode];
        }
      }
      
      //  If it's an 80211 interface, we need to see if an AirPort
      //  entity exists for the service:
      if (CFStringCompare([[self baseLevelInterface] networkInterfaceType],kSCNetworkInterfaceTypeIEEE80211,0) == kCFCompareEqualTo) {
        //  Try to create our "hacked" AirPort protocol object:
        NCDirectoryNode*    apNode = [NCProtocolNode airPortProtocolNodeWithRootDirectory:root andService:self];
        
        if (apNode) {
          if (doConfig)
            [apNode setDefaultProperties];
          [self appendChild:apNode];
        }
      }
    } else
      [self addStandardProtocols];
    
    if (networkProtocols)
      CFRelease(networkProtocols);
  }
  
//

  - (void) addStandardProtocols
  {
    //  Walk the chain of interfaces and add any default protocols for each
    //  interface in the chain.
    NCInterfaceNode*      interface = [self topLevelInterface];
    
    while (interface) {
      CFArrayRef            protocolTypes = SCNetworkInterfaceGetSupportedProtocolTypes([interface networkInterface]);
      
      if (protocolTypes) {
        CFIndex         i = 0,iMax = CFArrayGetCount(protocolTypes);
        
        while ( i < iMax ) {
          CFStringRef   protocolType = CFArrayGetValueAtIndex(protocolTypes,i++);
          
          if (protocolType)
            SCNetworkServiceAddProtocolType(_networkService,protocolType);
        }
        
        //  If it's an 80211 interface, we need to add an AirPort entity for
        //  the service:
        if (CFStringCompare([interface networkInterfaceType],kSCNetworkInterfaceTypeIEEE80211,0) == kCFCompareEqualTo) {
          CFStringRef   serviceID = [self networkServiceID];
          CFStringRef   path = SCPathCreateFromComponents(kSCPrefNetworkServices,serviceID,kSCEntNetAirPort,NULL);
          
          if (path) {
            [[self preferenceSession] createPathIfNotPresent:path];
            CFRelease(path);
          }
        }
      }
      interface = (NCInterfaceNode*)[interface child];
    }
  }
  
@end

//
#pragma mark -
//

@implementation NCServiceDirectory

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    if (!NCServiceDirectory_Name) {
      NCServiceDirectory_Name = CFSTR("name");
    }
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }

//

  + (CFStringRef) directoryType
  {
    static CFStringRef NCServiceDirectory_DirectoryType = NULL;
    if (!NCServiceDirectory_DirectoryType)
      NCServiceDirectory_DirectoryType = CFSTR("Service");
    return NCServiceDirectory_DirectoryType;
  }

//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkService:(SCNetworkServiceRef)theService
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      _networkService = CFRetain(theService);
      
      //  Setup the interface:
      [self setupInterfaceNodesWithRoot:root doConfiguration:NO];
      
      //  Setup the protocols:
      [self setupProtocolNodesWithRoot:root doConfiguration:NO];
    }
    return self;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNewNetworkService:(SCNetworkServiceRef)theService
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      _networkService = CFRetain(theService);
      
      //  Setup the interface:
      [self setupInterfaceNodesWithRoot:root doConfiguration:YES];
      
      //  Add the standard protocols:
      [self addStandardProtocols];
      [self setupProtocolNodesWithRoot:root doConfiguration:YES];
    }
    return self;
  }
  
//

  - (void) dealloc
  {
    if (_networkService) CFRelease(_networkService);
    [super dealloc];
  }
  
//

  - (SCNetworkServiceRef) networkService
  {
    return _networkService;
  }

//

  - (CFStringRef) networkServiceID
  {
    return SCNetworkServiceGetServiceID(_networkService);
  }

//

  - (void) removeService
  {
    NCLocationDirectory*  location = (NCLocationDirectory*)[self parent];
    
    //  Get the service removed:
    if (_networkService) {
      SCNetworkSetRemoveService([location networkSet],_networkService);
      //SCNetworkServiceRemove(_networkService);
      _networkService = NULL;
    }
      
    //  Remove myself from my parent and release:
    [self removeFromParent];
    [self release];
    
    //  Store all properties:
    [location commitUpdatesToNodes:kNCTreeNodeApplyToAll];
  }

//

  - (BOOL) pushInterfaceLayerOfType:(CFStringRef)type
  {
    NCInterfaceNode*  topNode = [self topLevelInterface];
    CFArrayRef        validInterfaces = [topNode supportedInterfaceTypes];
    BOOL              result = NO;
    
    //  Only try this if our top-most interface object allows this
    //  interface layer:
    if (validInterfaces && CFArrayContainsValue(validInterfaces,CFRangeMake(0,CFArrayGetCount(validInterfaces)),type)) {
      SCNetworkInterfaceRef   newLayer;
      
      // Try to create the new layer:
      if ((newLayer = SCNetworkInterfaceCreateWithInterface([topNode networkInterface],type))) {
        //  Pop the top-level interface object out of the tree and release it:
        [topNode removeFromParent];
        [topNode release];
        
        //  Create the new node:
        if ((topNode = [NCInterfaceNode interfaceNodeWithRootDirectory:(NCRootDirectory*)[self root] andNetworkInterface:newLayer])) {
          [self prependChild:topNode];
          result = YES;
        }
        CFRelease(newLayer);
      }
    }
    return result;
  }
  
//

  - (BOOL) popInterfaceLayer
  {
    NCInterfaceNode*  topNode = [self topLevelInterface];
    NCInterfaceNode*  firstChild = (NCInterfaceNode*)[topNode child];
    BOOL              result = NO;
    
    //  We'll only try this if there's an underlying interface:
    if (firstChild) {
    
    }
    return result;
  }

//

  - (CFMutableDictionaryRef) readPropertiesDictionary
  {
    //  We grab values from various locations and dump them into
    //  a mutable dictionary, since there isn't a whole dictionary associated
    //  with the location itself:
    CFMutableDictionaryRef    result = CFDictionaryCreateMutable(
                                          kCFAllocatorDefault,
                                          0,
                                          &kCFCopyStringDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks
                                        );
    if (result) {
      CFStringRef             aStr;
      
      //  Name of the service:
      if ((aStr = SCNetworkServiceGetName(_networkService)))
        CFDictionaryAddValue(result,kSCPropUserDefinedName,aStr);
      
      //  Enabled/disabled:
      if (!SCNetworkServiceGetEnabled(_networkService))
        CFDictionaryAddValue(result,kSCResvInactive,CFOne());
    }
    return result;
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    if (propDict) {
      CFStringRef             aStr;
      CFNumberRef             aNum;
      Boolean                 active;
      
      //  Name of the service:
      if ((aStr = CFDictionaryGetValue(propDict,kSCPropUserDefinedName)))
        SCNetworkServiceSetName(_networkService,aStr);
      
      //  Enabled/disabled:
      active = SCNetworkServiceGetEnabled(_networkService);
      if ((aNum = CFDictionaryGetValue(propDict,kSCResvInactive))) {
        if (active != (!CFNumberToBoolean(aNum)))
          SCNetworkServiceSetEnabled(_networkService,!active);
      } else if (!active)
        SCNetworkServiceSetEnabled(_networkService,TRUE);
    }
  }
  
//

  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCServiceDirectoryPropertyHandler = nil;
    
    if (NCServiceDirectoryPropertyHandler == nil) {
      NCPropertyRef   properties[2];
      
      properties[0] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeString,
                        NCServiceDirectory_Name,
                        kSCPropUserDefinedName,
                        FALSE,
                        NULL
                      );
      properties[1] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeBoolean,
                        CFSTR("inactive"),
                        kSCResvInactive,
                        FALSE,
                        NULL
                      );
      NCServiceDirectoryPropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:2] retain];
      NCPropertyRelease(properties[0]);
      NCPropertyRelease(properties[1]);
    }
    return NCServiceDirectoryPropertyHandler;
  }

//

  - (BOOL) setValue:(CFPropertyListRef)value
    ofProperty:(CFStringRef)property
  {
    BOOL    result;
    
    //  We override to see when the name changes; when that happens, the
    //  location's property handler must be invalidated:
    if (CFStringCompare(property,kSCPropUserDefinedName,0) == kCFCompareEqualTo) {
      CFStringRef     oldName = [self valueOfProperty:property];
      
      if (oldName)
        oldName = CFRetain(oldName);
      if ((result = [super setValue:value ofProperty:property])) {
        //  Are they not the same?
        if (!oldName || (oldName && CFStringCompare(oldName,value,0) != kCFCompareEqualTo))
          [(NCDirectoryNode*)[self parent] invalidatePropertyHandler];
      }
      if (oldName)
        CFRelease(oldName);
    } else
      result = [super setValue:value ofProperty:property];
    return result;
  }

//

  - (NCProtocolNode*) searchForProtocol:(CFStringRef)protocolName
  {
    NCDirectoryNode*  children = (NCDirectoryNode*)[self child];
    
    if (children)
      return (NCProtocolNode*)[children searchForNodeWithDirectoryName:protocolName andClass:[NCProtocolNode class]];
    return nil;
  }
  
//

  - (NCInterfaceNode*) topLevelInterface
  {
    NCDirectoryNode*  children = (NCDirectoryNode*)[self child];
    
    while (children) {
      if ([children isKindOfClass:[NCInterfaceNode class]])
        return (NCInterfaceNode*)children;
      children = (NCDirectoryNode*)[children sibling];
    }
    return nil;
  }

//

  - (NCInterfaceNode*) baseLevelInterface
  {
    NCInterfaceNode*    lastInterface = nil;
    NCInterfaceNode*    curInterface = [self topLevelInterface];
    
    do {
      lastInterface = curInterface;
      curInterface = (NCInterfaceNode*)[curInterface child];
    } while (curInterface);
    return lastInterface;
  }

//

  - (NCInterfaceNode*) searchForInterface:(CFStringRef)interfaceName
  {
    NCInterfaceNode*    primary = [self topLevelInterface];
    
    if (primary)
      return (NCInterfaceNode*)[primary searchDeep:YES forNodeWithDirectoryName:interfaceName andClass:[NCInterfaceNode class]];
    return nil;
  }
  
//

  - (NCProtocolNode*) protocolChain
  {
    NCDirectoryNode*  children = (NCDirectoryNode*)[self child];
    
    while (children) {
      if ([children isKindOfClass:[NCProtocolNode class]])
        return (NCProtocolNode*)children;
      children = (NCDirectoryNode*)[children sibling];
    }
    return nil;
  }

@end
