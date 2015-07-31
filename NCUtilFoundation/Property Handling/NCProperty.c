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

#include "NCProperty.h"
#include "NCError.h"
#include "CFAdditions.h"
#include "CFCString.h"

static Boolean NCPropertyTextualPasswords = TRUE;

Boolean
NCPropertyUsesTextualPasswords()
{
  return NCPropertyTextualPasswords;
}

//

void
NCPropertySetUsesTextualPasswords(
  Boolean   state
)
{
  NCPropertyTextualPasswords = state;
}

//
#pragma mark -
//

static Boolean NCPropertyOverrideLockingFlag = FALSE;

Boolean
NCPropertyOverrideLocking()
{
  return NCPropertyOverrideLockingFlag;
}

//

void
NCPropertySetOverrideLocking(
  Boolean   override
)
{
  NCPropertyOverrideLockingFlag = override;
}

//
#pragma mark -
//

CFStringRef
NCPropertyTypeAsString(
  NCPropertyType  aType
)
{
  switch (aType) {
    case kNCPropertyTypeBoolean:
      return CFSTR("Boolean");
    case kNCPropertyTypeNumber:
      return CFSTR("Integer");
    case kNCPropertyTypeString:
      return CFSTR("String");
    case kNCPropertyTypeData:
      return CFSTR("Binary Data");
    case kNCPropertyTypeMAC:
      return CFSTR("MAC Address");
    case kNCPropertyTypeIP4:
      return CFSTR("IPv4 Address");
    case kNCPropertyTypeIP6:
      return CFSTR("IPv6 Address");
    case kNCPropertyTypeStringArray:
      return CFSTR("String Array");
    case kNCPropertyTypeIP4Array:
      return CFSTR("IPv4 Address Array");
    case kNCPropertyTypeIP6Array:
      return CFSTR("IPv6 Address Array");
    case kNCPropertyTypeNumberArray:
      return CFSTR("Integer Array");
    case kNCPropertyTypeUniqueNumberArray:
      return CFSTR("Integer Set");
    case kNCPropertyTypeStringEnum:
      return CFSTR("String Enumeration");
    case kNCPropertyTypeStringEnumArray:
      return CFSTR("Multi-Value String Enumeration");
    case kNCPropertyTypeDNSSortList:
      return CFSTR("DNS Sort List Array");
    case kNCPropertyTypeNumberWithRange:
      return CFSTR("Ranged Integer");
    case kNCPropertyTypePassword:
      return CFSTR("Password");
  }
  return NULL;
}

//

CF_INLINE UInt8
CFIntFromHexDigit(
  char      digit
)
{
  if (digit >= '0' && digit <= '9')
    return (digit - '0');
  if (digit >= 'A' && digit <= 'F')
    return (10 + digit - 'A');
  if (digit >= 'a' && digit <= 'f')
    return (10 + digit - 'a');
  return (UInt8)-1;
}

CFDataRef
NCCreatePasswordFromHexString(
  char*       hexstring
)
{
  char          *p1,*p2;
  CFIndex       length = strlen(hexstring),byteCount,actualByteCount = 0;
  
  p1 = hexstring;
  //  Remove leading whitespace:
  while (*p1 && isspace(*p1)) p1++;
  //  See if we have a leading '0x' sequence to dump:
  if ((p2 = strcasestr(p1,"0x")))
    p1 = p2 + 2;
  //  Finally, calculate the remaining length:
  length -= (p1 - hexstring);
  
  //  How many bytes would that be?
  if ((byteCount = (length / 2) + (length % 2))) {
    UInt8       bytes[byteCount];
  
    //  If we had an odd length then the first digit is
    //  0X:
    if (length % 2) {
      bytes[0] = CFIntFromHexDigit(*p1);
      if (bytes[0] == (UInt8)-1)
        return NULL;
      actualByteCount = 1;
      byteCount--;
      p1++;
      length--;
    }
    
    //  Now, try for the rest of the bytes:
    while (length && byteCount--) {
      UInt8   hiNibble,loNibble;
      
      hiNibble = CFIntFromHexDigit(*p1); p1++;
      loNibble = CFIntFromHexDigit(*p1); p1++;
      if (hiNibble == (UInt8)-1 || loNibble == (UInt8)-1)
        break;
      bytes[actualByteCount++] = (hiNibble << 4) | loNibble;
      length -= 2;
    }
    
    //  Once we get here, if any bytes were read we can return something:
    if (actualByteCount)
      return CFDataCreate(kCFAllocatorDefault,bytes,actualByteCount);
  }
  return NULL;
}

