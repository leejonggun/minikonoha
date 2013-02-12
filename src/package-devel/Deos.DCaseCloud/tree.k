#!/usr/local/bin/minikonoha

Import("cstyle.file");
Import("Deos.DCaseCloud");


void main() {

	API repo = new API("dcasedb","dcasedb");

	stdout.println("Content-type: application/json; charset=UTF-8\n\n");
	stdout.println(repo.GetArgument(1).toJson());
}

main();
