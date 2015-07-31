//
//  ncutil3 - network configuration utility, version 3
//  NCPortOptions
//
//  Moved over from NCUtilFoundation 1.0.  Retrieves hardware-level
//  configuration options via IOKit to make our interface a bit
//  more intelligent.
//
//  Created by Jeffrey Frey on Tue Jun  7 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCPortOptions.h"
#include <mach/mach.h>
#include <IOKit/IOBSD.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IONetworkController.h>
#include <SystemConfiguration/SystemConfiguration.h>

#include "CFAdditions.h"
#include "CFCString.h"
#include "NCError.h"

// This corrects an error in the Apple-supplied IOKit/network/IONetworkMedium.h
// header:

#ifdef IOMediumGetNetworkType
  #undef IOMediumGetNetworkType
#endif
#define IOMediumGetNetworkType(x)   ((x) & kIOMediumNetworkTypeMask)

//  Inspecting if_media.h we see that there are a maximum of seven
//  options; but we know an interface can't be full- and half-duplex
//  simultaneously, so we can subtract one:
#define NCMaxMediaOptions 6

  CFStringRef
  NCMediaDescriptor_CFStringForSubType(
    IOMediumType    medium
  )
  {
    static struct ifmedia_description enetSubTypes[] = IFM_SUBTYPE_ETHERNET_DESCRIPTIONS;
    static struct ifmedia_description tokenSubTypes[] = IFM_SUBTYPE_TOKENRING_DESCRIPTIONS;
    static struct ifmedia_description fddiSubTypes[] = IFM_SUBTYPE_FDDI_DESCRIPTIONS;
    static struct ifmedia_description ieee80211SubTypes[] = IFM_SUBTYPE_IEEE80211_DESCRIPTIONS;
    static struct ifmedia_description sharedSubTypes[] = IFM_SUBTYPE_SHARED_DESCRIPTIONS;
    
    struct ifmedia_description* target = NULL;
    IOMediumType      type = IOMediumGetNetworkType(medium);
    IOMediumType      subType = IOMediumGetSubType(medium);
    
    if ((subType >= IFM_AUTO) && (subType <= IFM_NONE))
      return CFStringCreateWithCStringNoCopy(
                kCFAllocatorDefault,
                sharedSubTypes[subType].ifmt_string,
                kCFStringEncodingASCII,
                kCFAllocatorNull);
    
    switch (type) {
      case IFM_TOKEN:
        target = tokenSubTypes;
        break;
      case IFM_FDDI:
        target = fddiSubTypes;
        break;
      case kIOMediumEthernet:
        target = enetSubTypes;
        break;
      case kIOMediumIEEE80211:
        target = ieee80211SubTypes;
        break;
      default:
        return NULL;
    }
    
    if (target->ifmt_string == NULL)
      return NULL;
    do {
      if (target->ifmt_word == subType)
        return CFStringCreateWithCStringNoCopy(
                      kCFAllocatorDefault,
                      target->ifmt_string,
                      kCFStringEncodingASCII,
                      kCFAllocatorNull);
      target++;
    } while (target->ifmt_string != NULL);
    return NULL;
  }
  
//

  CFMutableSetRef
  NCMediaDescriptor_CFStringsForCommonOptions(
    IOMediumType      medium,
    CFMutableSetRef   reuseSet
  )
  {
    static struct ifmedia_description optionsList[] = IFM_SHARED_OPTION_DESCRIPTIONS;
    
    struct ifmedia_description* target = optionsList;
    CFMutableSetRef     result = NULL;
    
    //  Isolate just the shared options:
    medium &= kIOMediumCommonOptionsMask;
    
    //  If we have an incoming CFSet then we have an easy
    //  way to force it to be reused:
    result = reuseSet;
    
    do {
      if (medium & target->ifmt_word) {
        CFStringRef   newStr = CFStringCreateWithCStringNoCopy(
                                  kCFAllocatorDefault,
                                  target->ifmt_string,
                                  kCFStringEncodingASCII,
                                  kCFAllocatorNull);
        //  The medium word that the user passed to us
        //  has the current option set.  We dump the
        //  string into a CFSet:
        if (result == NULL) {
          //  Create a set now:
          result = CFSetCreateMutable(
                      kCFAllocatorDefault,
                      NCMaxMediaOptions,
                      &kCFCopyStringSetCallBacks);
        }
        CFSetAddValue(result,newStr);
        CFRelease(newStr);
      }
      target++;
    } while (target->ifmt_string);
    return result;
  }
  
