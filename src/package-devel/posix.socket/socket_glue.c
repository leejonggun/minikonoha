/****************************************************************************
 * Copyright (c) 2012-2013, the Konoha project authors. All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ***************************************************************************/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define BUF 1024*8

#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <errno.h>
#include <signal.h>
#if defined(__NetBSD__)
#include <time.h>  //for 'struct timeval'
#endif

#if defined(__NetBSD__)
#include <sys/time.h>
#include <sys/select.h>
#endif //__NetBSD__

#include <konoha3/konoha.h>
#include <konoha3/sugar.h>
#include <konoha3/konoha_common.h>
#include <konoha3/import/methoddecl.h>

#ifdef __cplusplus
extern "C" {
#endif

#define WORD2INT(val) ((int)val)

typedef const struct _kSockAddr kSockAddr;
struct _kSockAddr {
	kObjectHeader h;
	struct sockaddr_in *sockaddr_in;
};

/* ------------------------------------------------------------------------ */
static void SockAddr_Init(KonohaContext *kctx, kObject *o, void *conf)
{
	struct _kSockAddr *sa = (struct _kSockAddr *)o;
	sa->sockaddr_in = (struct sockaddr_in *)KCalloc_UNTRACE(sizeof(struct sockaddr_in), 1);
}

static void SockAddr_Free(KonohaContext *kctx, kObject *o)
{
	struct _kSockAddr *sa = (struct _kSockAddr *)o;
	if(sa->sockaddr_in != NULL) {
		KFree(sa->sockaddr_in, sizeof(struct sockaddr_in));
		sa->sockaddr_in = NULL;
	}
}

/* ======================================================================== */
// [private functions]

// <String, int, int> => sockaddr_in*
void toSockaddr(struct sockaddr_in *addr, const char *ip, const int port, const int family)
{
	memset(addr, 0, sizeof(*addr));
	addr->sin_addr.s_addr = (*ip==0) ? 0 : inet_addr(ip);
	addr->sin_port        = htons(port);
	addr->sin_family      = family;
}

// sockaddr_in* => Map
//void fromSockaddr(KonohaContext *kctx, struct kMap* info, struct sockaddr_in addr)
//{
//	if(info != NULL) {
//		knh_DataMap_SetString(kctx, info, "addr", inet_ntoa(addr.sin_Addr));
//		knh_DataMap_SetInt(kctx, info, "port", ntohs(addr.sin_port));
//		knh_DataMap_SetInt(kctx, info, "family", addr.sin_family);
//	}
//}

//// for select :: kArray* => fd_set*
//static fd_set *toFd(fd_set* s, kArray *a )
//{
//	if(s == NULL || kArray_size(a) <= 0) {
//		return NULL;
//	}
//	FD_ZERO(s);
//	size_t indx;
//	int fd;
//	for(indx = 0; indx < kArray_size(a); indx++) {
//		fd = WORD2INT(a->kintItems[indx]);
//		if((fd >= 0) && (fd < FD_SETSIZE)) {
//			FD_SET(fd, s);
//		}
//	}
//	return s;
//}

//// for select :: fd_set* => kArray*
//static void fromFd(KonohaContext *kctx, fd_set *s, kArray *a)
//{
//	if(s != NULL && kArray_size(a) > 0) {
//		size_t indx;
//		for(indx = 0; indx < kArray_size(a); indx++) {
//			if(!FD_ISSET(WORD2INT(a->kintItems[indx]), s)) {
////				kArray_Remove(a, indx);
//			}
//		}
//	}
//}

//// for select
//static int getArrayMax(kArray *a)
//{
//	int ret = -1;
//	if(kArray_size(a) > 0) {
//		size_t cnt;
//		int fd;
//		for(cnt = 0; cnt < kArray_size(a); cnt++) {
//			if((fd = WORD2INT(a->kintItems[cnt])) > ret) {
//				ret = fd;
//			}
//		}
//	}
//	return ret;
//}

// for select
//static int getNfd(kArray *a1, kArray *a2, kArray *a3)
//{
//	int ret = -1;
//	int tmp;
//
//	if((tmp=getArrayMax(a1)) > ret) {
//		ret = tmp;
//	}
//	if((tmp=getArrayMax(a2)) > ret) {
//		ret = tmp;
//	}
//	if((tmp=getArrayMax(a3)) > ret) {
//		ret = tmp;
//	}
//	return ret;
//}

int Sys_Ex_Diagnosis(const char *dsthost) {
	//struct sock_ctx -> hostname, IP, Gateway IP, routing table, iptables settings
	int ret = 0;
//	FILE *fp, *output;
//	char buf[BUF], string[BUF] = "";
//	char diagcmd[BUF] = "sudo konoha /home/joseph/workspace/dscript-library/Diagnosis/DCase/Experiment.ds ";
//	char updatecmd[BUF] = "konoha /home/joseph/workspace/TRY/DCaseDB/test/UpdateEvidence.k ";
//	const char *result_filename = "/home/joseph/workspace/TRY/DCaseDB/test/output.txt";
//	strcat(diagcmd, dsthost);
//	fprintf(stderr, "\"%s\"\n", diagcmd);
//
//	if ((output = fopen("/home/joseph/workspace/TRY/DCaseDB/test/output.txt", "w")) == NULL) {
//		fprintf(stderr, "can't open file \"output.txt\"\n", output);
//		return -1;
//	}
//
//	if ((fp = popen(diagcmd, "r")) == NULL) {
//		fprintf(stderr, "can't exec \"%s\"\n", diagcmd);
//		return -1;
//	}
//
//	while(fgets(buf, BUF, fp) != NULL) {
//		(void) fputs(buf, output);
//		strcat(string, buf);
//	}
//	(void) pclose(fp);
//	(void) fclose(output);
//	fprintf(stdout, "%s\n", string);
//	if (strstr(string, "false") > 0) {
//		ret = SystemFault;
//	}/* else {
//		ret = ExternalFault;
//	}*/
//	fprintf(stderr, "before exec update\n");
//	strcat(updatecmd, result_filename);
//	fprintf(stdout,"%s\n",updatecmd);
//	if (system(updatecmd) == -1) {
//		fprintf(stderr, "UpdateEvidence.k can't execute.\n");
//	}
//	fprintf(stderr, "Finished.\n");
	return ret;
}

int diagnosis_detail(char *host, int Guessed_UserFault, int Guessed_SoftwareFault, int Guessed_SystemFault, int Guessed_ExternalFault) {
	int user_fault = Guessed_UserFault;
	int software_fault = Guessed_SoftwareFault;
	int ret = Guessed_SystemFault | Guessed_ExternalFault;

	fprintf(stderr, "user_fault = %d, software_fault = %d, system_fault = %d, external_fault = %d\n", user_fault, software_fault, Guessed_SystemFault, Guessed_ExternalFault);
	if ((!user_fault) && (software_fault)) {
		software_fault = SoftwareFault;//How to check given by user or given by programmer statically.
	} else {
		software_fault = 0;
	}
	if (Guessed_ExternalFault || Guessed_SystemFault) {
		if ((ret = Sys_Ex_Diagnosis(host)) == -1) {//Run Network Diagnosis Script & inform the fault.
			fprintf(stderr, "Something's wrong.");
			return -1;
		}
	}
	return user_fault | software_fault | ret;
}

static int diagnosisSocketFaultType(KonohaContext *kctx, char *Host, int err, int Guessed_UserFault)
{
	switch(err) {
		case 0:      //Success
			return 0;
		case EPERM:  /* 1. The user tried to connect to a broadcast address without having the socket broadcast flag enabled. Firewall rules forbid connection. */	//for connect, accept
			return SoftwareFault|SystemFault;

		case ENOENT: /* 2. No such file or directory */	//for bind
			return Guessed_UserFault|SoftwareFault;
		case EBADF:  /* 9. Bad file number */	//for bind, listen, connect, accept
			return SoftwareFault;

		case EINTR: /* 4. The system call was interrupted by a signal that was caught before a valid connection arrived */	//for connect, accept
			return Guessed_UserFault|SoftwareFault;
//			break;
		case EAGAIN: /* 11. No more free local ports or insufficient entries in the routhing cache. */	//for, connect, accept
			return SoftwareFault|SystemFault;

		case ENOMEM: /* 12. Insufficient memory is available */	//for socket, bind, accept
			return SystemFault;

		case EACCES: /* 13. Permission denied and/or protocol is denied, the connection failed because of a local firewall rule*/	//for socket, bind, connect

			return Guessed_UserFault|SystemFault;

		case EFAULT: /* 14 The addr argument is not writalbe */	//for bind, connect, accept
			return SoftwareFault/*|SystemFault TODO:Stack size depends on the architecture of a PC.スタックにアローケートされている場合,かつスタックオーバーフロー*/;

		case ENOTDIR: /*20 Not a directory */	//for bind
		case EINVAL: /* 22 Unknown protocol, addrlen is invalid, or the socket was not in the AF_UNIX family */	//for socket, bind
			return diagnosis_detail(Host, Guessed_UserFault, SoftwareFault, 0, 0);
//			return Guessed_UserFault|SoftwareFault;

		case ENFILE:  /* 23. File table overflow */	//for socket, accept
		case EMFILE: /* 24. Too many open files */	//for socket, accept
			return SystemFault;
		case EROFS:  /* 30 The socket inode would reside on a read-only file system */	//for bind
			return SystemFault;

		case ENAMETOOLONG:  /* 36 File name too long */	//for bind
			return Guessed_UserFault|SoftwareFault;
		case ELOOP: /* 40 Too many symbolic links encountered */	//for bind
			return Guessed_UserFault|SoftwareFault;

		case ENOTSOCK: /* The file descriptor is not associated with a socket */	//for bind, listen, connect, accept
			return SoftwareFault;
		case EPROTONOSUPPORT: /* 88 Protocol not supported */	//for socket
			/*insert a function for increasing the accuracy*/
			/*サポートするプロトコルが何か(どうやって?)、指定されたプロトコルが何か比較する*/
			return Guessed_UserFault|SoftwareFault;
		case EPROTO:   /* 92 Protocol error */	//for accept
			return SoftwareFault;

		case ESOCKTNOSUPPORT: /* 94 Socket type not supported */
		case EOPNOTSUPP:   /* 95 The referenced socket type is not SOCK_STREAM, Not supported the socket type*/	//for listen, accept
		case EAFNOSUPPORT: /* 97 Address family not supported by protocol */	//for socket, connect
			return SoftwareFault;
		case EADDRINUSE:   /* 98 Address already in use */	//for bind, listen, connect
			return SoftwareFault;
		case EADDRNOTAVAIL: /* 99 Cannot assign requested address */	//for bind
			return SoftwareFault;
		case ENETUNREACH: /* 101 Network is unreachable */	//for connect
			return diagnosis_detail(Host, 0, SoftwareFault, SystemFault, 0);
			/*pingを飛ばすではなく、pingの挙動を理解してその返り値で判定する*/
//			return SystemFault;
		case ECONNABORTED: /* 103 A connection has been aborted */	//for accept
			return SoftwareFault;

		case ENOBUFS:   /* 105 Insufficient buffer space available */	//for socket, accept
			return SystemFault;

		case EISCONN:   /* 106 The socket is already connected */	//for connect
			return Guessed_UserFault;
		case ETIMEDOUT: /* 110 Connection timed out while attempting connection. The server may be too busy*/	//for connect
			return diagnosis_detail(Host, Guessed_UserFault, SoftwareFault, SystemFault, ExternalFault);
//			return SoftwareFault|SystemFault|ExternalFault;
		case ECONNREFUSED: /* 111 No-one listening on the remote address*/	//for connect
			return diagnosis_detail(Host, Guessed_UserFault, SoftwareFault, 0, ExternalFault);
			//return ExternalFault;
		case EHOSTUNREACH: /* 113 No route to host */	//for connect, but man doesn't have this.
			return diagnosis_detail(Host, Guessed_UserFault, SoftwareFault, 0, ExternalFault);
			//return Guessed_UserFault|SoftwareFault|ExternalFault;

		case EALREADY: /* 114 The socket is nonblocking and a previous connection attempt has not yet been completed.*/	//for connect
			return Guessed_UserFault;
		case EINPROGRESS: /* 115 The socket is nonblocking and the connection cannot be completed immediately. */	//for, connect
			return SoftwareFault;
		default:
			break;
	}
	fprintf(stderr, "");
	return Guessed_UserFault | SystemFault| SoftwareFault | ExternalFault;
}

/* ======================================================================== */
// [KMETHODS]

//## int System.accept(int socket, Map remoteInfo);
//KMETHOD System_accept(KonohaContext *kctx, KonohaStack* sfp)
//{
//	struct sockaddr_in addr;
//	int addrLen = sizeof(addr);
//	memset(&addr, 0, addrLen);
//
//	int ret = accept(
//			WORD2INT(sfp[1].intValue),
//			(struct sockaddr *)&addr,
//			(socklen_t *)&addrLen
//	);
//	if(ret >= 0) {
//		 fromSockaddr(kctx, sfp[2].m, addr);
//	} else {
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "accept"),
//				LogUint("errno", errno),
//				LogText("errstr", strerror(errno))
//		);
//	}
//	KReturnUnboxValue(ret);
//}

