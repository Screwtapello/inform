[Inter::PropertyValue::] The PropertyValue Construct.

Defining the propertyvalue construct.

@

@e PROPERTYVALUE_IST

=
void Inter::PropertyValue::define(void) {
	inter_construct *IC = InterConstruct::create_construct(PROPERTYVALUE_IST, I"propertyvalue");
	InterConstruct::specify_syntax(IC, I"propertyvalue IDENTIFIER IDENTIFIER = TOKENS");
	InterConstruct::fix_instruction_length_between(IC, EXTENT_PVAL_IFR, EXTENT_PVAL_IFR);
	InterConstruct::permit(IC, INSIDE_PLAIN_PACKAGE_ICUP);
	METHOD_ADD(IC, CONSTRUCT_READ_MTID, Inter::PropertyValue::read);
	METHOD_ADD(IC, CONSTRUCT_VERIFY_MTID, Inter::PropertyValue::verify);
	METHOD_ADD(IC, CONSTRUCT_WRITE_MTID, Inter::PropertyValue::write);
}

@

@d PROP_PVAL_IFLD 2
@d OWNER_PVAL_IFLD 3
@d DVAL1_PVAL_IFLD 4
@d DVAL2_PVAL_IFLD 5

@d EXTENT_PVAL_IFR 6

=
void Inter::PropertyValue::read(inter_construct *IC, inter_bookmark *IBM, inter_line_parse *ilp, inter_error_location *eloc, inter_error_message **E) {
	*E = InterConstruct::check_level_in_package(IBM, PROPERTYVALUE_IST, ilp->indent_level, eloc);
	if (*E) return;

	if (SymbolAnnotation::nonempty(&(ilp->set))) { *E = Inter::Errors::plain(I"__annotations are not allowed", eloc); return; }

	inter_symbol *prop_name = TextualInter::find_symbol(IBM, eloc, ilp->mr.exp[0], PROPERTY_IST, E);
	if (*E) return;
	inter_symbol *owner_name = Inter::PropertyValue::parse_owner(eloc, InterBookmark::scope(IBM), ilp->mr.exp[1], E);
	if (*E) return;

	inter_ti plist_ID;
	if (Inter::Typename::is(owner_name)) plist_ID = Inter::Typename::properties_list(owner_name);
	else plist_ID = Inter::Instance::properties_list(owner_name);
	inter_node_list *FL = InterWarehouse::get_node_list(InterBookmark::warehouse(IBM), plist_ID);
	if (FL == NULL) internal_error("no properties list");

	inter_tree_node *X;
	LOOP_THROUGH_INTER_NODE_LIST(X, FL) {
		inter_symbol *prop_X = InterSymbolsTable::symbol_from_ID_at_node(X, PROP_PVAL_IFLD);
		if (prop_X == prop_name)
			{ *E = Inter::Errors::quoted(I"property already given", ilp->mr.exp[0], eloc); return; }
	}

	inter_type val_type = InterTypes::of_symbol(prop_name);
	inter_pair con_val = InterValuePairs::undef();
	*E = InterValuePairs::parse(ilp->line, eloc, IBM, val_type, ilp->mr.exp[2], &con_val, InterBookmark::scope(IBM));
	if (*E) return;

	*E = Inter::PropertyValue::new(IBM, InterSymbolsTable::id_from_symbol_at_bookmark(IBM, prop_name), InterSymbolsTable::id_from_symbol_at_bookmark(IBM, owner_name),
		con_val, (inter_ti) ilp->indent_level, eloc);
}

inter_symbol *Inter::PropertyValue::parse_owner(inter_error_location *eloc, inter_symbols_table *T, text_stream *name, inter_error_message **E) {
	*E = NULL;
	inter_symbol *symb = InterSymbolsTable::symbol_from_name(T, name);
	if (symb == NULL) { *E = Inter::Errors::quoted(I"no such symbol", name, eloc); return NULL; }
	inter_tree_node *D = InterSymbol::definition(symb);
	if (D == NULL) { *E = Inter::Errors::quoted(I"undefined symbol", name, eloc); return NULL; }
	if ((D->W.instruction[ID_IFLD] != TYPENAME_IST) &&
		(D->W.instruction[ID_IFLD] != INSTANCE_IST)) { *E = Inter::Errors::quoted(I"symbol of wrong type", name, eloc); return NULL; }
	return symb;
}

