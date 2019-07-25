[Inter::Symbols::] Symbols.

To manage named symbols in inter code.

@h Symbols themselves.

@e LABEL_ISYMT from 1
@e MISC_ISYMT
@e PACKAGE_ISYMT
@e PTYPE_ISYMT

@e DEFINED_ISYMD from 1
@e UNDEFINED_ISYMD

@e PRIVATE_ISYMS from 1
@e PUBLIC_ISYMS
@e EXTERNAL_ISYMS
@e LINK_ISYMS

=
typedef struct inter_symbol {
	int allocation_id;
	inter_t symbol_ID;
	struct inter_symbols_table *owning_table;
	struct text_stream *symbol_name;
	int symbol_type;
	int symbol_scope;
	int definition_status;
	struct inter_tree_node *definition;
	struct inter_symbol *equated_to;
	struct text_stream *equated_name;
	int symbol_flags;
	int no_symbol_annotations;
	struct inter_annotation symbol_annotations[MAX_INTER_ANNOTATIONS_PER_SYMBOL];
	struct text_stream *translate_text;
	struct text_stream *append_text;
} inter_symbol;

@ =
int next_symbol_aid = 0;
inter_symbol *Inter::Symbols::new(text_stream *name, inter_symbols_table *T, inter_t ID) {
	if (Str::len(name) == 0) internal_error("symbol cannot have empty text as identifier");

	inter_symbol *symb = CREATE(inter_symbol);
	symb->allocation_id = next_symbol_aid++;
	symb->owning_table = T;
	symb->symbol_ID = ID;
	symb->symbol_type = MISC_ISYMT;
	symb->symbol_scope = PUBLIC_ISYMS;
	symb->symbol_name = Str::duplicate(name);
	Inter::Symbols::undefine(symb);
	symb->no_symbol_annotations = 0;
	for (int i=0; i<MAX_INTER_ANNOTATIONS_PER_SYMBOL; i++)
		symb->symbol_annotations[i] = Inter::Defn::invalid_annotation();
	symb->equated_to = NULL;
	symb->equated_name = NULL;
	symb->symbol_flags = 0;
	symb->translate_text = NULL;
	symb->append_text = NULL;
	LOGIF(INTER_SYMBOLS, "Created symbol $3 in $4\n", symb, T);

	return symb;
}

void Inter::Symbols::log(OUTPUT_STREAM, void *vs) {
	inter_symbol *S = (inter_symbol *) vs;
	if (S == NULL) WRITE("<no-symbol>");
	else {
		Inter::SymbolsTables::symbol_to_url_name(DL, S);
		WRITE("{%d}", S->symbol_ID - SYMBOL_BASE_VAL);
		if (Str::len(S->translate_text) > 0) WRITE("'%S'", S->translate_text);
	}
}

@ =
int Inter::Symbols::is_stored_in_data(inter_t val1, inter_t val2) {
	if (val1 == ALIAS_IVAL) return TRUE;
	return FALSE;
}

void Inter::Symbols::to_data(inter_tree *I, inter_package *pack, inter_symbol *S, inter_t *val1, inter_t *val2) {
	if (S == NULL) internal_error("no symbol");
	*val1 = ALIAS_IVAL; *val2 = Inter::SymbolsTables::id_from_symbol(I, pack, S);
}

@ =
void Inter::Symbols::write_declaration(OUTPUT_STREAM, inter_symbol *mark, int N) {
	for (int L=0; L<N; L++) WRITE("\t");
	WRITE("symbol ");
	switch (mark->symbol_scope) {
		case PRIVATE_ISYMS: WRITE("private"); break;
		case PUBLIC_ISYMS: WRITE("public"); break;
		case EXTERNAL_ISYMS: WRITE("external"); break;
		case LINK_ISYMS: WRITE("link"); break;
		default: internal_error("unknown symbol type"); break;
	}
	WRITE(" ");
	switch (mark->symbol_type) {
		case LABEL_ISYMT: WRITE("label"); break;
		case MISC_ISYMT: WRITE("misc"); break;
		case PACKAGE_ISYMT: WRITE("package"); break;
		case PTYPE_ISYMT: WRITE("packagetype"); break;
		default: internal_error("unknown symbol type"); break;
	}
	WRITE(" %S", mark->symbol_name);
	if (Inter::Symbols::get_flag(mark, MAKE_NAME_UNIQUE)) WRITE("*");
	if (mark->symbol_scope == LINK_ISYMS) {
		WRITE(" == %S", mark->equated_name);
	} else {
		text_stream *trans_name = Inter::Symbols::get_translate(mark);
		if (Str::len(trans_name) > 0)
			WRITE(" -> %S", trans_name);
		inter_symbol *eq = mark->equated_to;
		if (eq) {
			WRITE(" == ");
			Inter::SymbolsTables::symbol_to_url_name(OUT, eq);
		}
	}
}

