// SPDX-License-Identifier: MPL-2.0
// (c) Hare authors <https://harelang.org>

export type sa_family_t = u8;
export type socklen_t = u32;

export type in_addr = struct {
	s_addr: u32
};

// Socket address, internet style.
export type sockaddr_in = struct {
	sin_len: u8,
	sin_family: sa_family_t,
	sin_port: u16,
	sin_addr: in_addr,
	__pad: [8]u8,
};

// IPv6 address
export type in6_addr = struct {
	// 128-bit IP6 address
	union {
		s6_addr: [16]u8,
		s6_addr16: [8]u16,
		s6_addr32: [4]u32,
	}
};

export type sockaddr_in6 = struct {
	sin6_len: u8,			// length of this struct
	sin6_family: sa_family_t,	// AF_INET6
	sin6_port: u16,			// Transport layer port #
	sin6_flowinfo: u32,		// IP6 flow information
	sin6_addr: in6_addr,		// IP6 address
	sin6_scope_id: u32,		// scope zone index
};

export def UNIX_PATH_MAX: size = 104;

// Definitions for UNIX IPC domain
export type sockaddr_un = struct {
	sun_len: u8,			// sockaddr len including NUL
	sun_family: sa_family_t,	// AF_UNIX
	sun_path: [UNIX_PATH_MAX]u8,	// path name (gag)
};

// The definition in Dragonfly (sys/socket.h) is slightly different
// but the one below makes more sense.
export type sockaddr = struct {
	union {
		in: sockaddr_in,
		in6: sockaddr_in6,
		un: sockaddr_un,
	},
};

export def SCM_RIGHTS: int = 0x01;	// access rights (array of int)
export def SCM_TIMESTAMP: int = 0x02;	// timestamp (struct timeval)
export def SCM_CREDENTIALS: int = 0x03;	// process cred (struct cmsgcred)

// Message header for recvmsg and sendmsg calls.
// Used value-result for recvmsg, value only for sendmsg.
export type msghdr = struct {
	msg_name: nullable *opaque,	// optional address
	msg_namelen: socklen_t,		// size of address
	msg_iov: nullable *[*]iovec,	// scatter/gather array
	msg_iovlen: int,		// # elements in msg_iov
	msg_control: nullable *opaque,	// ancillary data, see below
	msg_controllen: socklen_t,	// ancillary data buffer len
	msg_flags: int			// flags on received message
};

// Header for ancillary data objects in msg_control buffer.
// Used for additional information with/about a datagram
// not expressible by flags.  The format is a sequence
// of message elements headed by cmsghdr structures.
export type cmsghdr = struct {
	cmsg_len: socklen_t,		// data byte count, including hdr
	cmsg_level: int,		// originating protocol
	cmsg_type: int,			// protocol-specific type
};

export type cmsg = struct {
	hdr: cmsghdr,
	cmsg_data: [*]u8,
};

export def AF_UNSPEC: sa_family_t = 0;	// unspecified
export def AF_UNIX: sa_family_t = 1;	// local to host (pipes, portals)
export def AF_LOCAL: sa_family_t = AF_UNIX;
export def AF_INET: sa_family_t = 2;	// internetwork: UDP, TCP, etc.
export def AF_IMPLINK: sa_family_t = 3;	// arpanet imp addresses
export def AF_PUP: sa_family_t = 4;	// pup protocols: e.g. BSP
export def AF_CHAOS: sa_family_t = 5;	// mit CHAOS protocols
export def AF_NETBIOS: sa_family_t = 6;	// SMB protocols
export def AF_ISO: sa_family_t = 7;	// ISO protocols
export def AF_OSI: sa_family_t = AF_ISO;
export def AF_ECMA: sa_family_t = 8;	// European computer manufacturers
export def AF_DATAKIT: sa_family_t = 9;	// datakit protocols
export def AF_CCITT: sa_family_t = 10;	// CCITT protocols, X.25 etc
export def AF_SNA: sa_family_t = 11;	// IBM SNA
export def AF_DECnet: sa_family_t = 12;	// DECnet
export def AF_DLI: sa_family_t = 13;	// DEC Direct data link interface
export def AF_LAT: sa_family_t = 14;	// LAT
export def AF_HYLINK: sa_family_t = 15;	// NSC Hyperchannel
export def AF_APPLETALK: sa_family_t = 16; // Apple Talk
export def AF_ROUTE: sa_family_t = 17;	// Internal Routing Protocol
export def AF_LINK: sa_family_t = 18;	// Link layer interface
export def pseudo_AF_XTP: sa_family_t = 19; // eXpress Transfer Protocol (no AF)
export def AF_COIP: sa_family_t = 20;	// connection-oriented IP, aka ST II
export def AF_CNT: sa_family_t = 21;	// Computer Network Technology
export def pseudo_AF_RTIP: sa_family_t = 22; // Help Identify RTIP packets
export def AF_IPX: sa_family_t = 23;	// Novell Internet Protocol
export def AF_SIP: sa_family_t = 24;	// Simple Internet Protocol
export def pseudo_AF_PIP: sa_family_t = 25; // Help Identify PIP packets
export def AF_ISDN: sa_family_t = 26;	// Integrated Services Digital Network
export def AF_E164: sa_family_t = AF_ISDN; // CCITT E.164 recommendation
export def pseudo_AF_KEY: sa_family_t = 27; // Internal key-management function
export def AF_INET6: sa_family_t = 28;	// IPv6
export def AF_NATM: sa_family_t = 29;	// native ATM access
export def AF_ATM: sa_family_t = 30;	// ATM
// Used by BPF to not rewrite headers in interface output routine
export def pseudo_AF_HDRCMPLT: sa_family_t = 31;
export def AF_NETGRAPH: sa_family_t = 32; // Netgraph sockets
export def AF_BLUETOOTH: sa_family_t = 33; // Bluetooth
export def AF_MPLS: sa_family_t = 34;	// Multi-Protocol Label Switching
export def AF_IEEE80211: sa_family_t = 35; // IEEE 802.11 protocol
export def AF_ARP: sa_family_t = 36;	// (rev.) addr. res. prot. (RFC 826)
export def AF_MAX: sa_family_t = 37;

