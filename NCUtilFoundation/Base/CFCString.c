/*
 *  ncutil3 - network configuration utility, version 3
 *  CFCString
 *
 *  Pseudo-class that mutates a CFString into a string
 *  in the default string encoding.
 *
 *  Created by Jeffrey Frey on Fri Jun  10 2005.
 *  Copyright (c) 2005. All rights reserved.
 *
 */

#include "CFCString.h"

typedef struct _CFCString {
  CFAllocatorRef    allocator;
  char*             cString;
} CFCString;

CFCString*
__CFCStringAlloc(
  CFAllocatorRef    allocator,
  CFIndex           length
)
{
  CFIndex     bytes = sizeof(CFCString);
  CFCString*  newCString = CFAllocatorAllocate(allocator,bytes,0);
  
  if (length)
    bytes += (length + 1);
  if (newCString) {
    newCString->allocator       = allocator;
    newCString->cString         = ((char*)newCString) + sizeof(CFCString);
  }
  return newCString;
}

CFCString*
__CFCStringNullString()
{
  static CFCString nullString = { NULL , "" };
  
  if (nullString.allocator == NULL)
    nullString.allocator = kCFAllocatorNull;
  return &nullString;
}

//
#pragma mark -
//

CFCStringRef
CFCStringCreate(
  CFAllocatorRef    allocator,
  CFStringRef       string
)
{
  CFCString*        newString = NULL;
  
  if (string) {
    char*           cStrPtr = (char*)CFStringGetCStringPtr(string,CFCStringGetDefaultEncoding());
    CFIndex         length = CFStringGetLength(string);
    
    //  Any zero-length strings => the default null string:
    if (length == 0)
      return (CFCStringRef)__CFCStringNullString();
    
    //  If we can get a CStringPtr for the string, construct
    //  the CFCString to just point to that:
    if (cStrPtr) {
      if ((newString = __CFCStringAlloc(allocator,0)))
        newString->cString = cStrPtr;
    } else if ((newString = __CFCStringAlloc(allocator,length))) {
      CFStringGetBytes(
          string,
          CFRangeMake(0,length),
          CFCStringGetDefaultEncoding(),
          0,
          FALSE,
          (UInt8*)newString->cString,
          0,
          &length
        );
      newString->cString[length] = '\0';
    }
  }
  return (CFCStringRef)newString;
}

//

CFCStringRef
CFCStringCreateWithCString(
  CFAllocatorRef  allocator,
  const char*     cString
)
{
  CFCString*      newString = NULL;
  
  if (cString) {
    CFIndex       length = strlen(cString);
    
    //  Any zero-length strings => the default null string:
    if (length == 0)
      return (CFCStringRef)__CFCStringNullString();
    
    if ((newString = __CFCStringAlloc(allocator,length)))
      strcpy(newString->cString,cString);
  }
  return (CFCStringRef)newString;
}

//

CFCStringRef
CFCStringCreateWithCStringNoCopy(
  CFAllocatorRef  allocator,
  const char*     cString
)
{
  CFCString*      newString = NULL;
  
  if (cString) {
    CFIndex       length = strlen(cString);
    
    //  Any zero-length strings => the default null string:
    if (length == 0)
      return (CFCStringRef)__CFCStringNullString();
    
    if ((newString = __CFCStringAlloc(allocator,0)))
      newString->cString = (char*)cString;
  }
  return (CFCStringRef)newString;
}

//

void
CFCStringDealloc(
  CFCStringRef  aString
)
{
  CFAllocatorDeallocate(aString->allocator,(CFCString*)aString);
}

//

CFIndex
CFCStringGetLength(
  CFCStringRef  aString
)
{
  if (aString)
    return strlen(aString->cString);
  return 0;
}

//

const char*
CFCStringGetCStringPtr(
  CFCStringRef  aString
)
{
  if (aString)
    return aString->cString;
  return NULL;
}

//
#pragma mark -
//

CFStringEncoding
CFCStringGetDefaultEncoding()
{
  static Boolean ready = FALSE;
  static CFStringEncoding encoding = kCFStringEncodingMacRoman;
  
  if (!ready) {
    if ((encoding = CFStringGetSystemEncoding()) == kCFStringEncodingUnicode)
      encoding = kCFStringEncodingUTF8;
    ready = TRUE;
  }
  return encoding;
}
