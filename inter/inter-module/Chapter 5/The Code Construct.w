[Inter::Code::] The Code Construct.

Defining the Code construct.

@

@e CODE_IST

=
void Inter::Code::define(void) {
	inter_construct *IC = Inter::Defn::create_construct(
		CODE_IST,
		L"code",
		I"code", I"codes");
	IC->min_level = 1;
	IC->max_level = 100000000;
	IC->usage_permissions = INSIDE_CODE_PACKAGE + CAN_HAVE_CHILDREN;
	METHOD_ADD(IC, CONSTRUCT_READ_MTID, Inter::Code::read);
	METHOD_ADD(IC, CONSTRUCT_VERIFY_MTID, Inter::Code::verify);
	METHOD_ADD(IC, CONSTRUCT_WRITE_MTID, Inter::Code::write);
	METHOD_ADD(IC, VERIFY_INTER_CHILDREN_MTID, Inter::Code::verify_children);
}

@

@d BLOCK_CODE_IFLD 2

@d EXTENT_CODE_IFR 3

=
void Inter::Code::read(inter_construct *IC, inter_reading_state *IRS, inter_line_parse *ilp, inter_error_location *eloc, inter_error_message **E) {
	if (ilp->no_annotations > 0) { *E = Inter::Errors::plain(I"__annotations are not allowed", eloc); return; }

	*E = Inter::Defn::vet_level(IRS, CODE_IST, ilp->indent_level, eloc);
	if (*E) return;

	inter_symbol *routine = Inter::Defn::get_latest_block_symbol();
	if (routine == NULL) { *E = Inter::Errors::plain(I"'code' used outside function", eloc); return; }

	*E = Inter::Code::new(IRS, routine, ilp->indent_level, eloc);
}

inter_error_message *Inter::Code::new(inter_reading_state *IRS, inter_symbol *routine, int level, inter_error_location *eloc) {
	inter_frame P = Inter::Frame::fill_1(IRS, CODE_IST, 0, eloc, (inter_t) level);
	inter_error_message *E = Inter::Defn::verify_construct(IRS->current_package, P); if (E) return E;
	Inter::Frame::insert(P, IRS);
	return NULL;
}

void Inter::Code::verify(inter_construct *IC, inter_frame P, inter_package *owner, inter_error_message **E) {
	if (P.extent != EXTENT_CODE_IFR) *E = Inter::Frame::error(&P, I"extent wrong", NULL);
}

void Inter::Code::write(inter_construct *IC, OUTPUT_STREAM, inter_frame P, inter_error_message **E) {
	WRITE("code");
}

void Inter::Code::verify_children(inter_construct *IC, inter_frame P, inter_error_message **E) {
	LOOP_THROUGH_INTER_CHILDREN(C, P) {
		if ((C.data[0] != INV_IST) && (C.data[0] != SPLAT_IST) && (C.data[0] != EVALUATION_IST) && (C.data[0] != LABEL_IST) && (C.data[0] != VAL_IST) && (C.data[0] != COMMENT_IST)) {
			*E = Inter::Frame::error(&C, I"only an inv, a val, a splat, a concatenate or a label can be below a code", NULL);
			return;
		}
	}
}