//

  CFMutableSetRef
  NCMediaDescriptor_CFStringsForMediaSpecificOptions(
    IOMediumType      medium,
    CFMutableSetRef   reuseSet
  )
  {
    static struct ifmedia_description tokenOptions[] = IFM_SUBTYPE_TOKENRING_OPTION_DESCRIPTIONS;
    static struct ifmedia_description fddiOptions[] = IFM_SUBTYPE_FDDI_OPTION_DESCRIPTIONS;
    static struct ifmedia_description ieee802111Options[] = IFM_SUBTYPE_IEEE80211_OPTION_DESCRIPTIONS;
    
    struct ifmedia_description* target = NULL;
    IOMediumType        type = IOMediumGetNetworkType(medium);
    CFMutableSetRef     result = NULL;
    
    //  If we have an incoming CFSet then we have an easy
    //  way to force it to be reused:
    result = reuseSet;
    
    switch (type) {
      case IFM_TOKEN:
        target = tokenOptions;
        break;
      case IFM_FDDI:
        target = fddiOptions;
        break;
      case kIOMediumIEEE80211:
        target = ieee802111Options;
        break;
      default:
        return result;
    }
    
    if (target->ifmt_string == NULL)
      return result;
    
    //  Isolate just the media-specific options:
    medium &= kIOMediumOptionsMask;
    
    do {
      if (medium & target->ifmt_word) {
        CFStringRef   newStr = CFStringCreateWithCStringNoCopy(
                                  kCFAllocatorDefault,
                                  target->ifmt_string,
                                  kCFStringEncodingASCII,
                                  kCFAllocatorNull);
        //  The medium word that the user passed to us
        //  has the current option set.  We dump the
        //  string into a CFSet:
        if (result == NULL) {
          //  Create a set now:
          result = CFSetCreateMutable(
                    kCFAllocatorDefault,
                    NCMaxMediaOptions,
                    &kCFCopyStringSetCallBacks);
        }
        CFSetAddValue(result,newStr);
        CFRelease(newStr);
      }
      target++;
    } while (target->ifmt_string);
    return NULL;
  }
  
//
#pragma mark -
//

@interface NCPortOptions(NCPortOptionsPrivate)

- (BOOL) processMediumTypesDictionary;

@end

//
#pragma mark -
//

@implementation NCPortOptions

  + (NCPortOptions*) portOptionsWithBSDDevice:(CFStringRef)devname
  {
    CFCStringRef            cDevName = CFCStringCreate(kCFAllocatorDefault,devname);
    CFMutableDictionaryRef  lookupParams;
    NCPortOptions*          portOpts = nil;
    
    if (cDevName) {
      io_object_t     match;
      
      lookupParams = IOBSDNameMatching(
                        kIOMasterPortDefault,
                        0,
                        CFCStringGetCStringPtr(cDevName)
                      );
      match = IOServiceGetMatchingService(kIOMasterPortDefault,lookupParams);
      
      if (match) {
        portOpts = [[[NCPortOptions alloc] initWithIOKitInterfaceObject:match] autorelease];
        IOObjectRelease(match);
      }
      CFCStringDealloc(cDevName);
    }
    return portOpts;
  }

//

  + (NCPortOptions*) portOptionsWithIOKitInterfaceObject:(io_object_t)iface
  {
    return [[[NCPortOptions alloc] initWithIOKitInterfaceObject:iface] autorelease];
  }