export def SOCK_STREAM: int = 1;	// stream socket
export def SOCK_DGRAM: int = 2;		// datagram socket
export def SOCK_RAW: int = 3;		// raw-protocol interface
export def SOCK_RDM: int = 4;		// reliably-delivered message
export def SOCK_SEQPACKET: int = 5;	// sequenced packet stream

//
// Creation flags, OR'ed into socket() and socketpair() type argument.
//

export def SOCK_CLOEXEC: int = 0x10000000;
export def SOCK_NONBLOCK: int = 0x20000000;
export def SOCK_CLOFORK: int = 0x40000000;
// For kern_accept(): don't inherit FNONBLOCK or FASYNC.
export def SOCK_KERN_NOINHERIT: int = 0x00100000;


//
// Protocols (RFC 1700) that are part of standards
//

export def IPPROTO_IP: int = 0;		// dummy for IP
export def IPPROTO_ICMP: int = 1;	// control message protocol
export def IPPROTO_TCP: int = 6;	// tcp
export def IPPROTO_UDP: int = 17;	// user datagram protocol
export def IPPROTO_IPV6: int = 41;	// IP6 header
export def IPPROTO_RAW: int = 255;	// raw IP packet
export def IPPROTO_HOPOPTS: int = 0;	// IP6 hop-by-hop options
export def IPPROTO_IGMP: int = 2;	// group mgmt protocol
export def IPPROTO_GGP: int = 3;	// gateway^2 (deprecated)
export def IPPROTO_IPV4: int = 4;	// IPv4 encapsulation
export def IPPROTO_ST: int = 7;		// Stream protocol II
export def IPPROTO_EGP: int = 8;	// exterior gateway protocol
export def IPPROTO_PIGP: int = 9;	// private interior gateway
export def IPPROTO_RCCMON: int = 10;	// BBN RCC Monitoring
export def IPPROTO_NVPII: int = 11;	// network voice protocol
export def IPPROTO_PUP: int = 12;	// pup
export def IPPROTO_ARGUS: int = 13;	// Argus
export def IPPROTO_EMCON: int = 14;	// EMCON
export def IPPROTO_XNET: int = 15;	// Cross Net Debugger
export def IPPROTO_CHAOS: int = 16;	// Chaos
export def IPPROTO_MUX: int = 18;	// Multiplexing
export def IPPROTO_MEAS: int = 19;	// DCN Measurement Subsystems
export def IPPROTO_HMP: int = 20;	// Host Monitoring
export def IPPROTO_PRM: int = 21;	// Packet Radio Measurement
export def IPPROTO_IDP: int = 22;	// xns idp
export def IPPROTO_TRUNK1: int = 23;	// Trunk-1
export def IPPROTO_TRUNK2: int = 24;	// Trunk-2
export def IPPROTO_LEAF1: int = 25;	// Leaf-1
export def IPPROTO_LEAF2: int = 26;	// Leaf-2
export def IPPROTO_RDP: int = 27;	// Reliable Data
export def IPPROTO_IRTP: int = 28;	// Reliable Transaction
export def IPPROTO_TP: int = 29;	// tp-4 w/ class negotiation
export def IPPROTO_BLT: int = 30;	// Bulk Data Transfer
export def IPPROTO_NSP: int = 31;	// Network Services
export def IPPROTO_INP: int = 32;	// Merit Internodal
export def IPPROTO_SEP: int = 33;	// Sequential Exchange
export def IPPROTO_3PC: int = 34;	// Third Party Connect
export def IPPROTO_IDPR: int = 35;	// InterDomain Policy Routing
export def IPPROTO_XTP: int = 36;	// XTP
export def IPPROTO_DDP: int = 37;	// Datagram Delivery
export def IPPROTO_CMTP: int = 38;	// Control Message Transport
export def IPPROTO_TPXX: int = 39;	// TP++ Transport
export def IPPROTO_IL: int = 40;	// IL transport protocol
export def IPPROTO_SDRP: int = 42;	// Source Demand Routing
export def IPPROTO_ROUTING: int = 43;	// IP6 routing header
export def IPPROTO_FRAGMENT: int = 44;	// IP6 fragmentation header
export def IPPROTO_IDRP: int = 45;	// InterDomain Routing
export def IPPROTO_RSVP: int = 46;	// resource reservation
export def IPPROTO_GRE: int = 47;	// General Routing Encap.
export def IPPROTO_MHRP: int = 48;	// Mobile Host Routing
export def IPPROTO_BHA: int = 49;	// BHA
export def IPPROTO_ESP: int = 50;	// IP6 Encap Sec. Payload
export def IPPROTO_AH: int = 51;	// IP6 Auth Header
export def IPPROTO_INLSP: int = 52;	// Integ. Net Layer Security
export def IPPROTO_SWIPE: int = 53;	// IP with encryption
export def IPPROTO_NHRP: int = 54;	// Next Hop Resolution
export def IPPROTO_MOBILE: int = 55;	// IP Mobility
export def IPPROTO_TLSP: int = 56;	// Transport Layer Security
export def IPPROTO_SKIP: int = 57;	// SKIP
export def IPPROTO_ICMPV6: int = 58;	// ICMP6
export def IPPROTO_NONE: int = 59;	// IP6 no next header
export def IPPROTO_DSTOPTS: int = 60;	// IP6 destination option
export def IPPROTO_AHIP: int = 61;	// any host internal protocol
export def IPPROTO_CFTP: int = 62;	// CFTP
export def IPPROTO_HELLO: int = 63;	// "hello" routing protocol
export def IPPROTO_SATEXPAK: int = 64;	// SATNET/Backroom EXPAK
export def IPPROTO_KRYPTOLAN: int = 65;	// Kryptolan
export def IPPROTO_RVD: int = 66;	// Remote Virtual Disk
export def IPPROTO_IPPC: int = 67;	// Pluribus Packet Core
export def IPPROTO_ADFS: int = 68;	// Any distributed FS
export def IPPROTO_SATMON: int = 69;	// Satnet Monitoring
export def IPPROTO_VISA: int = 70;	// VISA Protocol
export def IPPROTO_IPCV: int = 71;	// Packet Core Utility
export def IPPROTO_CPNX: int = 72;	// Comp. Prot. Net. Executive
export def IPPROTO_CPHB: int = 73;	// Comp. Prot. HeartBeat
export def IPPROTO_WSN: int = 74;	// Wang Span Network
export def IPPROTO_PVP: int = 75;	// Packet Video Protocol
export def IPPROTO_BRSATMON: int = 76;	// BackRoom SATNET Monitoring
export def IPPROTO_ND: int = 77;	// Sun net disk proto (temp.)
export def IPPROTO_WBMON: int = 78;	// WIDEBAND Monitoring
export def IPPROTO_WBEXPAK: int = 79;	// WIDEBAND EXPAK
export def IPPROTO_EON: int = 80;	// ISO cnlp
export def IPPROTO_VMTP: int = 81;	// VMTP
export def IPPROTO_SVMTP: int = 82;	// Secure VMTP
export def IPPROTO_VINES: int = 83;	// Banyon VINES
export def IPPROTO_TTP: int = 84;	// TTP
export def IPPROTO_IGP: int = 85;	// NSFNET-IGP
export def IPPROTO_DGP: int = 86;	// dissimilar gateway prot.
export def IPPROTO_TCF: int = 87;	// TCF
export def IPPROTO_IGRP: int = 88;	// Cisco/GXS IGRP
export def IPPROTO_OSPFIGP: int = 89;	// OSPFIGP
export def IPPROTO_SRPC: int = 90;	// Strite RPC protocol
export def IPPROTO_LARP: int = 91;	// Locus Address Resoloution
export def IPPROTO_MTP: int = 92;	// Multicast Transport
export def IPPROTO_AX25: int = 93;	// AX.25 Frames
export def IPPROTO_IPEIP: int = 94;	// IP encapsulated in IP
export def IPPROTO_MICP: int = 95;	// Mobile Int.ing control
export def IPPROTO_SCCSP: int = 96;	// Semaphore Comm. security
export def IPPROTO_ETHERIP: int = 97;	// Ethernet IP encapsulation
export def IPPROTO_ENCAP: int = 98;	// encapsulation header
export def IPPROTO_APES: int = 99;	// any private encr. scheme
export def IPPROTO_GMTP: int = 100;	// GMTP
export def IPPROTO_IPCOMP: int = 108;	// payload compression (IPComp)
export def IPPROTO_PIM: int = 103;	// Protocol Independent Mcast
export def IPPROTO_CARP: int = 112;	// CARP
export def IPPROTO_PGM: int = 113;	// PGM
export def IPPROTO_PFSYNC: int = 240;	// PFSYNC
export def IPPROTO_DIVERT: int = 254;	// divert pseudo-protocol
export def IPPROTO_MAX: int = 256;	//
export def IPPROTO_DONE: int = 257;	//
export def IPPROTO_UNKNOWN: int = 258;	//

