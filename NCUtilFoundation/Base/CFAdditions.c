/*
 *  ncutil3 - network configuration utility, version 3
 *  CFAdditions
 *
 *  Additions to the CoreFoundation types.
 *
 *  Created by Jeffrey Frey on Wed Jun 1 2005.
 *  Copyright (c) 2005. All rights reserved.
 *
 */

#include "CFAdditions.h"
#include "CFCString.h"
#include <pwd.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

//

  CFStringRef
  CFUserName(
    CFAllocatorRef  alloc
  )
  {
    CFStringRef       result = NULL;
    struct passwd*    userrec = getpwuid(getuid());
    
    if (userrec)
      result = CFStringCreateWithCString(alloc,userrec->pw_name,kCFStringEncodingASCII);
    return result;
  }
  
//

  CFStringRef
  CFFullUserName(
    CFAllocatorRef  alloc
  )
  {
    CFStringRef       result = NULL;
    struct passwd*    userrec = getpwuid(getuid());
    
    if (userrec)
      result = CFStringCreateWithCString(alloc,userrec->pw_gecos,kCFStringEncodingASCII);
    return result;
  }
  
//

  CFStringRef
  CFHomeDirectory(
    CFAllocatorRef  alloc
  )
  {
    CFStringRef       result = NULL;
    struct passwd*    userrec = getpwuid(getuid());
    
    if (userrec)
      result = CFStringCreateWithCString(alloc,userrec->pw_dir,kCFStringEncodingASCII);
    return result;
  }
  
//

  CFStringRef
  CFHomeDirectoryForUser(
    CFAllocatorRef  alloc,
    CFStringRef     uname
  )
  {
    CFStringRef     result = NULL;
    CFCStringRef    cname;
    
    if (uname) {
      struct passwd* userrec;
      
      if (cname = CFCStringCreate(alloc,uname)) {
        if (userrec = getpwnam(CFCStringGetCStringPtr(cname)))
          result = CFStringCreateWithCString(alloc,userrec->pw_dir,kCFStringEncodingASCII);
        CFCStringDealloc(cname);
      }
    }
    return result;
  }
  
//

  CFStringRef
  CFStringByExpandingTildeInPath(
    CFAllocatorRef      alloc,
    CFStringRef         path
  )
  {
    CFStringRef         result = NULL;
    
    if (!path)
      return NULL;
      
    if (CFStringGetCharacterAtIndex(path,0) == '~') {
      CFIndex     length = CFStringGetLength(path);
      
      if (length == 1) {
        result = CFHomeDirectory(alloc);
      } else if (CFStringGetCharacterAtIndex(path,1) == '/') {
        if (result = CFHomeDirectory(alloc)) {
          if (length > 2) {
            CFStringRef   sub = CFStringCreateWithSubstring(alloc,path,CFRangeMake(2,length - 2));
            CFStringRef   whole;
            
            whole = CFStringCreateWithFormat(alloc,NULL,CFSTR("%@/%@"),result,sub);
            CFRelease(sub);
            CFRelease(result);
            result = whole;
          }
        }
      } else {
        CFIndex       slash = 1;
        CFStringRef   uname;
        while ((slash < length) && (CFStringGetCharacterAtIndex(path,slash) != '/'))
          slash++;
        if (uname = CFStringCreateWithSubstring(alloc,path,CFRangeMake(1,slash - 1))) {
          if (result = CFHomeDirectoryForUser(alloc,uname)) {
            if (++slash < length) {
              //  Append the rest of the path:
              CFStringRef   sub = CFStringCreateWithSubstring(alloc,path,CFRangeMake(slash,length - slash));
              CFStringRef   whole;
              
              whole = CFStringCreateWithFormat(alloc,NULL,CFSTR("%@/%@"),result,sub);
              CFRelease(sub);
              CFRelease(result);
              result = whole;
            }
          }
        }
      }
    } else
      result = CFStringCreateCopy(alloc,path);
    return result;
  }

//

  Boolean
  CFStringIsRelativePath(
    CFStringRef   path
  )
  {
    if (path) {
      CFIndex             i = 0,iMax = CFStringGetLength(path);
      CFCharacterSetRef   wsnl = CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
      UniChar             c = '\0';
      
      while (i < iMax) {
        if (CFCharacterSetIsCharacterMember(wsnl,c = CFStringGetCharacterAtIndex(path,i)))
          i++;
        else
          break;
      }
      if (c != '/')
        return TRUE;
    }
    return FALSE;
  }