//

  - (id) initWithIOKitInterfaceObject:(io_object_t)iface
  {
    if (self = [super init]) {
      io_object_t   controller;
      CFNumberRef   mtuObj;
      
      //  We can grab the max transmission unit size from the
      //  interface object:
      if ((mtuObj = IORegistryEntryCreateCFProperty(iface,CFSTR(kIOMaxTransferUnit),nil,kNilOptions)) == NULL) {
        [self release];
        return nil;
      }
      if (!CFNumberGetValue(mtuObj,kCFNumberCFIndexType,&maxTransmitUnitSize)) {
        CFRelease(mtuObj);
        [self release];
        return nil;
      }
      CFRelease(mtuObj);
      
      //  The interface object's parent contains the information we're
      //  looking for:
      if (IORegistryEntryGetParentEntry(iface,kIOServicePlane,&controller)) {
        [self release];
        return nil;
      }
      if ((mediumTypesFromIOKit = IORegistryEntryCreateCFProperty(controller,CFSTR(kIOMediumDictionary),nil,kNilOptions)) == NULL) {
        IOObjectRelease(controller);
        [self release];
        return nil;
      }
      IOObjectRelease(controller);
      if (![self processMediumTypesDictionary]) {
        [self release];
        return nil;
      }
    }
    return self;
  }
  
//

  - (void) dealloc
  {
    if (mediumTypesFromIOKit) CFRelease(mediumTypesFromIOKit);
    if (portOptionsDictionary) CFRelease(portOptionsDictionary);
    [super dealloc];
  }
  
//

  - (void) summarizeToStream:(FILE*)stream
  {
    fprintf(stream,"NCPort[%lu] { mtu: %ld \n",(unsigned long)[self retainCount],maxTransmitUnitSize);
    if (portOptionsDictionary) {
      CFIndex       i = 0,count = CFDictionaryGetCount(portOptionsDictionary);
      CFTypeRef*    keysAndVals = CFAllocatorAllocate(kCFAllocatorDefault,NCMaxMediaOptions + 2 * sizeof(CFStringRef) * count,0);
      CFTypeRef*    valBase = keysAndVals + count;
      CFTypeRef*    optsBase = valBase + count;
      
      if (keysAndVals) {
        CFDictionaryGetKeysAndValues(portOptionsDictionary,keysAndVals,keysAndVals + count);
        while ( i < count ) {
          NCPrint(stream,CFSTR("  %@: "),keysAndVals[i]);
          if (valBase[i] != kCFNull) {
            CFIndex     j = 0,setCount = CFSetGetCount(valBase[i]);
            
            CFSetGetValues(valBase[i],optsBase);
            while ( j < setCount) {
              if (j != 0)
                NCPrint(stream,CFSTR("| %@ "),optsBase[j]);
              else
                NCPrint(stream,CFSTR("%@ "),optsBase[j]);
              j++;
            }
          }
          fputc('\n',stream);
          i++;
        }
        CFAllocatorDeallocate(kCFAllocatorDefault,keysAndVals);
      }
    }
    fprintf(stream,"}\n");
  }

//

  - (CFDictionaryRef) portOptionsDictionary { return portOptionsDictionary; }
  - (CFIndex) maxTransmitUnitSize { return maxTransmitUnitSize; };

//

  - (BOOL) validMediaSubType:(CFStringRef)subTypeName
  {
    if (portOptionsDictionary) {
      if (CFDictionaryGetValue(portOptionsDictionary,subTypeName))
        return YES;
    }
    return NO;
  }

