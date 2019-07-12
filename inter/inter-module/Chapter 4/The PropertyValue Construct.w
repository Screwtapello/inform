[Inter::PropertyValue::] The PropertyValue Construct.

Defining the propertyvalue construct.

@

@e PROPERTYVALUE_IST

=
void Inter::PropertyValue::define(void) {
	inter_construct *IC = Inter::Defn::create_construct(
		PROPERTYVALUE_IST,
		L"propertyvalue (%i+) (%i+) = (%c+)",
		I"propertyvalue", I"propertyvalues");
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
void Inter::PropertyValue::read(inter_construct *IC, inter_reading_state *IRS, inter_line_parse *ilp, inter_error_location *eloc, inter_error_message **E) {
	*E = Inter::Defn::vet_level(IRS, PROPERTYVALUE_IST, ilp->indent_level, eloc);
	if (*E) return;

	if (ilp->no_annotations > 0) { *E = Inter::Errors::plain(I"__annotations are not allowed", eloc); return; }

	inter_symbol *prop_name = Inter::Textual::find_symbol(IRS->read_into, eloc, Inter::Bookmarks::scope(IRS), ilp->mr.exp[0], PROPERTY_IST, E);
	if (*E) return;
	inter_symbol *owner_name = Inter::Textual::find_KOI(eloc, Inter::Bookmarks::scope(IRS), ilp->mr.exp[1], E);
	if (*E) return;

	if (Inter::PropertyValue::permitted(IRS->read_into, IRS->current_package, owner_name, prop_name) == FALSE) {
		*E = Inter::Errors::quoted(I"no permission to have this property", ilp->mr.exp[1], eloc);
		return;
	}

	inter_t plist_ID;
	if (Inter::Kind::is(owner_name)) plist_ID = Inter::Kind::properties_list(owner_name);
	else plist_ID = Inter::Instance::properties_list(owner_name);
	inter_frame_list *FL = Inter::find_frame_list(IRS->read_into, plist_ID);
	if (FL == NULL) internal_error("no properties list");

	inter_frame X;
	LOOP_THROUGH_INTER_FRAME_LIST(X, FL) {
		inter_symbol *prop_X = Inter::SymbolsTables::symbol_from_frame_data(X, PROP_PVAL_IFLD);
		if (prop_X == prop_name)
			{ *E = Inter::Errors::quoted(I"property already given", ilp->mr.exp[0], eloc); return; }
	}

	inter_symbol *val_kind = Inter::Property::kind_of(prop_name);
	inter_t con_val1 = 0;
	inter_t con_val2 = 0;
	*E = Inter::Types::read(ilp->line, eloc, IRS->read_into, IRS->current_package, val_kind, ilp->mr.exp[2], &con_val1, &con_val2, Inter::Bookmarks::scope(IRS));
	if (*E) return;

	*E = Inter::PropertyValue::new(IRS, Inter::SymbolsTables::id_from_IRS_and_symbol(IRS, prop_name), Inter::SymbolsTables::id_from_IRS_and_symbol(IRS, owner_name),
		con_val1, con_val2, (inter_t) ilp->indent_level, eloc);
}

int Inter::PropertyValue::permitted(inter_repository *I, inter_package *pack, inter_symbol *owner, inter_symbol *prop_name) {
	inter_t plist_ID;
	if (Inter::Kind::is(owner)) plist_ID = Inter::Kind::permissions_list(owner);
	else plist_ID = Inter::Instance::permissions_list(owner);
	inter_frame_list *FL = Inter::find_frame_list(I, plist_ID);
	inter_frame X;
	LOOP_THROUGH_INTER_FRAME_LIST(X, FL) {
		inter_symbol *prop_allowed = Inter::SymbolsTables::symbol_from_frame_data(X, PROP_PERM_IFLD);
		if (prop_allowed == prop_name)
			return TRUE;
	}
	inter_symbol *inst_kind;
	if (Inter::Kind::is(owner)) inst_kind = Inter::Kind::super(owner);
	else inst_kind = Inter::Instance::kind_of(owner);
	while (inst_kind) {
		inter_frame_list *FL =
			Inter::find_frame_list(I, Inter::Kind::permissions_list(inst_kind));
		if (FL == NULL) internal_error("no permissions list");
		inter_frame X;
		LOOP_THROUGH_INTER_FRAME_LIST(X, FL) {
			inter_symbol *prop_allowed = Inter::SymbolsTables::symbol_from_frame_data(X, PROP_PERM_IFLD);
			if (prop_allowed == prop_name)
				return TRUE;
		}
		inst_kind = Inter::Kind::super(inst_kind);
	}
	return FALSE;
}

inter_error_message *Inter::PropertyValue::new(inter_reading_state *IRS, inter_t PID, inter_t OID,
	inter_t con_val1, inter_t con_val2, inter_t level, inter_error_location *eloc) {
	inter_frame P = Inter::Frame::fill_4(IRS, PROPERTYVALUE_IST,
		PID, OID, con_val1, con_val2, eloc, level);
	inter_error_message *E = Inter::Defn::verify_construct(IRS->current_package, P); if (E) return E;
	Inter::Frame::insert(P, IRS);
	return NULL;
}

void Inter::PropertyValue::verify(inter_construct *IC, inter_frame P, inter_package *owner, inter_error_message **E) {
	inter_t vcount = P.repo_segment->bytecode[P.index + PREFRAME_VERIFICATION_COUNT]++;

	if (P.extent != EXTENT_PVAL_IFR) { *E = Inter::Frame::error(&P, I"extent wrong", NULL); return; }
	*E = Inter::Verify::symbol(owner, P, P.data[PROP_PVAL_IFLD], PROPERTY_IST); if (*E) return;
	*E = Inter::Verify::symbol_KOI(owner, P, P.data[OWNER_PVAL_IFLD]); if (*E) return;

	if (vcount == 0) {
		inter_symbol *prop_name = Inter::SymbolsTables::symbol_from_id(Inter::Packages::scope(owner), P.data[PROP_PVAL_IFLD]);;
		inter_symbol *owner_name = Inter::SymbolsTables::symbol_from_id(Inter::Packages::scope(owner), P.data[OWNER_PVAL_IFLD]);;

		if (Inter::PropertyValue::permitted(P.repo_segment->owning_repo, owner, owner_name, prop_name) == FALSE) {
			text_stream *err = Str::new();
			WRITE_TO(err, "no permission for '%S' have this property", owner_name->symbol_name);
			*E = Inter::Frame::error(&P, err, prop_name->symbol_name); return;
		}

		inter_t plist_ID;
		if (Inter::Kind::is(owner_name)) plist_ID = Inter::Kind::properties_list(owner_name);
		else plist_ID = Inter::Instance::properties_list(owner_name);

		inter_frame_list *FL =
			Inter::find_frame_list(
				P.repo_segment->owning_repo,
				plist_ID);
		if (FL == NULL) internal_error("no properties list");

		inter_frame X;
		LOOP_THROUGH_INTER_FRAME_LIST(X, FL) {
			if (X.data[PROP_PVAL_IFLD] == P.data[PROP_PVAL_IFLD]) { *E = Inter::Frame::error(&P, I"duplicate property value", NULL); return; }
			if (X.data[OWNER_PVAL_IFLD] != P.data[OWNER_PVAL_IFLD]) { *E = Inter::Frame::error(&P, I"instance property list malformed", NULL); return; }
		}

		Inter::add_to_frame_list(FL, P);
	}
}

void Inter::PropertyValue::write(inter_construct *IC, OUTPUT_STREAM, inter_frame P, inter_error_message **E) {
	inter_symbol *prop_name = Inter::SymbolsTables::symbol_from_frame_data(P, PROP_PVAL_IFLD);
	inter_symbol *owner_name = Inter::SymbolsTables::symbol_from_frame_data(P, OWNER_PVAL_IFLD);
	if ((prop_name) && (owner_name)) {
		inter_symbol *val_kind = Inter::Property::kind_of(Inter::SymbolsTables::symbol_from_frame_data(P, PROP_PVAL_IFLD));
		WRITE("propertyvalue %S %S = ", prop_name->symbol_name, owner_name->symbol_name);
		Inter::Types::write(OUT, P.repo_segment->owning_repo, val_kind, P.data[DVAL1_PVAL_IFLD], P.data[DVAL2_PVAL_IFLD], Inter::Packages::scope_of(P), FALSE);
	} else { *E = Inter::Frame::error(&P, I"cannot write propertyvalue", NULL); return; }
}
