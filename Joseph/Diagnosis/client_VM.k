//Wrtten by Joseph
/*
   This script is for connect() fault
   run etimedout_client.sh
   */
Import("posix.socket");
Import("cstyle");

void test() {
//	destination
	String dstIP = "192.168.122.179";
	System.p(dstIP);
	int dstPort = 10001;
	int dstFamily = AF_INET;
	int dstType = SOCK_STREAM;
	int dstOPT = 0;

//	socket socket(System.socket())
	int sockfd = System.socket(dstFamily, dstType, dstOPT);
	System.p(sockfd);

//	socket connect(System.connect())
	int ret = System.connect(sockfd, dstIP, dstPort, dstFamily);

	String msg = "Hello world!";
	System.p(msg);
		//rebind System.sendto() function
			ret = System.sendto(sockfd, msg, 0, dstIP, dstPort, dstFamily);
			System.p(ret);
			System.p("Sent a message\"Hello world!\" to server");
//	}
//	int ret = System.sendto(sockfd, dstIP, dstPort, dstFamily);
	System.close(sockfd);
}

test();
