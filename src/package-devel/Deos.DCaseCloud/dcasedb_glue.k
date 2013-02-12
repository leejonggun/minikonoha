//FIXME This File is obsolete.
//import("konoha.ns");
//import("konoha.json");
//import("openssl");
//import("cstyle");
//import("java2.class");
//import("konoha.map");
//import("konoha.sql");
//import("konoha.object");
//import("js4.array");
//import("js4.date");
Import("MiniKonoha.NameSpace");
Import("Type.Json");
Import("Lib.Openssl");
Import("Syntax.CStyleFor");
Import("Java.Class");
Import("MiniKonoha.Map");
Import("MiniKonoha.Sql");
Import("JavaStyle.Object");
Import("JavaScript.Array");
Import("JavaScript.Date");

DefineConst("MtdCreateDBNode","CreateDBNode");
DefineConst("MtdDeleteDBNode","DeleteDBNode");
DefineConst("MtdUpdateDBNode","UpdateDBNode");
DefineConst("MtdInsertLink","InsertLink");
DefineConst("MtdDeleteLink","DeleteLink");
DefineConst("MtdUpdateLink","UpdateLink");
DefineConst("JsonKeyDBNodeType", "DBNodeType");
DefineConst("JsonKeyCommitLog", "CommitLog");
DefineConst("JsonKeyRoot", "root");
DefineConst("JsonKeyNodes", "nodes");
DefineConst("JsonKeyLinks", "links");
DefineConst("NodeTypeGoal","Goal");
DefineConst("NodeTypeStrategy","Strategy");
DefineConst("NodeTypeContext","Context");
DefineConst("NodeTypeEvidence","Evidence");

//const MtdCreateDBNode = "CreateDBNode";
//const MtdDeleteDBNode = "DeleteDBNode";
//const MtdUpdateDBNode = "UpdateDBNode";
//const MtdInsertLink   = "InsertLink";
//const MtdDeleteLink   = "DeleteLink";
//const MtdUpdateLink   = "UpdateLink";
//
//const JsonKeyDBNodeType = "DBNodeType";
//const JsonKeyCommitLog  = "CommitLog";
//const JsonKeyRoot       = "root";
//const JsonKeyNodes      = "nodes";
//const JsonKeyLinks      = "links";
//
//const NodeTypeGoal     = "Goal";
//const NodeTypeStrategy = "Strategy";
//const NodeTypeContext  = "Context";
//const NodeTypeEvidence = "Evidence";

class DBNode {
	String  name;
	String  description;
	boolean is_evidence;
	//TODO add some fields

	DBNode(Json content) {
		this.updateContent(content);
	}

	Json _toJson() {
		Json json = new Json();
		json.setString("name",this.name);
		json.setString("description",this.description);
		json.setBoolean("is_evidence",this.is_evidence);
		return json;
	}

	Json toJson() {
		return this._toJson();
	}

	void updateContent(Json content) {
		if(content.hasKey("name")) {
			this.name = content.getString("name");
		}
		if(content.hasKey("description")) {
			this.description = content.getString("description");
		}
		if(content.hasKey("is_evidence")) {
			this.is_evidence = content.getBoolean("is_evidence");
		}
	}

	Json update(Json content) {
		Json json = new Json();
		json.set("before",this.toJson());
		this.updateContent(content);
		json.set("after", this.toJson());
		return json;
	}
}

class Link {
	String parent;
	String child;
	Link(String parent, String child) {
		this.parent = parent;
		this.child  = child;
	}

	Link(Json content) {
		if(content.hasKey("parent")) {
			this.parent = content.getString("parent");
		}
		if(content.hasKey("child")) {
			this.child  = content.getString("child");
		}
	}

	//TODO LinktoTreeJson
	Json toJson() {
		Json json = new Json();
		json.setString("parent",this.parent);
		json.setString("child",this.child);
		return json;
	}
}

class Context extends DBNode {
	Json condition;
	Context(Json content) {
		//TODO Create Argument
		this.condition = new Json();
		this.updateContent(content);
		if(content.hasKey("context")) {
			Json array = content.get("condition");
			String[] keys = array.keys();
			for(int i = 0; i < keys.getSize(); i++) {
				this.condition.setString(keys[i],array.getString(keys[i])); //TODO Need validation
			}
		}
	}

	String searchValue(String key) {
		if(this.condition.hasKey(key)) {
			return this.condition.getString(key);
		}
		return NULL;
	}

	void addKeyValue(Json json) {
		String[] keys = json.keys();
		for(int i = 0; i < keys.getSize(); i++) {
			this.condition.setString(keys[i],json.getString(keys[i])); //TODO Need validation
		}
	}

