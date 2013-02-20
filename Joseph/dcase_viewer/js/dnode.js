/* class DNode */
var DNode = function(id, name, type, text) {
	this.id = id;
	this.name = name;
	this.text = text;
	this.type = type;
	this.children = [];
	this.context = null;
	this.parents = [];
	this.prevVersion = null;
	this.nextVersion = null;
}

DNode.prototype.addChild = function(node) {
	if(node.type != "Context" || node.type != "DScriptContext") {
		this.children.push(node);
	} else {
		this.context = node;
	}
	node.parents.push(this);
}

DNode.prototype.removeChild = function(node) {
	if(this.context == node) {
		this.context = null;
	} else {
		var n = this.children.indexOf(node);
		this.children.splice(n, 1);
	}
}

DNode.prototype.isArgument = function() {
	return this.context != null && this.type == "Goal";
}

DNode.prototype.isUndevelop = function() {
	return this.children.length == 0 && this.type == "Goal";
}

DNode.getTypes = function() {
	return [
			"Goal", "Context", "Strategy", "Evidence", "Monitor", "DScript", "DScriptContext", "Rebuttal"
	];
}

//-------------------------------------
// FIXME?
var DSCRIPT_PREF = "D-Script:";
var DSCRIPT_PREF_CONTEXT = "D-Script.Name:";
DNode.prototype.isDScript = function() {
	return this.type == "DScript";
	//return this.type === "Evidence" && this.text.indexOf(DSCRIPT_PREF) == 0;
}

DNode.prototype.getDScriptNameInEvidence = function() {
	//return this.text.substr(DSCRIPT_PREF.length);
	return this.text;
}

DNode.prototype.getDScriptNameInContext = function() {
	if(this.type == "Context" && this.text.indexOf(DSCRIPT_PREF_CONTEXT) == 0) {
		return this.text.substr(DSCRIPT_PREF_CONTEXT.length);
	} else {
		return null;
	}
}

//-------------------------------------
function createNodeFromURL(url) {
	var a = $.ajax({
		type: "GET",
		url : url,
		async: false,
		dataType: "json",
	});
	return createNodeFromJson(JSON.parse(a.responseText));
}

function contextParams(params) {
	var s = "";
	for(key in params) {
		s += "@" + key + " : " + params[key] + "\n";
	}
	return s;
}

function createNodeFromJson(json) {
	console.log(json);
	var nodes = [];
	for(var i=0; i<json.nodes.length; i++) {
		var c = json.nodes[i];
		nodes[c.node_id] = c;
	}
		
	function createChildren(l, node) {
		for(var i=0; i<l.children.length; i++) {
			var child = l.children[i];
			var n = nodes[child.node_id];
			n.name = n.type.charAt(0) + n.node_id;
			var desc = n.description ? n.description : contextParams(n.properties);
			if(n.description.indexOf("D-Script:") == 0) {
				desc = n.description.slice(9);
				n.type = "DScript";
			}
			else if(n.type == "Context" && n.properties.hasOwnProperty("D-Script")) {
				n.type = "DScriptContext";
				desc = n.properties["D-Script"];
			}
			var newNode = new DNode(n.node_id, n.name, n.type, desc);
			newNode.isEvidence = n.isEvidence;
			node.addChild(newNode);
			createChildren(child, newNode);
		}
	}
	var n = nodes[json.links.node_id];
	var topNode = new DNode(0, "TopGoal", n.type, n.description);
	createChildren(json.links, topNode);
	return topNode;
}

function createBinNode(n) {
	if(n > 0) {
		var node = new DNode(0, "Goal", "Goal", "description");
		node.addChild(createBinNode(n-1));
		node.addChild(createBinNode(n-1));
		return node;
	} else {
		return new DNode(0, "Goal", "Goal", "description");
	}
}

var id_count = 1;
function createNodeFromJson2(json) {
	var id = json.id != null ? parseInt(json.id) : id_count++;
	var desc = json.desc ? json.desc : contextParams(json.prop);
	var node = new DNode(0, json.name, json.type, desc);
	if(json.prev != null) {
		node.prevVersion = createNodeFromJson2(json.prev);
		node.prevVersion.nextVersion = node;
	}
	if(json.children != null) {
		for(var i=0; i<json.children.length; i++) {
			var child = createNodeFromJson2(json.children[i]);
			node.addChild(child);
		}
	}
	return node;
}