export def MSG_OOB: int = 0x00000001;	// process out-of-band data
export def MSG_PEEK: int = 0x00000002;	// peek at incoming message
export def MSG_DONTROUTE: int = 0x00000004; // send without using routing tables
export def MSG_EOR: int = 0x00000008;	// data completes record
export def MSG_TRUNC: int = 0x00000010;	// data discarded before delivery
export def MSG_CTRUNC: int = 0x00000020; // control data lost before delivery
export def MSG_WAITALL: int = 0x00000040; // wait for full request or error
export def MSG_DONTWAIT: int = 0x00000080; // this message should be nonblocking
export def MSG_EOF: int = 0x00000100;	// data completes connection
export def MSG_UNUSED09: int = 0x00000200; // was: notification message (SCTP)
export def MSG_NOSIGNAL: int = 0x00000400; // No SIGPIPE to unconnected socket stream
export def MSG_SYNC: int = 0x00000800;		// No asynchronized pru_send
export def MSG_CMSG_CLOEXEC: int = 0x00001000;	// make received fds close-on-exec
export def MSG_CMSG_CLOFORK: int = 0x00002000;	// make received fds close-on-fork
export def MSG_FBLOCKING: int = 0x00010000;	// force blocking operation
export def MSG_FNONBLOCKING: int = 0x00020000;	// force non-blocking operation
export def MSG_FMASK: uint = 0xFFFF0000;	// force mask

