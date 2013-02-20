load("../DCaseCloud_glue.k");


void main() {

	API repo = new API("konoha","konoha");
//	System.p(repo.Search("","Goal"));
	System.p(repo.Search(".ds","Evidence"));
	System.p(repo.Search(".ds","DScriptEvidence"));
}

main();