//

CFStringRef
NCCreateIP4Address(
  const char*   string
)
{
  unsigned int    d1,d2,d3,d4;
  
  if (sscanf(string,"%u.%u.%u.%u",&d1,&d2,&d3,&d4) == 4)
    if (d1 < 256 && d2 < 256 && d3 < 256 && d4 < 256)
      return CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%u.%u.%u.%u"),d1,d2,d3,d4);
  return NULL;
}

//

CFStringRef
NCCreateIP6Address(
  const char*   string
)
{
  unsigned int    d1,d2,d3,d4,d5,d6,d7,d8;
  
  if (sscanf(string,"%X:%X:%X:%X:%X:%X:%X:%X",&d1,&d2,&d3,&d4,&d5,&d6,&d7,&d8) == 8)
    if (d1 < 256 && d2 < 256 && d3 < 256 && d4 < 256 && d5 < 256 && d6 < 256 && d7 < 256 && d8 < 256)
      return CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X"),d1,d2,d3,d4,d5,d6,d7,d8);
  return NULL;
}

//

CFStringRef
NCCreateIPAddress(
  const char*   string,
  int*          addrType
)
{
  unsigned int    d1,d2,d3,d4,d5,d6,d7,d8;
  
  if (sscanf(string,"%X:%X:%X:%X:%X:%X:%X:%X",&d1,&d2,&d3,&d4,&d5,&d6,&d7,&d8) == 8) {
    if (d1 < 256 && d2 < 256 && d3 < 256 && d4 < 256 && d5 < 256 && d6 < 256 && d7 < 256 && d8 < 256) {
      *addrType = 6;
      return CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X"),d1,d2,d3,d4,d5,d6,d7,d8);
    }
  } else if (sscanf(string,"%u.%u.%u.%u",&d1,&d2,&d3,&d4) == 4) {
    if (d1 < 256 && d2 < 256 && d3 < 256 && d4 < 256) {
      *addrType = 4;
      return CFStringCreateWithFormat(kCFAllocatorDefault,NULL,CFSTR("%u.%u.%u.%u"),d1,d2,d3,d4);
    }
  }
  return NULL;
}

//

CFStringRef
NCCreateStringEnumValue(
  CFArrayRef        enumSet,
  const char*       string
)
{
  if (enumSet && string) {
    CFIndex         index;
    CFStringRef     cfString = CFStringCreateWithCStringNoCopy(
                                  kCFAllocatorDefault,
                                  string,
                                  CFCStringGetDefaultEncoding(),
                                  kCFAllocatorNull
                                );
    CFTypeID        enumType = CFGetTypeID(enumSet);
    
    if (enumType == CFArrayGetTypeID()) {
      if ((index = CFArrayGetFirstIndexOfValue(enumSet,CFRangeMake(0,CFArrayGetCount(enumSet)),cfString)) != kCFNotFound) {
        CFRelease(cfString);
        return CFStringCreateCopy(kCFAllocatorDefault,CFArrayGetValueAtIndex(enumSet,index));
      }
    } else if (enumType == CFSetGetTypeID()) {
      if (CFSetContainsValue((CFSetRef)enumSet,cfString)) {
        CFStringRef   result = CFStringCreateCopy(kCFAllocatorDefault,cfString);
        CFRelease(cfString);
        return result;
      }
    }
    CFRelease(cfString);
  }
  return NULL;
}