void Inter::Symbols::define(inter_symbol *S, inter_tree_node *P) {
	if (S == NULL) internal_error("tried to define null symbol");
	S->definition = P;
	S->definition_status = DEFINED_ISYMD;
}

inter_tree_node *Inter::Symbols::definition(inter_symbol *S) {
	if (S == NULL) internal_error("tried to find definition of null symbol");
	return S->definition;
}

int Inter::Symbols::is_defined(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (Inter::Symbols::definition(S)) return TRUE;
	return FALSE;
}

int Inter::Symbols::evaluate_to_int(inter_symbol *S) {
	inter_tree_node *P = Inter::Symbols::definition(S);
	if ((P) &&
		(P->W.data[ID_IFLD] == CONSTANT_IST) &&
		(P->W.data[FORMAT_CONST_IFLD] == CONSTANT_DIRECT) &&
		(P->W.data[DATA_CONST_IFLD] == LITERAL_IVAL)) {
		return (int) P->W.data[DATA_CONST_IFLD + 1];
	}
	if ((P) &&
		(P->W.data[ID_IFLD] == CONSTANT_IST) &&
		(P->W.data[FORMAT_CONST_IFLD] == CONSTANT_DIRECT) &&
		(P->W.data[DATA_CONST_IFLD] == ALIAS_IVAL)) {
		inter_symbols_table *scope = S->owning_table;
		inter_symbol *alias_to = Inter::SymbolsTables::symbol_from_id(scope, P->W.data[DATA_CONST_IFLD + 1]);
		return Inter::Symbols::evaluate_to_int(alias_to);
	}
	return -1;
}

void Inter::Symbols::strike_definition(inter_symbol *S) {
	if (S) {
		inter_tree_node *D = Inter::Symbols::definition(S);
		if (D) Inter::Tree::remove_node(D);
		Inter::Symbols::undefine(S);
	}
}

void Inter::Symbols::remove_from_table(inter_symbol *S) {
	int index = (int) S->symbol_ID - (int) SYMBOL_BASE_VAL;
	S->owning_table->symbol_array[index] = NULL;
}

void Inter::Symbols::undefine(inter_symbol *S) {
	if (S == NULL) internal_error("tried to undefine null symbol");
	S->definition = NULL;
	S->definition_status = UNDEFINED_ISYMD;
}

void Inter::Symbols::clear_transient_flags(inter_symbol *symb) {
	symb->symbol_flags = (symb->symbol_flags) & NONTRANSIENT_SYMBOL_BITS;
}

int Inter::Symbols::get_flag(inter_symbol *symb, int f) {
	if (symb == NULL) internal_error("no symbol");
	return (symb->symbol_flags & f)?TRUE:FALSE;
}

void Inter::Symbols::set_flag(inter_symbol *symb, int f) {
	if (symb == NULL) internal_error("no symbol");
	symb->symbol_flags = symb->symbol_flags | f;
}

void Inter::Symbols::clear_flag(inter_symbol *symb, int f) {
	if (symb == NULL) internal_error("no symbol");
	if (symb->symbol_flags & f) symb->symbol_flags = symb->symbol_flags - f;
}

void Inter::Symbols::set_translate(inter_symbol *symb, text_stream *S) {
	if (symb == NULL) internal_error("no symbol");
	symb->translate_text = Str::duplicate(S);
}

text_stream *Inter::Symbols::get_translate(inter_symbol *symb) {
	if (symb == NULL) internal_error("no symbol");
	return symb->translate_text;
}

void Inter::Symbols::set_append(inter_symbol *symb, text_stream *S) {
	if (symb == NULL) internal_error("no symbol");
	symb->append_text = S;
}

text_stream *Inter::Symbols::get_append(inter_symbol *symb) {
	if (symb == NULL) internal_error("no symbol");
	return symb->append_text;
}

