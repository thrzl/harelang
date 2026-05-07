// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

// The filepath of the system's "leap-seconds.list" file, which contains UTC/TAI
// leap second data.
// TODO: There is no such file on DragonFly (yet)!
// It can be obtained from:
// https://github.com/NetBSD/src/blob/43d53c97b01cfa07cfc6fe2818c7ecafb7fcee66/external/public-domain/tz/dist/leap-seconds.list
export def UTC_LEAPSECS_PATH: str = "/usr/share/zoneinfo/leap-seconds.list";