//## int System.accept(int socket, SockAddr remoteInfo);
KMETHOD System_accept(KonohaContext *kctx, KonohaStack* sfp)
{
	struct _kSockAddr *sa = (struct _kSockAddr *)sfp[2].asObject;
	struct sockaddr_in *addr = sa->sockaddr_in;
	int addrLen = sizeof(struct sockaddr_in);

	int ret = accept(
			WORD2INT(sfp[1].intValue),
			(struct sockaddr *)addr,
			(socklen_t *)&addrLen
	);
	if(ret >= 0) {
		//fromSockaddr(kctx, sa, addr);
	}
	else {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "accept:errno = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, "NotGiven", errno, 0);
		KTraceErrorPoint(trace, fault, "accept",
			LogUint("socket", WORD2INT(sfp[1].intValue)),
			LogText("SockAddr", (struct sockaddr *)addr),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "accept"),
//				LogUint("errno", errno),
//				LogText("errstr", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## int System.bind(int socket, String srcIP, int srcPort, int family);
KMETHOD System_bind(KonohaContext *kctx, KonohaStack* sfp)
{
	struct sockaddr_in addr;

	kString *srcIP = sfp[2].asString;
	toSockaddr(&addr,
			kString_text(srcIP),
			WORD2INT(sfp[3].intValue),
			WORD2INT(sfp[4].intValue)
	);
	int ret = bind(WORD2INT(sfp[1].intValue),
			(struct sockaddr *)&addr,
			sizeof(addr)
	);
	if(ret != 0) {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "bind:errno = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, kString_text(srcIP), errno, kString_GuessUserFault(srcIP));
		KTraceErrorPoint(trace, fault, "bind",
			LogUint("socket", WORD2INT(sfp[1].intValue)),
			LogText("srcIP", kString_text(sfp[2].asString)),
			LogUint("srcPort", WORD2INT(sfp[3].intValue)),
			LogUint("family", WORD2INT(sfp[4].intValue)),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//			LogText("@", "bind"),
//			LogUint("errno", errno),
//			LogText("errstr", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## int System.close(int fd);
KMETHOD System_close(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = close(WORD2INT(sfp[1].intValue));

	if(ret != 0) {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
			LogText("@", "close"),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno))
		);
	}
	KReturnUnboxValue(ret);
}

//## int System.connect(int socket, String dstIP, int dstPort, int family);
KMETHOD System_connect(KonohaContext *kctx, KonohaStack* sfp)
{
	struct sockaddr_in addr;

	kString *dstIP = sfp[2].asString;
	toSockaddr(&addr,
				kString_text(dstIP),
				WORD2INT(sfp[3].intValue),
				WORD2INT(sfp[4].intValue)
	);

	int ret = connect(WORD2INT(sfp[1].intValue),
			(struct sockaddr *)&addr,
			sizeof(addr)
	);
	if(ret != 0) {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "errno in connect = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, kString_text(dstIP), errno, kString_GuessUserFault(dstIP));
		KTraceErrorPoint(trace, fault, "connect",
			LogUint("socket", WORD2INT(sfp[1].intValue)),
			LogText("dstIP", kString_text(sfp[2].asString)),
			LogUint("dstPort", WORD2INT(sfp[3].intValue)),
			LogUint("family", WORD2INT(sfp[4].intValue)),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//			LogText("@", "connect"),
//			LogUint("errno", errno),
//			LogText("errstr", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## int System.listen(int socket, int backlog);
KMETHOD System_listen(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = listen(WORD2INT(sfp[1].intValue), WORD2INT(sfp[2].intValue));
	if(ret != 0) {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "listen:errno = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, "NotGiven", errno, 0);
		KTraceErrorPoint(trace, fault, "listen",
			LogUint("socket", WORD2INT(sfp[1].intValue)),
			LogUint("backlog", WORD2INT(sfp[2].intValue)),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//			LogText("@", "listen"),
//			LogUint("errno", errno),
//			LogText("errstr", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## String System.getsockname(int socket);
//KMETHOD System_getsockname(KonohaContext *kctx, KonohaStack *sfp)
//{
//	struct sockaddr_in addr;
//	int addrLen = sizeof(addr);
//	memset(&addr, 0, addrLen);
//
//	kMap *ret_s = KNH_TNULL(Map);
//	if(getsockname(WORD2INT(sfp[1].intValue),
//					   (struct sockaddr *)&addr,
//					   (socklen_t *)&addrLen ) == 0) {
//		ret_s = new_DataMap(ctx);
//		fromSockaddr(kctx, ret_s, addr);
//	} else {
//		KNH_NTRACE2(kctx, "konoha.socket.name ", K_PERROR, KNH_LDATA0);
//	}
//	KReturn(ret_s);
//}

//## int System.getsockopt(int socket, int option);
KMETHOD System_getsockopt(KonohaContext *kctx, KonohaStack* sfp)
{
	int val;
	int valLen = sizeof(val);

	int ret = getsockopt(
			WORD2INT(sfp[1].intValue),
			SOL_SOCKET,
			(int)sfp[2].intValue,
			&val,
			(socklen_t *)&valLen
	);
	if(ret == 0) {
		ret = val;
	}
	else {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
			LogText("@", "getsockopt"),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno))
		);
	}
	KReturnUnboxValue(ret);
}

//## int System.setsockopt(int socket, int option, int value);
KMETHOD System_Setsockopt(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = setsockopt(
			WORD2INT(sfp[1].intValue),
			SOL_SOCKET,
			(int)sfp[2].intValue,
			&sfp[3].intValue,
			sizeof(sfp[3].intValue)
	);
	if(ret != 0) {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
			LogText("@", "setsockopt"),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno))
		);
	}
	KReturnUnboxValue(ret);
}

//## Map System.getpeername(int socket);
//KMETHOD System_getpeername(KonohaContext *kctx, KonohaStack* sfp)
//{
//	struct sockaddr_in addr;
//	int addrLen = sizeof(addr);
//	memset(&addr, 0, addrLen);
//
//	kMap *ret_s = KNH_TNULL(Map);
//	if(getpeername(WORD2INT(sfp[1].intValue),
//					   (struct sockaddr *)&addr,
//					   (socklen_t *)&addrLen ) == 0) {
//		ret_s = new_DataMap(ctx);
//		fromSockaddr(kctx, ret_s, addr);
//	} else {
//		KNH_NTRACE2(kctx, "konoha.socket.peername ", K_PERROR, KNH_LDATA0);
//	}
//
//	KReturn(ret_s);
//}

////## int System.recv(int socket, byte[] buffer, int flags);
//static KMETHOD System_recv(KonohaContext *kctx, KonohaStack* sfp)
//{
//	kBytes *ba  = sfp[2].asBytes;
//	int ret = recv(WORD2INT(sfp[1].intValue),
//					  ba->buf,
//					  ba->bytesize,
//					  (int)sfp[3].intValue);
//	if(ret < 0) {
//		KMakeTrace(trace, sfp);
//		fprintf(stderr, "errno in recv = %d, err = %s\n", errno, strerror(errno));//Joseph
//		int fault = diagnosisSocketFaultType(kctx, "NotGiven", errno, 0);
//		KTraceErrorPoint(trace, fault, "recv",
//			LogUint("socket", WORD2INT(sfp[1].intValue)),
//			LogText("buffer", kString_text(sfp[2].asString)),
//			LogUint("flags", WORD2INT(sfp[3].intValue)),
//			LogUint("errno", errno),
//			LogText("errstr", strerror(errno)),
//			LogErrno);
//		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
////		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
////				LogText("@", "recv"),
////				LogText("perror", strerror(errno))
////		);
//	}
//	KReturnUnboxValue(ret);
//}

////## int System.recv(int socket, String msgfrom, int flags);
static KMETHOD System_recv(KonohaContext *kctx, KonohaStack* sfp)
{
	kString *msgfrom  = sfp[2].asString;
	int ret = recv(WORD2INT(sfp[1].intValue),
					  kString_text(msgfrom),
					  kString_size(msgfrom),
					  (int)sfp[3].intValue);
	if(ret < 0) {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "errno in recv = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, "NotGiven", errno, 0);
		KTraceErrorPoint(trace, fault, "recv",
			LogUint("socket", WORD2INT(sfp[1].intValue)),
			LogText("buffer", kString_text(sfp[2].asString)),
			LogUint("flags", WORD2INT(sfp[3].intValue)),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "recv"),
//				LogText("perror", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## int System.recvfrom(int socket, byte[] buffer, int flags, Map remoteInfo);
//static KMETHOD System_recvfrom(KonohaContext *kctx, KonohaStack* sfp)
//{
//	struct sockaddr_in addr;
//	int addrLen = sizeof(addr);
//	memset(&addr, 0, addrLen);
//
//	kBytes *ba  = sfp[2].asBytes;
//	int ret = recvfrom(WORD2INT(sfp[1].intValue),
//			  	  	  	   ba->buf,
//			  	  	  	   ba->bytesize,
//			  	  	  	   (int)sfp[3].intValue,
//			  	  	  	   (struct sockaddr *)&addr,
//			  	  	  	   (socklen_t *)&addrLen);
//	if(ret >= 0) {
//		fromSockaddr(kctx, sfp[4].m, addr);
//	} else {
//		KNH_NTRACE2(kctx, "konoha.socket.recvfrom ", K_PERROR, KNH_LDATA0);
//	}
//	KReturnUnboxValue(ret);
//}

////## int System.select(int[] readsock, int[] writesock, int[] exceptsock, long timeoutSec, long timeoutUSec);
//static KMETHOD System_Select(KonohaContext *kctx, KonohaStack* sfp)
//{
//	kArray *a1 = sfp[1].asArray;
//	kArray *a2 = sfp[2].asArray;
//	kArray *a3 = sfp[3].asArray;
//	int nfd = getNfd(a1, a2, a3);
//
//	fd_set rfds, wfds, efds;
//	fd_set *rfd = toFd(&rfds, a1);
//	fd_set *wfd = toFd(&wfds, a2);
//	fd_set *efd = toFd(&efds, a3);
//
//	struct timeval tv;
//	tv.tv_sec  = (long)sfp[4].intValue;
//	tv.tv_usec = (long)sfp[5].intValue;
//
//	int ret = select(nfd+1, rfd, wfd, efd, &tv);
//	if(ret > 0) {
//		fromFd(kctx, rfd, a1);
//		fromFd(kctx, wfd, a2);
//		fromFd(kctx, efd, a3);
//	}
//	else {
//		if(ret < 0) {
//			OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//					LogText("@", "select"),
//					LogText("perror", strerror(errno))
//			);
//		}
//		// TODO::error or timeout is socket list all clear [pending]
//		KLIB kArray_Clear(kctx, a1, 0);
//		KLIB kArray_Clear(kctx, a2, 0);
//		KLIB kArray_Clear(kctx, a3, 0);
//	}
//	KReturnUnboxValue(ret);
//}
//
////## int System.send(int socket, byte[] message, int flags);
//static KMETHOD System_send(KonohaContext *kctx, KonohaStack* sfp)
//{
//	kBytes *ba = sfp[2].asBytes;
//	// Broken Pipe Signal Mask
//#if defined(__linux__)
//	__sighandler_t oldset = signal(SIGPIPE, SIG_IGN);
//	__sighandler_t ret_signal = SIG_ERR;
//#elif defined(__APPLE__) || defined(__NetBSD__)
//	sig_t oldset = signal(SIGPIPE, SIG_IGN);
//	sig_t ret_signal = SIG_ERR;
//#endif
//	if(oldset == SIG_ERR) {
//		OLDTRACE_SWITCH_TO_KTrace(_UserFault,
//				LogText("@", "signal"),
//				LogText("perror", strerror(errno))
//		);
//	}
//	int ret = send(WORD2INT(sfp[1].intValue),
//					  ba->buf,
//					  ba->bytesize,
//					  (int)sfp[3].intValue);
//	if(ret < 0) {
//		OLDTRACE_SWITCH_TO_KTrace(_UserFault,
//				LogText("@", "send"),
//				LogText("perror", strerror(errno))
//		);
//	}
//	if(oldset != SIG_ERR) {
//		ret_signal = signal(SIGPIPE, oldset);
//		if(ret_signal == SIG_ERR) {
//			OLDTRACE_SWITCH_TO_KTrace(_UserFault,
//					LogText("@", "signal"),
//					LogText("perror", strerror(errno))
//			);
//		}
//	}
//	KReturnUnboxValue(ret);
//}
//
//## int System.sendto(int socket, Bytes message, int flags, String dstIP, int dstPort, int family);
//static KMETHOD System_sendto(KonohaContext *kctx, KonohaStack* sfp)
//{
//	kBytes *ba = sfp[2].asBytes;
//	struct sockaddr_in addr;
//	kString* s = sfp[4].asString;
//	toSockaddr(&addr, kString_text(s), WORD2INT(sfp[5].intValue), WORD2INT(sfp[6].intValue));
//	// Broken Pipe Signal Mask
//#if defined(__linux__)
//	__sighandler_t oldset = signal(SIGPIPE, SIG_IGN);
//	__sighandler_t ret_signal = SIG_ERR;
//#elif defined(__APPLE__) || defined(__NetBSD__)
//	sig_t oldset = signal(SIGPIPE, SIG_IGN);
//	sig_t ret_signal = SIG_ERR;
//#endif
//	int ret = sendto(
//			WORD2INT(sfp[1].intValue),
//			ba->buf,
//			ba->bytesize,
//			(int)sfp[3].intValue,
//			(struct sockaddr *)&addr,
//			sizeof(struct sockaddr)
//	);
//	if(ret < 0) {
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "sendto"),
//				LogUint("errno", errno),
//				LogText("errstr", strerror(errno))
//		);
//	}
//	if(oldset != SIG_ERR) {
//		ret_signal = signal(SIGPIPE, oldset);
//		if(ret_signal == SIG_ERR) {
//			OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "signal"),
//				LogUint("errno", errno),
//				LogText("errstr", strerror(errno))
//			);
//		}
//	}
//	KReturnUnboxValue(ret);
//}

//## int System.sendto(int socket, String message, int flags, String dstIP, int dstPort, int family);
static KMETHOD System_sendto(KonohaContext *kctx, KonohaStack* sfp)
{
	kString* msg = sfp[2].asString;
	struct sockaddr_in addr;
	kString* s = sfp[4].asString;
	toSockaddr(&addr, kString_text(s), WORD2INT(sfp[5].intValue), WORD2INT(sfp[6].intValue));
	// Broken Pipe Signal Mask
#if defined(__linux__)
	__sighandler_t oldset = signal(SIGPIPE, SIG_IGN);
	__sighandler_t ret_signal = SIG_ERR;
#elif defined(__APPLE__) || defined(__NetBSD__)
	sig_t oldset = signal(SIGPIPE, SIG_IGN);
	sig_t ret_signal = SIG_ERR;
#endif
	int ret = sendto(
			WORD2INT(sfp[1].intValue),
			kString_text(msg),
			kString_size(msg),
			(int)sfp[3].intValue,
			(struct sockaddr *)&addr,
			sizeof(struct sockaddr)
	);
	if(ret < 0) {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
				LogText("@", "sendto"),
				LogUint("errno", errno),
				LogText("errstr", strerror(errno))
		);
	}
	if(oldset != SIG_ERR) {
		ret_signal = signal(SIGPIPE, oldset);
		if(ret_signal == SIG_ERR) {
			OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
				LogText("@", "signal"),
				LogUint("errno", errno),
				LogText("errstr", strerror(errno))
			);
		}
	}
	KReturnUnboxValue(ret);
}

//## int System.shutdown(int socket, int how);
KMETHOD System_shutdown(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = shutdown(WORD2INT(sfp[1].intValue), WORD2INT(sfp[2].intValue));
	if(ret != 0) {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
			LogText("@", "shutdown"),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno))
		);
	}
	KReturnUnboxValue(ret);
}

