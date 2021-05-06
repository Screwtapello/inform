[CompilationUnits::] Compilation Units.

The source text is divided into compilation units, and the material they lead
to is similarly divided up.

@h Units.
The source text is divided up into "compilation units". Each extension is its
own compilation unit, and so is the main source text. This demarcation is also
reflected in the Inter hierarchy, where each different compilation unit has its
own sub-hierarchy, a |module_package|.

=
typedef struct compilation_unit {
	struct module_package *to_module;
	struct parse_node *head_node;
	CLASS_DEFINITION
} compilation_unit;

void CompilationUnits::log(compilation_unit *cu) {
	if (cu == NULL) LOG("<null>");
	else LOG("unit'%W'", Node::get_text(cu->head_node));
}

module_package *CompilationUnits::to_module_package(compilation_unit *C) {
	if (C == NULL) internal_error("no unit");
	return C->to_module;
}

@ The main source text, and the extensions included, are exactly the level-0
|HEADING_NT| nodes in the parse tree which correspond to files read in, so we
can find them easily enough. This is done very early in compilation: see
//core: How To Compile//.

=
void CompilationUnits::determine(void) {
	SyntaxTree::traverse(Task::syntax_tree(), CompilationUnits::look_for_cu);
}

void CompilationUnits::look_for_cu(parse_node *p) {
	if (Node::get_type(p) == HEADING_NT) {
		heading *h = Headings::from_node(p);
		if ((h) && (h->level == 0)) {
			source_location sl = Wordings::location(Node::get_text(p));
			if (sl.file_of_origin) @<Create a new compilation unit for this heading@>;
		}
	}
}

@<Create a new compilation unit for this heading@> =
	inform_extension *ext = Extensions::corresponding_to(
		Lexer::file_of_origin(Wordings::first_wn(Node::get_text(p))));

	TEMPORARY_TEXT(pname)
	@<Compose a name for the unit package this will lead to@>;
	module_package *M = Packaging::get_unit(Emit::tree(), pname, I"_module");
	@<Give M a category@>;
	if (ext) @<Give M metadata indicating the source extension@>;
	DISCARD_TEXT(pname)

	compilation_unit *C = CREATE(compilation_unit);
	C->head_node = p;
	C->to_module = M;
	CompilationUnits::join(p, C);

@<Give M a category@> =
	inter_ti cat = 1;
	if (ext) cat = 2;
	if (Extensions::is_standard(ext)) cat = 3;
	Hierarchy::apply_metadata_from_number(M->the_package, EXT_CATEGORY_MD_HL, cat);

@ The extension credit consists of a single line, with name, version number
and author; together with any "extra credit" asked for by the extension.

@<Give M metadata indicating the source extension@> =
	Hierarchy::apply_metadata(M->the_package, EXT_AUTHOR_MD_HL,
		ext->as_copy->edition->work->raw_author_name);
	Hierarchy::apply_metadata(M->the_package, EXT_TITLE_MD_HL,
		ext->as_copy->edition->work->raw_title);
	TEMPORARY_TEXT(V)
	semantic_version_number N = ext->as_copy->edition->version;
	WRITE_TO(V, "%v", &N);
	Hierarchy::apply_metadata(M->the_package, EXT_VERSION_MD_HL, V);
	DISCARD_TEXT(V)
	inter_name *iname = Hierarchy::make_iname_in(EXTENSION_ID_HL, M->the_package);
	Emit::numeric_constant(iname, 0);
	TEMPORARY_TEXT(C)
	WRITE_TO(C, "%S", ext->as_copy->edition->work->raw_title);
	if (VersionNumbers::is_null(N) == FALSE) WRITE_TO(C, " version %v", &N);
	WRITE_TO(C, " by %S", ext->as_copy->edition->work->raw_author_name);
	if (Str::len(ext->extra_credit_as_lexed) > 0)
		WRITE_TO(C, " (%S)", ext->extra_credit_as_lexed);
	Hierarchy::apply_metadata(M->the_package, EXT_CREDIT_MD_HL, C);
	DISCARD_TEXT(C)
	TEMPORARY_TEXT(the_author_name)
	WRITE_TO(the_author_name, "%S", ext->as_copy->edition->work->author_name);
	int self_penned = FALSE;
	if (BibliographicData::story_author_is(the_author_name)) self_penned = TRUE;
	inter_ti modesty = 1;
	if ((ext->authorial_modesty == FALSE) &&      /* if (1) extension doesn't ask to be modest */
		((general_authorial_modesty == FALSE) || /* and (2a) author doesn't ask to be modest, or */
			(self_penned == FALSE)))             /*     (2b) didn't write this extension */
		modesty = 0;
	Hierarchy::apply_metadata_from_number(M->the_package, EXT_MODESTY_MD_HL, modesty);
	DISCARD_TEXT(the_author_name)

@ Here we must find a unique name, valid as an Inter identifier: the code
compiled from the compilation unit will go into a package of that name.

@<Compose a name for the unit package this will lead to@> =
	if (ext == NULL) {
		WRITE_TO(pname, "source_text");
	} else {
		WRITE_TO(pname, "%X", ext->as_copy->edition->work);
		LOOP_THROUGH_TEXT(pos, pname)
			if (Str::get(pos) == ' ')
				Str::put(pos, '_');
			else
				Str::put(pos, Characters::tolower(Str::get(pos)));
	}

@h What unit a node belongs to.
We are going to need to determine, for any node |p|, which compilation unit it
belongs to. If there were a fast way to go up in the syntax tree, that would be
easy -- we could simply run upward until we reach a level-0 heading. But the
node links all run downwards. Instead, we'll annotate the nodes in a given unit.
The annotations propagates downwards thus:

=
void CompilationUnits::join(parse_node *p, compilation_unit *C) {
	Node::set_unit(p, C);
	for (parse_node *d = p->down; d; d = d->next)
		CompilationUnits::join(d, C);
}

@ Nodes are sometimes added later, so that it may be necessary to mark them
by hand as belonging to the same nodes as their progenitors:

=
void CompilationUnits::assign_to_same_unit(parse_node *to, parse_node *from) {
	CompilationUnits::join(to, Node::get_unit(from));
}

@ As promised, then, given a parse node, we have to return its compilation unit:
but that's now easy.

=
compilation_unit *CompilationUnits::find(parse_node *from) {
	if (from) return Node::get_unit(from);
	return NULL;
}
