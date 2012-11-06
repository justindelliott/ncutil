/*
 *  ncutil3 - network configuration utility, version 3
 *  CFCString
 *
 *  Pseudo-class that wraps standard, NULL-terminated C
 *  strings.
 *
 *  Created by Jeffrey Frey on Fri Jun  10 2005.
 *  Copyright (c) 2005. All rights reserved.
 *
 */

#if !defined(__NCUTIL_CFCSTRING__)
#define __NCUTIL_CFCSTRING__ 1

#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
  @typedef CFCStringRef
  A reference to a wrapped C string.
*/
typedef const struct _CFCString * CFCStringRef;

/*!
  @function CFCStringCreate
  Creates a new C string wrapper using the contents of a CoreFoundation string.
  The <TT>string</TT> is converted to the default, 8-bit encoding.
*/
CF_EXPORT CFCStringRef CFCStringCreate(CFAllocatorRef allocator,CFStringRef string);
/*!
  @function CFCStringCreateWithCString
  Creates a new C string wrapper using the contents of a C string.  The characters
  are copied to the new wrapper.
*/
CF_EXPORT CFCStringRef CFCStringCreateWithCString(CFAllocatorRef allocator,const char* cString);
/*!
  @function CFCStringCreateWithCStringNoCopy
  Creates a new C string wrapper using a C string.  The new wrapper does not create
  a local copy of the characters, it merely retains the <TT>cString</TT> pointer.
*/
CF_EXPORT CFCStringRef CFCStringCreateWithCStringNoCopy(CFAllocatorRef allocator,const char* cString);
/*!
  @function CFCStringDealloc
  Deallocates a CFCString instance.
*/
CF_EXPORT void CFCStringDealloc(CFCStringRef aString);
/*!
  @function CFCStringGetLength
  Returns the length of the CFCString.
*/
CF_EXPORT CFIndex CFCStringGetLength(CFCStringRef aString);
/*!
  @function CFCStringGetCStringPtr
  Returns a pointer to the C string wrapped by <TT>aString</TT>.
*/
CF_EXPORT const char* CFCStringGetCStringPtr(CFCStringRef aString);

/*!
  @function CFCStringGetDefaultEncoding
  Returns the default, 8-bit encoding that should be used for strings going to/coming from
  stdio streams.
*/
CF_EXPORT CFStringEncoding CFCStringGetDefaultEncoding();

#if defined(__cplusplus)
}
#endif

#endif // !__NCUTIL_CFCSTRING__
