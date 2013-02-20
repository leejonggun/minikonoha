Import("Deos.DCaseCloud");
Import("Type.Json");


void main() {

	API repo = new API("konoha","konoha");
//	Json Ids = repo.GetArgumentIds();
//	System.p(Ids);
//	System.p(Ids.get(1));
//	System.p(Ids.get(1).getString("argument_id"));
	DCaseArgument argument = repo.GetArgument(1);
	System.p(argument.toJson());
}

main();
