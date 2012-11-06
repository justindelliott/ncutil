//
//  ncutil3 - network configuration utility, version 3
//  NCPreferenceSession
//
//  Class that manages a preference session.
//
//  Created by Jeffrey Frey on Sun May 22 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCPreferenceSession.h"
#import "NCRootDirectory.h"
#include "CFAdditions.h"
#include "NCError.h"

CFStringRef
SCPathCreateFromComponents(
  CFStringRef         firstStr,...
)
{
  va_list               args;
  CFMutableStringRef    result = NULL;
  
  if (firstStr) {
    result = CFStringCreateMutable(kCFAllocatorDefault,0);
    if (result) {
      CFStringRef   str;
      
      va_start(args,firstStr);
      str = firstStr;
      do {
        if (CFStringGetCharacterAtIndex(str,0) != '/')
          CFStringAppendFormat(result,NULL,CFSTR("/%@"),str);
        else
          CFStringAppendFormat(result,NULL,CFSTR("%@"),str);
      } while (str = va_arg(args,CFTypeRef));
      va_end(args);
    }
  }
  return result;
}

//

CFStringRef
SCCurrentLocationName(
  SCPreferencesRef		scSession
)
{
  CFStringRef         path = SCPreferencesGetValue(scSession,kSCPrefCurrentSet);
  
  if (path) {
    CFDictionaryRef   dict = SCPreferencesPathGetValue(scSession,path);
    
    if (dict)
      return CFDictionaryGetValue(dict,kSCPropUserDefinedName);
  }
  return NULL;
}

//
#pragma mark -
//

@interface NCPreferenceSession(NCPrivatePreferenceSession)

- (BOOL) setupNewPreferenceFile;

@end

@implementation NCPreferenceSession(NCPrivatePreferenceSession)

  - (BOOL) setupNewPreferenceFile
  {
    //  Add a location:
    if ([_directoryTree addLocationWithName:CFSTR("Default")]) {
      if ([_directoryTree setValue:CFSTR("Default") ofProperty:NCRootDirectory_LocName])
        return YES;
    }
    return NO;
  }

@end

//
#pragma mark -
//

static CFStringRef NCDefaultPathSeparator = NULL;

@implementation NCPreferenceSession

#ifdef NCUTIL_USE_FOUNDATION
  + (void) initialize
#else
  + (id) initialize
#endif
  {
    
    if (!NCDefaultPathSeparator)
      NCDefaultPathSeparator = CFSTR("/");
    
#ifndef NCUTIL_USE_FOUNDATION
    return self;
#endif
  }
  
//

  - (id) init
  {
    return [self initWithPreferencesAtPath:NULL];
  }

//

  - (id) initWithPreferencesAtPath:(CFStringRef)prefPath
  {
    if (self = [super init]) {
      BOOL      existedAlready = (prefPath ? CFStringPathExists(prefPath) : YES);
    
      _sessionReference = SCPreferencesCreate(kCFAllocatorDefault,CFSTR("ncutil"),prefPath);
      
      if (!_sessionReference) {
        [self release];
        return nil;
      }
    
      //  Setup the directory ID bit vector and allocate zero to us:
      _directoryIDs = CFBitVectorCreateMutable(kCFAllocatorDefault,0);
      CFBitVectorSetCount(_directoryIDs,32);
      
      //  Note whether the system default was asked for; if it was by-path
      //  then allow lock overrides down at the property handler level.
      if (!prefPath)
        _isSystemDefault = YES;
      else
        NCPropertySetOverrideLocking(TRUE);
        
      _directoryTree = [[NCRootDirectory alloc] initWithPreferenceSession:self];
      
      //  If it didn't exist, add a default location, etc:
      if (!existedAlready) {
        if (![self setupNewPreferenceFile]) {
          NCErrorPush(kNCErrorCouldNotSetupPreferences,CFSTR("Could not setup the new preference store."),NULL);
          [self release];
          return nil;
        }
      }
    }
    return self;
  }
  
//

  - (id) initWithPreferenceRef:(SCPreferencesRef)prefSess
  {
    if (prefSess) {
      if (self = [super init]) {
        _sessionReference = CFRetain(prefSess);
    
        //  Setup the directory ID bit vector and allocate zero to us:
        _directoryIDs = CFBitVectorCreateMutable(kCFAllocatorDefault,0);
        CFBitVectorSetCount(_directoryIDs,32);
        
        if (_sessionReference) {
          _isSystemDefault = NO;
          _directoryTree = [[NCRootDirectory alloc] initWithPreferenceSession:self];
        } else {
          [self release];
          self = nil;
        }
      }
    } else
      self = [self init];
    return self; 
  }

//

  - (void) dealloc
  {
    if (_pathSeparator) CFRelease(_pathSeparator);
    if (_directoryTree) [_directoryTree release];
    //  We need to keep the directory ID bit vector around because the tree
    //  will be deallocating their directory IDs!!!
    if (_directoryIDs) CFRelease(_directoryIDs);
    if (_sessionReference) CFRelease(_sessionReference);
    [super dealloc];
  }

//

  - (SCPreferencesRef) sessionReference { return _sessionReference; }
  - (BOOL) isSystemDefault { return _isSystemDefault; }
  
