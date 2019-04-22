[Modules::] Compilation Modules.

To identify which parts of the source text come from which source (the main source
text, the Standard Rules, or another extension).

@h Compilation modules.
Inform is a language in which it is semantically relevant which source file the
source text is coming from: unlike, say, C, where |#include| allows files to include
each other in arbitrary ways. In Inform, all source text comes from one of the
following places:

(a) The main source text, as shown in the Source panel of the UI app;
(b) An extension file, including the Standard Rules extension;
(c) Invented text created by the compiler itself.

The Inter hierarchy also splits, with named modules representing each possibility
in (a) or (b) above. This section of code determines to which module any new
definition (of, say, a property or kind) belongs.

=
typedef struct compilation_module {
	struct module_package *inter_presence;
	struct parse_node *hanging_from;
	MEMORY_MANAGEMENT
} compilation_module;

// compilation_module *pool_module = NULL;
compilation_module *SR_module = NULL; /* the one for the Standard Rules */

compilation_module *Modules::SR(void) {
	return SR_module;
}

@ We find these by performing a traverse of the parse tree, and looking for
level-0 headings, which are the nodes from which these blocks of source text hang:

=
void Modules::traverse_to_define(void) {
//	pool_module = Modules::new(NULL);
	ParseTree::traverse(Modules::look_for_cu);
}

void Modules::look_for_cu(parse_node *p) {
	if (ParseTree::get_type(p) == HEADING_NT) {
		heading *h = ParseTree::get_embodying_heading(p);
		if ((h) && (h->level == 0)) {
			compilation_module *cm = Modules::new(p);
			if (SR_module == NULL) SR_module = cm;
		}
	}
}

compilation_module *Modules::new(parse_node *from) {
	extension_file *owner = NULL;
//	if ((from) && (Wordings::nonempty(ParseTree::get_text(from)))) {
// WRITE_TO(STDOUT, "MN: %W\n", ParseTree::get_text(from));
		source_location sl = Wordings::location(ParseTree::get_text(from));
		if (sl.file_of_origin == NULL) owner = standard_rules_extension;
		else owner = SourceFiles::get_extension_corresponding(
			Lexer::file_of_origin(Wordings::first_wn(ParseTree::get_text(from))));
		if (owner == NULL) return NULL;
//	} else {
//WRITE_TO(STDOUT, "MN: Blank!\n");
//	return NULL;
//}

//	if ((owner == NULL) && (pool_module != NULL)) return pool_module;

	compilation_module *C = CREATE(compilation_module);
	C->hanging_from = from;
//	if (C->allocation_id == 0) C->abbreviation = I"root";
//	else {
//		C->abbreviation = Str::new();
//		if (from == NULL) internal_error("unlocated CM");
		if (Modules::markable(from) == FALSE) internal_error("inappropriate CM");
//		char *x = "";
//		if ((C->allocation_id == 1) && (export_mode)) x = "x";
//		if ((C->allocation_id == 0) && (export_mode)) x = "x";
//		WRITE_TO(C->abbreviation, "m%s%d", x, C->allocation_id);
		ParseTree::set_module(from, C);
		Modules::propagate_downwards(from->down, C);
//	}

	TEMPORARY_TEXT(PN);
	@<Compose a name for the module package this will lead to@>;
	C->inter_presence = Packaging::get_module(PN);
	DISCARD_TEXT(PN);

	return C;
}

@ Here we must find a unique name, valid as an Inter identifier: the code
compiled from the compilation module will go into a package of that name.

@<Compose a name for the module package this will lead to@> =
	if (owner == standard_rules_extension) WRITE_TO(PN, "standard_rules");
	else if (owner == NULL) WRITE_TO(PN, "source_text");
	else {
		WRITE_TO(PN, "%X", Extensions::Files::get_eid(owner));
		LOOP_THROUGH_TEXT(pos, PN)
			if (Str::get(pos) == ' ')
				Str::put(pos, '_');
			else
				Str::put(pos, Characters::tolower(Str::get(pos)));
	}

@ We are eventually going to need to be able to look at a given node in the parse
tree and say which compilation module it belongs to. If there were a fast way
to go up in the tree, that would be easy -- we could simply run upward until we
reach a level-0 heading. But the node links all run downwards. Instead, we'll
"mark" nodes in the tree, annotating them with the compilation module which owns
them. This is done by "propagating downwards", as follows, and marks only nodes
of certain structural kinds.

@ =
void Modules::propagate_downwards(parse_node *P, compilation_module *C) {
	while (P) {
		if (Modules::markable(P)) ParseTree::set_module(P, C);
		Modules::propagate_downwards(P->down, C);
		P = P->next;
	}
}

int Modules::markable(parse_node *from) {
	if (from == NULL) return FALSE;
	if ((ParseTree::get_type(from) == ROOT_NT) ||
		(ParseTree::get_type(from) == HEADING_NT) ||
		(ParseTree::get_type(from) == SENTENCE_NT) ||
		(ParseTree::get_type(from) == ROUTINE_NT)) return TRUE;
	return FALSE;
}

@ As promised, then, given a parse node, we have to return its compilation module:
but that's now easy, as we just have to read off the annotation made above --

=
compilation_module *Modules::find(parse_node *from) {
	if (from == NULL) return NULL;
	if (Modules::markable(from)) return ParseTree::get_module(from);
//	return pool_module;
	return NULL;
}

@h Current module.
Inform has a concept of the "current module" it's working on, much as it has
a concept of "current sentence".

=
compilation_module *current_CM = NULL;

compilation_module *Modules::current_or_null(void) {
	return Modules::current();
//	if (current_CM) return current_CM;
//	return NULL;
}

compilation_module *Modules::current(void) {
	if (current_CM) return current_CM;
//	return pool_module;
	return NULL;
}

//void Modules::set_current_to_SR(void) {
//	if (SR_module == NULL) internal_error("too soon");
//	current_CM = SR_module;
//}

void Modules::set_current_to(compilation_module *CM) {
	current_CM = CM;
}

void Modules::set_current(parse_node *P) {
	if (P) current_CM = Modules::find(P);
	else current_CM = NULL;
}

@h Relating to Inter.
Creating the necessary package, of type |_module|, is the work of the
Packaging code.

=
module_package *Modules::inter_presence(compilation_module *C) {
	if (C == NULL) internal_error("no module");
	return C->inter_presence;
}
