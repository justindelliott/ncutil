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

#import "NCInterfaceNode.h"
#import "NCRootDirectory.h"
#import "NCPortOptions.h"
#include "CFAdditions.h"

CFStringRef     NCInterfaceNode_LayerableInterfaces = NULL;

@interface NCInterfaceNode(NCPrivateInterfaceNode)

+ (Class) privateSubclassForInterfaceType:(CFStringRef)interfaceType;

- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkInterface:(SCNetworkInterfaceRef)theInterface;
- (id) initWithRootDirectory:(NCRootDirectory*)root andNetworkInterfaceTemplate:(SCNetworkInterfaceRef)theInterface;

- (void) stripUnwantedProperties:(CFMutableDictionaryRef)propDict;

@end

//
// Begin Private Subclasses:
//
#import "Private Interface Nodes/NCBluetoothInterfaceNode.h"
#import "Private Interface Nodes/NCEthernetInterfaceNode.h"
#import "Private Interface Nodes/NCFireWireInterfaceNode.h"
#import "Private Interface Nodes/NCL2TPInterfaceNode.h"
#import "Private Interface Nodes/NCModemInterfaceNode.h"
#import "Private Interface Nodes/NC6to4InterfaceNode.h"
#import "Private Interface Nodes/NCPPPInterfaceNode.h"

#define NCInterfaceSubClassCount    12
//
// End Private Subclasses
//

struct NCInterfaceSubClass {
  CFStringRef     interfaceType;
  Class           interfaceClass;
};

@implementation NCInterfaceNode(NCPrivateInterfaceNode)

  + (Class) privateSubclassForInterfaceType:(CFStringRef)interfaceType;
  {
    static struct NCInterfaceSubClass NCInterfaceSubClasses[NCInterfaceSubClassCount];
    static BOOL NCInterfaceSubClassesReady = NO;
    
    if (!NCInterfaceSubClassesReady) {
      NCInterfaceSubClasses[0].interfaceType  = kSCNetworkInterfaceType6to4;
      NCInterfaceSubClasses[1].interfaceType  = kSCNetworkInterfaceTypeBluetooth;
      NCInterfaceSubClasses[2].interfaceType  = kSCNetworkInterfaceTypeModem;
      NCInterfaceSubClasses[3].interfaceType  = kSCNetworkInterfaceTypePPP;
      NCInterfaceSubClasses[4].interfaceType  = kSCNetworkInterfaceTypeL2TP;
      NCInterfaceSubClasses[5].interfaceType  = kSCNetworkInterfaceTypeFireWire;
      NCInterfaceSubClasses[6].interfaceType  = kSCNetworkInterfaceTypeIEEE80211;
      NCInterfaceSubClasses[7].interfaceType  = kSCNetworkInterfaceTypeEthernet;
      NCInterfaceSubClasses[8].interfaceType  = kSCNetworkInterfaceTypeBond;
      NCInterfaceSubClasses[9].interfaceType  = kSCNetworkInterfaceTypeIrDA;
      NCInterfaceSubClasses[10].interfaceType  = kSCNetworkInterfaceTypeSerial;
      NCInterfaceSubClasses[11].interfaceType  = kSCNetworkInterfaceTypeVLAN;
      //
      NCInterfaceSubClasses[0].interfaceClass = [NC6to4InterfaceNode class];
      NCInterfaceSubClasses[1].interfaceClass = [NCBluetoothInterfaceNode class];
      NCInterfaceSubClasses[2].interfaceClass = [NCModemInterfaceNode class];
      NCInterfaceSubClasses[3].interfaceClass = [NCPPPInterfaceNode class];
      NCInterfaceSubClasses[4].interfaceClass = [NCL2TPInterfaceNode class];
      NCInterfaceSubClasses[5].interfaceClass = [NCFireWireInterfaceNode class];
      NCInterfaceSubClasses[6].interfaceClass = [NCInterfaceNode class];
      NCInterfaceSubClasses[7].interfaceClass = [NCEthernetInterfaceNode class];
      NCInterfaceSubClasses[8].interfaceClass = [NCInterfaceNode class];
      NCInterfaceSubClasses[9].interfaceClass = [NCInterfaceNode class];
      NCInterfaceSubClasses[10].interfaceClass = [NCInterfaceNode class];
      NCInterfaceSubClasses[11].interfaceClass = [NCInterfaceNode class];
      //
      NCInterfaceSubClassesReady = YES;
    }
    
    CFIndex                       count = NCInterfaceSubClassCount;
    struct NCInterfaceSubClass*   subClass = NCInterfaceSubClasses;
    
    while (count--) {
      if (CFStringCompare(interfaceType,subClass->interfaceType,0) == kCFCompareEqualTo)
        return subClass->interfaceClass;
      subClass++;
    }
    return Nil;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterface:(SCNetworkInterfaceRef)theInterface
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      _networkInterface = CFRetain(theInterface);
      
      //  Do we have a sub-interface that we're layered on top of?
      if ((theInterface = SCNetworkInterfaceGetInterface(theInterface))) {
        NCInterfaceNode*    newNode = [NCInterfaceNode interfaceNodeWithRootDirectory:root andNetworkInterface:theInterface];
        
        if (newNode)
          [self appendChild:newNode];
      }
    }
    return self;
  }
  