//## int System.sockatmark(int socket);
KMETHOD System_sockatmark(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = sockatmark(WORD2INT(sfp[1].intValue));
	if(ret < 0) {
		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
			LogText("@", "sockadmark"),
			LogUint("errno", errno),
			LogText("errstr", strerror(errno))
		);
	}
	KReturnUnboxValue(ret);
}

//## int System.socket(int family, int type, int protocol);
KMETHOD System_socket(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = socket(WORD2INT(sfp[1].intValue),
					WORD2INT(sfp[2].intValue),
					WORD2INT(sfp[3].intValue));
	if(ret < 0) {
		KMakeTrace(trace, sfp);
		fprintf(stderr, "socket:errno = %d, err = %s\n", errno, strerror(errno));//Joseph
		int fault = diagnosisSocketFaultType(kctx, "NotGiven", errno, 0);
		KTraceErrorPoint(trace, fault, "socket",
			LogUint("family", WORD2INT(sfp[1].intValue)),
			LogUint("type", WORD2INT(sfp[2].intValue)),
			LogUint("protocol", WORD2INT(sfp[3].intValue)),
			LogErrno);
		KLIB KRuntime_raise(kctx, KException_("IO"), fault, NULL, trace->baseStack);
//		OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
//				LogText("@", "socket"),
//				LogUint("errno", errno),
//				LogText("errstr", strerror(errno))
//		);
	}
	KReturnUnboxValue(ret);
}

