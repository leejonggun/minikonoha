Import("Deos.DCaseCloud");
Import("JavaStyle.Object");
Import("Type.Json");

Strategy makeStrategy(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Strategy");
	return repo.CreateDBNode(json) as Strategy;
}

Goal makeGoal(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Goal");
	return repo.CreateDBNode(json) as Goal;
}

Evidence makeEvidence(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Evidence");
	return repo.CreateDBNode(json) as Evidence;
}

Context makeContext(API repo, int argumentId, Json context) {
	Json json = new Json();
	json.set("properties",context);
	json.setString("type","Context");
	return repo.CreateDBNode(json) as Context;
}

void GenerateTree1(API repo) {
	DCaseArgument argument = repo.CreateArgument("ネットワークに障害要因はない");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("HOST-IP","192.168.59.75");
	json.setString("OS","ubuntu12.10");
	json.setString("Version","3.2.0-37-generic");
	json.setString("Structure","x86-64");
	json.setString("FTP-Control-Port","21");
	json.setString("FTP-Data-Port","21以外");
	json.setString("Port","21");
	json.setString("DEST","test");
	json.setString("DEST-IP","192.168.59.40");
	json.setString("OS","ubuntu12.04");
	json.setString("Version","3.2.0-37-generic");
	json.setString("Structure","x86-64");
	json.setString("FTP-Control-Port","21");
	json.setString("FTP-Data-Port","21以外");
	repo.AddContext(id, root.node_id, json);

	Strategy s0 = makeStrategy(repo, id, "レイヤーレベルで議論する");
	repo.InsertLink(id, root, s0);

	Goal g1 = makeGoal(repo, id, "データリンク層に障害要因がない");
	repo.InsertLink(id, s0 , g1);

	Strategy s1 = makeStrategy(repo, id, "PCや周辺機器の状態により議論する");
	repo.InsertLink(id, g1 , s1);

	Goal g1_1 = makeGoal(repo, id, "イーサネットカードが認識されている");
	repo.InsertLink(id, s1, g1_1);
	Evidence e1_1 = makeEvidence(repo, id, "D-Script:CheckNIC.ds");
	repo.InsertLink(id, g1_1, e1_1);

	Goal g1_2 = makeGoal(repo, id, "ネットワークドライバがインストールされている");
	repo.InsertLink(id, s1, g1_2);
	Evidence e1_2 = makeEvidence(repo, id, "D-Script:CheckDriver.ds");
	repo.InsertLink(id, g1_2, e1_2);

	Goal g1_3 = makeGoal(repo, id, "正しいカーネルモジュールがロードされている");
	repo.InsertLink(id, s1, g1_3);
	Evidence e1_3 = makeEvidence(repo, id, "D-Script:CheckMOD.ds");
	repo.InsertLink(id, g1_3, e1_3);

	Goal g1_4 = makeGoal(repo, id, "イーサネットインターフェースが有効になっている");
	repo.InsertLink(id, s1, g1_4);
	Evidence e1_4 = makeEvidence(repo, id, "D-Script:Connection.ds");
	repo.InsertLink(id, g1_4, e1_4);

	Goal g2 = makeGoal(repo, id, "インターネット層に障害要因がない");
	repo.InsertLink(id, s0 , g2);

	Strategy s2_1 = makeStrategy(repo, id, "インターネット層の持つ役割を基に議論する");
	repo.InsertLink(id, g2 , s2_1);

	Goal g2_1 = makeGoal(repo, id, "IPアドレスが割り当てられている");
	repo.InsertLink(id, s2_1, g2_1);
	Evidence e2_1 = makeEvidence(repo, id, "D-Script:CheckIPAddress.ds");
	repo.InsertLink(id, g2_1, e2_1);

	Goal g2_2 = makeGoal(repo, id, "ルーティング設定は障害要因ではない");
	repo.InsertLink(id, s2_1, g2_2);

	Evidence e2_2 = makeEvidence(repo, id, "D-Script:Routing.ds");
	repo.InsertLink(id, g2_2, e2_2);

	Goal g2_3 = makeGoal(repo, id, "firewall設定によりIPレベルでパケットが破棄されない");
	repo.InsertLink(id, s2_1, g2_3);

	Strategy s2_3 = makeStrategy(repo, id, "INPUT, FORWARD, OUTPUT別に確認する");
	repo.InsertLink(id, g2_3, s2_3);

	Goal g2_3_1 = makeGoal(repo, id, "INPUTチェーンでパケットを破棄していない");
	repo.InsertLink(id, s2_3, g2_3_1);
	Evidence e2_3_1 = makeEvidence(repo, id, "D-Script:FirewallIPInput.ds");
	repo.InsertLink(id, g2_3_1, e2_3_1);

	Goal g2_3_2 = makeGoal(repo, id, "FORWARDチェーンでパケットを破棄していない");
	repo.InsertLink(id, s2_3, g2_3_2);
	Evidence e2_3_2 = makeEvidence(repo, id, "D-Script:FirewallIPForward.ds");
	repo.InsertLink(id, g2_3_2, e2_3_2);

	Goal g2_3_3 = makeGoal(repo, id, "OUTPUTチェーンでパケットを破棄していない");
	repo.InsertLink(id, s2_3, g2_3_3);
	Evidence e2_3_3 = makeEvidence(repo, id, "D-Script:FirewallIPOutput.ds");
	repo.InsertLink(id, g2_3_3, e2_3_3);

	Goal g2_4 = makeGoal(repo, id, "firewall設定によりPOLICYでパケットが破棄されない");
	repo.InsertLink(id, s2_1, g2_4);

	Strategy s2_4 = makeStrategy(repo, id, "INPUT, FORWARD, OUTPUT別に確認する");
	repo.InsertLink(id, g2_4, s2_4);

	Goal g2_4_1 = makeGoal(repo, id, "INPUTチェーンで基本的にパケットを破棄していない");
	repo.InsertLink(id, s2_4, g2_4_1);
	Evidence e2_4_1 = makeEvidence(repo, id, "D-Script:FirewallPolicyInput.ds");
	repo.InsertLink(id, g2_4_1, e2_4_1);

	Goal g2_4_2 = makeGoal(repo, id, "FORWARDチェーンで基本的にパケットを破棄していない");
	repo.InsertLink(id, s2_4, g2_4_2);
	Evidence e2_4_2 = makeEvidence(repo, id, "D-Script:FirewallPolicyForward.ds");
	repo.InsertLink(id, g2_4_2, e2_4_2);

	Goal g2_4_3 = makeGoal(repo, id, "OUTPUTチェーンで基本的にパケットを破棄していない");
	repo.InsertLink(id, s2_4, g2_4_3);
	Evidence e2_4_3 = makeEvidence(repo, id, "D-Script:FirewallPolicyOutput.ds");
	repo.InsertLink(id, g2_4_3, e2_4_3);

	Goal g3 = makeGoal(repo, id, "トランスポート層に障害要因がない");
	repo.InsertLink(id, s0 , g3);

	Strategy s3 = makeStrategy(repo, id, "firewall設定を考慮する");
	repo.InsertLink(id, g3, s3);

	Goal g3_1 = makeGoal(repo, id, "受信するTCPプロトコルのパケットを破棄しない");
	repo.InsertLink(id, s3, g3_1);
	Evidence e3_1 = makeEvidence(repo, id, "D-Script:FirewallTCPInput.ds");
	repo.InsertLink(id, g3_1, e3_1);

	Goal g3_2 = makeGoal(repo, id, "中継するTCPプロトコルのパケットを破棄しない");
	repo.InsertLink(id, s3, g3_2);
	Evidence e3_2 = makeEvidence(repo, id, "D-Script:FirewallTCPForward.ds");
	repo.InsertLink(id, g3_2, e3_2);

	Goal g3_3 = makeGoal(repo, id, "送信するTCPプロトコルのパケットを破棄しない");
	repo.InsertLink(id, s3, g3_3);
	Evidence e3_3 = makeEvidence(repo, id, "D-Script:FirewallTCPOutput.ds");
	repo.InsertLink(id, g3_3, e3_3);

	Goal g4 = makeGoal(repo, id, "アプリケーション層に障害要因がない");
	repo.InsertLink(id, s0 , g4);

	Strategy s4 = makeStrategy(repo, id, "サービス毎に考慮する");
	repo.InsertLink(id, g4, s4);

	Goal g4_1 = makeGoal(repo, id, "名前解決できる");
	repo.InsertLink(id, s4 , g4_1);
	Evidence e4_1 = makeEvidence(repo, id, "D-Script:Nslookup.ds");
	repo.InsertLink(id, g4_1, e4_1);

	Goal g4_2 = makeGoal(repo, id, "FTP設定は間違っていない");
	repo.InsertLink(id, s4 , g4_2);

	Strategy s4_2 = makeStrategy(repo, id, "コントロールコネクションの接続可否について議論する");
	repo.InsertLink(id, g4_2, s4_2);

	Goal g4_2_1 = makeGoal(repo, id, "firewall設定により21番ポートのINPUTパケットを破棄しない");
	repo.InsertLink(id, s4_2 , g4_2_1);
	Evidence e4_2_1 = makeEvidence(repo, id, "D-Script:FirewallFTPInput.ds");
	repo.InsertLink(id, g4_2_1, e4_2_1);

	Goal g4_2_2 = makeGoal(repo, id, "firewall設定により21番ポートのFORWARDパケットを破棄しない");
	repo.InsertLink(id, s4_2 , g4_2_2);
	Evidence e4_2_2 = makeEvidence(repo, id, "D-Script:FirewallFTPForward.ds");
	repo.InsertLink(id, g4_2_2, e4_2_2);

	Goal g4_2_3 = makeGoal(repo, id, "firewall設定により21番ポートのOUTPUTパケットを破棄しない");
	repo.InsertLink(id, s4_2 , g4_2_3);
	Evidence e4_2_3 = makeEvidence(repo, id, "D-Script:FirewallFTPOutput.ds");
	repo.InsertLink(id, g4_2_3, e4_2_3);

	Goal g4_2_4 = makeGoal(repo, id, "ユーザ名、パスワードが間違っていない");
	repo.InsertLink(id, s4_2 , g4_2_4);
	Evidence e4_2_4 = makeEvidence(repo, id, "ユーザの確認結果");
	repo.InsertLink(id, g4_2_4, e4_2_4);

	Strategy s4_3 = makeStrategy(repo, id, "データコネクションの接続可否について議論する");
	repo.InsertLink(id, g4_2, s4_3);

	Goal g4_3_1 = makeGoal(repo, id, "firewall設定によりデータ転送に使用するポートのINPUTパケットを破棄しない");
	repo.InsertLink(id, s4_3 , g4_3_1);
	Evidence e4_3_1 = makeEvidence(repo, id, "D-Script:FirewallFTPDataInput.ds");
	repo.InsertLink(id, g4_3_1, e4_3_1);

	Goal g4_3_2 = makeGoal(repo, id, "firewall設定によりデータ転送に使用するポートのFORWARDパケットを破棄しない");
	repo.InsertLink(id, s4_3 , g4_3_2);
	Evidence e4_3_2 = makeEvidence(repo, id, "D-Script:FirewallDataForward.ds");
	repo.InsertLink(id, g4_3_2, e4_3_2);

	Goal g4_3_3 = makeGoal(repo, id, "firewall設定によりデータ転送に使用するポートのOUTPUTパケットを破棄しない");
	repo.InsertLink(id, s4_3 , g4_3_3);
	Evidence e4_3_3 = makeEvidence(repo, id, "D-Script:FirewallFTPDataOutput.ds");
	repo.InsertLink(id, g4_3_3, e4_3_3);

	Strategy s4_4 = makeStrategy(repo, id, "FTP設定について議論する");
	repo.InsertLink(id, g4_2, s4_4);

	Goal g4_4_1 = makeGoal(repo, id, "匿名で接続できる設定になっている");
	repo.InsertLink(id, s4_4 , g4_4_1);
	Evidence e4_4_1 = makeEvidence(repo, id, "D-Script:CheckAnonConf.ds");
	repo.InsertLink(id, g4_4_1, e4_4_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void CheckNIC(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","CheckNIC.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "lspciのコマンドは/usr/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void CheckDriver(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","CheckDriver.ds");
	repo.AddContext(id, root.node_id, json);

//	Strategy s1 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
//	Strategy s1 = makeStrategy(repo, id, "想定している実行環境について議論する");
//	repo.InsertLink(id, root, s1);
//
//	Goal g1_1 = makeGoal(repo, id, "UbuntuOS上で実行される");
//	repo.InsertLink(id, s1, g1_1);
//
//	Goal g1_2 = makeGoal(repo, id, "lspciによりPCIバスデバイスを参照できる");
//	repo.InsertLink(id, s1, g1_2);
//
//	Goal g1_3 = makeGoal(repo, id, "NICに対応するドライバが存在する");
//	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s2, g2_1);

	Goal g2_2 = makeGoal(repo, id, "lspciのコマンドは/usr/bin/に格納されている");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_2 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_3 = makeGoal(repo, id, "無限ループが発生しない");
	repo.InsertLink(id, s2, g2_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
//	repo.InsertLink(id, g1_1, e3_1);
//	repo.InsertLink(id, g1_2, e3_1);
//	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);
	repo.InsertLink(id, g2_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void CheckMOD(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","CheckMOD.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "lspciのコマンドは/usr/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "lsmodのコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_2 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "無限ループが発生しない");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "lspciコマンドによりPCIバスドライバを確認できる");
	repo.InsertLink(id, s2, g2_1);

	Goal g2_2 = makeGoal(repo, id, "lsmodコマンドによりロードされているモジュールを確認できる");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_3 = makeGoal(repo, id, "ネットワークモジュールがロードされている");
	repo.InsertLink(id, s2, g2_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);
	repo.InsertLink(id, g2_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void Connection(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","Connection.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "netstatコマンドは/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "netstatコマンドによりルーティングテーブルを参照できる");
	repo.InsertLink(id, s2, g2_1);

	Goal g2_2 = makeGoal(repo, id, "ルーティングテーブルにネットワークインターフェースが表示される");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_3 = makeGoal(repo, id, "ネットワークモジュールがロードされている");
	repo.InsertLink(id, s2, g2_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);
	repo.InsertLink(id, g2_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void CheckIPAddress(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","CheckIPAddress.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "netstatコマンドは/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "ifconfigコマンドによりネットワーク環境を確認できる");
	repo.InsertLink(id, s2, g2_1);

	Goal g2_2 = makeGoal(repo, id, "所属しているネットワークが間違っていない");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_3 = makeGoal(repo, id, "ネットワークモジュールがロードされている");
	repo.InsertLink(id, s2, g2_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);
	repo.InsertLink(id, g2_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void Routing(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","Routing.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "gethostipコマンドは/usr/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "netstatコマンドは/bin/に格納されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "ルーティングテーブルにデフォルトゲートウェイが登録されているか、接続先のIPの所属しているネットワークが登録されている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallIPInput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallIPInput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallIPForward(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallIPForward.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallIPOutput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallIPOutput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallPolicyInput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallPolicyInput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallPolicyForward(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallPolicyForward.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallPolicyOutput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallPolicyOutput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallTCPInput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallTCPInput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallTCPForward(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallTCPForward.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallTCPOutput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallTCPOutput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void Nslookup(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","Nslookup.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "名前解決できない場合、hostsファイルにホストネームに対応するIPが登録されている");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "hostsファイルは/etc/に保存されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_4);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "nslookupコマンドが/usr/bin/に格納されている");
	repo.InsertLink(id, s1, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPInput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPInput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPForward(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPForward.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPOutput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPOutput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPDataInput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPDataInput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPDataForward(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPDataForward.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void FirewallFTPDataOutput(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","FirewallFTPDataOutput.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "sudoコマンドを使用できる");
	repo.InsertLink(id, s1, g1_2);

	Goal g1_3 = makeGoal(repo, id, "iptablesコマンドは/sbin/に格納されている");
	repo.InsertLink(id, s1, g1_3);

	Goal g1_4 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_3);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "iptablesがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g1_3, e3_1);
	repo.InsertLink(id, g1_4, e3_1);
	repo.InsertLink(id, g2_1, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void CheckAnonConf(API repo) {
	DCaseArgument argument = repo.CreateArgument("スクリプトは正しく実行する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("D-Script","CheckAnonConf.ds");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "スクリプトのバグとなりうる要因を議論する");
	repo.InsertLink(id, root, s1);

	Goal g1_1 = makeGoal(repo, id, "bashコマンドの実行結果を文字列に保持することができる");
	repo.InsertLink(id, s1, g1_1);

	Goal g1_2 = makeGoal(repo, id, "文字列が空になる時のエラー処理を書いている");
	repo.InsertLink(id, s1, g1_2);

	Strategy s2 = makeStrategy(repo, id, "スクリプトの実行環境について議論する");
	repo.InsertLink(id, root, s2);

	Goal g2_1 = makeGoal(repo, id, "vsftpdがインストールされている");
	repo.InsertLink(id, s2, g2_1);

	Goal g2_2 = makeGoal(repo, id, "vsftpd.confファイルが/etc/に保存されている");
	repo.InsertLink(id, s2, g2_2);

	Goal g2_3 = makeGoal(repo, id, "anonymous接続を有効にしている");
	repo.InsertLink(id, s2, g2_3);

	Evidence e3_1 = makeEvidence(repo, id, "人による確認");
	repo.InsertLink(id, g1_1, e3_1);
	repo.InsertLink(id, g1_2, e3_1);
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);
	repo.InsertLink(id, g2_3, e3_1);

//	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void main() {
	API repo = new API("dcasedb","dcasedb");
//Network
	GenerateTree1(repo);
//D-Scripts
	CheckNIC(repo);
	CheckDriver(repo);
	CheckMOD(repo);
	Connection(repo);
	CheckIPAddress(repo);
	Routing(repo);
	FirewallIPInput(repo);
	FirewallIPForward(repo);
	FirewallIPOutput(repo);
	FirewallPolicyInput(repo);
	FirewallPolicyForward(repo);
	FirewallPolicyOutput(repo);
	FirewallTCPInput(repo);
	FirewallTCPForward(repo);
	FirewallTCPOutput(repo);
	Nslookup(repo);
	FirewallIPInput(repo);
	FirewallFTPForward(repo);
	FirewallFTPOutput(repo);
	FirewallFTPDataInput(repo);
	FirewallFTPDataForward(repo);
	FirewallFTPDataOutput(repo);
	CheckAnonConf(repo);
}

main();