	Json toJson() {
		Json json = this._toJson();
		json.setString("DBNodeType","Context");
		json.set("context",this.condition);
		return json;
	}
}

//TODO
class Goal extends DBNode {
	Context context; //FIXME Why need this?
	Goal(Json content, Context context) {
		this.updateContent(content);
		this.context = context;
	}

	Json toJson() {
		Json json = this._toJson();
		json.setString("DBNodeType","Goal");
		return json;
	}
}

class Strategy extends DBNode {
	Context context;
	Strategy(Json content, Context context) {
		this.updateContent(content);
		this.context = context;
	}

	Json toJson() {
		Json json = this._toJson();
		json.setString("DBNodeType","Strategy");
		return json;
	}
}

class Evidence extends DBNode {
	Evidence() {}

	Json toJson() {
		Json json = this._toJson();
		json.setString("DBNodeType","Evidence");
		return json;
	}
}

class Commit {
	String method;
	Json argument;
	String revision;
	int time;

	Commit() {
	}

	Commit(String method, Json argument, String revision) {
		this.method   = method;
		this.argument = argument;
		this.revision = revision;
		this.time     = new Date().getTime();
	}

	Json toJson() {
		Json json = new Json();
		json.setString("method",this.method);
		json.set("argument",this.argument);
		json.setString("revision",this.revision);
		json.setInt("time",this.time);

		return json;
	}
}

class CommitLog {
	Commit[] commits;
	String head;
	SHA1 sha1;

	CommitLog() {
		this.commits = [];
		this.sha1 = new SHA1();
		this.sha1.update(new Date().toString());
	}

	Commit addCommit(String method, Json argument) {
		Commit commit = new Commit(method, argument, this.sha1.final());
		this.commits.add(commit);
		this.head = commit.revision;
		return commit;
	}

	Json toJson() {
		Json json = Json.parse("[]");
		for(int i = 0;i < this.commits.getSize(); i++) {
			json.add(this.commits[i].toJson());
		}
		return json;
	}
}

class LinkTree {
	String name;
	LinkTree[] children;

	LinkTree(String name) {
		this.name = name;
	}

	Json toJson() {
		Json json = new Json();
		json.setString("name",this.name);
		Json jarr = Json.parse("[]");
		for(int i = 0; i < this.children.getSize();i++) {
			jarr.add(this.children[i].toJson());
		}
		json.set("children",jarr);
		return json;
	}
}

class Argument {
	CommitLog commit_log;
	DBNode     root;
	DBNode[]   nodes;
	Link[]   links;
	Argument[] arguments;

	Argument() {
		//this.root = root;
		this.commit_log = new CommitLog();
		this.links = [];
		this.nodes = [];
		this.arguments = [];
	}

	Argument(DBNode[] nodes, Link[] links, CommitLog cl,DBNode root) {
		this.commit_log = cl;
		this.links = links;
		this.nodes = nodes;
		this.arguments = [];
		this.root = root;
	}

	@Private Json jsonArgument() {
		Json json = new Json();
		json.set(JsonKeyRoot,this.root.toJson());
		json.set(JsonKeyNodes,this.DBNodesToJson());
		json.set(JsonKeyLinks,this.LinksToJson());
		return json;
	}

	Commit Commit(String method, Json argument) {
		return this.commit_log.addCommit(method,argument);
	}

	@Private Json DBNodesToJson() {
		Json json = Json.parse("[]");
		for(int i = 0; i < this.nodes.getSize();i++) {
			json.add(this.nodes[i].toJson());
		}
		return json;
	}

	@Private void LinkToTreeJson(String name,int index,LinkTree[] tree) {
		LinkTree[] lts = [];
		for(int i = 0;i < this.links.getSize(); i++) {
			if(name == this.links[i].parent) {
				LinkTree lt = new LinkTree(this.links[i].child);
				lts.add(lt);
			}
		}
		tree[index].children = lts;
		for(int i = 0; i < lts.getSize(); i++) {
			this.LinkToTreeJson(lts[i].name, i,lts);
		}
	}

	@Private Json LinksToJson() {
		String name = this.root.name;
		LinkTree ltroot = new LinkTree(name);
		LinkTree[] lts = [];
		for(int i = 0; i < this.links.getSize(); i++) {
			if(name == this.links[i].parent) {
				LinkTree lt = new LinkTree(this.links[i].child);
				lts.add(lt);
			}
		}
		for(int i = 0; i < lts.getSize(); i++) {
			this.LinkToTreeJson(lts[i].name, i, lts);
		}
		ltroot.children = lts;
		return ltroot.toJson();
	}

