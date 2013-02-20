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
	DCaseArgument argument = repo.CreateArgument("Nslookup.dsは正しく動作する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
//	json.setString("IP","192.168.0.1");
//	json.setString("PORT","1234");
//	json.setString("DEST","192.168.0.2");
//	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "DNSに関して議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "DNSが登録されている");
	repo.InsertLink(id, s1 , g1_1);
	Evidence e1_1 = makeEvidence(repo, id, "resolv設定を確認する", true);
	repo.InsertLink(id, g2_4, e2_4);

	Goal g1_2 = makeGoal(repo, id, "DNSの電源が入っている");
	repo.InsertLink(id, s1 , g1_2);
	Evidence e1_2 = makeEvidence(repo, id, "確認する", true);
	repo.InsertLink(id, g1_2, e1_2);

	Goal g1_3 = makeGoal(repo, id, "DNSから応答がある");
	repo.InsertLink(id, s1 , g1_3);
	Evidence e1_3 = makeEvidence(repo, id, "DNSにpingを飛ばして確認する", true);
	repo.InsertLink(id, g1_3, e1_3);

	Strategy s2 = makeStrategy(repo, id, "名前解決に関して議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "DNSからドメイン名を取得不可能ではない");
	repo.InsertLink(id, s2 , g2_1);
	Evidence e2_1 = makeEvidence(repo, id, "DNSの設定ファイル(hosts)を確認する", true);
	repo.InsertLink(id, g2_1, e2_1);

	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void main() {
	API repo = new API("konoha","konoha");
	GenerateTree1(repo);
}

main();