//

  FILE*
  CFFOpen(
    CFStringRef   path,
    CFStringRef   mode
  )
  {
    CFCStringRef  cpath = CFCStringCreate(kCFAllocatorDefault,path);
    CFCStringRef  cmode = CFCStringCreate(kCFAllocatorDefault,mode);
    FILE*         result;
    
    if (!path || !mode)
      return NULL;
      
    if (cpath && cmode)
      result = fopen(CFCStringGetCStringPtr(cpath),CFCStringGetCStringPtr(cmode));
    
    CFCStringDealloc(cpath);
    CFCStringDealloc(cmode);
    
    return result;
  }
  
//

Boolean
CFStringPathExists(
  CFStringRef aPath
)
{
  struct stat   fileopts;
  CFCStringRef  cPath = CFCStringCreate(kCFAllocatorDefault,aPath);
  
  if (cPath) {
    if (stat(CFCStringGetCStringPtr(cPath),&fileopts) == 0) {
      CFCStringDealloc(cPath);
      return TRUE;
    }
    CFCStringDealloc(cPath);
  }
  return FALSE;
}

//
#pragma mark -
//

Boolean
CFStringToCFIndex(
  CFStringRef		str,
  CFIndex*			val
)
{
  CFCStringRef  cstr = CFCStringCreate(kCFAllocatorDefault,str);
  Boolean       result = FALSE;
  
  if (cstr) {
    CFIndex     value;
    
    if (sscanf(CFCStringGetCStringPtr(cstr),"%ld",&value) == 1) {
      if (val) *val = value;
      result = TRUE;
    }
    CFCStringDealloc(cstr);
  }
  return result;
}

//
#pragma mark -
//

CFNumberRef
CFOne()
{
  static CFNumberRef __CFNumberOne = NULL;
  if (!__CFNumberOne) {
    SInt8   value = 1;
    __CFNumberOne = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&value);
  }
  return __CFNumberOne;
}

//

CFNumberRef
CFZero()
{
  static CFNumberRef __CFNumberZero = NULL;
  if (!__CFNumberZero) {
    SInt8   value = 0;
    __CFNumberZero = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&value);
  }
  return __CFNumberZero;
}

//
#pragma mark -
//

Boolean
CFGetContainerMutability(
  CFTypeRef   cf
)
{
  CFTypeID    type = CFGetTypeID(cf);
  Boolean     result = FALSE;
  
  if (type == CFArrayGetTypeID() || type == CFDictionaryGetTypeID() || \
      type == CFSetGetTypeID() || type == CFBagGetTypeID())
  {
    CFStringRef   desc = CFCopyDescription(cf);
    
    //  It's a collection class, look for "type = immutable" to verify
    //  that it's immutable:
    if (desc) {
      CFIndex     length = CFStringGetLength(desc),openBracket,closeBracket;
      CFRange     searchRange = CFRangeMake(0,length);
      CFRange     foundRange;
      
      //  Define the search range to run from the first '{' to the next '{' or
      //  '}':
      if (CFStringFindWithOptions(desc,CFSTR("{"),searchRange,0,&foundRange)) {
        searchRange.location = foundRange.location + foundRange.length;
        searchRange.length = length - searchRange.location;
        
        if (CFStringFindWithOptions(desc,CFSTR("{"),searchRange,0,&foundRange))
          openBracket = foundRange.location;
        else
#if defined(__ppc64__)
          openBracket = INT64_MAX;
#else
          openBracket = INT32_MAX;
#endif
        if (CFStringFindWithOptions(desc,CFSTR("}"),searchRange,0,&foundRange))
          closeBracket = foundRange.location;
        else
#if defined(__ppc64__)
          closeBracket = INT64_MAX;
#else
          closeBracket = INT32_MAX;
#endif
        if (openBracket != closeBracket)
          searchRange.length = (openBracket < closeBracket ? openBracket : closeBracket) - searchRange.location;
        if (!CFStringFindWithOptions(desc,CFSTR("type = immutable"),searchRange,0,NULL))
          result = TRUE;
      }
      CFRelease(desc);
    }
  }
  return result;
}
