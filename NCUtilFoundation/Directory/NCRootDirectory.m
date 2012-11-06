//
//  ncutil3 - network configuration utility, version 3
//  NCRootDirectory
//
//  Concrete directory node class that represents the root
//  node of a preference store.
//
//  Created by Jeffrey Frey on Thu Jun  2 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCRootDirectory.h"
#import "NCLocationDirectory.h"
#import "NCInterfaceNode.h"
#include "CFAdditions.h"
#include "NCError.h"

CFStringRef NCRootDirectory_LocName = NULL;
CFStringRef NCRootDirectory_CompName = NULL;
CFStringRef NCRootDirectory_HostName = NULL;
CFStringRef NCRootDirectory_InterfacesDirName = NULL;

@implementation NCRootDirectory

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    if (!NCRootDirectory_LocName) {
      NCRootDirectory_LocName = CFSTR("current-location");
      NCRootDirectory_CompName = CFSTR("computer-name");
      NCRootDirectory_HostName = CFSTR("local-host-name");
      NCRootDirectory_InterfacesDirName = CFSTR("Interfaces");
    }
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }

//

  + (CFStringRef) directoryType
  {
    static CFStringRef NCRootDirectory_DirectoryType = NULL;
    if (!NCRootDirectory_DirectoryType)
      NCRootDirectory_DirectoryType = CFSTR("Root");
    return NCRootDirectory_DirectoryType;
  }

//

  - (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess
  {
    if (self = [super initWithPreferenceSession:prefSess]) {
      
      //  Add the interface templates directory:
      CFArrayRef    availableInterfaces = SCNetworkInterfaceCopyAll();
      
      if (availableInterfaces) {
        CFIndex               i = 0,iMax = CFArrayGetCount(availableInterfaces);
        NCDirectoryNode*      interfaceTmpls = [[NCDirectoryNode alloc] initWithPreferenceSession:prefSess];
        
        if (interfaceTmpls) {
          CFStringRef         dirName = NCRootDirectory_InterfacesDirName;
          
          //  Add the container directory:
          [interfaceTmpls setDirectoryName:dirName]; CFRelease(dirName);
          [interfaceTmpls setIsLocked:YES];
          [self appendChild:interfaceTmpls];
          
          //  Make the children:
          while (i < iMax) {
            SCNetworkInterfaceRef   theInterface = CFArrayGetValueAtIndex(availableInterfaces,i++);
            NCInterfaceNode*        newDir = [NCInterfaceNode templateInterfaceNodeWithRootDirectory:self andNetworkInterface:theInterface];
            
            if (newDir) {
              [interfaceTmpls appendChild:newDir];
              //[newDir release];
            }
          }
          
          [interfaceTmpls release];
        }
        CFRelease(availableInterfaces);
      }
      
      //  Populate with locations:
      CFArrayRef            networkSets = SCNetworkSetCopyAll([prefSess sessionReference]);
      
      if (networkSets) {
        CFIndex               i = 0,iMax = CFArrayGetCount(networkSets);
        NCLocationDirectory*  lastDir = nil;
        
        while ( i < iMax ) {
          SCNetworkSetRef       theSet = CFArrayGetValueAtIndex(networkSets,i++);
          NCLocationDirectory*  newDir = [[NCLocationDirectory alloc] initWithRootDirectory:self andNetworkSet:theSet];
          
          if (newDir) {
            if (lastDir)
              [lastDir insertSibling:newDir];
            else
              [self appendChild:newDir];
            lastDir = newDir;
            [newDir release];
          }
        }
        CFRelease(networkSets);
      }
    }
    return self;
  }

//
  - (void) refreshEntireTree
  {
    [self refreshNodes:kNCTreeNodeApplyToAll];
  }
  
//

  - (void) commitUpdatesToEntireTree
  {
    [self commitUpdatesToNodes:kNCTreeNodeApplyToAll];
  }

//

  - (BOOL) addLocationWithName:(CFStringRef)name
  {
    if (![self locationWithName:name]) {
      NCPreferenceSession*  prefSess = [self preferenceSession];
      SCNetworkSetRef       newSet = SCNetworkSetCreate([prefSess sessionReference]);
      NCLocationDirectory*  newDir = nil;
      
      if (newSet) {
        //  Give the thing a name right here, rather than going through the NCDirectory
        //  API for it:
        SCNetworkSetSetName(newSet,name);
        
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1050
        //  Add an empty dictionary at the global NetInfo path:
        CFStringRef     locID = SCNetworkSetGetSetID(newSet);
        CFStringRef     netInfoPath = SCPathCreateFromComponents(
                                          kSCPrefSets,
                                          locID,
                                          kSCCompNetwork,
                                          kSCCompGlobal,
                                          kSCEntNetNetInfo,
                                          NULL
                                        );
        if (netInfoPath) {
          [prefSess createPathIfNotPresent:netInfoPath];
          CFRelease(netInfoPath);
        }
#endif

        //  Create the new location directory now:
        if (newDir = [[NCLocationDirectory alloc] initWithRootDirectory:self andNetworkSet:newSet]) {
          //[newDir setDirectoryName:name];
          [self appendChild:newDir];
          [newDir release];
          return YES;
        }
        
        //  The directory has retained the set, so we should dump our reference:
        CFRelease(newSet);
      }
    } else
      NCErrorPush(kNCErrorLocationExists,CFSTR("A location with that name already exists."),NULL);
    return NO;
  }

//

  - (CFMutableDictionaryRef) readPropertiesDictionary
  {
    //  We grab values from various global locations and dump them into
    //  a mutable dictionary, since there isn't a whole dictionary associated
    //  with the root node itself:
    CFMutableDictionaryRef    result = CFDictionaryCreateMutable(
                                          kCFAllocatorDefault,
                                          0,
                                          &kCFCopyStringDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks
                                        );
    if (result) {
      NCPreferenceSession*    pSess = [self preferenceSession];
      CFStringRef             aStr;
      
      //  Current location name:
      if (aStr = SCCurrentLocationName([pSess sessionReference]))
        CFDictionaryAddValue(result,NCRootDirectory_LocName,aStr);
        
      //  Current computer name:
      if (aStr = [pSess getValueOfProperty:kSCPropSystemComputerName atPath:CFSTR("/System/System")])
        CFDictionaryAddValue(result,NCRootDirectory_CompName,aStr);
      
      //  Current local hostname:
      if (aStr = [pSess getValueOfProperty:kSCPropNetLocalHostName atPath:CFSTR("/System/Network/HostNames")])
        CFDictionaryAddValue(result,NCRootDirectory_HostName,aStr);
    }
    return result;
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    if (propDict) {
      NCPreferenceSession*    pSess = [self preferenceSession];
      CFStringRef             aStr;
      
      //  Current computer name:
      if (aStr = CFDictionaryGetValue(propDict,NCRootDirectory_CompName))
        [pSess setValue:aStr ofProperty:kSCPropSystemComputerName atPath:CFSTR("/System/System")];
      else
        [pSess removeProperty:kSCPropSystemComputerName atPath:CFSTR("/System/System")];
      
      //  Current local hostname:
      if (aStr = CFDictionaryGetValue(propDict,NCRootDirectory_HostName))
        [pSess setValue:aStr ofProperty:kSCPropNetLocalHostName atPath:CFSTR("/System/Network/HostNames")];
      else
        [pSess removeProperty:kSCPropNetLocalHostName atPath:CFSTR("/System/Network/HostNames")];
      
      //  Current location name:
      if (aStr = CFDictionaryGetValue(propDict,NCRootDirectory_LocName)) {
        //  We just ask the location itself -- if it exists -- to become the
        //  current:
        NCLocationDirectory*  theLoc = [self locationWithName:aStr];
        
        if (theLoc)
          [theLoc setAsCurrentLocation];
        else
          NCErrorPush(kNCErrorNoSuchLocation,CFSTR("The specified location does not exist."),NULL);
      }
    }
  }
  
//

  + (NCPropertyHandler*) propertyHandler
  {
    static NCPropertyHandler* NCRootDirectoryPropertyHandler = nil;
    
    if (NCRootDirectoryPropertyHandler == nil) {
      NCPropertyRef   properties[3];
      
      properties[0] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeString,
                        NCRootDirectory_LocName,
                        NCRootDirectory_LocName,
                        FALSE,
                        NULL
                      );
      properties[1] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeString,
                        NCRootDirectory_CompName,
                        NCRootDirectory_CompName,
                        FALSE,
                        NULL
                      );
      properties[2] = NCPropertyCreate(kCFAllocatorDefault,
                        kNCPropertyTypeString,
                        NCRootDirectory_HostName,
                        NCRootDirectory_HostName,
                        FALSE,
                        NULL
                      );
      NCRootDirectoryPropertyHandler = [[NCPropertyHandler propertyHandlerWithProperties:properties count:3] retain];
      NCPropertyRelease(properties[0]);
      NCPropertyRelease(properties[1]);
      NCPropertyRelease(properties[2]);
    }
    return NCRootDirectoryPropertyHandler;
  }