function createSampleNode() {
	var strategy_children1 = [
		{ name: "Strategy", type: "Strategy", desc: "レイヤーレベルで議論",//TCP/IPの階層でアプリケーション層(アプリケーション、プレゼンテーション、セッション)、トランスポート層(トランスポート)、インターネット層(インターネット)、ネットワークインターフェイス層(データリンク、物理)に分ける
		children: [
		{ name: "SubGoal 1", type: "Goal", desc: "物理層は正常である",
		children: [
			{ name: "Strategy", type: "Strategy", desc: "PCや周辺機器の状態により判断する" ,
			children: [
				{ name: "SubGoal 1.1", type: "Goal", desc: "PC機器は障害要因ではない",
				children:[
					{name: "Strategy", type: "Strategy", desc: "PCとネットワークケーブルとの接続状態を考慮する",
					children:[
						{ name: "SubGoal 1.1.1", type: "Goal",  desc: "PCにネットワークケーブルが繋がっている" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						},
						{ name: "SubGoal 1.1.2", type: "Goal",  desc: "ネットワークケーブルがPCに半差しになっていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						}
									]
					},
					{name: "Strategy", type: "Strategy", desc: "PCとネットワークケーブルとの接続状態を考慮する",
					children:[
						{ name: "SubGoal 1.1.3", type: "Goal",  desc: "ネットワークドライバは壊れていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						}
									]
					}
								]
				},
				{ name: "SubGoal 1.2", type: "Goal", desc: "周辺機器は障害要因ではない",
				children: [
					{ name: "Strategy", type: "Strategy", desc: "ネットワークケーブルの状態に関して議論する",
					children: [
						{ name: "SubGoal 1.2", type: "Goal",  desc: "ネットワークケーブルは断線されていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						}
										]
					},
					{ name: "Strategy", type: "Strategy", desc: "ハブの状態に関して議論する",
					children: [
						{ name: "SubGoal 1.3", type: "Goal",  desc: "ハブが壊れていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						},
						{ name: "SubGoal 1.4", type: "Goal",  desc: "ハブの電源が切られていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						},
										]
					},
					{ name: "Strategy", type: "Strategy", desc: "ルータの状態に関して議論する",
					children: [
						{ name: "SubGoal 1.5", type: "Goal",  desc: "ルータが壊れていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						},
						{ name: "SubGoal 1.6", type: "Goal",  desc: "ルータの電源が切られていない" ,
						children: [
							{ name: "Evidence", type: "Evidence", desc: "人による確認結果" }
											]
						},
										]
					}
									]
				}
								]
			}
							]
		},

		{ name: "SubGoal 2", type: "Goal", desc: "データリンク層は正常である",
		children: [
					{ name: "Strategy", type: "Strategy", desc: "PCの構成状況により議論する" ,
					children: [
						{ name: "SubGoal 2.1", type: "Goal",  desc: "イーサネットカードが認識されている" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "CheckNIC.ds" }
											]
						},
						{ name: "SubGoal 2.2", type: "Goal",  desc: "正しいドライバがインストールされている" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "CheckDriver.ds" }
											]
						},
						{ name: "SubGoal 2.2", type: "Goal",  desc: "カーネルモジュールがアンロードされていない" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "CheckMOD.ds" }
											]
						},
						{ name: "SubGoal 2.2", type: "Goal",  desc: "interfaces設定ファイルが間違っていない" ,
						children: [
//							{ name: "D-Script", type: "DScript", desc: "CheckSetting.ds" }
											]
						},
						{ name: "SubGoal 2.3", type: "Goal",  desc: "PCでイーサネットインターフェースが有効になっている" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "Connection.ds" }
											]
						}
									]
					}
							]
		},

			//パケットを送信元から宛先まで届ける全工程を担っている。
			//仮想的なパケット交換ネットワークを構築、ホストとホスト間の通信を実現。ICMP(Internet Control Message Protocol)等もここ。つまり、pingによるチェックはここまで。
			//同じネットワーク媒体上に接続されているコンピュータ間同士だけではなく、異なるネットワーク媒体上に接続されているコンピュータの間でも通信を行えるようにする。(IP)アドレス付け。(ゲートウェイ内外の)ルーティングプロトコル。
		{ name: "SubGoal 2", type: "Goal", desc: "インターネット層は障害要因ではない",
		children: [
			{ name: "Strategy", type: "Strategy", desc: "Internet layerの持つ役割を基に議論する" ,
			children: [
				{ name: "SubGoal 2.1", type: "Goal", desc: "IP Addressが割り当てられている" ,
				children: [
					{ name: "D-Script", type: "DScript", desc: "CheckIPAddress.ds" }
									]
				},
				{ name: "SubGoal 2", type: "Goal", desc: "ルーティング機能は障害要因ではない",
				children: [
					{ name: "D-Script", type: "DScript", desc: "Routing.ds" }
									]
				},
				{ name: "SubGoal 2.3", type: "Goal", desc: "firewall設定によりIP Addressレベルでパケットが破棄されない" ,
				children: [
					{ name: "Strategy", type: "Strategy", desc: "INPUT, FORWARD, OUTPUT別に確認する" ,
					children: [
						{ name: "SubGoal 2.3.1", type: "Goal", desc: "INPUTチェーンではパケットを破棄しない" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "FirewallIPInput.ds" }
											]
							},
							{ name: "SubGoal 2.3.2", type: "Goal", desc: "FORWARDチェーンではパケットを破棄しない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallIPForward.ds" }
												]
								},
								{ name: "SubGoal 2.3.3", type: "Goal", desc: "OUTPUTチェーンではパケットを破棄しない" ,
								children: [
									{ name: "D-Script", type: "DScript", desc: "FirewallIPOutput.ds" }
													]
								}
										]
					}
									]
				},
				{ name: "SubGoal 2.4", type: "Goal", desc: "firewall設定によりPOLICYでパケットが破棄されない" ,
				children: [
					{ name: "Strategy", type: "Strategy", desc: "INPUT, FORWARD, OUTPUT別に確認する" ,
					children: [
						{ name: "SubGoal 2.4.1", type: "Goal", desc: "INPUTチェーンではパケットを破棄しない" ,
						children: [
							{ name: "D-Script", type: "DScript", desc: "FirewallIPInput.ds" }
											]
							},
							{ name: "SubGoal 2.4.2", type: "Goal", desc: "FORWARDチェーンではパケットを破棄しない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallIPForward.ds" }
												]
								},
								{ name: "SubGoal 2.4.3", type: "Goal", desc: "OUTPUTチェーンではパケットを破棄しない" ,
								children: [
									{ name: "D-Script", type: "DScript", desc: "FirewallIPOutput.ds" }
													]
								}
										]
					}
									]
				}
								]
			}
							]
		},