int Inter::PropertyValue::permitted(inter_tree_node *F, inter_package *pack, inter_symbol *owner, inter_symbol *prop_name) {
	inter_ti plist_ID;
	if (Inter::Typename::is(owner)) plist_ID = Inter::Typename::permissions_list(owner);
	else plist_ID = Inter::Instance::permissions_list(owner);
	inter_node_list *FL = Inode::ID_to_frame_list(F, plist_ID);
	inter_tree_node *X;
	LOOP_THROUGH_INTER_NODE_LIST(X, FL) {
		inter_symbol *prop_allowed = InterSymbolsTable::symbol_from_ID_at_node(X, PROP_PERM_IFLD);
		if (prop_allowed == prop_name)
			return TRUE;
	}
	inter_symbol *inst_kind;
	if (Inter::Typename::is(owner)) inst_kind = Inter::Typename::super(owner);
	else inst_kind = Inter::Instance::kind_of(owner);
	while (inst_kind) {
		inter_node_list *FL =
			Inode::ID_to_frame_list(F, Inter::Typename::permissions_list(inst_kind));
		if (FL == NULL) internal_error("no permissions list");
		inter_tree_node *X;
		LOOP_THROUGH_INTER_NODE_LIST(X, FL) {
			inter_symbol *prop_allowed = InterSymbolsTable::symbol_from_ID_at_node(X, PROP_PERM_IFLD);
			if (prop_allowed == prop_name)
				return TRUE;
		}
		inst_kind = Inter::Typename::super(inst_kind);
	}
	return FALSE;
}

inter_error_message *Inter::PropertyValue::new(inter_bookmark *IBM, inter_ti PID, inter_ti OID,
	inter_pair val, inter_ti level, inter_error_location *eloc) {
	inter_tree_node *P = Inode::new_with_4_data_fields(IBM, PROPERTYVALUE_IST,
		PID, OID, InterValuePairs::to_word1(val), InterValuePairs::to_word2(val), eloc, level);
	inter_error_message *E = Inter::Verify::instruction(InterBookmark::package(IBM), P); if (E) return E;
	NodePlacement::move_to_moving_bookmark(P, IBM);
	return NULL;
}

void Inter::PropertyValue::verify(inter_construct *IC, inter_tree_node *P, inter_package *owner, inter_error_message **E) {
	*E = Inter::Verify::SID_field(owner, P, PROP_PVAL_IFLD, PROPERTY_IST); if (*E) return;
	*E = Inter::Verify::POID_field(owner, P, OWNER_PVAL_IFLD); if (*E) return;

	inter_symbol *prop_name = InterSymbolsTable::symbol_from_ID(InterPackage::scope(owner), P->W.instruction[PROP_PVAL_IFLD]);;
	inter_symbol *owner_name = InterSymbolsTable::symbol_from_ID(InterPackage::scope(owner), P->W.instruction[OWNER_PVAL_IFLD]);;

	if (Inter::PropertyValue::permitted(P, owner, owner_name, prop_name) == FALSE) {
		text_stream *err = Str::new();
		WRITE_TO(err, "no permission for '%S' have this property", InterSymbol::identifier(owner_name));
		*E = Inode::error(P, err, InterSymbol::identifier(prop_name)); return;
	}

	inter_ti plist_ID;
	if (Inter::Typename::is(owner_name)) plist_ID = Inter::Typename::properties_list(owner_name);
	else plist_ID = Inter::Instance::properties_list(owner_name);

	inter_node_list *FL = Inode::ID_to_frame_list(P, plist_ID);
	if (FL == NULL) internal_error("no properties list");

	inter_tree_node *X;
	LOOP_THROUGH_INTER_NODE_LIST(X, FL) {
		if (X->W.instruction[PROP_PVAL_IFLD] == P->W.instruction[PROP_PVAL_IFLD]) { *E = Inode::error(P, I"duplicate property value", NULL); return; }
		if (X->W.instruction[OWNER_PVAL_IFLD] != P->W.instruction[OWNER_PVAL_IFLD]) { *E = Inode::error(P, I"instance property list malformed", NULL); return; }
	}

	InterNodeList::add(FL, P);
}

void Inter::PropertyValue::write(inter_construct *IC, OUTPUT_STREAM, inter_tree_node *P, inter_error_message **E) {
	inter_symbol *prop_name = InterSymbolsTable::symbol_from_ID_at_node(P, PROP_PVAL_IFLD);
	inter_symbol *owner_name = InterSymbolsTable::symbol_from_ID_at_node(P, OWNER_PVAL_IFLD);
	if ((prop_name) && (owner_name)) {
		WRITE("propertyvalue %S %S = ", InterSymbol::identifier(prop_name), InterSymbol::identifier(owner_name));
		InterValuePairs::write(OUT, P, InterValuePairs::in_field(P, DVAL1_PVAL_IFLD), InterPackage::scope_of(P), FALSE);
	} else { *E = Inode::error(P, I"cannot write propertyvalue", NULL); return; }
}