//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterfaceTemplate:(SCNetworkInterfaceRef)theInterface
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      _networkInterface = CFRetain(theInterface);
      [self setIsLocked:YES];
      
      //  Do we have a sub-interface that we're layered on top of?
      if ((theInterface = SCNetworkInterfaceGetInterface(theInterface))) {
        NCInterfaceNode*    newNode = [NCInterfaceNode templateInterfaceNodeWithRootDirectory:root andNetworkInterface:theInterface];
        
        if (newNode) {
          [newNode setIsLocked:YES];
          [self appendChild:newNode];
        }
      }
    }
    return self;
  }
  
//

  - (void) stripUnwantedProperties:(CFMutableDictionaryRef)propDict
  {
    if (propDict && CFGetContainerMutability(propDict)) {
      CFDictionaryRemoveValue(propDict,kSCPropBSDDevice);
      //
      // If locking has been disabled, then we DON'T scrub the MAC address:
      //
      if (!NCPropertyOverrideLocking())
        CFDictionaryRemoveValue(propDict,kSCPropMACAddress);
    }
  }

@end

//
#pragma mark -
//

@implementation NCInterfaceNode

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    if (!NCInterfaceNode_LayerableInterfaces) {
      NCInterfaceNode_LayerableInterfaces = CFSTR("layerable-interfaces");
    }
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }

//

  + (CFStringRef) directoryType
  {
    static CFStringRef NCInterfaceNode_DirectoryType = NULL;
    if (!NCInterfaceNode_DirectoryType)
      NCInterfaceNode_DirectoryType = CFSTR("Interface");
    return NCInterfaceNode_DirectoryType;
  }

//

  + (NCInterfaceNode*) interfaceNodeWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterface:(SCNetworkInterfaceRef)theInterface
  {
    //  Check to see if a substitution must be made:
    Class     interfaceClass = [NCInterfaceNode privateSubclassForInterfaceType:SCNetworkInterfaceGetInterfaceType(theInterface)];
    
    if (interfaceClass)
      return [[[interfaceClass alloc] initWithRootDirectory:root andNetworkInterface:theInterface] autorelease];
    return nil;
  }
  
//

  + (NCInterfaceNode*) templateInterfaceNodeWithRootDirectory:(NCRootDirectory*)root
    andNetworkInterface:(SCNetworkInterfaceRef)theInterface
  {
    //  Check to see if a substitution must be made:
    Class             interfaceClass = [NCInterfaceNode privateSubclassForInterfaceType:SCNetworkInterfaceGetInterfaceType(theInterface)];
    
    if (interfaceClass)
      return [[[interfaceClass alloc] initWithRootDirectory:root andNetworkInterfaceTemplate:theInterface] autorelease];
    return nil;
  }

//

  - (void) dealloc
  {
    if (_networkInterface) CFRelease(_networkInterface);
    //if (_supportedLayers) CFRelease(_supportedLayers);
    [super dealloc];
  }
  
//

  - (SCNetworkInterfaceRef) networkInterface
  {
    return _networkInterface;
  }

//

  - (CFStringRef) networkInterfaceType
  {
    return SCNetworkInterfaceGetInterfaceType(_networkInterface);
  }

