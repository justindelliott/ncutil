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

#import "NCProtocolNode.h"
#import "NCServiceDirectory.h"

//
#pragma mark -
//

@interface NCProtocolNode(NCPrivateProtocolNode)

+ (Class) privateSubclassForProtocolType:(CFStringRef)protocoltype;

- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkProtocol:(SCNetworkProtocolRef)theProtocol;

@end

//
// Begin Private Subclasses:
//
#import "Private Protocol Nodes/NCAppleTalkProtocolNode.h"
#import "Private Protocol Nodes/NCDNSProtocolNode.h"
#import "Private Protocol Nodes/NCIPv4ProtocolNode.h"
#import "Private Protocol Nodes/NCIPv6ProtocolNode.h"
#import "Private Protocol Nodes/NCProxiesProtocolNode.h"
#import "Private Protocol Nodes/NCAirPortProtocolNode.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
# import "Private Protocol Nodes/NCSMBProtocolNode.h"
# define NCProtocolSubClassCount    6
#else
# define NCProtocolSubClassCount    5
#endif

//
// End Private Subclasses
//

struct NCProtocolSubClass {
  CFStringRef     protocolType;
  Class           protocolClass;
};

@implementation NCProtocolNode(NCPrivateProtocolNode)

  + (Class) privateSubclassForProtocolType:(CFStringRef)protocolType
  {
    static struct NCProtocolSubClass NCProtocolSubClasses[NCProtocolSubClassCount];
    static BOOL NCProtocolSubClassesReady = NO;
    
    if (!NCProtocolSubClassesReady) {
      NCProtocolSubClasses[0].protocolType  = kSCNetworkProtocolTypeAppleTalk;
      NCProtocolSubClasses[1].protocolType  = kSCNetworkProtocolTypeDNS;
      NCProtocolSubClasses[2].protocolType  = kSCNetworkProtocolTypeIPv4;
      NCProtocolSubClasses[3].protocolType  = kSCNetworkProtocolTypeIPv6;
      NCProtocolSubClasses[4].protocolType  = kSCNetworkProtocolTypeProxies;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
      NCProtocolSubClasses[5].protocolType  = kSCNetworkProtocolTypeSMB;
#endif
      //
      NCProtocolSubClasses[0].protocolClass = [NCAppleTalkProtocolNode class];
      NCProtocolSubClasses[1].protocolClass = [NCDNSProtocolNode class];
      NCProtocolSubClasses[2].protocolClass = [NCIPv4ProtocolNode class];
      NCProtocolSubClasses[3].protocolClass = [NCIPv6ProtocolNode class];
      NCProtocolSubClasses[4].protocolClass = [NCProxiesProtocolNode class];
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1050
      NCProtocolSubClasses[5].protocolClass = [NCSMBProtocolNode class];
#endif
      //
      NCProtocolSubClassesReady = YES;
    }
    
    CFIndex                       count = NCProtocolSubClassCount;
    struct NCProtocolSubClass*    subClass = NCProtocolSubClasses;
    
    while (count--) {
      if (CFStringCompare(protocolType,subClass->protocolType,0) == kCFCompareEqualTo)
        return subClass->protocolClass;
      subClass++;
    }
    return Nil;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkProtocol:(SCNetworkProtocolRef)theProtocol
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      _networkProtocol = CFRetain(theProtocol);
    }
    return self;
  }

@end

//
#pragma mark -
//

@implementation NCProtocolNode

  + (CFStringRef) directoryType
  {
    static CFStringRef NCProtocolNode_DirectoryType = NULL;
    if (!NCProtocolNode_DirectoryType)
      NCProtocolNode_DirectoryType = CFSTR("Protocol");
    return NCProtocolNode_DirectoryType;
  }

//

  + (NCProtocolNode*) protocolNodeWithRootDirectory:(NCRootDirectory*)root
    andNetworkProtocol:(SCNetworkProtocolRef)theProtocol
  {
    //  Check to see if a substitution must be made:
    Class     protocolClass = [NCProtocolNode privateSubclassForProtocolType:SCNetworkProtocolGetProtocolType(theProtocol)];
  
    if (protocolClass)
      return [[[protocolClass alloc] initWithRootDirectory:root andNetworkProtocol:theProtocol] autorelease];
    return nil;
  }

//

  + (NCDirectoryNode*) airPortProtocolNodeWithRootDirectory:(NCRootDirectory*)root
    andService:(NCServiceDirectory*)theService
  {
    NCAirPortProtocolNode*  airPortNode = nil;
    CFStringRef             serviceID = [theService networkServiceID];
    CFStringRef             path = SCPathCreateFromComponents(kSCPrefNetworkServices,serviceID,kSCEntNetAirPort,NULL);
    
    if (path) {
      if (SCPreferencesPathGetValue([[root preferenceSession] sessionReference],path)) {
        //  It exists, go ahead and create it:
        airPortNode = [[[NCAirPortProtocolNode alloc] initWithRootDirectory:root andPath:path] autorelease];
      }
      CFRelease(path);
    }
    return airPortNode;
  }

//

  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCProtocolNodePropertyHandler = nil;
    if (NCProtocolNodePropertyHandler == nil) {
      CFIndex         count = 1;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      
      NCProtocolNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCProtocolNodePropertyHandler;
  }
  
//

  - (void) dealloc
  {
    if (_networkProtocol) CFRelease(_networkProtocol);
    [super dealloc];
  }
  
//

  - (SCNetworkProtocolRef) networkProtocol
  {
    return _networkProtocol;
  }

//

  - (CFMutableDictionaryRef) readPropertiesDictionary
  {
    CFDictionaryRef     props = SCNetworkProtocolGetConfiguration(_networkProtocol);
    
    if (props)
      return CFDictionaryCreateMutableCopy(kCFAllocatorDefault,0,props);
    return CFDictionaryCreateMutable(
              kCFAllocatorDefault,
              0,
              &kCFCopyStringDictionaryKeyCallBacks,
              &kCFTypeDictionaryValueCallBacks
            );
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    if ( propDict )
      SCNetworkProtocolSetConfiguration(_networkProtocol,propDict);
  }
  
//

  - (CFStringRef) directoryName
  {
    return SCNetworkProtocolGetProtocolType(_networkProtocol);
  }
  
//

  - (BOOL) setDirectoryName:(CFStringRef)name
  {
    return NO;
  }

@end
