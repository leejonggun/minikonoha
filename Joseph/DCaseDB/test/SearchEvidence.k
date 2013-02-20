load("../DCaseCloud_glue.k");
Import("JavaScript.Regexp");
Import("Type.Json");

int getId(Json json){
	int i = 0;
	while(i < json.getSize()) {
//		if(/診断スクリプトが正常に動作する/.test(json[i].getString("description"))) {
		if(/ネットワークに障害要因(Fault)がない/.test(json[i].getString("description"))) {
			return json[i].getString("argument_id").toint();
		}
		i = i + 1;
	}
	return -1; //FIXME error handleing
}

void main() {

	API repo = new API("konoha","konoha");
	Json json = repo.Search(".ds","Evidence");
	int argument_id = getId(repo.GetArgumentIds());
	DCaseArgument argument = repo.GetArgument(argument_id);
	System.p(json);
}

main();
