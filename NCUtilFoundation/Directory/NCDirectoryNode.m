//
//  ncutil3 - network configuration utility, version 3
//  NCDirectoryNode
//
//  Abstract base class for representing nodes in the virtual
//  SystemConfiguration preference directory.
//
//  Created by Jeffrey Frey on Tue May 31 2005.
//  Copyright (c) 2005. All rights reserved.
//
//  $Id$
//

#import "NCDirectoryNode.h"
#include "CFAdditions.h"
#include "NCError.h"

#include "CFCString.h"

CFStringRef kSCPropBSDDevice = CFSTR("bsd-device");

@interface NCDirectoryNode(NCDirectoryNodePrivate)

- (NCDirectoryNode*) searchForNodeWithMutablePath:(CFMutableStringRef)aPath pathSeparator:(CFStringRef)sepStr;
- (void) insertParentDirectoriesInPath:(CFMutableStringRef)aPath pathSeparator:(CFStringRef)sepStr;

@end

@implementation NCDirectoryNode(NCDirectoryNodePrivate)

  - (NCDirectoryNode*) searchForNodeWithMutablePath:(CFMutableStringRef)aPath
    pathSeparator:(CFStringRef)sepStr
  {
    CFIndex             length = CFStringGetLength(aPath);
    CFIndex             sepLen = CFStringGetLength(sepStr);
    NCDirectoryNode*    target = nil;
    
    if (length > 0) {
      //  Remove any occurances of the separator string from the head of the
      //  path and dispatch the relative remainder to the root node:
      while (length > 0 && CFStringFindWithOptions(aPath,sepStr,CFRangeMake(0,length),kCFCompareAnchored,NULL)) {
        CFStringDelete(aPath,CFRangeMake(0,sepLen));
        length = CFStringGetLength(aPath);
        target = (NCDirectoryNode*)[self root];
      }
      if (target) {
        //  If nothing remains to the path, then return the target:
        if (CFStringGetLength(aPath) == 0)
          return target;
        return [target searchForNodeWithMutablePath:aPath pathSeparator:sepStr];
      }
      
      //  Now we must check if we have '.[sep]' or '..[sep]' heading off the path:
      target = self;
      while (length > 0 && CFStringGetCharacterAtIndex(aPath,0) == '.') {
        CFIndex     from = 1;
        
        if (length > 1) {
          if (CFStringGetCharacterAtIndex(aPath,0) == '.')
            from++;
            
          if (length > 2 && CFStringFindWithOptions(aPath,sepStr,CFRangeMake(from,length - from),kCFCompareAnchored,NULL)) {
            CFStringDelete(aPath,CFRangeMake(0,from + sepLen));
            length = CFStringGetLength(aPath);
            //  If it was '..[sep]' then we need to modify the target:
            if (from == 2) {
              if ((target = (NCDirectoryNode*)[target parent]) == nil)
                return nil;
            }
            //  Remove any additional occurances of the separator string that were
            //  after the '.[sep]' or '..[sep]':
            while (length > 0 && CFStringFindWithOptions(aPath,sepStr,CFRangeMake(0,length),kCFCompareAnchored,NULL)) {
              CFStringDelete(aPath,CFRangeMake(0,sepLen));
              length = CFStringGetLength(aPath);
            }
          } else if (length == from) {
            CFStringDelete(aPath,CFRangeMake(0,from)); length = 0;
            //  If it was '..[sep]' then we need to modify the target:
            if (from == 2) {
              if ((target = (NCDirectoryNode*)[target parent]) == nil)
                return nil;
            }
            break;
          }
        } else {
          CFStringDelete(aPath,CFRangeMake(0,1)); length = 0;
          break;
        }
      }
      //  Whatever remains is relative; if WE are the target then handle it, otherwise
      //  dispatch:
      if (target != self) {
        if (length)
          return [target searchForNodeWithMutablePath:aPath pathSeparator:sepStr];
        return target;
      }
      
      //  Isolate the path component and try to get a new target therefrom:
      CFRange           foundRange;
      NCDirectoryNode*  child = (NCDirectoryNode*)[self child];
      CFStringRef       relPath;
      
      //  If there's nothing left then skip all this:
      if (length == 0)
        return self;
      
      if (CFStringFindWithOptions(aPath,sepStr,CFRangeMake(0,length),0,&foundRange))
        relPath = CFStringCreateWithSubstring(kCFAllocatorDefault,aPath,CFRangeMake(0,foundRange.location));
      else
        relPath = aPath;
      
      if (child) {
        //  We want a child node of ourself with 'relPath' as its name:
        target = [child searchForNodeWithDirectoryName:relPath];
      } else
        return nil;
      
      if (relPath != aPath) {
        //  Now we must delete the relative component and release the
        //  relPath object:
        CFRelease(relPath);
        CFStringDelete(aPath,CFRangeMake(0,foundRange.location + foundRange.length));
        length = CFStringGetLength(aPath);
        //  Remove any additional occurances of the separator string:
        while (length > 0 && CFStringFindWithOptions(aPath,sepStr,CFRangeMake(0,length),kCFCompareAnchored,NULL)) {
          CFStringDelete(aPath,CFRangeMake(0,sepLen));
          length = CFStringGetLength(aPath);
        }
        //  If something remains to the string, then we need to make yet
        //  another call to this routine for the target:
        if (length > 0)
          return [target searchForNodeWithMutablePath:aPath pathSeparator:sepStr];
      }
      //  If we get here we just need to return the target, period:
      return target;
    }
    //  Oops, passed us an empty string!!
    return nil;
  }

