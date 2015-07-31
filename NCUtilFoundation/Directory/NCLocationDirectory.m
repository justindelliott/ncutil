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

#import "NCLocationDirectory.h"
#import "NCServiceDirectory.h"
#import "NCInterfaceNode.h"
#import "NCRootDirectory.h"
#include "NCError.h"
#include "CFAdditions.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1050
# import "NCGlobalNetInfoNode.h"
#endif

static CFStringRef NCLocationDirectory_Name = NULL;
static CFStringRef NCLocationDirectory_ServiceOrder = NULL;

@interface NCLocationDirectory(NCPrivateLocationDirectory)

- (CFArrayRef) serviceOrderByName;
- (CFMutableArrayRef) serviceOrderByIDForNames:(CFArrayRef)names;

- (void) addDefaultServicesToSetWithRoot:(NCRootDirectory*)root;

@end

@implementation NCLocationDirectory(NCPrivateLocationDirectory)

  - (CFArrayRef) serviceOrderByName
  {
    if (_serviceOrderByName) return _serviceOrderByName;
    
    CFArrayRef      serviceOrder = SCNetworkSetGetServiceOrder(_networkSet);
    
    if (serviceOrder) {
      CFIndex       count = CFArrayGetCount(serviceOrder);
      
      if (count) {
        CFStringRef names[count];
        CFStringRef ids[count];
        CFIndex     i = 0,j = 0;
        
        while ( i < count ) {
          CFStringRef           serviceID = CFArrayGetValueAtIndex(serviceOrder,i++);
          NCServiceDirectory*   theService = [self serviceWithID:serviceID];
          
          if (theService) {
            names[j] = [theService directoryName];
            ids[j] = serviceID;
            j++;
          }
        }
        _serviceOrderByName = CFArrayCreate(
                                kCFAllocatorDefault,
                                (const void **)names,
                                j,
                                &kCFTypeArrayCallBacks
                              );
        _serviceIDsByName   = CFDictionaryCreate(
                                kCFAllocatorDefault,
                                (const void **)names,
                                (const void **)ids,
                                j,
                                &kCFTypeDictionaryKeyCallBacks,
                                &kCFTypeDictionaryValueCallBacks
                              );
      }
    }
    return _serviceOrderByName;
  }

//

  - (CFMutableArrayRef) serviceOrderByIDForNames:(CFArrayRef)names
  {
    CFMutableArrayRef   result = NULL;
    
    if (_serviceIDsByName && names) {
      CFIndex         count = CFArrayGetCount(names);
      
      if (count == CFArrayGetCount(_serviceOrderByName)) {
        CFIndex       i = 0;
        
        result = CFArrayCreateMutable(
                      kCFAllocatorDefault,
                      count,
                      &kCFTypeArrayCallBacks
                    );
        
        while ( i < count ) {
          CFStringRef   idString = CFDictionaryGetValue(_serviceIDsByName,CFArrayGetValueAtIndex(names,i++));
          
          if (idString) {
            if (CFArrayContainsValue(result,CFRangeMake(0,CFArrayGetCount(result)),idString)) {
              NCErrorPush(kNCErrorBadServiceOrder,CFSTR("Repeated service name in service order list"),NULL);
              CFRelease(result);
              result = NULL;
              break;
            }
            CFArrayAppendValue(result,(const void*)(idString));
          } else {
            NCErrorPush(kNCErrorBadServiceOrder,CFSTR("Invalid service name in service order list"),NULL);
            CFRelease(result);
            result = NULL;
            break;
          }
        }
      } else
        NCErrorPush(kNCErrorBadServiceOrder,CFSTR("Too many or too few service names in service order list"),NULL);
    }
    return result;
  }
  
//

  - (void) addDefaultServicesToSetWithRoot:(NCRootDirectory*)root
  {
    NCDirectoryNode*    templates = [root interfaceTemplateDirectory];
    
    if (templates) {
      NCInterfaceNode*  interface = (NCInterfaceNode*)[templates child];
      CFIndex           interfaceCount = 0;
      
      //  Get an interface count:
      while (interface) {
        interfaceCount++;
        interface = (NCInterfaceNode*)[interface sibling];
      }
      
      if (interfaceCount) {
        CFStringRef   serviceIDs[interfaceCount];
        CFIndex       serviceIdx = 0;
        
        interface = (NCInterfaceNode*)[templates child];
        while (interface) {
          SCNetworkServiceRef   theNewService = [interface createNetworkService];
          
          if (theNewService && SCNetworkSetAddService(_networkSet,theNewService)) {
            NCServiceDirectory*    newDir = [[NCServiceDirectory alloc] initWithRootDirectory:root
                                                andNewNetworkService:theNewService];
            //  Append the new directory to our child chain and invalidate
            //  our property handler to adapt to the new service list:
            serviceIDs[serviceIdx++] = [newDir networkServiceID];
            if (newDir) {
              CFStringRef   name = SCNetworkInterfaceGetLocalizedDisplayName([interface networkInterface]);
              
              [newDir setDirectoryName:name];
              [self appendChild:newDir];
              [newDir release];
            }
          }
          interface = (NCInterfaceNode*)[interface sibling];
        }
        if (serviceIdx) {
          CFArrayRef    serviceOrder = CFArrayCreate(
                                          kCFAllocatorDefault,
                                          (const void**)serviceIDs,
                                          serviceIdx,
                                          &kCFTypeArrayCallBacks
                                        );
          if (serviceOrder) {
            SCNetworkSetSetServiceOrder(_networkSet,serviceOrder);
            CFRelease(serviceOrder);
          }
        }
        [self invalidatePropertyHandler];
      }
      //  Store all properties:
      [self commitUpdatesToNodes:kNCTreeNodeApplyToAll];
    }
  }