void Inter::Symbols::annotate(inter_symbol *symb, inter_annotation IA) {
	if (symb == NULL) internal_error("annotated null symbol");
	if (symb->no_symbol_annotations >= MAX_INTER_ANNOTATIONS_PER_SYMBOL)
		internal_error("too many annotations");
	symb->symbol_annotations[symb->no_symbol_annotations++] = IA;
}

void Inter::Symbols::annotate_i(inter_symbol *symb, inter_t annot_ID, inter_t n) {
	inter_annotation IA = Inter::Defn::annotation_from_bytecode(annot_ID, n);
	Inter::Symbols::annotate(symb, IA);
}

int Inter::Symbols::read_annotation(inter_symbol *symb, inter_t ID) {
	for (int i=0; i<symb->no_symbol_annotations; i++)
		if (symb->symbol_annotations[i].annot->annotation_ID == ID)
			return (int) symb->symbol_annotations[i].annot_value;
	return -1;
}

text_stream *Inter::Symbols::read_annotation_t(inter_symbol *symb, inter_tree *I, inter_t ID) {
	for (int i=0; i<symb->no_symbol_annotations; i++)
		if (symb->symbol_annotations[i].annot->annotation_ID == ID) {
			inter_t N = symb->symbol_annotations[i].annot_value;
			return Inter::Warehouse::get_text(Inter::Tree::warehouse(I), N);
		}
	return NULL;
}

void Inter::Symbols::annotate_t(inter_tree *I, inter_package *owner, inter_symbol *symb, inter_t annot_ID, text_stream *S) {
	inter_t n = Inter::Warehouse::create_text(Inter::Tree::warehouse(I), owner);
	Str::copy(Inter::Warehouse::get_text(Inter::Tree::warehouse(I), n), S);
	inter_annotation IA = Inter::Defn::annotation_from_bytecode(annot_ID, n);
	Inter::Symbols::annotate(symb, IA);
}

void Inter::Symbols::write_annotations(OUTPUT_STREAM, inter_tree_node *F, inter_symbol *symb) {
	if (symb)
		for (int i=0; i<symb->no_symbol_annotations; i++)
			Inter::Defn::write_annotation(OUT, F, symb->symbol_annotations[i]);
}

@ =
int Inter::Symbols::is_predeclared(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope != PUBLIC_ISYMS) return FALSE;
	if (S->symbol_type != MISC_ISYMT) return FALSE;
	if (S->definition_status != UNDEFINED_ISYMD) return FALSE;
	return TRUE;
}

int Inter::Symbols::is_predeclared_local(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope != PRIVATE_ISYMS) return FALSE;
	if (S->symbol_type != MISC_ISYMT) return FALSE;
	if (S->definition_status != UNDEFINED_ISYMD) return FALSE;
	return TRUE;
}

int Inter::Symbols::is_undefined_private(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope != PRIVATE_ISYMS) return FALSE;
	if (S->definition_status != UNDEFINED_ISYMD) return FALSE;
	return TRUE;
}

int Inter::Symbols::is_extern(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope == EXTERNAL_ISYMS) return TRUE;
	return FALSE;
}

void Inter::Symbols::extern(inter_symbol *S) {
	S->symbol_scope = EXTERNAL_ISYMS;
	S->symbol_type = MISC_ISYMT;
	S->definition_status = UNDEFINED_ISYMD;
}

int Inter::Symbols::is_label(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope != PRIVATE_ISYMS) return FALSE;
	if (S->symbol_type != LABEL_ISYMT) return FALSE;
	return TRUE;
}

void Inter::Symbols::label(inter_symbol *S) {
	if (Str::get_first_char(S->symbol_name) != '.') {
		LOG("Name is %S\n", S->symbol_name);
		internal_error("not a label name");
	}
	S->symbol_scope = PRIVATE_ISYMS;
	S->symbol_type = LABEL_ISYMT;
	S->definition_status = UNDEFINED_ISYMD;
}

void Inter::Symbols::local(inter_symbol *S) {
	S->symbol_scope = PRIVATE_ISYMS;
	S->symbol_type = MISC_ISYMT;
	S->definition_status = UNDEFINED_ISYMD;
}

int Inter::Symbols::is_local(inter_symbol *S) {
	if (S == NULL) return FALSE;
	if (S->symbol_scope != PRIVATE_ISYMS) return FALSE;
	if (S->symbol_type != MISC_ISYMT) return FALSE;
	return TRUE;
}