//

CFStringRef
NCCreateDNSSortListAddress(
  char*         dnsSortList
)
{
  char*         ipPart = NULL;
  char*         nmPart = dnsSortList;
  CFStringRef   result = NULL;
  
  if ((ipPart = strsep(&nmPart,"/"))) {
    if (ipPart && ipPart != nmPart) {
      int           ipType,nmType = 0;
      CFStringRef   ipAddr = NCCreateIPAddress(ipPart,&ipType);
      CFStringRef   nmAddr = NULL;
      
      //  If there was a netmask part, make a string for it:
      if (nmPart)
        nmAddr = NCCreateIPAddress(nmPart,&nmType);
      
      if (ipAddr) {
        //  If there was a netmask and both addresses were the same type
        //  then we can make a addr/mask item.  Otherwise, as long as
        //  there was an ip we make an addr item.
        if (nmAddr && ipType == nmType) {
          result = CFStringCreateWithFormat(
                      kCFAllocatorDefault,
                      NULL,
                      CFSTR("%@/%@"),
                      ipAddr,
                      nmAddr
                    );
        } else if (!nmAddr) {
          result = CFRetain(ipAddr);
        }
      }
      if (ipAddr)
        CFRelease(ipAddr);
      if (nmAddr)
        CFRelease(nmAddr);
    }
  }
  return result;
}

//
#pragma mark -
//

typedef CFPropertyListRef (*NCPropertyParseCallback)(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData);
typedef void (*NCPropertyDisplayCallback)(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData);
typedef void (*NCPropertySummaryCallback)(FILE* stream,CFTypeRef supportData);

typedef struct __NCProperty {
  CFAllocatorRef      allocator;
  CFIndex             references;
  
  NCPropertyType      propType;
  CFStringRef         propUIName;
  CFStringRef         propSCName;
  Boolean             propLocked;
  CFTypeRef           propSupportData;
  
  NCPropertyParseCallback     parse;
  NCPropertyDisplayCallback   display;
  NCPropertySummaryCallback   summary;
  
} NCProperty;

//
#pragma mark -
//

