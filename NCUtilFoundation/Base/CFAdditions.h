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

#if !defined(__NCUTIL_CFADDITIONS__)
#define __NCUTIL_CFADDITIONS__ 1

#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
  @function CFUserName
  Returns the current user's login name as a <TT>CFString</TT>.
*/
CFStringRef CFUserName(CFAllocatorRef alloc);
/*!
  @function CFFullUserName
  Returns the current user's human-readable (gecos) name
  as a <TT>CFString</TT>.
*/
CFStringRef CFFullUserName(CFAllocatorRef alloc);
/*!
  @function CFHomeDirectory
  Returns the current user's home directory path as a
  <TT>CFString</TT>.
*/
CFStringRef CFHomeDirectory(CFAllocatorRef alloc);
/*!
  @function CFHomeDirectoryForUser
  If the user whose name was passed to the function exists on the
  host, his/her home directory path is returned as a <TT>CFString</TT>.
*/
CFStringRef CFHomeDirectoryForUser(CFAllocatorRef alloc,CFStringRef uname);
/*!
  @function CFStringByExpandingTildeInPath
  If the string is prefixed by '~' then user home directory substitution
  is attempted.
*/
CFStringRef CFStringByExpandingTildeInPath(CFAllocatorRef alloc,CFStringRef path);
/*!
  @function CFStringIsRelativePath
  Is the string a relative filepath?
*/
Boolean CFStringIsRelativePath(CFStringRef path);
/*!
  @function CFFOpen
  Attempts to call fopen() on the filepath in the string.
*/
FILE* CFFOpen(CFStringRef path,CFStringRef mode);
/*!
  @funtion CFStringPathExists
  Returns <TT>TRUE</TT> if the path in <TT>aPath</TT> exists.
*/
Boolean CFStringPathExists(CFStringRef aPath);

//

/*!
	@function CFIndexToCFNumber
	@discussion Create a new CFNumber using the given CFIndex value.
	
	The default allocator (kCFAllocatorDefault) is used by this routine.
	If, for some reason, you need to use an alternate allocator, then you
	may as well just use the <TT>CFNumberCreate</TT> routine anyway.
	@param num A numerical value of type CFIndex
	@result A new CFNumber object initialized to hold the value in
	<I>num</I> or NULL if the object could not be created
*/
CF_INLINE CFNumberRef CFIndexToCFNumber(CFIndex num)
{
  return CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&num);
};
/*!
	@function CFNumberToCFIndex
	@discussion Retrieve the numerical value held by the CFNumber object as
	a CFIndex-type value.
	
	This function literally wraps the <TT>CFNumberGetValue</TT> function and
	returns the result of that call.
	@param num A CFNumber object
	@param val Pointer to the CFIndex to hold the value
	@result TRUE if the conversion was successful, FALSE otherwise
*/
CF_INLINE Boolean CFNumberToCFIndex(CFNumberRef num,CFIndex* val)
{
  return CFNumberGetValue(num,kCFNumberCFIndexType,val);
};
/*!
	@function CFNumberToCFIndexOnly
	@discussion Retrieve the numerical value held by the CFNumber object as
	a CFIndex-type value.
	
	This function returns whatever value <TT>CFNumberGetValue</TT> returns
	and does not worry about conversion errors.
	@param num A CFNumber object
	@result The CFIndex value of the CFNumber; returns zero on error.
*/
CF_INLINE CFIndex CFNumberToCFIndexOnly(CFNumberRef num)
{
  CFIndex			val;
  if (CFNumberGetValue(num,kCFNumberCFIndexType,&val))
    return val;
  return 0;
};
/*!
	@function CFStringToCFIndex
	@discussion Retrieve the numerical value held by the CFString object as
	a CFIndex-type value.
	@param str A CFString object
	@param val The CFIndex value of the CFString; value is not changed in
	the case of an error.
	@result This function returns FALSE on conversion failure, and TRUE otherwise.
*/
Boolean CFStringToCFIndex(CFStringRef str,CFIndex* val);
/*!
	@function CFNumberToBoolean
	@discussion Retrieve the numerical value held by the CFNumber object as
	a Boolean-type value.
	@param num A CFNumber object
	@result TRUE if the value was non-zero, FALSE otherwise
*/
CF_INLINE Boolean CFNumberToBoolean(CFNumberRef num)
{
  CFIndex   val;
  if (num && CFNumberGetValue(num,kCFNumberCFIndexType,&val))
    return (val != 0 ? TRUE : FALSE);
  return FALSE;
};

/*!
  @function CFOne
  Returns a shared CFNumber that is equal to one.
*/
CF_EXPORT CFNumberRef CFOne();
/*!
  @function CFZero
  Returns a shared CFNumber that is equal to zero.
*/
CF_EXPORT CFNumberRef CFZero();

/*!
  @function CFGetContainerMutability
  If <TT>cf</TT> is a CoreFoundation container, attempts to determine
  the mutability of <TT>cf</TT>.
*/
CF_EXPORT Boolean CFGetContainerMutability(CFTypeRef cf);

#if defined(__cplusplus)
}
#endif

#endif // !__NCUTIL_CFADDITIONS__