	@Public Json toJson() {
		Json json = this.jsonArgument();
		json.set(JsonKeyCommitLog,this.commit_log.toJson());
		json.setString("HEAD", this.commit_log.head);
		return json;
	}

	DBNode SearchDBNode(String search) {
		for(int i = 0; i < this.nodes.getSize(); i++) {
			if(this.nodes[i].name == search) {
				return this.nodes[i];
			}
		}
		return NULL;
	}

	int SearchDBNodeIndex(String search) {
		for(int i = 0; i < this.nodes.getSize(); i++) {
			if(this.nodes[i].name == search) {
				return i;
			}
		}
		return -1;
	}

	int[] SearchLinkIndexes(String searchText) {
		int[] ret = [];
		for(int i = 0; i < this.links.getSize(); i++) {
			if(this.links[i].child == searchText) {
				ret.add(i);
			}
			if(this.links[i].parent == searchText) {
				ret.add(i);
			}
		}
		return ret;
	}

	void DeleteLink(int i) {
		Link l = this.links[i];
		this.Commit(MtdDeleteLink, l.toJson());
		this.links.removeAt(i);
	}

	int SearchLinkIndex(String parent, String child) {
		for(int i = 0; i < this.links.getSize(); i++) {
			if(this.links[i].child == child && this.links[i].parent == parent) {
				return i;
			}
		}
		return -1;
	}

	void UpdateLink(int is_child,String parent, String newId, String child) {
		int i = this.SearchLinkIndex(parent,child);
		Link l = this.links[i];
		Json json = new Json();
		json.set("before", l.toJson());
		if(is_child == 0) {
			l.parent = newId;
		}else{
			l.child  = newId;
		}
		json.set("after", l.toJson());
		this.Commit(MtdUpdateLink,json);
	}
}

//@Abstract
class DBDriver {
	DBDriver() {
	}

	Json getContext(int id) {
	}

	void addArgumentRoot(String name, int id) {
	}

	Argument SearchArgument(String name) {
	}

	int CreateArgument(String name) {
	}

	void CreateDBNode(String name,String nodeType, Json content) {
	}

	void InsertCommit(String argument_name, String method, Commit c) {
	}

	void InsertLink(String argument_name, String parent_name, String child_name) {
	}

	void addContext(String argument_name, String context_name, Json context) {
	}

}

class MySQLDriver extends DBDriver {
	Connection con;

	MySQLDriver(String name, String passwd) {
		this.con = new Connection("mysql://" + name + ":" + passwd + "@localhost:3306");
		this.con.query("USE dcasedb;");
	}

	DBNode MakeNode(String NodeType) {
		if(NodeType == NodeTypeGoal) {
			return new Goal();
		} else if (NodeType == NodeTypeStrategy) {
			return new Strategy();
		} else if (NodeType == NodeTypeContext) {
			return new Context();
		} else if (NodeType == NodeTypeEvidence) {
			return new Evidence();
		}
		return new DBNode();
	}

	Json getContext(int id) {
		Json json = new Json();
		ResultSet r = this.con.query("SELECT context_key,value FROM Context WHERE node_id="+id);
		while(r.next()) {
			String key = r.getString("context_key");
			String value = r.getString("value");
			json.setString(key,value);
		}
		return json;
	}

	DBNode[] getDBNodeList(int argument_id) {
		ResultSet r = this.con.query("SELECT DBNode.id,name,description,evidence_flag,type_name FROM DBNode,NodeType WHERE argument_id="+argument_id+" AND nodeType_id=NodeType.id;");
		DBNode[] nodes = [];
		while(r.next()) {
			String type = r.getString("type_name");
			DBNode node = this.MakeNode(type);
			node.name = r.getString("name");
			node.description = r.getString("description");
			node.is_evidence = r.getBoolean("evidence_flag");
			if(type == "Context") {
				Context context = node as Context;
				context.condition = this.getContext(r.getInt("id"));
				nodes.add(context);
			} else {
				nodes.add(node);
			}
		}
		return nodes;
	}

	Link[] getLinksList(int argument_id) {
		ResultSet r = this.con.query("SELECT parent.name AS parent_name,child.name AS child_name FROM NodeLink INNER JOIN DBNode AS parent ON NodeLink.parent_Node_id=parent.id INNER JOIN DBNode AS child ON NodeLink.child_Node_id=child.id WHERE NodeLink.argument_id=" + argument_id);
		Link[] links = [];
		while(r.next()) {
			Link l = new Link();
			l.parent = r.getString("parent_name");
			l.child = r.getString("child_name");
			links.add(l);
		}
		return links;
	}