//データ伝送の信頼性を保証するための機能を物理的ネットワークから独立して提供。つまり、「仮想的な回線」を提供。データが正しく相手にまで届いたかどうかを確認し、問題があれば、データの再送信などを行う。(TCP,UDPなどがここ)
//任意のサイズのデータを送るために、データの分割と再構築を行う。アプリケーションにパケットを渡すときにPort番号で識別している
// TCP/UDP Port,再送制御、順序制御、フロー制御、輻輳制御
		{ name: "SubGoal 4", type: "Goal", desc: "トランスポート層は正常である",
			children: [
						{ name: "Strategy", type: "Strategy", desc: "firewall設定を考慮する" ,
						children: [
							{ name: "SubGoal 4.1.1", type: "Goal", desc: "受信するTCPプロトコルのパケットを破棄しない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallTCPInput.ds" }// TCP/UDP
												]
							},
							{ name: "SubGoal 4.1.2", type: "Goal", desc: "中継するTCPプロトコルのパケットを破棄しない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallTCPForward.ds" }// TCP/UDP
												]
							},
							{ name: "SubGoal 4.1.3", type: "Goal", desc: "送信するTCPプロトコルのパケットを破棄しない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallTCPOutput.ds" }// TCP/UDP
												]
							},
									]
				}
								]
		},