//## int System.socketpair(int family, int type, int protocol, int[] pairCSock);
static KMETHOD System_socketpair(KonohaContext *kctx, KonohaStack* sfp)
{
	int ret = -2;
	kArray *a = sfp[4].asArray;
	if(kArray_size(a)) {
		int pairFd[2];
		if((ret = socketpair(WORD2INT(sfp[1].intValue),
				WORD2INT(sfp[2].intValue),
				WORD2INT(sfp[3].intValue),
				pairFd)) == 0) {
			a->kintItems[0] = pairFd[0];
			a->kintItems[1] = pairFd[1];
		}
		else {
			OLDTRACE_SWITCH_TO_KTrace(_SystemFault,
					LogText("@", "socketpair"),
					LogUint("errno", errno),
					LogText("errstr", strerror(errno))
			);
		}
	}
	KReturnUnboxValue(ret);
}


// --------------------------------------------------------------------------

static KMETHOD SockAddr_new (KonohaContext *kctx, KonohaStack *sfp)
{
	KReturn(KLIB new_kObject(kctx, OnStack, KGetReturnType(sfp), 0));
}

// --------------------------------------------------------------------------

#define KType_SockAddr         cSockAddr->typeId

#define KDefineConstInt(T) #T, KType_Int, T

static kbool_t socket_PackupNameSpace(KonohaContext *kctx, kNameSpace *ns, int option, KTraceInfo *trace)
{
	KDEFINE_CLASS defSockAddr = {
		STRUCTNAME(SockAddr),
		.cflag = KClassFlag_Final,
		.init = SockAddr_Init,
		.free = SockAddr_Free,
	};
	KClass *cSockAddr = KLIB kNameSpace_DefineClass(kctx, ns, NULL, &defSockAddr, trace);
	kparamtype_t pi = {KType_Int, KFieldName_("intValue")};
	KClass *KClass_IntArray = KLIB KClass_Generics(kctx, KClass_Array, KType_Int, 1, &pi);
	ktypeattr_t KType_IntArray = KClass_IntArray->typeId;

	KDEFINE_METHOD MethodData[] = {
		_Public|_Static|_Const|_Im, _F(System_accept), KType_Int, KType_System, KMethodName_("accept"), 2, KType_Int, KFieldName_("fd"), KType_SockAddr, KFieldName_("sockaddr"),
		_Public|_Static|_Const|_Im, _F(System_bind), KType_Int, KType_System, KMethodName_("bind"), 4, KType_Int, KFieldName_("fd"), KType_String, KFieldName_("srcIP"), KType_Int, KFieldName_("srcPort"), KType_Int, KFieldName_("family"),
		_Public|_Static|_Const|_Im, _F(System_close), KType_Int, KType_System, KMethodName_("close"), 1, KType_Int, KFieldName_("fd"),
		_Public|_Static|_Const|_Im, _F(System_connect), KType_Int, KType_System, KMethodName_("connect"), 4, KType_Int, KFieldName_("fd"), KType_String, KFieldName_("dstIP"), KType_Int, KFieldName_("dstPort"), KType_Int, KFieldName_("family"),
		_Public|_Static|_Const|_Im, _F(System_listen), KType_Int, KType_System, KMethodName_("listen"), 2, KType_Int, KFieldName_("fd"), KType_Int, KFieldName_("backlog"),
//		_Public|_Static|_Const|_Im, _F(System_getsockname), KType_Map KType_System, KMethodName_("getsockname"),1, KType_Int, KFieldName_("fd"),
		_Public|_Static|_Const|_Im, _F(System_getsockopt), KType_Int, KType_System, KMethodName_("getsockopt"), 2, KType_Int, KFieldName_("fd"), KType_Int, KFieldName_("opt"),
		_Public|_Static|_Const|_Im, _F(System_Setsockopt), KType_Int, KType_System, KMethodName_("setsockopt"), 3, KType_Int, KFieldName_("fd"), KType_Int, KFieldName_("opt"), KType_Int, KFieldName_("value"),
//		_Public|_Static|_Const|_Im, _F(System_getpeername), KType_Map, KType_System, KMethodName_("getpeername"), 1, KType_Int, KFieldName_("fd"),
//		_Public|_Static, _F(System_Select), KType_Int, KType_System, KMethodName_("select"), 5, KType_IntArray, KFieldName_("readsocks"), KType_IntArray, KFieldName_("writesocks"), KType_IntArray, KFieldName_("exceptsocks"), KType_Int, KFieldName_("timeoutSec"), KType_Int, KFieldName_("timeoutUSec"),
		_Public|_Static|_Const|_Im, _F(System_shutdown), KType_Int, KType_System, KMethodName_("shutdown"), 2, KType_Int, KFieldName_("fd"), KType_Int, KFieldName_("how"),
		_Public|_Static|_Const|_Im, _F(System_sockatmark), KType_Int, KType_System, KMethodName_("sockatmark"), 1, KType_Int, KFieldName_("fd"),
		_Public|_Static|_Const|_Im, _F(System_socket), KType_Int, KType_System, KMethodName_("socket"), 3, KType_Int, KFieldName_("family"), KType_Int, KFieldName_("type"), KType_Int, KFieldName_("protocol"),
		_Public|_Static|_Const|_Im, _F(System_socketpair), KType_Int, KType_System, KMethodName_("socketpair"), 4, KType_Int, KFieldName_("family"), KType_Int, KFieldName_("type"), KType_Int, KFieldName_("protocol"), KType_IntArray, KFieldName_("pairsock"),
		_Public|_Const|_Im, _F(SockAddr_new), KType_SockAddr, KType_SockAddr, KMethodName_("new"), 0,
//rebind sendto, recv
		_Public|_Static|_Const|_Im, _F(System_sendto), KType_Int, KType_System, KMethodName_("sendto"), 6, KType_Int, KFieldName_("socket"), KType_String, KFieldName_("msg"), KType_Int, KFieldName_("flag"), KType_String, KFieldName_("dstIP"), KType_Int, KFieldName_("dstPort"), KType_Int, KFieldName_("family"),
		_Public|_Static|_Const|_Im, _F(System_recv), KType_Int, KType_System, KMethodName_("recv"), 3, KType_Int, KFieldName_("fd"), KType_String, KFieldName_("buf"), KType_Int, KFieldName_("flags"),
		// the function below uses Bytes
		// FIXME
//		_Public|_Static|_Const|_Im, _F(System_sendto), KType_Int, KType_System, KMethodName_("sendto"), 6, KType_Int, KFieldName_("socket"), KType_Bytes, KFieldName_("msg"), KType_Int, KFieldName_("flag"), KType_String, KFieldName_("dstIP"), KType_Int, KFieldName_("dstPort"), KType_Int, KFieldName_("family"),
//		_Public|_Static|_Const|_Im, _F(System_recv), KType_Int, KType_System, KMethodName_("recv"), 3, KType_Int, KFieldName_("fd"), KType_Bytes, KFieldName_("buf"), KType_Int, KFieldName_("flags"),
//		_Public|_Static|_Const|_Im, _F(System_recvfrom), KType_Int, KType_System, KMethodName_("recvfrom"), 4, KType_Int, FN_x, KType_Bytes, FN_y, KType_Int, FN_z, KType_Map, FN_v,
//		_Public|_Static|_Const|_Im, _F(System_send), KType_Int, KType_System, KMethodName_("send"), 3, KType_Int, KFieldName_("fd"), KType_Bytes, KFieldName_("msg"), KType_Int, KFieldName_("flags"),
		DEND,
	};
	KLIB kNameSpace_LoadMethodData(kctx, ns, MethodData, trace);
	KDEFINE_INT_CONST IntData[] = {
			{KDefineConstInt(PF_LOCAL)},
			{KDefineConstInt(PF_UNIX)},
			{KDefineConstInt(PF_INET)},
			{KDefineConstInt(PF_INET6)},
			{KDefineConstInt(PF_APPLETALK)},
#ifdef __linux___
			{KDefineConstInt(PF_PACKET)},
#endif
			{KDefineConstInt(AF_LOCAL)},
			{KDefineConstInt(AF_UNIX)},
			{KDefineConstInt(AF_INET)},
			{KDefineConstInt(AF_INET6)},
			{KDefineConstInt(AF_APPLETALK)},
#ifdef __linux___
			{KDefineConstInt(AF_PACKET)},
#endif
			// Types of sockets
			{KDefineConstInt(SOCK_STREAM)},
			{KDefineConstInt(SOCK_DGRAM)},
			{KDefineConstInt(SOCK_RAW)},
			{KDefineConstInt(SOCK_RDM)},
			// send & recv flags
			{KDefineConstInt(MSG_OOB)},
			{KDefineConstInt(MSG_PEEK)},
			{KDefineConstInt(MSG_DONTROUTE)},
			{KDefineConstInt(MSG_OOB)},
			{KDefineConstInt(MSG_TRUNC)},
			{KDefineConstInt(MSG_DONTWAIT)},
			{KDefineConstInt(MSG_EOR)},
			{KDefineConstInt(MSG_WAITALL)},
#ifdef	__linux__
			{KDefineConstInt(MSG_CONFIRM)},
			{KDefineConstInt(MSG_ERRQUEUE)},
			{KDefineConstInt(MSG_NOSIGNAL)},
			{KDefineConstInt(MSG_MORE)},
#endif
			// socket options
			{KDefineConstInt(SO_REUSEADDR)},
			{KDefineConstInt(SO_TYPE)},
			{KDefineConstInt(SO_ERROR)},
			{KDefineConstInt(SO_DONTROUTE)},
			{KDefineConstInt(SO_BROADCAST)},
			{KDefineConstInt(SO_SNDBUF)},
			{KDefineConstInt(SO_RCVBUF)},
			{KDefineConstInt(SO_KEEPALIVE)},
			{KDefineConstInt(SO_OOBINLINE)},
#ifdef	__linux__
			{KDefineConstInt(SO_NO_CHECK)},
			{KDefineConstInt(SO_PRIORITY)},
#endif
			{KDefineConstInt(SHUT_RD)},
			{KDefineConstInt(SHUT_WR)},
			{KDefineConstInt(SHUT_RDWR)},
			{KDefineConstInt(SOMAXCONN)},
			{KDefineConstInt(IPPROTO_ICMP)},
			{}
	};
	KLIB kNameSpace_LoadConstData(kctx, ns, KConst_(IntData), trace);
	return true;
}

static kbool_t socket_ExportNameSpace(KonohaContext *kctx, kNameSpace *ns, kNameSpace *exportNS, int option, KTraceInfo *trace)
{
	return true;
}

KDEFINE_PACKAGE *socket_Init(void)
{
	static KDEFINE_PACKAGE d = {
		KPACKNAME("posix", "1.0"),
		.PackupNameSpace    = socket_PackupNameSpace,
		.ExportNameSpace   = socket_ExportNameSpace,
	};
	return &d;
}

#ifdef __cplusplus
}
#endif