@end

//
#pragma mark -
//

@implementation NCLocationDirectory

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    if (!NCLocationDirectory_Name) {
      NCLocationDirectory_Name = CFSTR("name");
      NCLocationDirectory_ServiceOrder = CFSTR("service-order");
    }
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }

//

  + (CFStringRef) directoryType
  {
    static CFStringRef NCLocationDirectory_DirectoryType = NULL;
    if (!NCLocationDirectory_DirectoryType)
      NCLocationDirectory_DirectoryType = CFSTR("Location");
    return NCLocationDirectory_DirectoryType;
  }

//

  - (id) initWithRootDirectory:(NCRootDirectory*)root
    andNetworkSet:(SCNetworkSetRef)theSet
  {
    if (self = [super initWithPreferenceSession:[root preferenceSession]]) {
      NCTree*               lastDir = nil;
      
      _networkSet = CFRetain(theSet);

#if MAC_OS_X_VERSION_MAX_ALLOWED < 1050
      //  Try for a global NetInfo entity:
      NCGlobalNetInfoNode*    netInfo = [[NCGlobalNetInfoNode alloc] initWithRootDirectory:root andNetworkSet:theSet];
      
      if (netInfo) {
        [self appendChild:netInfo];
        lastDir = netInfo;
        [netInfo release];
      }
#endif
      
      //  Populate with services:
      CFArrayRef            networkServices = SCNetworkSetCopyServices(_networkSet);
      
      if (networkServices) {
        CFIndex               i = 0,iMax = CFArrayGetCount(networkServices);
        
        //
        // If there are ZERO network services, this is a location that we need to
        // setup:
        //
        if (iMax == 0) {
          [self addDefaultServicesToSetWithRoot:root];
        } else {
          while ( i < iMax ) {
            SCNetworkServiceRef   theService = CFArrayGetValueAtIndex(networkServices,i++);
            NCServiceDirectory*   newDir = [[NCServiceDirectory alloc] initWithRootDirectory:root andNetworkService:theService];
            
            if (newDir) {
              if (lastDir)
                [lastDir insertSibling:newDir];
              else
                [self appendChild:newDir];
              lastDir = newDir;
              [newDir release];
            }
          }
        }
        CFRelease(networkServices);
      }
    }
    return self;
  }
  
//

  - (void) dealloc
  {
    if (_networkSet) CFRelease(_networkSet);
    if (_propertyHandler) [_propertyHandler release];
    if (_serviceOrderByName) CFRelease(_serviceOrderByName);
    if (_serviceIDsByName) CFRelease(_serviceIDsByName);
    [super dealloc];
  }
  
//

  - (void) invalidatePropertyHandler
  {
    if (_propertyHandler) [_propertyHandler release];
    _propertyHandler = nil;
    if (_serviceOrderByName) CFRelease(_serviceOrderByName);
    _serviceOrderByName = NULL;
    if (_serviceIDsByName) CFRelease(_serviceIDsByName);
    _serviceIDsByName = NULL;
  }

//

  - (SCNetworkSetRef) networkSet
  {
    return _networkSet;
  }

//

  - (void) setAsCurrentLocation
  {
    //  Note that we're not asking the root node to refresh itself;
    //  that's up to the consumer, in this case.
    if (_networkSet)
      SCNetworkSetSetCurrent(_networkSet);
  }
  
//

  - (void) removeLocation
  {
    if (_networkSet) {
      //  We have to get all of this set's services removed!  Right now we do this by getting
      //  the first child of the location and walk the sibling chain manually.
      NCDirectoryNode*    childChain;
      NCServiceDirectory* service;
      
      //  This may look weird (hell, even I had a tough time figuring out what was going on
      //  the last time I looked at it!), but essentially since removing the service snaps the
      //  service node out of our child chain, we've gotta re-get the chain root each iteration
      //  and look for a service node attached to it.
      while ( (childChain = (NCDirectoryNode*)[self child]) && (service = (NCServiceDirectory*)[childChain searchDeep:NO forNodeWithClass:[NCServiceDirectory class]]) )
        [service removeService];
      
      //  Get the set removed now:
      SCNetworkSetRemove(_networkSet);
      _networkSet = NULL;
    }
    
    //  Remove me from my parent and then deallocate:
    [self removeFromParent];
    [self release];
  }

