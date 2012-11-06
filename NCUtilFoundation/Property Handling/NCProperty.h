/*
 *  ncutil3 - network configuration utility, version 3
 *  NCProperty
 *
 *  Conversion and summary of the various property types used
 *  in the SystemConfiguration preference store.
 *
 *  Created by Jeffrey Frey on Wed Jun 1 2005.
 *  Copyright (c) 2005. All rights reserved.
 *
 */

#if !defined(__NCUTIL_NCPROPERTY__)
#define __NCUTIL_NCPROPERTY__ 1

#include <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SystemConfiguration.h>

#if defined(__cplusplus)
extern "C" {
#endif

/*!
  @function NCPropertyUsesTextualPasswords
  Returns <TT>TRUE</TT> if the NCProperty routines expect passwords to
  be in textual form.  Otherwise, passwords will be parsed as hexadecimal
  strings.
*/
CF_EXPORT Boolean NCPropertyUsesTextualPasswords();
/*!
  @function NCPropertySetUsesTextualPasswords
  Pass <TT>TRUE</TT> if the NCProperty routines should expect passwords to
  be in textual form.  Otherwise, passwords should be hexadecimal strings.
*/
CF_EXPORT void NCPropertySetUsesTextualPasswords(Boolean state);
/*!
  @function NCPropertyOverrideLocking
  Returns <TT>TRUE</TT> if property locks are to be ignored.
*/
CF_EXPORT Boolean NCPropertyOverrideLocking();
/*!
  @function NCPropertySetOverrideLocking
  Pass <TT>TRUE</TT> if property locks are to be ignored.
*/
CF_EXPORT void NCPropertySetOverrideLocking(Boolean override);

/*!
  @typedef NCPropertyType
  An enumeration that includes all of the kinds of data that NCProperty
  recognizes.
*/
typedef enum {
  kNCPropertyTypeBoolean = 0,
  kNCPropertyTypeNumber,
  kNCPropertyTypeString,
  kNCPropertyTypeData,
  kNCPropertyTypeMAC,
  kNCPropertyTypeIP4,
  kNCPropertyTypeIP6,
  kNCPropertyTypeStringArray,
  kNCPropertyTypeIP4Array,
  kNCPropertyTypeIP6Array,
  kNCPropertyTypeNumberArray,
  kNCPropertyTypeUniqueNumberArray,
  kNCPropertyTypeStringEnum,
  kNCPropertyTypeStringEnumArray,   /* support data = CFArray { CFString } */
  kNCPropertyTypeDNSSortList,
  kNCPropertyTypeNumberWithRange,   /* support data = CFNumber (SInt64) ==> [ low SInt32 , high SInt32 ] */
  kNCPropertyTypePassword,
  kNCPropertyTypeMax
} NCPropertyType;

/*!
  @typedef NCPropertyRef
  A reference to an NCProperty.
*/
typedef const struct __NCProperty * NCPropertyRef;

/*!
  @function NCPropertyCreate
  Creates a new instance of NCProperty given a type, user interface name,
  SystemConfiguration name, and locking information.  The <TT>supportData</TT>
  is specific to the NCPropertyType you are passing.
*/
CF_EXPORT NCPropertyRef
NCPropertyCreate(
  CFAllocatorRef      allocator,
  NCPropertyType      type,
  CFStringRef         uiName,
  CFStringRef         scName,
  Boolean             locked,
  CFTypeRef           supportData
);
/*!
  @function NCPropertyRetain
  Increment the reference count of <TT>aProperty</TT> and return a reference
  to it.
*/
CF_EXPORT NCPropertyRef
NCPropertyRetain(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyRelease
  Decrement the reference count of <TT>aProperty</TT> and deallocate it once
  that count reaches zero.
*/
CF_EXPORT void
NCPropertyRelease(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyGetType
  Returns the NCPropertyType associated with <TT>aProperty</TT>.
*/
CF_EXPORT NCPropertyType
NCPropertyGetType(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyIsArrayType
  Returns the <TT>TRUE</TT> if the value associated with <TT>aProperty</TT>
  is an array.
*/
CF_EXPORT Boolean
NCPropertyIsArrayType(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyGetUIName
  Returns the user interface name associated with <TT>aProperty</TT>.
*/
CF_EXPORT CFStringRef
NCPropertyGetUIName(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyGetSCName
  Returns the SystemConfiguration name associated with <TT>aProperty</TT>.
*/
CF_EXPORT CFStringRef
NCPropertyGetSCName(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyGetLockStatus
  Returns <TT>FALSE</TT> if <TT>aProperty</TT> can be modified.
*/
CF_EXPORT Boolean
NCPropertyGetLockStatus(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertyGetSupportData
  Returns the optional support data associated with <TT>aProperty</TT>.
*/
CF_EXPORT CFTypeRef
NCPropertyGetSupportData(
  NCPropertyRef       aProperty
);
/*!
  @function NCPropertySetSupportData
  Set the optional support data associated with <TT>aProperty</TT>.
*/
CF_EXPORT void
NCPropertySetSupportData(
  NCPropertyRef       aProperty,
  CFTypeRef           supportData
);
/*!
  @function NCPropertyParseArguments
  Given a property and an array of C strings, attempt to parse the data
  and turn it into an appropriate CFPropertyList object.  When called,
  <TT>argi</TT> should point to a CFIndex containing the starting index
  in <TT>argv</TT>; passing <TT>NULL</TT> for <TT>argi</TT> implies zero.
  The index following the last converted element of <TT>argv</TT> is
  returned in <TT>argi</TT> if it is non-<TT>NULL</TT>.  <TT>argn</TT> is
  the dimension of the <TT>argv</TT> array.
*/
CF_EXPORT CFPropertyListRef
NCPropertyParseArguments(
  NCPropertyRef       aProperty,
  char*               argv[],
  CFIndex*            argi,
  CFIndex             argn
);
/*!
  @function NCPropertyDisplayValue
  Writes the value of <TT>aProperty</TT> to the specified stdio stream.
  <TT>locked</TT> allows the caller to override property locks on a
  per-property basis.
*/
CF_EXPORT void
NCPropertyDisplayValue(
  NCPropertyRef       aProperty,
  FILE*               stream,
  Boolean             locked,
  CFPropertyListRef   value
);
/*!
  @function NCPropertyDisplayValueOnly
  Writes the value of <TT>aProperty</TT> to the specified stdio stream.
  This function does not print the property name and locking information.
*/
CF_EXPORT void
NCPropertyDisplayValueOnly(
  NCPropertyRef       aProperty,
  FILE*               stream,
  CFPropertyListRef   value
);
/*!
  @function NCPropertySummarize
  Writes a standardized property summary of <TT>aProperty</TT> to the specified
  stdio stream.  <TT>locked</TT> allows the caller to override property locks on a
  per-property basis.
*/
CF_EXPORT void
NCPropertySummarize(
  NCPropertyRef       aProperty,
  FILE*               stream,
  Boolean             locked
);

#define PROPERTY_DECL(I,TYPE,UINAME,SCNAME,LOCK,DATA) \
uiNames[I] = UINAME; \
properties[I] = NCPropertyCreate(kCFAllocatorDefault,TYPE,UINAME,SCNAME,LOCK,DATA);

#define PROPERTY_DECL2(I,TYPE,UINAME,SCNAME) PROPERTY_DECL(I,TYPE,UINAME,SCNAME,FALSE,NULL)
#define PROPERTY_DECL3(I,TYPE,UINAME,SCNAME,LOCK) PROPERTY_DECL(I,TYPE,UINAME,SCNAME,LOCK,NULL)

#if defined(__cplusplus)
}
#endif

#endif /* !__NCUTIL_NCPROPERTY__ */
