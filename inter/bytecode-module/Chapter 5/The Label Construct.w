[Inter::Label::] The Label Construct.

Defining the label construct.

@

@e LABEL_IST

=
void Inter::Label::define(void) {
	inter_construct *IC = InterConstruct::create_construct(
		LABEL_IST,
		L"(.%i+)",
		I"label", I"labels");
	IC->min_level = 0;
	IC->max_level = 100000000;
	IC->usage_permissions = INSIDE_CODE_PACKAGE;
	METHOD_ADD(IC, CONSTRUCT_READ_MTID, Inter::Label::read);
	METHOD_ADD(IC, CONSTRUCT_VERIFY_MTID, Inter::Label::verify);
	METHOD_ADD(IC, CONSTRUCT_WRITE_MTID, Inter::Label::write);
}

@

@d BLOCK_LABEL_IFLD 2
@d DEFN_LABEL_IFLD 3

@d EXTENT_LABEL_IFR 4

=
void Inter::Label::read(inter_construct *IC, inter_bookmark *IBM, inter_line_parse *ilp, inter_error_location *eloc, inter_error_message **E) {
	if (SymbolAnnotation::nonempty(&(ilp->set))) { *E = Inter::Errors::plain(I"__annotations are not allowed", eloc); return; }
	*E = InterConstruct::vet_level(IBM, LABEL_IST, ilp->indent_level, eloc);
	if (*E) return;
	inter_package *routine = InterConstruct::get_latest_block_package();
	if (routine == NULL) { *E = Inter::Errors::plain(I"'label' used outside function", eloc); return; }
	inter_symbols_table *locals = InterPackage::scope(routine);
	if (locals == NULL) { *E = Inter::Errors::plain(I"function has no symbols table", eloc); return; }

	inter_symbol *lab_name = InterSymbolsTable::symbol_from_name(locals, ilp->mr.exp[0]);
	if (InterSymbol::is_label(lab_name) == FALSE) { *E = Inter::Errors::plain(I"not a label", eloc); return; }

	*E = Inter::Label::new(IBM, lab_name, (inter_ti) ilp->indent_level, eloc);
}

inter_error_message *Inter::Label::new(inter_bookmark *IBM, inter_symbol *lab_name, inter_ti level, inter_error_location *eloc) {
	inter_tree_node *P = Inode::new_with_2_data_fields(IBM, LABEL_IST, 0, InterSymbolsTable::id_from_symbol_at_bookmark(IBM, lab_name), eloc, level);
	inter_error_message *E = InterConstruct::verify_construct(InterBookmark::package(IBM), P); if (E) return E;
	NodePlacement::move_to_moving_bookmark(P, IBM);
	return NULL;
}

void Inter::Label::verify(inter_construct *IC, inter_tree_node *P, inter_package *owner, inter_error_message **E) {
	if (P->W.extent != EXTENT_LABEL_IFR) { *E = Inode::error(P, I"extent wrong", NULL); return; }
	inter_symbol *lab_name = InterSymbolsTable::symbol_from_ID_in_package(owner, P->W.instruction[DEFN_LABEL_IFLD]);
	if (InterSymbol::is_label(lab_name) == FALSE) {
		*E = Inode::error(P, I"not a label", (lab_name)?(lab_name->symbol_name):NULL);
		return;
	}
	if (P->W.instruction[LEVEL_IFLD] < 1) { *E = Inode::error(P, I"label with bad level", NULL); return; }
	inter_symbols_table *locals = InterPackage::scope(owner);
	if (locals == NULL) { *E = Inode::error(P, I"no symbols table in function", NULL); return; }
	*E = Inter::Verify::local_defn(P, DEFN_LABEL_IFLD, locals);
}

void Inter::Label::write(inter_construct *IC, OUTPUT_STREAM, inter_tree_node *P, inter_error_message **E) {
	inter_package *pack = InterPackage::container(P);
	inter_symbol *lab_name = InterSymbolsTable::symbol_from_ID_in_package(pack, P->W.instruction[DEFN_LABEL_IFLD]);
	if (lab_name) {
		WRITE("%S", lab_name->symbol_name);
	} else { *E = Inode::error(P, I"cannot write label", NULL); return; }
}