//

  - (BOOL) addServiceWithName:(CFStringRef)name
    andInterface:(NCInterfaceNode*)interface
  {
    if (![self serviceWithName:name]) {
      SCNetworkServiceRef   theNewService = [interface createNetworkService];
      
      //  Set the service's name right now, rather than later through the NCDirectory
      //  API:
      if ( theNewService ){
        if ( SCNetworkServiceSetName(theNewService,name) && SCNetworkSetAddService(_networkSet,theNewService) ) {
          NCServiceDirectory*    newDir = [[NCServiceDirectory alloc] initWithRootDirectory:(NCRootDirectory*)[self root]
                                              andNewNetworkService:theNewService];
          //  Append the new directory to our child chain and invalidate
          //  our property handler to adapt to the new service list:
          if (newDir) {
            //[newDir setDirectoryName:name];
            [self appendChild:newDir];
            
            //  We need to add the new service to the service order array:
            CFArrayRef          origOrder = SCNetworkSetGetServiceOrder(_networkSet);
            CFMutableArrayRef   newOrder = CFArrayCreateMutableCopy(
                                              kCFAllocatorDefault,
                                              0,
                                              origOrder
                                            );
            if (newOrder) {
              CFArrayAppendValue(newOrder,SCNetworkServiceGetServiceID(theNewService));
              SCNetworkSetSetServiceOrder(_networkSet,newOrder);
              CFRelease(newOrder);
            }
            
            //  Store all properties:
            [self commitUpdatesToNodes:kNCTreeNodeApplyToAll];
            [newDir release];
            
            //  newDir retained the new service, so we need to release our
            //  reference:
            CFRelease(theNewService);
            
            return YES;
          }
        }
      }
    } else
      NCErrorPush(kNCErrorServiceExists,CFSTR("A network service with that name already exists in that location."),NULL);
    return NO;
  }

//

  - (NCServiceDirectory*) serviceWithName:(CFStringRef)serviceName
  {
    NCDirectoryNode*  children = (NCDirectoryNode*)[self child];
    
    if (children)
      return (NCServiceDirectory*)[children searchForNodeWithDirectoryName:serviceName andClass:[NCServiceDirectory class]];
    return nil;
  }
  
//

  - (NCServiceDirectory*) serviceWithID:(CFStringRef)serviceID
  {
    NCDirectoryNode*  child = (NCDirectoryNode*)[self child];
    
    while (child) {
      if ([child isKindOfClass:[NCServiceDirectory class]]) {
        CFStringRef   altServiceID = SCNetworkServiceGetServiceID([(NCServiceDirectory*)child networkService]);
        
        if (CFStringCompare(serviceID,altServiceID,0) == kCFCompareEqualTo)
          return (NCServiceDirectory*)child;
      }
      child = (NCDirectoryNode*)[child sibling];
    }
    return nil;
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
      CFArrayRef              anArray;
      
      //  Name of the location:
      if ((aStr = SCNetworkSetGetName(_networkSet)))
        CFDictionaryAddValue(result,kSCPropUserDefinedName,aStr);
      
      //  Service order:
      if ((anArray = [self serviceOrderByName])) {
        CFMutableArrayRef   srvcCopy = CFArrayCreateMutableCopy(
                                          kCFAllocatorDefault,
                                          CFArrayGetCount(anArray),
                                          anArray
                                        );
        if (srvcCopy) {
          CFDictionaryAddValue(result,kSCPropNetServiceOrder,srvcCopy);
          CFRelease(srvcCopy);
        }
      }
    }
    return result;
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    if (propDict) {
      CFStringRef             aStr;
      CFArrayRef              anArray;
      
      //  Name of the location:
      if ((aStr = CFDictionaryGetValue(propDict,kSCPropUserDefinedName)))
        SCNetworkSetSetName(_networkSet,aStr);
      
      //  Service order:
      if ((anArray = CFDictionaryGetValue(propDict,kSCPropNetServiceOrder))) {
        CFMutableArrayRef   byID = [self serviceOrderByIDForNames:anArray];
        
        if (byID) {
          CFArrayRef      oldOrder = SCNetworkSetGetServiceOrder(_networkSet);
          
          if (oldOrder && CFEqual(oldOrder,byID)) {
          } else {
            SCNetworkSetSetServiceOrder(_networkSet,byID);
            CFRelease(byID);
          }
        }
      }
    }
  }
  
//

  - (NCPropertyHandler*) propertyHandler
  {
    if (_propertyHandler == nil) {
      NCPropertyRef   properties[2];
      
      properties[0] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeString,
                        NCLocationDirectory_Name,
                        kSCPropUserDefinedName,
                        FALSE,
                        NULL
                      );
      properties[1] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeStringEnumArray,
                        NCLocationDirectory_ServiceOrder,
                        kSCPropNetServiceOrder,
                        FALSE,
                        [self serviceOrderByName]
                      );
      _propertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:2] retain];
      NCPropertyRelease(properties[0]);
      NCPropertyRelease(properties[1]);
    }
    return _propertyHandler;
  }

@end