//
// Option flags per-socket.
//

export def SO_DEBUG: int = 0x0001;	// turn on debugging info recording
export def SO_ACCEPTCONN: int = 0x0002;	// socket has had listen()
export def SO_REUSEADDR: int = 0x0004;	// allow local address reuse
export def SO_KEEPALIVE: int = 0x0008;	// keep connections alive
export def SO_DONTROUTE: int = 0x0010;	// just use interface addresses
export def SO_BROADCAST: int = 0x0020;	// permit sending of broadcast msgs
export def SO_USELOOPBACK: int = 0x0040;// bypass hardware when possible
export def SO_LINGER: int = 0x0080;	// linger on close if data present
export def SO_OOBINLINE: int = 0x0100;	// leave received OOB data in line
export def SO_REUSEPORT: int = 0x0200;	// allow local address & port reuse
export def SO_TIMESTAMP: int = 0x0400;	// timestamp received dgram traffic
export def SO_NOSIGPIPE: int = 0x0800;	// no SIGPIPE from EPIPE
export def SO_ACCEPTFILTER: int = 0x1000;// there is an accept filter
export def SO_RERROR: int = 0x2000;	// Keep track of receive errors
export def SO_PASSCRED: int = 0x4000;	// receive credentials
export def SO_SNDBUF: int = 0x1001;	// send buffer size
export def SO_RCVBUF: int = 0x1002;	// receive buffer size
export def SO_SNDLOWAT: int = 0x1003;	// send low-water mark
export def SO_RCVLOWAT: int = 0x1004;	// receive low-water mark
export def SO_SNDTIMEO: int = 0x1005;	// send timeout
export def SO_RCVTIMEO: int = 0x1006;	// receive timeout
export def SO_ERROR: int = 0x1007;	// get error status and clear
export def SO_TYPE: int = 0x1008;	// get socket type
export def SO_SNDSPACE: int = 0x100a;	// get appr. send buffer free space
export def SO_USER_COOKIE: int = 0x1015;// user cookie
export def SO_CPUHINT: int = 0x1030;	// get socket's owner cpuid hint

//
// Level number for (get/set)sockopt() to apply to socket itself.
//

export def SOL_SOCKET: int = 0xffff;	// options for socket level