//

  - (void) insertParentDirectoriesInPath:(CFMutableStringRef)aPath
    pathSeparator:(CFStringRef)sepStr
  {
    NCDirectoryNode*    target = self;
    
    while (target) {
      //  Insert my name:
      CFStringInsert(aPath,0,[target directoryName]);
      
      if ((target = (NCDirectoryNode*)[target parent]))
        //  Insert the separator string:
        CFStringInsert(aPath,0,sepStr);
    }
  }

@end

//
#pragma mark -
//

@implementation NCDirectoryNode

  + (CFStringRef) directoryType
  {
    static CFStringRef NCDirectoryNode_DirectoryType = NULL;
    if (!NCDirectoryNode_DirectoryType)
      NCDirectoryNode_DirectoryType = CFSTR("Directory");
    return NCDirectoryNode_DirectoryType;
  }

//

  - (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess
  {
    return [self initWithPreferenceSession:prefSess andDirectoryID:[prefSess allocateDirectoryID]];
  }
  
//

  - (id) initWithPreferenceSession:(NCPreferenceSession*)prefSess
    andDirectoryID:(CFIndex)dirID
  {
    if (self = [super initWithObject:prefSess])
      _directoryID = dirID;
    return self;
  }

//

  - (void) dealloc
  {
    CFCStringRef    name = CFCStringCreate(NULL,[self directoryName]);
    
    if ( name ) {
      fprintf(stddbg,"%s ",CFCStringGetCStringPtr(name));
      CFCStringDealloc(name);
    }
    
    //  Deallocate the directory ID:
    [[self preferenceSession] deallocateDirectoryID:_directoryID];
    if (_preferencePath) CFRelease(_preferencePath);
    if (_propertyCache) CFRelease(_propertyCache);
    [super dealloc];
  }

//

  - (NCPreferenceSession*) preferenceSession { return (NCPreferenceSession*)[self object]; }
  - (void) setPreferenceSession:(NCPreferenceSession*)prefSess
  {
    [self setObject:prefSess];
  }

//

  - (CFStringRef) preferencePath { return _preferencePath; }
  - (void) setPreferencePath:(CFStringRef)path
  {
    if (path) path = CFStringCreateCopy(kCFAllocatorDefault,path);
    if (_preferencePath) CFRelease(_preferencePath);
    _preferencePath = path;
  }

//

  - (CFIndex) directoryID { return _directoryID; }
  - (void) setDirectoryID:(CFIndex)dirID
  {
    if (dirID >= 0)
      _directoryID = dirID;
  }

//

  - (CFMutableDictionaryRef) readPropertiesDictionary
  {
    NCPreferenceSession*    prefSess = [self preferenceSession];
    
    if (prefSess) {
      if (_preferencePath) {
        CFDictionaryRef   props = [prefSess getValueAtPath:_preferencePath];
        
        if (props)
          return CFDictionaryCreateMutableCopy(
                    kCFAllocatorDefault,
                    0,
                    props
                  );
      }
      return CFDictionaryCreateMutable(
                kCFAllocatorDefault,
                0,
                &kCFCopyStringDictionaryKeyCallBacks,
                &kCFTypeDictionaryValueCallBacks
              );
    }
    return NULL;
  }

//

  - (CFMutableDictionaryRef) properties
  {
    
    if (_propertyCache)
      return _propertyCache;
    return (_propertyCache = [self readPropertiesDictionary]);
  }
  
//

  - (void) writePropertiesDictionary:(CFDictionaryRef)propDict
  {
    NCPreferenceSession*    prefSess = [self preferenceSession];
    
    if (prefSess && propDict) {
      if (_preferencePath && CFDictionaryGetCount(propDict)) {
        CFMutableDictionaryRef  props = CFDictionaryCreateMutableCopy(
                                          kCFAllocatorDefault,
                                          0,
                                          propDict
                                        );
        if (props) {
          [prefSess setValue:props atPath:_preferencePath];
          CFRelease(props);
        }
      }
    }
  }

//

  - (void) setProperties:(CFDictionaryRef)propDict
  {
    if (!_isLocked) {
      if (propDict)
        [self writePropertiesDictionary:propDict];
      if (_propertyCache) {
        CFRelease(_propertyCache);
        _propertyCache = nil;
      }
      _wasModified = NO;
      [self invalidatePropertyHandler];
    }
  }
  
//

  + (NCPropertyHandler*) propertyHandler
  {
    return nil;
  }
  
//

  - (NCPropertyHandler*) propertyHandler
  {
    return [[self class] propertyHandler];
  }
  
//

  - (void) invalidatePropertyHandler
  {
  }

//

  - (BOOL) isLocked { return _isLocked; }
  - (void) setIsLocked:(BOOL)locked
  {
    _isLocked = locked;
  }
  
//

  - (BOOL) wasModified { return _wasModified; };

@end

//
#pragma mark -
//

@implementation NCDirectoryNode(NCDirectoryNodeProperties)

  - (void) setDefaultProperties
  {
    //  Simply clear the dictionary of all key-value pairs:
    [self removeAllProperties];
  }

//

  - (CFPropertyListRef) valueOfProperty:(CFStringRef)property
  {
    CFMutableDictionaryRef  propDict = [self properties];
    
    if (propDict)
      return CFDictionaryGetValue(propDict,property);
    return NULL;
  }

//

  - (CFPropertyListRef) valueAtIndex:(CFIndex)index
    inProperty:(CFStringRef)property
  {
    CFPropertyListRef   value = [self valueOfProperty:property];
    
    if (value) {
      if (CFGetTypeID(value) == CFArrayGetTypeID()) {
        if (index < CFArrayGetCount(value))
          return CFArrayGetValueAtIndex(value,index);
      }
    }
    return NULL;
  }
  
//

  - (BOOL) valueExists:(CFPropertyListRef)value
    inProperty:(CFStringRef)property
  {
    CFPropertyListRef   Value = [self valueOfProperty:property];
    
    if (Value)
      if (CFGetTypeID(Value) == CFArrayGetTypeID())
        return ( CFArrayContainsValue(Value,CFRangeMake(0,CFArrayGetCount(Value)),value) ? YES : NO );
    return NO;
  }
  
//

  - (CFIndex) indexOfValue:(CFPropertyListRef)value
    inProperty:(CFStringRef)property
  {
    CFPropertyListRef   Value = [self valueOfProperty:property];
    
    if (Value) {
      if (CFGetTypeID(Value) == CFArrayGetTypeID()) {
        return CFArrayGetFirstIndexOfValue(Value,CFRangeMake(0,CFArrayGetCount(Value)),value);
      }
    }
    return kCFNotFound;
  }
  
//

  - (BOOL) setValue:(CFPropertyListRef)value
    ofProperty:(CFStringRef)property
  {
    if (!_isLocked) {
      CFMutableDictionaryRef  propDict = [self properties];
      
      if (propDict) {
        CFStringRef   key = CFStringCreateCopy(kCFAllocatorDefault,property);
        
        if (key) {
          CFDictionarySetValue(propDict,key,value);
          CFRelease(key);
          _wasModified = YES;
          return YES;
        }
      }
    }
    return NO;
  }
  
//

  - (BOOL) appendValue:(CFPropertyListRef)value
    toProperty:(CFStringRef)property
  {
    if (!_isLocked) {
      CFTypeID            valueType = CFGetTypeID(value);
      CFTypeID            arrayType = CFArrayGetTypeID();
      CFPropertyListRef   Value = [self valueOfProperty:property];
      
      if (Value) {
        if (CFGetTypeID(Value) == arrayType) {
          //  If it's not immutable, make a copy and make it so:
          if (!CFGetContainerMutability(Value)) {
            CFMutableArrayRef   newValue = CFArrayCreateMutableCopy(
                                              kCFAllocatorDefault,
                                              0,
                                              Value
                                            );
            [self setValue:newValue ofProperty:property];
            Value = newValue;
          }
          if (valueType == arrayType)
            CFArrayAppendArray((CFMutableArrayRef)Value,value,CFRangeMake(0,CFArrayGetCount(value)));
          else
            CFArrayAppendValue((CFMutableArrayRef)Value,value);
          _wasModified = YES;
          return YES;
        } else
          NCErrorPush(kNCErrorPropertyNotArrayType,CFSTR("Property is not an array type"),NULL);
      } else {
        if (valueType == arrayType) {
          Value = CFArrayCreateMutableCopy(
                    kCFAllocatorDefault,
                    0,
                    value
                  );
        } else {
          Value = CFArrayCreateMutable(
                    kCFAllocatorDefault,
                    0,
                    &kCFTypeArrayCallBacks
                  );
          if (Value)
            CFArrayAppendValue((CFMutableArrayRef)Value,value);
        }
        if (Value) {
          BOOL    result;
          
          result = [self setValue:Value ofProperty:property];
          CFRelease(Value);
          return result;
        }
      }
    }
    return NO;
  }
  
//

  - (BOOL) removeProperty:(CFStringRef)property
  {
    if (!_isLocked) {
      CFMutableDictionaryRef  propDict = [self properties];
      
      if (propDict) {
        CFDictionaryRemoveValue(propDict,property);
        _wasModified = YES;
        return YES;
      }
    }
    return NO;
  }
  
//

  - (BOOL) removeValue:(CFPropertyListRef)value
    fromProperty:(CFStringRef)property
  {
    if (!_isLocked) {
      CFTypeID            valueType = CFGetTypeID(value);
      CFTypeID            arrayType = CFArrayGetTypeID();
      CFPropertyListRef   Value = [self valueOfProperty:property];
      
      if (Value) {
        if (CFGetTypeID(Value) == arrayType) {
          //  If it's not immutable, make a copy and make it so:
          if (!CFGetContainerMutability(Value)) {
            CFMutableArrayRef   newValue = CFArrayCreateMutableCopy(
                                              kCFAllocatorDefault,
                                              0,
                                              Value
                                            );
            [self setValue:newValue ofProperty:property];
            Value = newValue;
          }
          if (valueType == arrayType) {
            CFIndex     i = 0,iMax = CFArrayGetCount(value);
            CFIndex     count = CFArrayGetCount(Value);
            Boolean     result = NO;
            
            while ( count && i < iMax ) {
              CFPropertyListRef   aVal = CFArrayGetValueAtIndex(value,i++);
              CFIndex             index = CFArrayGetFirstIndexOfValue(Value,CFRangeMake(0,count),aVal);
            
              if (index != kCFNotFound) {
                CFArrayRemoveValueAtIndex((CFMutableArrayRef)Value,index);
                count--;
                result = YES;
              }
            }
            if (result) {
              if (count == 0)
                [self removeProperty:property];
              _wasModified = YES;
            }
            return result;
          } else {
            CFIndex     count = CFArrayGetCount(Value);
            CFIndex     index = CFArrayGetFirstIndexOfValue(Value,CFRangeMake(0,count),value);
            
            if (index != kCFNotFound) {
              CFArrayRemoveValueAtIndex((CFMutableArrayRef)Value,index);
              if (count == 1)
                [self removeProperty:property];
              _wasModified = YES;
              return YES;
            }
          }
        }
      }
    }
    return NO;
  }
  
//

  - (BOOL) removeAllProperties
  {
    if (!_isLocked) {
      CFMutableDictionaryRef  propDict = [self properties];
      
      if (propDict) {
        CFDictionaryRemoveAllValues(propDict);
        _wasModified = YES;
        return YES;
      }
    }
    return NO;
  }
  
//

  - (BOOL) directoryIsActive
  {
    CFPropertyListRef   value = [self valueOfProperty:kSCResvInactive];
    
    if (value)
      return ( CFNumberToCFIndexOnly(value) ? NO : YES );
    return YES;
  }
  
//

  - (BOOL) setDirectoryIsActive:(BOOL)active
  {
    if (active)
      return [self removeProperty:kSCResvInactive];
    else
      return [self setValue:CFOne() ofProperty:kSCResvInactive];
    return NO;
  }
  
//

  - (CFStringRef) directoryName
  {
    return [self valueOfProperty:kSCPropUserDefinedName];
  }
  
//

  - (BOOL) setDirectoryName:(CFStringRef)name
  {
    return [self setValue:name ofProperty:kSCPropUserDefinedName];
  }

//

  - (void) listProperty:(CFStringRef)propertyName
    toStream:(FILE*)stream
  {
    //  Walk the property handler and summarize the values associated
    //  with each:
    NCPropertyHandler*      pHandler = [self propertyHandler];
    
    if (pHandler) {
      NCPropertyRef         theProperty = [pHandler propertyWithUIName:propertyName];
      
      if (theProperty) {
        CFPropertyListRef   theValue = [self valueOfProperty:NCPropertyGetSCName(theProperty)];
        
        if (theValue)
          NCPropertyDisplayValueOnly(theProperty,stream,theValue);
      } else
        NCErrorPush(kNCErrorUnknownProperty,NULL,NULL);
    }
  }

//

  - (void) listPropertiesToStream:(FILE*)stream
  {
    //  Walk the property handler and summarize the values associated
    //  with each:
    NCPropertyHandler*      pHandler = [self propertyHandler];
    
    if (pHandler) {
      NCPropertyEnumerator*   pEnum = [pHandler propertyEnumerator];
      NCPropertyRef           property;
      
      while ( (property = [pEnum nextProperty]) ) {
        CFPropertyListRef     value = [self valueOfProperty:NCPropertyGetSCName(property)];
        
        if (value)
          NCPropertyDisplayValue(property,stream,_isLocked,value);
      }
    }
  }

//

  - (void) summarizePropertiesToStream:(FILE*)stream
  {
    //  Walk the property handler and summarize the values associated
    //  with each:
    NCPropertyHandler*      pHandler = [self propertyHandler];
    
    if (pHandler)
      [pHandler summarizeHandledPropertiesToStream:stream locked:_isLocked];
  }

@end

//
#pragma mark -
//

@implementation NCDirectoryNode(NCDirectoryNodeUpdating)

  - (void) refresh
  {
    //  Purge the cached dictionary:
    if (_propertyCache && _wasModified) {
      CFRelease(_propertyCache);
      _propertyCache = NULL;
      _wasModified = NO;
    }
  }

//

  - (void) refreshNodes:(int)nodesToRefresh
  {
    if (nodesToRefresh == kNCTreeNodeApplyToSelf)
      [self refresh];
    else
      [self makeNodes:nodesToRefresh performSelector:@selector(refresh)];
  }

//

  - (void) commitUpdates
  {
    //  Commit the cache to the preference store:
    if (_propertyCache && _wasModified)
      [self setProperties:_propertyCache];
  }

//

  - (void) commitUpdatesToNodes:(int)nodesToUpdate
  {
    if (nodesToUpdate == kNCTreeNodeApplyToSelf)
      [self commitUpdates];
    else
      [self makeNodes:nodesToUpdate performSelector:@selector(commitUpdates)];
  }

@end

//
#pragma mark -
//

@implementation NCDirectoryNode(NCDirectoryNodeSearch)

  - (void) listSubdirectoriesToStream:(FILE*)stream
  {
    [self listSubdirectoriesToStream:stream recursive:NO indent:0];
  }

//

  - (void) listSubdirectoriesToStream:(FILE*)stream
    recursive:(BOOL)recursive
  {
    [self listSubdirectoriesToStream:stream recursive:recursive indent:0];
  }
  
//

  CF_INLINE void
  fpad(
    FILE*   stream,
    CFIndex padding,
    Boolean dHead
  )
  {
    if (padding < 0)
      return;
    if (dHead) {
      while (padding--)
        fprintf(stream,"|-");
    } else {
      while (padding--)
        fputc(' ',stream);
    }
    fflush(stream);
  }

  - (void) listSubdirectoriesToStream:(FILE*)stream
    recursive:(BOOL)recursive
    indent:(CFIndex)indent
  {
    NCDirectoryNode*      child = (NCDirectoryNode*)[self child];
    
    while (child) {
      CFStringRef   name = [child directoryName];
      CFIndex       padding = 40 - (2 * indent);
      
      fprintf(stream,"dr%c %-5ld ",([child isLocked] ? '-' : 'w'),[child directoryID]);
      if (indent)
        fpad(stream,indent,TRUE);
      if (name) {
        padding -= CFStringGetLength(name);
        NCPrint(stream,CFSTR("%@"),name);
      } else {
        padding -= 9;
        fprintf(stream,"<unnamed>");
      }
      if (padding > 0)
        fpad(stream,padding,FALSE);
      NCPrint(stream,CFSTR("%@\n"),[[child class] directoryType]);
      if (recursive)
        [child listSubdirectoriesToStream:stream recursive:TRUE indent:indent + 1];
      child = (NCDirectoryNode*)[child sibling];
    }
  }

//

  - (CFStringRef) pathToNode
  {
    //  A root node, just return the separator string:
    if ([self parent] == nil)
      return CFRetain([[self preferenceSession] pathSeparatorForDirectoryTree]);
    
    CFMutableStringRef    aPath = CFStringCreateMutable(
                                      kCFAllocatorDefault,
                                      0
                                    );
    [self insertParentDirectoriesInPath:aPath pathSeparator:[[self preferenceSession] pathSeparatorForDirectoryTree]];
    return aPath;
  }

//

  - (NCDirectoryNode*) searchForNodeWithPath:(CFStringRef)nodePath
  {
    NCDirectoryNode*      theNode = NULL;
    
    if (CFStringGetLength(nodePath) > 0) {
      //  We just end up calling a driver routine with a mutable copy of
      //  the path:
      CFMutableStringRef    altNodePath = CFStringCreateMutableCopy(kCFAllocatorDefault,CFStringGetLength(nodePath),nodePath);
      
      if (altNodePath) {
        CFStringTrimWhitespace(altNodePath);
        if (CFStringGetLength(altNodePath) > 0)
          theNode = [self searchForNodeWithMutablePath:altNodePath pathSeparator:[[self preferenceSession] pathSeparatorForDirectoryTree]];
        CFRelease(altNodePath);
      }
    }
    return theNode;
  }

//

  - (NCDirectoryNode*) searchForNodeWithDirectoryID:(CFIndex)dirID
  {
    return [self searchDeep:YES forNodeWithDirectoryID:dirID andClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchForNodeWithDirectoryID:(CFIndex)dirID
    andClass:(Class)aClass
  {
    return [self searchDeep:YES forNodeWithDirectoryID:dirID andClass:aClass];
  }
  - (NCDirectoryNode*) searchDeep:(BOOL)goDeep
    forNodeWithDirectoryID:(CFIndex)dirID
  {
    return [self searchDeep:goDeep forNodeWithDirectoryID:dirID andClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchDeep:(BOOL)goDeep
    forNodeWithDirectoryID:(CFIndex)dirID
    andClass:(Class)aClass
  {
    NCDirectoryNode*    node = nil;
    
    //  Is it I that we seek??
    if ((aClass && [self isKindOfClass:aClass]) || (!aClass)) {
      if ([self directoryID] == dirID)
        return self;
    }
    
    //  Search through any children:
    if (goDeep) {
      if ((node = (NCDirectoryNode*)[self child]))
        node = [node searchDeep:goDeep forNodeWithDirectoryID:dirID andClass:aClass];
    }
    
    //  Search from a sibling:
    if (!node) {
      if ((node = (NCDirectoryNode*)[self sibling]))
        return [node searchDeep:goDeep forNodeWithDirectoryID:dirID andClass:aClass];
    }
    
    //  Either nil or the child we found:
    return node;
  }
  
//

  - (NCDirectoryNode*) searchForNodeWithDirectoryName:(CFStringRef)dirName
  {
    return [self searchDeep:NO forNodeWithDirectoryName:dirName andClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchForNodeWithDirectoryName:(CFStringRef)dirName
    andClass:(Class)aClass
  {
    return [self searchDeep:NO forNodeWithDirectoryName:dirName andClass:aClass];
  }
  - (NCDirectoryNode*) searchDeep:(BOOL)goDeep
    forNodeWithDirectoryName:(CFStringRef)dirName
  {
    return [self searchDeep:goDeep forNodeWithDirectoryName:dirName andClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchDeep:(BOOL)goDeep
    forNodeWithDirectoryName:(CFStringRef)dirName
    andClass:(Class)aClass
  {
    NCDirectoryNode*    node = nil;
    CFStringRef         myName = [self directoryName];
    
    //  Is it I that we seek??
    if ((aClass && [self isKindOfClass:aClass]) || (!aClass)) {
      if (dirName == myName)
        return self;
      if (myName && dirName && CFStringCompare(myName,dirName,0) == kCFCompareEqualTo)
        return self;
    }
    
    //  Search through any children:
    if (goDeep) {
      if ((node = (NCDirectoryNode*)[self child]))
        node = [node searchDeep:goDeep forNodeWithDirectoryName:dirName andClass:aClass];
    }
        
    //  Search from a sibling:
    if (!node) {
      if ((node = (NCDirectoryNode*)[self sibling]))
        return [node searchDeep:goDeep forNodeWithDirectoryName:dirName andClass:aClass];
    }
    
    //  Either nil or the child we found:
    return node;
  }
  
//

  - (NCDirectoryNode*) searchForModifiedNode
  {
    return [self searchDeepForModifiedNode:YES withClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchDeepForModifiedNode:(BOOL)goDeep
  {
    return [self searchDeepForModifiedNode:goDeep withClass:[NCDirectoryNode class]];
  }
  - (NCDirectoryNode*) searchDeepForModifiedNode:(BOOL)goDeep
    withClass:(Class)aClass
  {
    NCDirectoryNode*    node = nil;
    
    //  Is it I that we seek??
    if ((aClass && [self isKindOfClass:aClass]) || (!aClass)) {
      if (_wasModified)
        return self;
    }
    
    //  Search through any children:
    if (goDeep) {
      if ((node = (NCDirectoryNode*)[self child]))
        node = [node searchDeepForModifiedNode:goDeep withClass:aClass];
    }
        
    //  Search from a sibling:
    if (!node) {
      if ((node = (NCDirectoryNode*)[self sibling]))
        node = [node searchDeepForModifiedNode:goDeep withClass:aClass];
    }
    
    //  Either nil or the child we found:
    return node;
  }
  
//

  - (NCDirectoryNode*) searchForNodeWithClass:(Class)aClass
  {
    return [self searchDeep:YES forNodeWithClass:aClass];
  }
  - (NCDirectoryNode*) searchDeep:(BOOL)goDeep
    forNodeWithClass:(Class)aClass
  {
    NCDirectoryNode*    node = nil;
    
    //  Is it I that we seek??
    if ((aClass && [self isKindOfClass:aClass]) || (!aClass))
      return self;
    
    //  Search through any children:
    if (goDeep) {
      if ((node = (NCDirectoryNode*)[self child]))
        node = [node searchDeep:goDeep forNodeWithClass:aClass];
    }
        
    //  Search from a sibling:
    if (!node) {
      if ((node = (NCDirectoryNode*)[self sibling]))
        node = [node searchDeep:goDeep forNodeWithClass:aClass];
    }
    
    //  Either nil or the child we found:
    return node;
  }

@end
