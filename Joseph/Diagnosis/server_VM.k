//Wrtten by Joseph
/*
   This script is for connect() fault
   run etimedout_client.sh
   */
Import("posix.socket");

void test() {
//	destination
	String dstIP = "192.168.122.179";
	System.p(dstIP);
	int srcPort = 10001;
	int srcFamily = AF_INET;
	int srcType = SOCK_STREAM;
	int srcOPT = 0;

	int dstPort = 10002;
	int dstFamily = AF_INET;
	int dstType = SOCK_STREAM;
	int dstOPT = 0;

	String msgfrom = "";
	SockAddr remoteInfo = new SockAddr();

//	socket socket(System.socket())
	int sockfd = System.socket(dstFamily, dstType, dstOPT);
	System.p(sockfd);

//	socket bind(System.bind())
	int ret = System.bind(sockfd, dstIP, dstPort, dstFamily);

//	socket listen(System.listen())
	ret = System.listen(sockfd, SOMAXCONN);

//	while (true) {
		System.p("Preparing to accept...");
		ret = System.accept(sockfd, remoteInfo);

		ret = System.recv(sockfd, msgfrom, 0);
		System.p(ret);
//	}
		System.p(msgfrom);
	System.close(sockfd);
}

test();
