// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

//
// Flags for getrandom()
//

// This flag does nothing on DragonFly.  /dev/random and
// /dev/urandom are identical.
export def GRND_RANDOM: u32 = 0x0001;

// Return EAGAIN instead of blocking, if the random(4)
// device has not yet been seeded.  By default, getrandom()
// will block until the device is seeded.
export def GRND_NONBLOCK: u32 = 0x0002;

// This flag is treated as an alternative name for
// GRND_NONBLOCK.  It is provided solely for API
// compatibility with Linux.
export def GRND_INSECURE: u32 = 0x0004;
