[Inter::Pragma::] The Pragma Construct.

Defining the pragma construct.

@

@e PRAGMA_IST

=
void Inter::Pragma::define(void) {
	inter_construct *IC = Inter::Defn::create_construct(
		PRAGMA_IST,
		L"pragma (%i+) \"(%c+)\"",
		I"pragma", I"pragmas"); /* pragmae? pragmata? */
	IC->usage_permissions = OUTSIDE_OF_PACKAGES;
	METHOD_ADD(IC, CONSTRUCT_READ_MTID, Inter::Pragma::read);
	METHOD_ADD(IC, CONSTRUCT_VERIFY_MTID, Inter::Pragma::verify);
	METHOD_ADD(IC, CONSTRUCT_WRITE_MTID, Inter::Pragma::write);
}

@

@d TARGET_PRAGMA_IFLD 2
@d TEXT_PRAGMA_IFLD 3

@d EXTENT_PRAGMA_IFR 4

=
void Inter::Pragma::read(inter_construct *IC, inter_reading_state *IRS, inter_line_parse *ilp, inter_error_location *eloc, inter_error_message **E) {
	*E = Inter::Defn::vet_level(IRS, PRAGMA_IST, ilp->indent_level, eloc);
	if (*E) return;

	if (ilp->no_annotations > 0) { *E = Inter::Errors::plain(I"__annotations are not allowed", eloc); return; }

	inter_symbol *target_name = Inter::SymbolsTables::symbol_from_name(Inter::Bookmarks::scope(IRS), ilp->mr.exp[0]);
	if (target_name == NULL)
		target_name = Inter::Textual::new_symbol(eloc, Inter::Bookmarks::scope(IRS), ilp->mr.exp[0], E);
	if (*E) return;

	text_stream *S = ilp->mr.exp[1];
	inter_t ID = Inter::create_text(IRS->read_into);
	int literal_mode = FALSE;
	LOOP_THROUGH_TEXT(pos, S) {
		int c = (int) Str::get(pos);
		if (literal_mode == FALSE) {
			if (c == '\\') { literal_mode = TRUE; continue; }
		} else {
			switch (c) {
				case '\\': break;
				case '"': break;
				case 't': c = 9; break;
				case 'n': c = 10; break;
				default: { *E = Inter::Errors::plain(I"no such backslash escape", eloc); return; }
			}
		}
		if (Inter::Constant::char_acceptable(c) == FALSE) { *E = Inter::Errors::quoted(I"bad character in text", S, eloc); return; }
		PUT_TO(Inter::get_text(IRS->read_into, ID), c);
		literal_mode = FALSE;
	}

	*E = Inter::Pragma::new(IRS, target_name, ID, (inter_t) ilp->indent_level, eloc);
}

inter_error_message *Inter::Pragma::new(inter_reading_state *IRS, inter_symbol *target_name, inter_t pragma_text, inter_t level, struct inter_error_location *eloc) {
	inter_frame P = Inter::Frame::fill_2(IRS, PRAGMA_IST, Inter::SymbolsTables::id_from_IRS_and_symbol(IRS, target_name), pragma_text, eloc, level);
	inter_error_message *E = Inter::Defn::verify_construct(IRS->current_package, P); if (E) return E;
	Inter::Frame::insert(P, IRS);
	return NULL;
}

void Inter::Pragma::verify(inter_construct *IC, inter_frame P, inter_package *owner, inter_error_message **E) {
	if (P.extent != EXTENT_PRAGMA_IFR) { *E = Inter::Frame::error(&P, I"extent wrong", NULL); return; }
	inter_symbol *target_name = Inter::SymbolsTables::symbol_from_frame_data(P, TARGET_PRAGMA_IFLD);
	if (target_name == NULL) { *E = Inter::Frame::error(&P, I"no target name", NULL); return; }
	if (P.data[TEXT_PRAGMA_IFLD] == 0) { *E = Inter::Frame::error(&P, I"no pragma text", NULL); return; }
}

void Inter::Pragma::write(inter_construct *IC, OUTPUT_STREAM, inter_frame P, inter_error_message **E) {
	inter_symbol *target_name = Inter::SymbolsTables::symbol_from_frame_data(P, TARGET_PRAGMA_IFLD);
	inter_t ID = P.data[TEXT_PRAGMA_IFLD];
	text_stream *S = Inter::get_text(P.repo_segment->owning_repo, ID);
	WRITE("pragma %S \"%S\"", target_name->symbol_name, S);
}