//

  - (CFArrayRef) mediaSubTypes
  {
    CFArrayRef      result = NULL;
    
    if (portOptionsDictionary) {
      CFIndex       count = CFDictionaryGetCount(portOptionsDictionary);
      CFTypeRef*    keys = CFAllocatorAllocate(kCFAllocatorDefault,sizeof(CFTypeRef) * count,0);
      
      if (keys) {
        CFDictionaryGetKeysAndValues(portOptionsDictionary,keys,NULL);
        result = CFArrayCreate(kCFAllocatorDefault,keys,count,&kCFTypeArrayCallBacks);
        CFAllocatorDeallocate(kCFAllocatorDefault,keys);
      }
    }
    return result;
  }
  
//

  - (CFSetRef) optionsForMediaSubType:(CFStringRef)subTypeName
  {
    if (portOptionsDictionary) {
      CFTypeRef   value = CFDictionaryGetValue(portOptionsDictionary,subTypeName);
      
      if (value != kCFNull)
        return value;
    }
    return NULL;
  }

//

  - (BOOL) validOption:(CFStringRef)option
    forMediaSubType:(CFStringRef)subTypeName
  {
    CFSetRef    opts = [self optionsForMediaSubType:subTypeName];
    
    if (opts) {
      if (CFSetContainsValue(opts,option))
        return YES;
    }
    return NO;
  }

//

  - (BOOL) validMediumDescriptor:(IOMediumType)medium
  {
    CFStringRef   typeStr = NCCreateMediumTypeString(medium);
    BOOL          result = NO;
    
    if (typeStr) {
      if (CFDictionaryContainsKey(mediumTypesFromIOKit,typeStr))
        result = YES;
      CFRelease(typeStr);
    }
    return result;
  }

@end

//
#pragma mark -
//

@implementation NCPortOptions(NCPortOptionsPrivate)

  - (BOOL) processMediumTypesDictionary
  {
    CFIndex       count = CFDictionaryGetCount(mediumTypesFromIOKit);
    CFStringRef*  keys = CFAllocatorAllocate(kCFAllocatorDefault,count * sizeof(CFStringRef),0);
    
    if (keys) {
      CFDictionaryGetKeysAndValues(mediumTypesFromIOKit,(CFTypeRef*)keys,NULL);
      while (count-- > 0) {
        CFDictionaryRef   item = CFDictionaryGetValue(mediumTypesFromIOKit,keys[count]);
        CFNumberRef       num;
        
        if ((num = CFDictionaryGetValue(item,CFSTR(kIOMediumType)))) {
          CFIndex         medium;
          
          if (CFNumberGetValue(num,kCFNumberCFIndexType,&medium)) {
            CFStringRef         mediaKey;
            CFMutableSetRef     mediaSet = NULL;
            
            //  Try to get a medium sub-type descriptor:
            if ((mediaKey = NCMediaDescriptor_CFStringForSubType(medium))) {
            
              //  If no portOptionsDictionary exists, then we simply
              //  create a new one and this whole cycle goes from
              //  scratch:
              if (portOptionsDictionary == NULL) {
                portOptionsDictionary = CFDictionaryCreateMutable(
                                          kCFAllocatorDefault,
                                          0,
                                          &kCFTypeDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks);
              } else {
                mediaSet = (CFMutableSetRef)CFDictionaryGetValue(portOptionsDictionary,mediaKey);
                if ((CFTypeRef)mediaSet == kCFNull)
                  mediaSet = NULL;
              }
              
              //  Set common options:
              mediaSet = NCMediaDescriptor_CFStringsForCommonOptions(medium,mediaSet);
              
              //  Set media-specific options:
              mediaSet = NCMediaDescriptor_CFStringsForMediaSpecificOptions(medium,mediaSet);
              
              //  If we came through with NULL, then set the mediaKey
              //  to kCFNull; otherwise, drop the set into the dictionary:
              if (mediaSet)
                CFDictionarySetValue(portOptionsDictionary,mediaKey,mediaSet);
              else
                CFDictionarySetValue(portOptionsDictionary,mediaKey,kCFNull);
            }
          }
        }
      }
    }
    if (portOptionsDictionary)
      return YES;
    return NO;
  }

@end
