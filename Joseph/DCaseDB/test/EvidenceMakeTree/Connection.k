Load("../DCaseCloud_glue.k");
Import("JavaStyle.Object");
Import("Type.Json");

Strategy makeStrategy(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Strategy");
	return repo.CreateDBNode(argumentId,json) as Strategy;
}

Goal makeGoal(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Goal");
	return repo.CreateDBNode(argumentId, json) as Goal;
}

Evidence makeEvidence(API repo, int argumentId, String description, boolean flag) {
	Json json = new Json();
	json.setString("description",description);
	json.setBoolean("isEvidence",flag);
	json.setString("type","Evidence");
	return repo.CreateDBNode(argumentId, json) as Evidence;
}

Context makeContext(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Context");
	return repo.CreateDBNode(argumentId, json) as Context;
}

void GenerateTree1(API repo) {
	DCaseArgument argument = repo.CreateArgument("CheckNIC.dsは正しく動作する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
//	json.setString("IP","192.168.0.1");
//	json.setString("PORT","1234");
//	json.setString("DEST","192.168.0.2");
//	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "ハブの状態を確認する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "ハブの電源が落ちていない");
	repo.InsertLink(id, s1 , g1_1);
	Evidence e1_1 = makeEvidence(repo, id, "ハブを確認する", true);
	repo.InsertLink(id, g2_4, e2_4);

	Goal g1_2 = makeGoal(repo, id, "ハブが壊れていない");
	repo.InsertLink(id, s1 , g1_2);
	Evidence e1_2 = makeEvidence(repo, id, "ハブを確認する", true);
	repo.InsertLink(id, g1_2, e1_2);

	Strategy s2 = makeStrategy(repo, id, "LANケーブルの状態を考慮する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "LANケーブルが切れていない");
	repo.InsertLink(id, s2 , g2_1);
	Evidence e2_1 = makeEvidence(repo, id, "LANケーブルを確認する", true);
	repo.InsertLink(id, g2_1, e2_1);

	Goal g2_2 = makeGoal(repo, id, "LANケーブルが半差しになっていない");
	repo.InsertLink(id, s2 , g2_2);
	Evidence e2_2 = makeEvidence(repo, id, "LANケーブルを確認する", true);
	repo.InsertLink(id, g2_2, e2_2);

	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void main() {
	API repo = new API("konoha","konoha");
	GenerateTree1(repo);
}

main();