//

  - (BOOL) isInterfaceTemplate
  {
    return [self isLocked];
  }

//

  - (SCNetworkServiceRef) createNetworkService
  {
    SCNetworkServiceRef   theNewService = NULL;
    
    if ([self isLocked])
      theNewService = SCNetworkServiceCreate(
                        [[self preferenceSession] sessionReference],
                        _networkInterface
                      );
    return theNewService;
  }

//

  - (CFArrayRef) supportedInterfaceTypes
  {
    if (!_supportedLayers)
      _supportedLayers = SCNetworkInterfaceGetSupportedInterfaceTypes(_networkInterface);
    return _supportedLayers;
  }

//

  - (CFMutableDictionaryRef) readPropertiesDictionary
  {
    CFMutableDictionaryRef  result = NULL;
    CFDictionaryRef         props = SCNetworkInterfaceGetConfiguration(_networkInterface);
    
    if (props)
      result = CFDictionaryCreateMutableCopy(kCFAllocatorDefault,0,props);
    else
      result = CFDictionaryCreateMutable(
                  kCFAllocatorDefault,
                  0,
                  &kCFCopyStringDictionaryKeyCallBacks,
                  &kCFTypeDictionaryValueCallBacks
                );
                
    //  Add a link-local address when appropriate:
    CFStringRef   linkLocal = SCNetworkInterfaceGetHardwareAddressString(_networkInterface);
    
    if (linkLocal)
      CFDictionarySetValue(result,kSCPropMACAddress,linkLocal);
                
    //  Add a BSD device name when appropriate:
    CFStringRef   bsdName = SCNetworkInterfaceGetBSDName(_networkInterface);
    
    if (bsdName)
      CFDictionarySetValue(result,kSCPropBSDDevice,bsdName);
      
    //  Add the layerable-interfaces item:
    CFArrayRef    layers = [self supportedInterfaceTypes];
    
    if (layers)
      CFDictionarySetValue(result,NCInterfaceNode_LayerableInterfaces,layers);
      
    return result;
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    if ( propDict )
      SCNetworkInterfaceSetConfiguration(_networkInterface,propDict);
  }

//

  - (void) setDefaultProperties
  {
    //  Call super:
    [super setDefaultProperties];
    //  If I have a child interface associated with me, do the same
    //  for it:
    NCInterfaceNode*    nextLevel = (NCInterfaceNode*)[self child];
    if (nextLevel)
      [nextLevel setDefaultProperties];
  }

//

  - (void) setProperties:(CFDictionaryRef)propDict
  {
    //
    // I MAY have to come back to this and alter what happens with the MAC address
    // if the SCNetworkConfiguration API won't set a new value for it.
    //
    [self stripUnwantedProperties:(CFMutableDictionaryRef)propDict];
    [super setProperties:propDict];
  }

//

  - (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCInterfaceNodePropertyHandler = nil;
    if (NCInterfaceNodePropertyHandler == nil) {
      CFIndex         count = 4;
      NCPropertyRef   properties[count];
      CFStringRef     uiNames[count];
      
      PROPERTY_DECL2(0,kNCPropertyTypeBoolean,CFSTR("inactive"),kSCResvInactive)
      PROPERTY_DECL3(1,kNCPropertyTypeMAC,CFSTR("mac-address"),kSCPropMACAddress,TRUE)
      PROPERTY_DECL3(2,kNCPropertyTypeString,kSCPropBSDDevice,kSCPropBSDDevice,TRUE)
      PROPERTY_DECL3(3,kNCPropertyTypeStringArray,NCInterfaceNode_LayerableInterfaces,NCInterfaceNode_LayerableInterfaces,TRUE)
      
      NCInterfaceNodePropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:count] retain];
      
      while (count--) {
        CFRelease(uiNames[count]);
        NCPropertyRelease(properties[count]);
      }
    }
    return NCInterfaceNodePropertyHandler;
  }
    
//

  - (CFStringRef) directoryName
  {
    return SCNetworkInterfaceGetLocalizedDisplayName(_networkInterface);
  }
  
//

  - (BOOL) setDirectoryName:(CFStringRef)name
  {
    return NO;
  }

@end