//Presentation layer->ネットワークに流れるデータの意味を統一。コードの変換以外にデータの暗号化や、データの圧縮なども。TCP/IP layerのApplication layer。
		{ name: "SubGoal 5", type: "Goal", desc: "アプリケーション層は障害要因ではない",
		children: [
			{ name: "Strategy", type: "Strategy", desc: "サービス別に議論する" ,
			children: [
				{ name: "SubGoal 5.1", type: "Goal", desc: "名前解決できる" ,
				children: [
					{ name: "D-Script", type: "DScript", desc: "Nslookup.ds" }
									]
				},
				{ name: "SubGoal 5.2", type: "Goal", desc: "ファイル転送(FTP)が可能である" ,
				children: [
						{ name: "Strategy", type: "Strategy", desc: "コントロールコネクション接続可否について議論" ,
						children: [
							{ name: "SubGoal 5.2.1.1", type: "Goal", desc: "firewallによりポート21番のFORWARDパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPForward.ds" },
												]
							},
							{ name: "SubGoal 5.2.1.1", type: "Goal", desc: "firewallによりポート21番のOUTPUTパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPOutput.ds" },
												]
							},
							{ name: "SubGoal 5.2.1.2", type: "Goal", desc: "firewallによりポート21番のINPUTパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPInput.ds" },
												]
							},
							{ name: "SubGoal 5.2.1.3", type: "Goal", desc: "ユーザ名、パスワード名が間違っていない" ,
							children: [
								{ name: "Evidence", type: "Evidence", desc: "ユーザの確認結果" },
												]
							}
											]
						},
						{ name: "Strategy", type: "Strategy", desc: "データコネクションについて議論" ,
						children: [
							{ name: "SubGoal 5.2.1.1", type: "Goal", desc: "firewallによりデータ転送に使用するポートのOUTPUTパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPDataOutput.ds" },
												]
							},
							{ name: "SubGoal 5.2.1.1", type: "Goal", desc: "firewallによりデータ転送に使用するポートのFORWARDパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPDataForward.ds" },
												]
							},
							{ name: "SubGoal 5.2.1.2", type: "Goal", desc: "firewallによりデータ転送に使用するポートのINPUTパケットを破棄していない" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "FirewallFTPDataInput.ds" },
												]
							},
											]
						},
						{ name: "Strategy", type: "Strategy", desc: "FTP設定ファイルを考慮する" ,
						children: [
							{ name: "SubGoal 5.2.2.1", type: "Goal", desc: "匿名で接続できる設定になっている" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "CheckAnonConf.ds" },
												]
							},
							{ name: "SubGoal 5.2.2.1", type: "Goal", desc: "匿名のためのルートディレクトリが設定されている" ,
							children: [
								{ name: "D-Script", type: "DScript", desc: "CheckRootConf.ds" },
												]
							}
											]
						}
									]
				}
								]
			}
							]
		}
							]
	}
	];
//	var strategy_children1 = [
//		{ name: "Strategy", type: "Strategy", desc: "レイヤーレベルで議論",//TCP/IPの階層でアプリケーション層(アプリケーション、プレゼンテーション、セッション)、トランスポート層(トランスポート)、インターネット層(インターネット)、ネットワークインターフェイス層(データリンク、物理)に分ける
//		children: [
//			{ name: "SubGoal2.1", type: "Goal", desc: "物理層は障害要因ではない"},
//			{ name: "SubGoal2.2", type: "Goal", desc: "データリンク層は障害要因ではない"},
//			{ name: "SubGoal2.3", type: "Goal", desc: "インターネット層は障害要因ではない"},
//			{ name: "SubGoal2.4", type: "Goal", desc: "トランスポート層は障害要因ではない"},
//			{ name: "SubGoal2.5", type: "Goal", desc: "アプリケーション層は障害要因ではない"}
//							]
//	}
//	];
	var strategy_children2 = [
		{ name: "Strategy2", type: "Strategy", desc: "レイヤーレベルで議論する",
		children: [
			{ name: "SubGoal2.1", type: "Goal", desc: "物理層は障害要因ではない"},
			{ name: "SubGoal2.2", type: "Goal", desc: "データリンク層は障害要因ではない"},
			{ name: "SubGoal2.3", type: "Goal", desc: "インターネット層は障害要因ではない"}
							]
		}
		];
	var strategy_children3 = [
		{ name: "Strategy2", type: "Strategy", desc: "レイヤーレベルで議論する",
		children: [
			{ name: "SubGoal2.1", type: "Goal", desc: "物理層は障害要因ではない"},
			{ name: "SubGoal2.2", type: "Goal", desc: "データリンク層は障害要因ではない"},
			{ name: "SubGoal2.3", type: "Goal", desc: "インターネット層は障害要因ではない"},
			{ name: "SubGoal2.4", type: "Goal", desc: "トランスポート層は障害要因ではない"},
			{ name: "SubGoal2.5", type: "Goal", desc: "アプリケーション層は障害要因ではない"}
							]
}
];

	return createNodeFromJson2({
		name: "TopGoal", type: "Goal",
		desc: "ネットワークに障害要因はない",
		children: [
			{ name: "Context", type: "Context", desc: "@IP:192.168.59.75\n@OS:ubuntu12.04LTS 64bit\n"+
			  "@Service:FTPConnection\n@Type:Passive Mode\n@Topology:star\n@DEST:test\n@DEST-IP:192.168.59.40\n@OS:ubuntu12.10 64bit"
			},
			{ name: "Strategy", type: "Strategy", desc: "構成機器により分割",
				children: [
				{ name: "SubGoal", type: "Goal", desc: "サーバは障害要因ではない",
			children: strategy_children1
				},
				{ name: "SubGoal", type: "Goal", desc: "ルータは障害要因ではない",
				children: strategy_children2
				},
				{ name: "SubGoal", type: "Goal", desc: "クライアントは障害要因ではない",
				children: strategy_children3
				}
				]
			}
		]
	});
}



