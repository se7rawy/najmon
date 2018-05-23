// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
// State Table follower for scanning UTF-8 strings without converting to
// 32- or 16-bit Unicode values.
//
// Author: dsites@google.com (Dick Sites)
//

#ifndef SCRIPT_SPAN_UTF8STATETABLE_H_
#define SCRIPT_SPAN_UTF8STATETABLE_H_

#include <string>

#include "integral_types.h" // for uint8, uint32, uint16
#include "stringpiece.h"

namespace chrome_lang_id {
namespace CLD2 {

class OffsetMap;


// These four-byte entries compactly encode how many bytes 0..255 to delete
// in making a string replacement, how many bytes to add 0..255, and the offset
// 0..64k-1 of the replacement string in remap_string.
struct RemapEntry {
  uint8 delete_bytes;
  uint8 add_bytes;
  uint16 bytes_offset;
};

// Exit type codes for state tables. All but the first get stuffed into
// signed one-byte entries. The first is only generated by executable code.
// To distinguish from next-state entries, these must be contiguous and
// all <= kExitNone
typedef enum {
  kExitDstSpaceFull = 239,
  kExitIllegalStructure,  // 240
  kExitOK,                // 241
  kExitReject,            // ...
  kExitReplace1,
  kExitReplace2,
  kExitReplace3,
  kExitReplace21,
  kExitReplace31,
  kExitReplace32,
  kExitReplaceOffset1,
  kExitReplaceOffset2,
  kExitReplace1S0,
  kExitSpecial,
  kExitDoAgain,
  kExitRejectAlt,
  kExitNone               // 255
} ExitReason;

typedef enum {
  kExitDstSpaceFull_2 = 32767,       // 0x7fff
  kExitIllegalStructure_2,  // 32768    0x8000
  kExitOK_2,                // 32769    0x8001
  kExitReject_2,            // ...
  kExitReplace1_2,
  kExitReplace2_2,
  kExitReplace3_2,
  kExitReplace21_2,
  kExitReplace31_2,
  kExitReplace32_2,
  kExitReplaceOffset1_2,
  kExitReplaceOffset2_2,
  kExitReplace1S0_2,
  kExitSpecial_2,
  kExitDoAgain_2,
  kExitRejectAlt_2,
  kExitNone_2               // 32783    0x800f
} ExitReason_2;


// This struct represents one entire state table. The three initialized byte
// areas are state_table, remap_base, and remap_string. state0 and state0_size
// give the byte offset and length within state_table of the initial state --
// table lookups are expected to start and end in this state, but for
// truncated UTF-8 strings, may end in a different state. These allow a quick
// test for that condition. entry_shift is 8 for tables subscripted by a full
// byte value and 6 for space-optimized tables subscripted by only six
// significant bits in UTF-8 continuation bytes.
typedef struct {
  const uint32 state0;
  const uint32 state0_size;
  const uint32 total_size;
  const int max_expand;
  const int entry_shift;
  const int bytes_per_entry;
  const uint32 losub;
  const uint32 hiadd;
  const uint8* state_table;
  const RemapEntry* remap_base;
  const uint8* remap_string;
  const uint8* fast_state;
} UTF8StateMachineObj;

// Near-duplicate declaration for tables with two-byte entries
typedef struct {
  const uint32 state0;
  const uint32 state0_size;
  const uint32 total_size;
  const int max_expand;
  const int entry_shift;
  const int bytes_per_entry;
  const uint32 losub;
  const uint32 hiadd;
  const unsigned short* state_table;
  const RemapEntry* remap_base;
  const uint8* remap_string;
  const uint8* fast_state;
} UTF8StateMachineObj_2;


typedef UTF8StateMachineObj UTF8PropObj;
typedef UTF8StateMachineObj UTF8ScanObj;
typedef UTF8StateMachineObj UTF8ReplaceObj;
typedef UTF8StateMachineObj_2 UTF8PropObj_2;
typedef UTF8StateMachineObj_2 UTF8ReplaceObj_2;
// NOT IMPLEMENTED typedef UTF8StateMachineObj_2 UTF8ScanObj_2;


// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericProperty(const UTF8PropObj* st,
                          const uint8** src,
                          int* srclen);

// Look up property of one UTF-8 character (assumed to be valid).
// (This is a faster version of UTF8GenericProperty.)
bool UTF8HasGenericProperty(const UTF8PropObj& st, const char* src);


// BigOneByte versions are needed for tables > 240 states, but most
// won't need the TwoByte versions.

// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericPropertyBigOneByte(const UTF8PropObj* st,
                          const uint8** src,
                          int* srclen);


// TwoByte versions are needed for tables > 240 states that don't fit onto
// BigOneByte -- rare ultimate fallback

// Look up property of one UTF-8 character (assumed to be valid).
// (This is a faster version of UTF8GenericProperty.)
bool UTF8HasGenericPropertyBigOneByte(const UTF8PropObj& st, const char* src);

// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericPropertyTwoByte(const UTF8PropObj_2* st,
                          const uint8** src,
                          int* srclen);

// Look up property of one UTF-8 character (assumed to be valid).
// (This is a faster version of UTF8GenericProperty.)
bool UTF8HasGenericPropertyTwoByte(const UTF8PropObj_2& st, const char* src);

// Scan a UTF-8 stringpiece based on a state table.
// Always scan complete UTF-8 characters
// Set number of bytes scanned. Return reason for exiting
int UTF8GenericScan(const UTF8ScanObj* st,
                    const StringPiece& str,
                    int* bytes_consumed);



// Scan a UTF-8 stringpiece based on state table, copying to output stringpiece
//   and doing text replacements.
// Always scan complete UTF-8 characters
// Set number of bytes consumed from input, number filled to output.
// Return reason for exiting
// Also writes an optional OffsetMap. Pass NULL to skip writing one.
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap);

// Older version without offsetmap
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed);

// Older version without is_plain_text or offsetmap
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed);


// TwoByte version is needed for tables > about 256 states, such
// as the table for full Unicode 4.1 canonical + compatibility mapping

// Scan a UTF-8 stringpiece based on state table with two-byte entries,
//   copying to output stringpiece
//   and doing text replacements.
// Always scan complete UTF-8 characters
// Set number of bytes consumed from input, number filled to output.
// Return reason for exiting
// Also writes an optional OffsetMap. Pass NULL to skip writing one.
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap);

// Older version without offsetmap
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed);

// Older version without is_plain_text or offsetmap
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed);


static const unsigned char kUTF8LenTbl[256] = {
  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,

  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
  2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2,
  3,3,3,3,3,3,3,3, 3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4, 4,4,4,4,4,4,4,4
};

inline int UTF8OneCharLen(const char* in) {
  return kUTF8LenTbl[*reinterpret_cast<const uint8*>(in)];
}

// Adjust a stringpiece to encompass complete UTF-8 characters.
// The data pointer will be increased by 0..3 bytes to get to a character
// boundary, and the length will then be decreased by 0..3 bytes
// to encompass the last complete character.
// This is useful especially when a UTF-8 string must be put into a fixed-
// maximum-size buffer cleanly, such as a MySQL buffer.
void UTF8TrimToChars(StringPiece* istr);

}       // End namespace CLD2
}       // End namespace chrome_lang_id

#endif  // SCRIPT_SPAN_UTF8STATETABLE_H_