CFPropertyListRef __NCPropertyParse_Boolean(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  int                 value = -1;
  
  if (strcasecmp(*argv,"yes") == 0) plistItem = CFOne();
  else if (strcasecmp(*argv,"true") == 0) plistItem = CFOne();
  else if (strcasecmp(*argv,"no") == 0) plistItem = CFZero();
  else if (strcasecmp(*argv,"false") == 0) plistItem = CFZero();
  else if (sscanf(*argv,"%d",&value) == 1) {
    if (value != 0)
      plistItem = CFOne();
    else
      plistItem = CFZero();
  }
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_Number(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFIndex             value;
  
  if (sscanf(*argv,"%ld",&value) == 1) {
    plistItem = CFNumberCreate(
                  kCFAllocatorDefault,
                  kCFNumberCFIndexType,
                  &value
                );
    *argi = 1;
  }
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_String(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = CFStringCreateWithBytes(
                                    kCFAllocatorDefault,
                                    (UInt8*)*argv,
                                    strlen(*argv),
                                    CFCStringGetDefaultEncoding(),
                                    FALSE
                                  );
  *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_Data(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = CFDataCreate(
                                    kCFAllocatorDefault,
                                    (UInt8*)*argv,
                                    strlen(*argv)
                                  );
  *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_MAC(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  int                 digitCount = 0;
  int                 charCount;
  char*               buffer = *argv;
  UInt8               digit;
  
  while (*buffer && sscanf(buffer,"%hhx%n",&digit,&charCount) == 1) {
    buffer += charCount;
    if (*buffer == ':') buffer++;
    digitCount++;
  }
  if (digitCount == 6 || digitCount == 8) {
    UInt8   digits[digitCount];
    int     i = 0;
    
    buffer = *argv;
    while (i < digitCount) {
      sscanf(buffer,"%hhx%n",digits + i++,&charCount);
      buffer += charCount;
      if (*buffer == ':') buffer++;
    }
    plistItem = CFDataCreate(kCFAllocatorDefault,digits,digitCount);
  }
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_IP4(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NCCreateIP4Address(*argv);
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_IP6(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NCCreateIP6Address(*argv);
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_StringArray(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFStringRef         strings[argn];
  CFIndex             i = 0;
  
  //  Create all the strings:
  while (i < argn) {
    strings[i] = CFStringCreateWithBytes(
                    kCFAllocatorDefault,
                    (UInt8*)*argv,
                    strlen(*argv),
                    CFCStringGetDefaultEncoding(),
                    FALSE
                  );
    if (!strings[i])
      break;
    i++;
    argv++;
  }
  if (i) {
    *argi = i;
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)strings,
                  i,
                  &kCFTypeArrayCallBacks
                );
    while (i--)
      CFRelease(strings[i]);
  }
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_IP4Array(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFStringRef         strings[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the strings:
  while (i < argn) {
    if ((strings[j] = NCCreateIP4Address(*argv)))
      j++;
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)strings,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(strings[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_IP6Array(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFStringRef         strings[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the strings:
  while (i < argn) {
    if ((strings[j] = NCCreateIP6Address(*argv)))
      j++;
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)strings,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(strings[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_NumberArray(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFNumberRef         numbers[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the numbers:
  while (i < argn) {
    CFIndex     value;
    
    if (sscanf(*argv,"%ld",&value) == 1)
      if ((numbers[j] = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value)))
        j++;
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)numbers,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(numbers[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_UniqueNumberArray(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFNumberRef         numbers[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the numbers:
  while (i < argn) {
    CFIndex     value;
    
    if (sscanf(*argv,"%ld",&value) == 1) {
      if ((numbers[j] = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value))) {
        CFIndex     k = j;
        
        //  Make sure we don't have one already:
        while (k) {
          if (CFEqual(numbers[j],numbers[--k])) {
            k = kCFNotFound;
            break;
          }
        }
        //  If k == kCFNotFound then we had one already:
        if (k == kCFNotFound)
          CFRelease(numbers[j]);
        else
          j++;
      }
    }
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)numbers,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(numbers[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_StringEnum(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NCCreateStringEnumValue(supportData,*argv);
  
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_StringEnumArray(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFStringRef         strings[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the numbers:
  while (i < argn) {
    if ((strings[j] = NCCreateStringEnumValue(supportData,*argv))) {
      CFIndex     k = j;
      
      //  Make sure we don't have one already:
      while (k) {
        if (CFEqual(strings[j],strings[--k])) {
          k = kCFNotFound;
          break;
        }
      }
      //  If k == kCFNotFound then we had one already:
      if (k == kCFNotFound)
        CFRelease(strings[j]);
      else
        j++;
    }
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)strings,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(strings[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_DNSSortList(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFStringRef         strings[argn];
  CFIndex             i = 0,j = 0;
  
  //  Create all the numbers:
  while (i < argn) {
    if ((strings[j] = NCCreateDNSSortListAddress(*argv))) {
      CFIndex     k = j;
      
      //  Make sure we don't have one already:
      while (k) {
        if (CFEqual(strings[j],strings[--k])) {
          k = kCFNotFound;
          break;
        }
      }
      //  If k == kCFNotFound then we had one already:
      if (k == kCFNotFound)
        CFRelease(strings[j]);
      else
        j++;
    }
    i++;
    argv++;
  }
  if (j) {
    plistItem = CFArrayCreate(
                  kCFAllocatorDefault,
                  (const void**)strings,
                  j,
                  &kCFTypeArrayCallBacks
                );
    while (j--)
      CFRelease(strings[j]);
  }
  *argi = i;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_NumberWithRange(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
  CFIndex             value;
        
  if (sscanf(*argv,"%ld",&value) == 1) {
    CFNumberRef   range = (CFNumberRef)supportData;
    SInt32        intRange[2] = { -32768 , 32768 };
    
    if (range)
      CFNumberGetValue(range,kCFNumberSInt64Type,intRange);
    if ((value >= intRange[0]) && (value <= intRange[1]))
      plistItem = CFNumberCreate(kCFAllocatorDefault,kCFNumberCFIndexType,&value);
  }
  if (plistItem)
    *argi = 1;
  return plistItem;
}

CFPropertyListRef __NCPropertyParse_Password(char* argv[],CFIndex* argi,CFIndex argn,CFTypeRef supportData)
{
  CFPropertyListRef   plistItem = NULL;
//
//  30.Jul.2004:
//    Added so that encryption, etc, can be handled properly
//
  if (NCPropertyTextualPasswords) {
    CFStringRef   stringForm = CFStringCreateWithBytes(
                                  kCFAllocatorDefault,
                                  (UInt8*)*argv,
                                  strlen(*argv),
                                  CFCStringGetDefaultEncoding(),
                                  FALSE
                                );
    if (stringForm) {
#ifndef NCPROPERTY_8BITPASSWORDS
      //  Unicode; convert right into a buffer, wrap it
      //  in a CFData object (forget the BOM character,
      //  as per Apple's Network c.p. as an example):
      CFIndex     sLen = CFStringGetLength(stringForm);
      CFIndex     bLen = sLen * sizeof(UniChar);
      
      if (sLen) {
        UniChar   buffer[sLen];
        //  Copy unicode into the buffer:
        CFIndex   uLen,rval;
        
        rval = CFStringGetBytes(
                  stringForm,
                  CFRangeMake(0,sLen),
                  kCFStringEncodingUnicode,
                  (UInt8)0,
                  FALSE,
                  (UInt8*)buffer,
                  bLen,
                  &uLen);
        if (rval == sLen)
          plistItem = CFDataCreate(
                        kCFAllocatorDefault,
                        (UInt8*)buffer,
                        bLen
                      );
      }
#else
    //  8-bit password encoding, just do a basic conversion
    //  to CFData:
      plistItem = CFStringCreateExternalRepresentation(
                    kCFAllocatorDefault,
                    stringForm,
                    CFCStringGetDefaultEncoding(),
                    0
                  );
#endif
    }
    CFRelease(stringForm);
  } else {
    //  The string represents a binary, hexadecimal password:
    plistItem = NCCreatePasswordFromHexString(*argv);
  }
  if (plistItem)
    *argi = 1;
  return plistItem;
}

//
#pragma mark -
//

void __NCPropertyDisplay_Boolean(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);
  int         triState = -1;
  
  if (typeID == CFNumberGetTypeID()) {
    CFIndex   state = CFNumberToCFIndexOnly(value);
    triState = (state != 0 ? 1 : 0);
  } else if (typeID == CFBooleanGetTypeID()) {
    if (CFEqual(kCFBooleanTrue,value))
      triState = 1;
    else
      triState = 0;
  }
  switch (triState) {
    case -1:
      fprintf(stream,"?????\n");
      break;
    case 0:
      fprintf(stream,"false\n");
      break;
    case 1:
      fprintf(stream,"true\n");
      break;
  }
}

void __NCPropertyDisplay_Number(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);

  if (typeID == CFNumberGetTypeID()) {
    CFIndex   intValue = CFNumberToCFIndexOnly(value);
    fprintf(stream,"%ld\n",intValue);
  } else
    fprintf(stream,"<non-numeric value>\n");
}

void __NCPropertyDisplay_String(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);
  
  if (typeID == CFStringGetTypeID())
    NCPrint(stream,CFSTR("%@\n"),value);
  else
    fprintf(stream,"<non-textual value>\n");
}

void __NCPropertyDisplay_Data(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);
  
  if (typeID == CFDataGetTypeID()) {
    CFIndex       i,iMax = CFDataGetLength(value);
    const UInt8*  bytes = CFDataGetBytePtr(value);
    
    for ( i = 0 ; i < iMax ; i++,bytes++ )
      fprintf(stream,"%02X",*bytes);
    fputc('\n',stream);
  } else
    fprintf(stream,"<non-data value>\n");
}

void __NCPropertyDisplay_Password(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);

  if (typeID == CFDataGetTypeID()) {
    CFIndex     i,iMax = CFDataGetLength(value);
    
    for ( i = 0 ; i < iMax ; i++ )
      fputc('*',stream);
    fputc('\n',stream);
  } else
      fprintf(stream,"<non-data value>\n");
}

void
NCPropertyCollectionWriter(
  const void*   value,
  void*         stream
)
{
  NCPrint((FILE*)stream,CFSTR("  %@\n"),value);
}

void
NCPropertyCollectionIndentedWriter(
  const void*   value,
  void*         stream
)
{
  NCPrint((FILE*)stream,CFSTR("            %@\n"),value);
}

void __NCPropertyDisplay_Array(FILE* stream,CFPropertyListRef value,Boolean indent,CFTypeRef supportData)
{
  CFTypeID    typeID = CFGetTypeID(value);
  
  if (typeID == CFArrayGetTypeID()) {
    fprintf(stream,"{\n");
    CFArrayApplyFunction(
        value,
        CFRangeMake(0,CFArrayGetCount(value)),
        (indent ? NCPropertyCollectionIndentedWriter : NCPropertyCollectionWriter),
        stream
      );
    if (indent)
      fprintf(stream,"          }\n");
    else
      fprintf(stream,"}\n");
  } else if (typeID == CFSetGetTypeID()) {
    fprintf(stream,"{\n");
    CFSetApplyFunction(
        value,
        (indent ? NCPropertyCollectionIndentedWriter : NCPropertyCollectionWriter),
        stream
      );
    if (indent)
      fprintf(stream,"          }\n");
    else
      fprintf(stream,"}\n");
  } else
    fprintf(stream,"<non-array value>\n");
}

//
#pragma mark -
//

void __NCPropertySummarize_StringEnum(FILE* stream,CFTypeRef supportData)
{
  CFTypeID      typeID = CFGetTypeID(supportData);
  
  if (typeID == CFArrayGetTypeID()) {
    CFArrayRef    values = (CFArrayRef)supportData;
    
    if (values) {
      CFIndex     i = 0,iMax = CFArrayGetCount(supportData);
      
      fprintf(stream," [ ");
      while (i < iMax) {
        CFStringRef   value = CFArrayGetValueAtIndex(values,i++);
        
        if (CFGetTypeID(value) == CFStringGetTypeID()) {
          if (i > 1)
            fprintf(stream," | ");
          NCPrint(stream,value);
        }
      }
      fprintf(stream," ]");
    }
  } else if (typeID == CFSetGetTypeID()) {
    CFSetRef        values = (CFSetRef)supportData;
    
    if (values) {
      CFIndex     i = 0,iMax = CFSetGetCount(supportData);
      CFStringRef strings[iMax];
      
      CFSetGetValues(values,(const void**)strings);
      
      fprintf(stream," [ ");
      while (i < iMax) {
        CFStringRef   value = strings[i++];
        
        if (CFGetTypeID(value) == CFStringGetTypeID()) {
          if (i > 1)
            fprintf(stream," | ");
          NCPrint(stream,value);
        }
      }
      fprintf(stream," ]");
    }
  }
}

void __NCPropertySummarize_NumberWithRange(FILE* stream,CFTypeRef supportData)
{
  CFNumberRef   range = (CFNumberRef)supportData;
  SInt32        intRange[2] = { -32768 , 32768 };
  
  if (range)
    CFNumberGetValue(range,kCFNumberSInt64Type,intRange);
  fprintf(stream," [ %d , %d ]",(int)intRange[0],(int)intRange[1]);
}

//
#pragma mark -
//

NCPropertyParseCallback   __NCPropertyParsers[kNCPropertyTypeMax] = {
                              __NCPropertyParse_Boolean,
                              __NCPropertyParse_Number,
                              __NCPropertyParse_String,
                              __NCPropertyParse_Data,
                              __NCPropertyParse_MAC,
                              __NCPropertyParse_IP4,
                              __NCPropertyParse_IP6,
                              __NCPropertyParse_StringArray,
                              __NCPropertyParse_IP4Array,
                              __NCPropertyParse_IP6Array,
                              __NCPropertyParse_NumberArray,
                              __NCPropertyParse_UniqueNumberArray,
                              __NCPropertyParse_StringEnum,
                              __NCPropertyParse_StringEnumArray,
                              __NCPropertyParse_DNSSortList,
                              __NCPropertyParse_NumberWithRange,
                              __NCPropertyParse_Password
                          };
NCPropertyDisplayCallback __NCPropertyDisplayers[kNCPropertyTypeMax] = {
                              __NCPropertyDisplay_Boolean,
                              __NCPropertyDisplay_Number,
                              __NCPropertyDisplay_String,
                              __NCPropertyDisplay_Data,
                              __NCPropertyDisplay_String,
                              __NCPropertyDisplay_String,
                              __NCPropertyDisplay_String,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_String,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Array,
                              __NCPropertyDisplay_Number,
                              __NCPropertyDisplay_Password
                          };
NCPropertySummaryCallback __NCPropertySummarizers[kNCPropertyTypeMax] = {
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              __NCPropertySummarize_StringEnum,
                              __NCPropertySummarize_StringEnum,
                              NULL,
                              __NCPropertySummarize_NumberWithRange,
                              NULL
                          };

//
#pragma mark Private functions:
//

NCProperty*
__NCPropertyAlloc(
  CFAllocatorRef      allocator,
  NCPropertyType      type
)
{
  NCProperty*     newProp = CFAllocatorAllocate(allocator,sizeof(NCProperty),0);
  
  if (newProp) {
    newProp->allocator    = allocator;
    newProp->references   = 1;
    newProp->propType     = type;
    
    //  Set the callback functions:
    newProp->parse        = __NCPropertyParsers[type];
    newProp->display      = __NCPropertyDisplayers[type];
    newProp->summary      = __NCPropertySummarizers[type];
  }
  return newProp;
}

//
#pragma mark Public functions:
//

NCPropertyRef
NCPropertyCreate(
  CFAllocatorRef      allocator,
  NCPropertyType      type,
  CFStringRef         uiName,
  CFStringRef         scName,
  Boolean             locked,
  CFTypeRef           supportData
)
{
  NCProperty*         newProp = __NCPropertyAlloc(allocator,type);
  
  if (newProp) {
    newProp->propUIName   = CFRetain(uiName);
    newProp->propSCName   = CFRetain(scName);
    newProp->propLocked   = locked;
    if (supportData)
      newProp->propSupportData  = CFRetain(supportData);
    else
      newProp->propSupportData  = NULL;
  }
  return (NCPropertyRef)newProp;
}

//

NCPropertyRef
NCPropertyRetain(
  NCPropertyRef       aProperty
)
{
  ((NCProperty*)aProperty)->references++;
  return aProperty;
}

//

void
NCPropertyRelease(
  NCPropertyRef       aProperty
)
{
  NCProperty*       theProp = (NCProperty*)aProperty;
  
  if (--theProp->references == 0) {
    if (theProp->propUIName) CFRelease(theProp->propUIName);
    if (theProp->propSCName) CFRelease(theProp->propSCName);
    if (theProp->propSupportData) CFRelease(theProp->propSupportData);
    CFAllocatorDeallocate(theProp->allocator,(void*)theProp);
  }
}

//

NCPropertyType
NCPropertyGetType(
  NCPropertyRef       aProperty
)
{
  return aProperty->propType;
}

//

Boolean
NCPropertyIsArrayType(
  NCPropertyRef       aProperty
)
{
  switch (aProperty->propType) {
    case kNCPropertyTypeStringArray:
    case kNCPropertyTypeIP4Array:
    case kNCPropertyTypeIP6Array:
    case kNCPropertyTypeNumberArray:
    case kNCPropertyTypeUniqueNumberArray:
    case kNCPropertyTypeStringEnumArray:
      return TRUE;
  }
  return FALSE;
}

//

CFStringRef
NCPropertyGetUIName(
  NCPropertyRef       aProperty
)
{
  return aProperty->propUIName;
}

//

CFStringRef
NCPropertyGetSCName(
  NCPropertyRef       aProperty
)
{
  return aProperty->propSCName;
}

//

Boolean
NCPropertyGetLockStatus(
  NCPropertyRef       aProperty
)
{
  if (NCPropertyOverrideLockingFlag)
    return FALSE;
  return aProperty->propLocked;
}

//

CFTypeRef
NCPropertyGetSupportData(
  NCPropertyRef       aProperty
)
{
  return aProperty->propSupportData;
}

//

void
NCPropertySetSupportData(
  NCPropertyRef       aProperty,
  CFTypeRef           supportData
)
{
  NCProperty*         theProp = (NCProperty*)aProperty;
  
  if (aProperty->propSupportData)
    CFRelease(aProperty->propSupportData);
  theProp->propSupportData = ( supportData ? CFRetain(supportData) : NULL );
}

//

CFPropertyListRef
NCPropertyParseArguments(
  NCPropertyRef       aProperty,
  char*               argv[],
  CFIndex*            argi,
  CFIndex             argn
)
{
  CFPropertyListRef   result = NULL;
  CFIndex             i = 0;
  
  //  Move ahead to the argument at which we're supposed to start:
  if (argi) {
    argv += *argi;
    argn -= *argi;
  }
  
  //  Invoke the parser:
  result = aProperty->parse(argv,&i,argn,aProperty->propSupportData);
  
  //  If a starting index came in, modify it accordingly:
  if (argi) *argi += i;
  
  return result;
}

//

void
NCPropertyDisplayValue(
  NCPropertyRef       aProperty,
  FILE*               stream,
  Boolean             locked,
  CFPropertyListRef   value
)
{
  if (NCPropertyOverrideLockingFlag)
    locked = FALSE;
  else if (aProperty->propLocked)
    locked = TRUE;
    
  NCPrint(stream,CFSTR("-r%c       %@ = "),(locked ? '-' : 'w'),aProperty->propUIName);

  aProperty->display(stream,value,TRUE,aProperty->propSupportData);
}

//

void
NCPropertyDisplayValueOnly(
  NCPropertyRef       aProperty,
  FILE*               stream,
  CFPropertyListRef   value
)
{
  aProperty->display(stream,value,FALSE,aProperty->propSupportData);
}

//

void
NCPropertySummarize(
  NCPropertyRef       aProperty,
  FILE*               stream,
  Boolean             locked
)
{
  if (NCPropertyOverrideLockingFlag)
    locked = FALSE;
  else if (aProperty->propLocked)
    locked = TRUE;
    
  NCPrint(stream,CFSTR("-r%c       (%@) %@"),(locked ? '-' : 'w'),NCPropertyTypeAsString(aProperty->propType),aProperty->propUIName);
    
  if (aProperty->summary) {
    fprintf(stream," = ");fflush(stream);
    aProperty->summary(stream,aProperty->propSupportData);
  }
  fputc('\n',stream);
}
