load("../DCaseCloud_glue.k");

Import("cstyle.file");
Import("cstyle");
Import("JavaScript.Regexp");
Import("JavaScript.String");
Import("Java.String");
Import("MiniKonoha.Map");

int getId(Json json){
	int i = 0;
	while(i < json.getSize()) {
		if(/ネットワークに障害要因(Fault)がない/.test(json[i].getString("description"))) {
			return json[i].getString("argument_id").toint();
		}
		i = i + 1;
	}
	return -1; //FIXME error handling
}

Json parseResult(String DiagResult) {
	FILE result = new FILE(DiagResult, "r");

	String Diagscript;
	String evidence_flag;
	String parse;
	String[] parsed;
	Json array_json = Json.parse("[]");

	while ((parse = result.readLine()) != null) {
		parsed = parse.split(/ +/);
		if (parsed.getLength() > 1) {
			Json json = new Json();

			evidence_flag = (parsed.get(parsed.getLength() - 1));
			Diagscript = parsed.get(parsed.getLength() - 2);
			Diagscript = Diagscript.substring(1, Diagscript.indexOf(":"));

			json.setString("description", Diagscript);
			json.setBoolean("result", evidence_flag.equals("true"));
			array_json.add(json);
		}
	}
	return array_json;
}

void main() {

	API repo = new API("konoha","konoha");

	Json db_node = repo.Search(".ds","Evidence");

	Json evidence_result = parseResult(SCRIPT_ARGV.get(1));//give filename
//	System.p(evidence_result);

	int argument_id = getId(repo.GetArgumentIds());
	DCaseArgument argument = repo.GetArgument(argument_id);

	//Mapping
	int i = 0;
	Map[boolean] outmap = new Map[boolean]();
	while (i < evidence_result.getSize()) {
		outmap.set(evidence_result[i].getString("description"), evidence_result[i].getBoolean("result"));
		i = i + 1;
	}

//Update( From DB = evidence_result)
	i = 0;
	while (i < db_node.getSize()) {
		int db_argument_id = db_node[i].getString("argument_id").toint();
//Evidence node has the TopGoal's id(argument_id)
		if (db_argument_id == argument_id) {
			int node_id = db_node[i].getString("node_id").toint();
			DBNode node = argument.GetDBNode(node_id);
			db_node[i].setBoolean("isEvidence", outmap.get(db_node[i].getString("description")));
			repo.UpdateDBNode(argument_id, node, db_node[i]);
		}
		i = i + 1;
	}

//	System.p(db_node);
}
main();