//

  - (CFStringRef) pathSeparatorForDirectoryTree
  {
    if (_pathSeparator)
      return _pathSeparator;
    return NCDefaultPathSeparator;
  }
  - (void) setPathSeparatorForDirectoryTree:(CFStringRef)sepStr
  {
    if (sepStr) sepStr = CFStringCreateCopy(kCFAllocatorDefault,sepStr);
    if (_pathSeparator) CFRelease(_pathSeparator);
    _pathSeparator = sepStr;
  }

//

  - (CFStringRef) createUniqueSubpathAtPath:(CFStringRef)parentPath
  {
    return SCPreferencesPathCreateUniqueChild(_sessionReference,parentPath);
  }

//

  - (CFDictionaryRef) getValueAtPath:(CFStringRef)path
  {
    return SCPreferencesPathGetValue(_sessionReference,path);
  }
  
//

  - (BOOL) setValue:(CFDictionaryRef)dict
    atPath:(CFStringRef)path
  {
    Boolean   result = SCPreferencesPathSetValue(_sessionReference,path,dict);
    
    return ((result == TRUE)?YES:NO);
  }
  
//

  - (BOOL) removeValueAtPath:(CFStringRef)path
  {
    Boolean   result = SCPreferencesPathRemoveValue(_sessionReference,path);
    
    return ((result == TRUE)?YES:NO);
  }

//

  - (BOOL) createPathIfNotPresent:(CFStringRef)path
  {
    if (![self getValueAtPath:path]) {
      BOOL                      result;
      CFMutableDictionaryRef    newDict = CFDictionaryCreateMutable(
                                            kCFAllocatorDefault,
                                            0,
                                            &kCFCopyStringDictionaryKeyCallBacks,
                                            &kCFTypeDictionaryValueCallBacks
                                          );
      if (!newDict)
        return NO;
      result = [self setValue:newDict atPath:path];
      CFRelease(newDict);
    }
    return YES;
  }

//

  - (CFPropertyListRef) getValueOfProperty:(CFStringRef)property
    atPath:(CFStringRef)path
  {
    CFDictionaryRef   dict = [self getValueAtPath:path];
    
    if (dict)
      return CFDictionaryGetValue(dict,property);
    return NULL;
  }
  
//

  - (void) setValue:(CFPropertyListRef)value
    ofProperty:(CFStringRef)property
    atPath:(CFStringRef)path
  {
    CFDictionaryRef   dict = [self getValueAtPath:path];
    
    if (dict) {
      CFDictionarySetValue((CFMutableDictionaryRef)dict,property,value);
      [self setValue:dict atPath:path];
    }
  }

//

  - (void) removeProperty:(CFStringRef)property
    atPath:(CFStringRef)path
  {
    CFDictionaryRef   dict = [self getValueAtPath:path];
    
    if (dict) {
      CFDictionaryRemoveValue((CFMutableDictionaryRef)dict,property);
      [self setValue:dict atPath:path];
    }
  }

//

  - (CFStringRef) getLinkAtPath:(CFStringRef)path
  {
    return SCPreferencesPathGetLink(_sessionReference,path);
  }
  
//

  - (BOOL) setLinkToPath:(CFStringRef)linkPath
    atPath:(CFStringRef)path
  {
    Boolean   result = SCPreferencesPathSetLink(_sessionReference,path,linkPath);
    
    return ((result == TRUE)?YES:NO);
  }
  
//

  - (BOOL) commitChanges
  {
    //  Get the tree to commit all changes:
    [_directoryTree commitUpdatesToEntireTree];
    
    if (SCPreferencesCommitChanges(_sessionReference))
      return YES;
    NCErrorPush(kNCErrorCouldNotCommit,CFSTR("The changes could not be written to the preference store."),NULL);
    return NO;
  }
  
//

  - (BOOL) applyChanges
  {
    //  Commit changes first!
    if ([self commitChanges]) {
      if (SCPreferencesApplyChanges(_sessionReference))
        return YES;
      NCErrorPush(kNCErrorCouldNotApply,CFSTR("The changes could not be applied."),NULL);
    }
    return NO;
  }
  
//

  - (NCRootDirectory*) directoryTree
  {
    return _directoryTree;
  }

//

  - (CFIndex) allocateDirectoryID
  {
    CFIndex     bitCount = CFBitVectorGetCount(_directoryIDs);
    CFIndex     nextID = CFBitVectorGetFirstIndexOfBit(_directoryIDs,CFRangeMake(0,bitCount),0);
    
    if (nextID != kCFNotFound)
      CFBitVectorSetBitAtIndex(_directoryIDs,nextID,1);
    else {
      CFBitVectorSetCount(_directoryIDs,bitCount + 32);
      CFBitVectorSetBitAtIndex(_directoryIDs,nextID = bitCount,1);
    }
    return nextID;
  }

//

  - (void) deallocateDirectoryID:(CFIndex)dirID
  {
    CFIndex     bitCount = CFBitVectorGetCount(_directoryIDs);
    
    if (dirID < bitCount)
      CFBitVectorSetBitAtIndex(_directoryIDs,dirID,0);
  }

@end