//

  - (NCLocationDirectory*) locationWithName:(CFStringRef)locationName
  {
    NCDirectoryNode*  children = (NCDirectoryNode*)[self child];
    
    if (children)
      return (NCLocationDirectory*)[children searchForNodeWithDirectoryName:locationName andClass:[NCLocationDirectory class]];
    return nil;
  }

//

  - (NCLocationDirectory*) currentLocation
  {
    CFStringRef   curLocName = [self valueOfProperty:NCRootDirectory_LocName];
    
    return [self locationWithName:curLocName];
  }

//

  - (NCLocationDirectory*) firstLocationDirectory
  {
    NCDirectoryNode*    children = (NCDirectoryNode*)[self child];
    
    while (children) {
      if ([children isKindOfClass:[NCLocationDirectory class]])
        return (NCLocationDirectory*)children;
      children = (NCDirectoryNode*)[children sibling];
    }
    return nil;
  }

//

  - (BOOL) treeHasBeenModified
  {
    //  Get the direct child node and walk through it's sibling chain.  For
    //  each that is a NCLocationDirectory, we'll check for modifications.
    BOOL                modified = [self wasModified];
    NCDirectoryNode*    aNode = (NCDirectoryNode*)[self child];
    
    while (!modified && aNode) {
      if ([aNode isKindOfClass:[NCLocationDirectory class]])
        modified = ([aNode searchForModifiedNode] != nil);
      aNode = (NCDirectoryNode*)[aNode sibling];
    }
    return modified;
  }

//

  - (NCDirectoryNode*) interfaceTemplateDirectory
  {
    NCDirectoryNode*    aNode = (NCDirectoryNode*)[self child];
    
    while (aNode) {
      if (CFStringCompare([aNode directoryName],NCRootDirectory_InterfacesDirName,0) == kCFCompareEqualTo)
        return aNode;
      aNode = (NCDirectoryNode*)[aNode sibling];
    }
    return nil;
  }

//

  - (CFStringRef) directoryName
  {
    return CFSTR("");
  }
  - (void) setDirectoryName:(CFStringRef)name
  {
    //  There's no such thing, but we must override to inhibit the default
    //  behavior of modifying the kSCPropUserDefinedName property.
  }

@end