	CommitLog getCommitLog(int argument_id) {
		ResultSet r = this.con.query("SELECT method,args,revision,time FROM Commit WHERE argument_id=" + argument_id);
		Commit[] commits = [];
		while(r.next()) {
			Commit c = new Commit();
			c.method = r.getString("method");
			c.argument = Json.parse(r.getString("args"));
			c.revision = r.getString("revision");
			c.time     = r.getInt("time");
			commits.add(c);
		}
		CommitLog cl = new CommitLog();
		cl.commits = commits;
		cl.head    = commits[commits.getSize()-1].revision;
		return cl;
	}

	Argument SearchArgument(String name) {
		int argument_id = this.getArgumentId(name);

		DBNode[] nodes = this.getDBNodeList(argument_id);
		Link[]   links = this.getLinksList(argument_id);
		CommitLog clog = this.getCommitLog(argument_id);
		//FIXME
		DBNode n;
		for(int i = 0; i < nodes.getSize(); i++) {
			if(nodes[i].name == name) {
				n = nodes[i];
			}
		}
		return new Argument(nodes,links,clog,n);
	}

	int CreateArgument(String name) {
		this.con.query("INSERT INTO Argument(name) VALUES('"+name+"')");
		return this.con.getInsertId();
	}

	void addArgumentRoot(String name, int id) {
		int nodeid = this.getDBNodeId(name);
		this.con.query("UPDATE Argument SET goal_id=" + nodeid +" WHERE id=" + id);
	}

	int getArgumentId(String name) {
		ResultSet argumentId = this.con.query("SELECT id FROM Argument WHERE name='" + name+"'");
		int id;
		while(argumentId.next()) {
			id = argumentId.getInt("id");
		}
		return id;
	}

	int getDBNodeId(String name) { //FIXME Argument_name
		ResultSet nodeId = this.con.query("SELECT id FROM DBNode WHERE name='" + name + "'");
		int id;
		while(nodeId.next()) {
			id = nodeId.getInt("id");
		}
		return id;
	}

	void InsertCommit(String argument_name, String method, Commit c) {
		int id = this.getArgumentId(argument_name);
		this.con.query("INSERT INTO Commit(method,args,argument_id,revision,time) VALUES ('"+ method +"','" + c.argument + "'," + id + ",'"+c.revision+"',"+ c.time +")");
	}

	void CreateDBNode(String name,String nodeType, Json content) {
		System.p(content.getString("description"));
		ResultSet nodeTypeId = this.con.query("SELECT id FROM NodeType WHERE type_name='" + nodeType + "'");
		int nodeId;
		while(nodeTypeId.next()) {
			nodeId = nodeTypeId.getInt("id");
		}
		int argument_id     = this.getArgumentId(name);
		String nodeName     = content.getString("name");
		String description  = content.getString("description");
		boolean is_evidence = content.getBoolean("is_evidence");
		String evidence = "FALSE";
		if(is_evidence) {
			evidence = "TRUE";
		}
		this.con.query("INSERT INTO DBNode(name,description,evidence_flag,nodeType_id,argument_id) VALUES('" + nodeName +"','"+ description + "'," + evidence + ","+nodeId+"," + argument_id +") ");
	}

	void InsertLink(String argument_name, String parent_name, String child_name) {
		int argument_id = this.getArgumentId(argument_name);
		int parent_id   = this.getDBNodeId(parent_name);
		int child_id    = this.getDBNodeId(child_name);
		this.con.query("INSERT INTO NodeLink(argument_id,parent_Node_id,child_Node_id) VALUES('"+argument_id+"','"+parent_id+"','"+child_id+"')");
	}

	void addContext(String argument_name, String context_name, Json context) {
		int argument_id     = this.getArgumentId(argument_name);
		int context_id      = this.getDBNodeId(context_name);
		String[] keys = context.keys();
		for(int i = 0; i<keys.getSize();i++) {
			String key = keys[i];
			this.con.query("INSERT INTO Context(context_key,value,node_id) Values('"+ key +"','" +context.getString(key)+ "'," +context_id+ ")");
		}
	}
}

class DCaseDB {
	Map[Argument] tree;
	DBDriver db;

	DCaseDB() {}

	@Public void CreateArgument(String name, String description) {
		int id = this.db.CreateArgument(name);
		Json content = new Json();
		content.setString("name",name);
		content.setString("description",description);
		content.setString("DBNodeType","Goal");

		this.tree.set(name,new Argument());
		Argument argument = this.tree.get(name);
		Commit c = argument.Commit("CreateArgument",content);
		this.db.InsertCommit(name,"CreateArgument",c);

		Goal g = this.CreateDBNode(name,content) as Goal;
		argument.root = g;
		this.db.addArgumentRoot(name,id);
	}

	@Public void Connect(String name, String passwd) {
		//this.db = new DBDriver();
		this.db = new MySQLDriver(name,passwd);
	}

	//TODO Search Argument
	@Public Argument SearchArgument(String name) {
		if(this.tree.has(name)) {
			return this.tree.get(name);
		} else {
			Argument a = this.db.SearchArgument(name);
			this.tree.set(name,a);
			return a;
		}
	}

	//TODO many tree & return DBNode[]
	@Public DBNode SearchDBNode(String root, String searchText) {
		return this.SearchArgument(root).SearchDBNode(searchText);
	}

	@Public DBNode CreateDBNode(String name, Json content) {
		Argument argument = this.SearchArgument(name);
		String NodeType = content.getString(JsonKeyDBNodeType);
		if(NodeType == NodeTypeGoal) {
			Commit c = argument.Commit(MtdCreateDBNode,content);
			this.db.CreateDBNode(name,NodeType,content);
			this.db.InsertCommit(name,MtdCreateDBNode,c);

			Goal node = new Goal(content);
			argument.nodes.add(node);
			return node;
		} else if (NodeType == NodeTypeStrategy) {
			Commit c = argument.Commit(MtdCreateDBNode,content);
			this.db.CreateDBNode(name,NodeType,content);
			this.db.InsertCommit(name,MtdCreateDBNode,c);

			Strategy node = new Strategy(content);
			argument.nodes.add(node);
			return node;
		} else if (NodeType == NodeTypeContext) {
			Commit c = argument.Commit(MtdCreateDBNode,content);
			this.db.CreateDBNode(name,NodeType,content);
			this.db.InsertCommit(name,MtdCreateDBNode,c);

			Context node = new Context(content);
			argument.nodes.add(node);
			return node;
		} else if (NodeType == NodeTypeEvidence) {
			Commit c = argument.Commit(MtdCreateDBNode,content);
			this.db.CreateDBNode(name,NodeType,content);
			this.db.InsertCommit(name,MtdCreateDBNode,c);

			Evidence node = new Evidence(content);
			argument.nodes.add(node);
			return node;
		}
		return NULL; //FIXME
	}

	@Public void InsertLink(String name, String parent, String child) {
		Argument argument = this.SearchArgument(name);
		this.db.InsertLink(name,parent,child);
		Link l = new Link(parent, child);
		argument.links.add(l);
		argument.Commit(MtdInsertLink,l.toJson());
	}

	@Public void UpdateDBNode(String name, DBNode node, Json contents) {
		this.SearchArgument(name).Commit(MtdUpdateDBNode, node.update(contents));
	}

	@Public void UpdateParentLink(String name, String parent_old, String parent_new, String child) {
		this.SearchArgument(name).UpdateLink(0,parent_old,parent_new,child);
	}

	@Public void UpdateChildLink(String name, String parent, String child_old, String child_new) {
		this.SearchArgument(name).UpdateLink(1,parent,child_new,child_old);
	}

	@Public void DeleteDBNode(String name, String node) {
		Argument argument = this.SearchArgument(name);
		int[] link_idx = argument.SearchLinkIndexes(node);
		int   node_idx = argument.SearchDBNodeIndex(node);
		for(int i = 0; i < link_idx.getSize(); i++) {
			argument.DeleteLink(link_idx[i]-i); //FIXME
		}
		argument.Commit(MtdDeleteDBNode,argument.nodes[node_idx].toJson());
		argument.nodes.removeAt(node_idx);
	}

	@Public void DeleteLink(String name, String parent, String child) {
		Argument argument = this.SearchArgument(name);
		argument.DeleteLink(argument.SearchLinkIndex(parent,child));
	}

	//TODO
	@Public Json ShowRevision(String name, String revision) {
		Argument argument = this.SearchArgument(name);
		return this.useCommitLog(argument);
	}

	@Public Json useCommitLog(Argument argument) {
		Json json = argument.toJson();
		Json commitlog = json.get(JsonKeyCommitLog);
		for(int i = 0; i < commitlog.getSize(); i++) {
			System.p(commitlog.get(i).getString("method"));
		}
		return json;
	}

	@Public void AddContext(String argument_name, String context_name, Json context) {
		Argument argument = this.SearchArgument(argument_name);
		Context c = argument.SearchDBNode(context_name) as Context;
		c.addKeyValue(context);
		Commit c = argument.Commit("AddContext",context); //FIXME
		this.db.addContext(argument_name,context_name,context);
		this.db.InsertCommit(argument_name,"AddContext",c);
	}
}
