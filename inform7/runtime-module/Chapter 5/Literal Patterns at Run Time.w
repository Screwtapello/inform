[RTLiteralPatterns::] Literal Patterns at Run Time.

Compiled code to print and parse values expressed as literals.

@h Matching an LP at run-time.
The following routine compiles an I6 general parsing routine (GPR) to match
typed input in the correct notation. It amounts to printing out a version of
the above routine, but ported to I6, and with the token loop "rolled out"
so that no |tc| and |ec| variables are needed at run-time, and simplified
by having the numerical overflow detection removed. (It's a little slow to
perform that check within the VM.)

Properly speaking this is not an entire GPR, but only a segment of one,
and we should compile code which allows execution to reach the end if and only
if we fail to make a match.

=
void RTLiteralPatterns::gpr(gpr_kit *gprk, literal_pattern *lp) {
	int label = lp->allocation_id;
	int tc, ec;
	RTLiteralPatterns::comment_use_of_lp(lp);

	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->wpos_s);
		EmitCode::val_number(0);
	EmitCode::up();
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->mid_word_s);
		EmitCode::val_false();
	EmitCode::up();
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->matched_number_s);
		EmitCode::val_number(0);
	EmitCode::up();

	TEMPORARY_TEXT(SL)
	WRITE_TO(SL, ".Succeeded_LP_%d", label);
	inter_symbol *succeeded_label = EmitCode::reserve_label(SL);
	DISCARD_TEXT(SL)
	TEMPORARY_TEXT(FL)
	WRITE_TO(FL, ".Failed_LP_%d", label);
	inter_symbol *failed_label = EmitCode::reserve_label(FL);
	DISCARD_TEXT(FL)

	for (tc=0, ec=0; tc<lp->no_lp_tokens; tc++) {
		int lookahead = -1;
		if ((tc+1<lp->no_lp_tokens) && (lp->lp_tokens[tc+1].lpt_type == CHARACTER_LPT))
			lookahead = (int) (lp->lp_tokens[tc+1].token_char);
		EmitCode::inv(IF_BIP);
		EmitCode::down();
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->mid_word_s);
				EmitCode::val_false();
			EmitCode::up();
			EmitCode::code();
			EmitCode::down();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_symbol(K_value, gprk->cur_word_s);
					EmitCode::call(Hierarchy::find(NEXTWORDSTOPPED_HL));
				EmitCode::up();
				EmitCode::inv(POSTDECREMENT_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
				EmitCode::up();
				inter_symbol *to_label = NULL;
				if ((lp->lp_elements[ec].preamble_optional) && (lp->lp_tokens[tc].lpt_type == ELEMENT_LPT))
					to_label = failed_label;
				else if (LiteralPatterns::at_optional_break_point(lp, ec, tc))
					to_label = succeeded_label;
				else
					to_label = failed_label;
				EmitCode::inv(IF_BIP);
				EmitCode::down();
					EmitCode::inv(EQ_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->cur_word_s);
						EmitCode::val_number((inter_ti) -1);
					EmitCode::up();
					EmitCode::code();
					EmitCode::down();
						EmitCode::inv(JUMP_BIP);
						EmitCode::down();
							EmitCode::lab(to_label);
						EmitCode::up();
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();

		switch (lp->lp_tokens[tc].lpt_type) {
			case WORD_LPT: @<Compile I6 code to match a fixed word token within a literal pattern@>; break;
			case CHARACTER_LPT: @<Compile I6 code to match a character token within a literal pattern@>; break;
			case ELEMENT_LPT: @<Compile I6 code to match an element token within a literal pattern@>; break;
			default: internal_error("unknown literal pattern token type");
		}
	}

	EmitCode::place_label(succeeded_label);

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::val_symbol(K_value, gprk->mid_word_s);
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(LT_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->sgn_s);
			EmitCode::val_number(0);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->matched_number_s);
				if (Kinds::FloatingPoint::uses_floating_point(lp->kind_specified)) {
					EmitCode::inv(BITWISEOR_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->matched_number_s);
						EmitCode::val_number(0x80000000);
					EmitCode::up();
				} else {
					EmitCode::inv(TIMES_BIP);
					EmitCode::down();
						EmitCode::val_number((inter_ti) -1);
						EmitCode::val_symbol(K_value, gprk->matched_number_s);
					EmitCode::up();
				}
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_iname(K_object, Hierarchy::find(PARSED_NUMBER_HL));
		EmitCode::val_symbol(K_value, gprk->matched_number_s);
	EmitCode::up();

	Kinds::Scalings::compile_quanta_to_value(lp->scaling,
		Hierarchy::find(PARSED_NUMBER_HL), gprk->sgn_s, gprk->x_s, failed_label);

	EmitCode::inv(IFDEBUG_BIP);
	EmitCode::down();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(IF_BIP);
			EmitCode::down();
				EmitCode::inv(GE_BIP);
				EmitCode::down();
					EmitCode::val_iname(K_value, Hierarchy::find(PARSER_TRACE_HL));
					EmitCode::val_number(3);
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(PRINT_BIP);
					EmitCode::down();
						EmitCode::val_text(I"  [parsed value ");
					EmitCode::up();
					EmitCode::inv(PRINTNUMBER_BIP);
					EmitCode::down();
						EmitCode::val_iname(K_object, Hierarchy::find(PARSED_NUMBER_HL));
					EmitCode::up();
					EmitCode::inv(PRINT_BIP);
					EmitCode::down();
						TEMPORARY_TEXT(EXP)
						WRITE_TO(EXP, " by: %W]\n", lp->prototype_text);
						EmitCode::val_text(EXP);
						DISCARD_TEXT(EXP)
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(RETURN_BIP);
	EmitCode::down();
		EmitCode::val_iname(K_value, Hierarchy::find(GPR_NUMBER_HL));
	EmitCode::up();
	EmitCode::place_label(failed_label);
}

@<Compile I6 code to match a fixed word token within a literal pattern@> =
	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::val_symbol(K_value, gprk->mid_word_s);
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(NE_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->cur_word_s);
			TEMPORARY_TEXT(N)
			WRITE_TO(N, "%N", lp->lp_tokens[tc].token_wn);
			EmitCode::val_dword(N);
			DISCARD_TEXT(N)
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(POSTINCREMENT_BIP);
	EmitCode::down();
		EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
	EmitCode::up();

@<Compile I6 code to match a character token within a literal pattern@> =
	@<Compile I6 code to enter mid-word parsing if not already in it@>;
	wchar_t lower_form = Characters::tolower(lp->lp_tokens[tc].token_char);
	wchar_t upper_form = Characters::toupper(lp->lp_tokens[tc].token_char);

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		if (upper_form != lower_form) { EmitCode::inv(AND_BIP); EmitCode::down(); }
		EmitCode::inv(NE_BIP);
		EmitCode::down();
			EmitCode::inv(LOOKUPBYTE_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->cur_addr_s);
				EmitCode::inv(POSTINCREMENT_BIP);
				EmitCode::down();
					EmitCode::ref_symbol(K_value, gprk->wpos_s);
				EmitCode::up();
			EmitCode::up();
			EmitCode::val_number((inter_ti) lower_form);
		EmitCode::up();
		if (upper_form != lower_form) {
			EmitCode::inv(NE_BIP);
			EmitCode::down();
				EmitCode::inv(LOOKUPBYTE_BIP);
				EmitCode::down();
					EmitCode::val_symbol(K_value, gprk->cur_addr_s);
					EmitCode::inv(MINUS_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->wpos_s);
						EmitCode::val_number(1);
					EmitCode::up();
				EmitCode::up();
				EmitCode::val_number((inter_ti) upper_form);
			EmitCode::up();
		}
		if (upper_form != lower_form) { EmitCode::up(); }
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	@<Compile I6 code to exit mid-word parsing if at end of a word@>;

@<Compile I6 code to match an element token within a literal pattern@> =
	@<Compile I6 code to enter mid-word parsing if not already in it@>;
	literal_pattern_element *lpe = &(lp->lp_elements[ec++]);
	if (ec == 1) {
		EmitCode::inv(STORE_BIP);
		EmitCode::down();
			EmitCode::ref_symbol(K_value, gprk->sgn_s);
			EmitCode::val_number(1);
		EmitCode::up();
	}
	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::inv(LOOKUPBYTE_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->cur_addr_s);
				EmitCode::val_symbol(K_value, gprk->wpos_s);
			EmitCode::up();
			EmitCode::val_number((inter_ti) '-');
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
		if ((lp->number_signed) && (ec == 1)) {
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->sgn_s);
				EmitCode::val_number((inter_ti) -1);
			EmitCode::up();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->wpos_s);
			EmitCode::up();
		} else {
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		}
		EmitCode::up();
	EmitCode::up();

	if (Kinds::FloatingPoint::uses_floating_point(lp->kind_specified))
		@<Compile I6 code to match a real number here@>
	else
		@<Compile I6 code to match an integer here@>;
	@<Compile I6 code to exit mid-word parsing if at end of a word@>;

@<Compile I6 code to match a real number here@> =
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->f_s);
		EmitCode::val_false();
	EmitCode::up();
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->x_s);
		EmitCode::inv(PLUS_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->cur_addr_s);
			EmitCode::val_symbol(K_value, gprk->wpos_s);
		EmitCode::up();
	EmitCode::up();
	@<March forwards through decimal digits@>;
	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->f_s);
			EmitCode::val_number(0);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->wpos_s);
			EmitCode::val_symbol(K_value, gprk->cur_len_s);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->cur_word_s);
				EmitCode::call(Hierarchy::find(NEXTWORDSTOPPED_HL));
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
				EmitCode::inv(MINUS_BIP);
				EmitCode::down();
					EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
					EmitCode::val_number(2);
				EmitCode::up();
			EmitCode::up();
			EmitCode::inv(IF_BIP);
			EmitCode::down();
				EmitCode::inv(EQ_BIP);
				EmitCode::down();
					EmitCode::val_symbol(K_value, gprk->cur_word_s);
					EmitCode::val_iname(K_value, Hierarchy::find(THEN1__WD_HL));
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
						EmitCode::inv(PLUS_BIP);
						EmitCode::down();
							EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
							EmitCode::val_number(2);
						EmitCode::up();
					EmitCode::up();
					EmitCode::inv(POSTINCREMENT_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->f_s);
					EmitCode::up();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->mid_word_s);
						EmitCode::val_false();
					EmitCode::up();
					EmitCode::inv(POSTINCREMENT_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->wpos_s);
					EmitCode::up();
					@<Compile I6 code to enter mid-word parsing if not already in it@>;
					@<March forwards through decimal digits@>;
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->tot_s);
		EmitCode::val_number(0);
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->wpos_s);
			EmitCode::val_symbol(K_value, gprk->cur_len_s);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->tot_s);
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->cur_word_s);
				EmitCode::call(Hierarchy::find(NEXTWORDSTOPPED_HL));
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->mid_word_s);
				EmitCode::val_false();
			EmitCode::up();
			@<Compile I6 code to enter mid-word parsing if not already in it@>;
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(AND_BIP);
		EmitCode::down();
			EmitCode::inv(LT_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->wpos_s);
				EmitCode::val_symbol(K_value, gprk->cur_len_s);
			EmitCode::up();
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::inv(LOOKUPBYTE_BIP);
				EmitCode::down();
					EmitCode::val_symbol(K_value, gprk->cur_addr_s);
					EmitCode::val_symbol(K_value, gprk->wpos_s);
				EmitCode::up();
				EmitCode::val_number((inter_ti) 'x');
			EmitCode::up();
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->f_s);
				EmitCode::inv(PLUS_BIP);
				EmitCode::down();
					EmitCode::inv(PLUS_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->f_s);
						EmitCode::val_symbol(K_value, gprk->tot_s);
					EmitCode::up();
					EmitCode::val_number(1);
				EmitCode::up();
			EmitCode::up();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->wpos_s);
			EmitCode::up();

			EmitCode::inv(IF_BIP);
			EmitCode::down();
				EmitCode::inv(EQ_BIP);
				EmitCode::down();
					EmitCode::val_symbol(K_value, gprk->wpos_s);
					EmitCode::val_symbol(K_value, gprk->cur_len_s);
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(POSTINCREMENT_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->f_s);
					EmitCode::up();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->cur_word_s);
						EmitCode::call(Hierarchy::find(NEXTWORDSTOPPED_HL));
					EmitCode::up();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->mid_word_s);
						EmitCode::val_false();
					EmitCode::up();
					@<Compile I6 code to enter mid-word parsing if not already in it@>;
				EmitCode::up();
			EmitCode::up();

			EmitCode::inv(IFELSE_BIP);
			EmitCode::down();
				EmitCode::inv(AND_BIP);
				EmitCode::down();
					EmitCode::inv(LT_BIP);
					EmitCode::down();
						EmitCode::inv(PLUS_BIP);
						EmitCode::down();
							EmitCode::val_symbol(K_value, gprk->wpos_s);
							EmitCode::val_number(3);
						EmitCode::up();
						EmitCode::val_symbol(K_value, gprk->cur_len_s);
					EmitCode::up();
					EmitCode::inv(AND_BIP);
					EmitCode::down();
						EmitCode::inv(EQ_BIP);
						EmitCode::down();
							EmitCode::inv(LOOKUPBYTE_BIP);
							EmitCode::down();
								EmitCode::val_symbol(K_value, gprk->cur_addr_s);
								EmitCode::val_symbol(K_value, gprk->wpos_s);
							EmitCode::up();
							EmitCode::val_number((inter_ti) '1');
						EmitCode::up();
						EmitCode::inv(AND_BIP);
						EmitCode::down();
							EmitCode::inv(EQ_BIP);
							EmitCode::down();
								EmitCode::inv(LOOKUPBYTE_BIP);
								EmitCode::down();
									EmitCode::val_symbol(K_value, gprk->cur_addr_s);
									EmitCode::inv(PLUS_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, gprk->wpos_s);
										EmitCode::val_number(1);
									EmitCode::up();
								EmitCode::up();
								EmitCode::val_number((inter_ti) '0');
							EmitCode::up();
							EmitCode::inv(EQ_BIP);
							EmitCode::down();
								EmitCode::inv(LOOKUPBYTE_BIP);
								EmitCode::down();
									EmitCode::val_symbol(K_value, gprk->cur_addr_s);
									EmitCode::inv(PLUS_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, gprk->wpos_s);
										EmitCode::val_number(2);
									EmitCode::up();
								EmitCode::up();
								EmitCode::val_number((inter_ti) '^');
							EmitCode::up();
						EmitCode::up();
					EmitCode::up();
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->f_s);
						EmitCode::inv(PLUS_BIP);
						EmitCode::down();
							EmitCode::val_symbol(K_value, gprk->f_s);
							EmitCode::val_number(3);
						EmitCode::up();
					EmitCode::up();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->wpos_s);
						EmitCode::inv(PLUS_BIP);
						EmitCode::down();
							EmitCode::val_symbol(K_value, gprk->wpos_s);
							EmitCode::val_number(3);
						EmitCode::up();
					EmitCode::up();
					EmitCode::inv(IF_BIP);
					EmitCode::down();
						EmitCode::inv(AND_BIP);
						EmitCode::down();
							EmitCode::inv(LT_BIP);
							EmitCode::down();
								EmitCode::val_symbol(K_value, gprk->wpos_s);
								EmitCode::val_symbol(K_value, gprk->cur_len_s);
							EmitCode::up();
							EmitCode::inv(OR_BIP);
							EmitCode::down();
								EmitCode::inv(EQ_BIP);
								EmitCode::down();
									EmitCode::inv(LOOKUPBYTE_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, gprk->cur_addr_s);
										EmitCode::val_symbol(K_value, gprk->wpos_s);
									EmitCode::up();
									EmitCode::val_number((inter_ti) '+');
								EmitCode::up();
								EmitCode::inv(EQ_BIP);
								EmitCode::down();
									EmitCode::inv(LOOKUPBYTE_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, gprk->cur_addr_s);
										EmitCode::val_symbol(K_value, gprk->wpos_s);
									EmitCode::up();
									EmitCode::val_number((inter_ti) '-');
								EmitCode::up();
							EmitCode::up();
						EmitCode::up();
						EmitCode::code();
						EmitCode::down();
							EmitCode::inv(POSTINCREMENT_BIP);
							EmitCode::down();
								EmitCode::ref_symbol(K_value, gprk->f_s);
							EmitCode::up();
							EmitCode::inv(POSTINCREMENT_BIP);
							EmitCode::down();
								EmitCode::ref_symbol(K_value, gprk->wpos_s);
							EmitCode::up();
						EmitCode::up();
					EmitCode::up();
					@<March forwards through decimal digits@>;
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(POSTDECREMENT_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, gprk->f_s);
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->x_s);
		EmitCode::call(Hierarchy::find(FLOATPARSE_HL));
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->x_s);
			EmitCode::val_symbol(K_value, gprk->f_s);
			EmitCode::val_true();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->x_s);
			EmitCode::val_symbol(K_value, Emit::get_veneer_symbol(FLOAT_NAN_VSYMB));
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->wpos_s);
			EmitCode::val_number(0);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->mid_word_s);
				EmitCode::val_false();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->matched_number_s);
		EmitCode::val_symbol(K_value, gprk->x_s);
	EmitCode::up();

@<March forwards through decimal digits@> =
	EmitCode::inv(WHILE_BIP);
	EmitCode::down();
		EmitCode::inv(AND_BIP);
		EmitCode::down();
			EmitCode::inv(LT_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->wpos_s);
				EmitCode::val_symbol(K_value, gprk->cur_len_s);
			EmitCode::up();
			EmitCode::inv(GE_BIP);
			EmitCode::down();
				EmitCode::call(Hierarchy::find(DIGITTOVALUE_HL));
				EmitCode::down();
					EmitCode::inv(LOOKUPBYTE_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->cur_addr_s);
						EmitCode::val_symbol(K_value, gprk->wpos_s);
					EmitCode::up();
				EmitCode::up();
				EmitCode::val_number(0);
			EmitCode::up();
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->f_s);
			EmitCode::up();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->wpos_s);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

@<Compile I6 code to match an integer here@> =
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->tot_s);
		EmitCode::val_number(0);
	EmitCode::up();
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->f_s);
		EmitCode::val_false();
	EmitCode::up();

	EmitCode::inv(WHILE_BIP);
	EmitCode::down();
		EmitCode::inv(AND_BIP);
		EmitCode::down();
			EmitCode::inv(LT_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->wpos_s);
				EmitCode::val_symbol(K_value, gprk->cur_len_s);
			EmitCode::up();
			EmitCode::inv(GE_BIP);
			EmitCode::down();
				EmitCode::call(Hierarchy::find(DIGITTOVALUE_HL));
				EmitCode::down();
					EmitCode::inv(LOOKUPBYTE_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->cur_addr_s);
						EmitCode::val_symbol(K_value, gprk->wpos_s);
					EmitCode::up();
				EmitCode::up();
				EmitCode::val_number(0);
			EmitCode::up();
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->f_s);
				EmitCode::call(Hierarchy::find(DIGITTOVALUE_HL));
				EmitCode::down();
					EmitCode::inv(LOOKUPBYTE_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->cur_addr_s);
						EmitCode::val_symbol(K_value, gprk->wpos_s);
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
			Kinds::Scalings::compile_scale_and_add(gprk->tot_s, gprk->sgn_s, 10, 0, gprk->f_s, failed_label);
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->f_s);
				EmitCode::val_true();
			EmitCode::up();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->wpos_s);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->f_s);
			EmitCode::val_false();
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(failed_label);
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

	if (lpe->element_index > 0) {
		EmitCode::inv(IF_BIP);
		EmitCode::down();
			EmitCode::inv(GE_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->tot_s);
				EmitCode::val_number((inter_ti) lpe->element_range);
			EmitCode::up();
			EmitCode::code();
			EmitCode::down();
				EmitCode::inv(JUMP_BIP);
				EmitCode::down();
					EmitCode::lab(failed_label);
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	}

	Kinds::Scalings::compile_scale_and_add(gprk->tot_s, gprk->sgn_s, lpe->element_multiplier, 0, gprk->matched_number_s, failed_label);
	EmitCode::inv(STORE_BIP);
	EmitCode::down();
		EmitCode::ref_symbol(K_value, gprk->matched_number_s);
		EmitCode::val_symbol(K_value, gprk->tot_s);
	EmitCode::up();

	int M = Kinds::Scalings::get_integer_multiplier(lp->scaling);
	if (M > 1) {
		EmitCode::inv(IF_BIP);
		EmitCode::down();
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, gprk->wpos_s);
				EmitCode::val_symbol(K_value, gprk->cur_len_s);
			EmitCode::up();
			EmitCode::code();
			EmitCode::down();
				EmitCode::inv(POSTINCREMENT_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
				EmitCode::up();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_symbol(K_value, gprk->cur_word_s);
					EmitCode::call(Hierarchy::find(NEXTWORDSTOPPED_HL));
				EmitCode::up();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
					EmitCode::inv(MINUS_BIP);
					EmitCode::down();
						EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
						EmitCode::val_number(2);
					EmitCode::up();
				EmitCode::up();
				EmitCode::inv(IF_BIP);
				EmitCode::down();
					EmitCode::inv(EQ_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, gprk->cur_word_s);
						EmitCode::val_iname(K_value, Hierarchy::find(THEN1__WD_HL));
					EmitCode::up();
					EmitCode::code();
					EmitCode::down();
						EmitCode::inv(STORE_BIP);
						EmitCode::down();
							EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
							EmitCode::inv(PLUS_BIP);
							EmitCode::down();
								EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
								EmitCode::val_number(2);
							EmitCode::up();
						EmitCode::up();
						EmitCode::inv(STORE_BIP);
						EmitCode::down();
							EmitCode::ref_symbol(K_value, gprk->mid_word_s);
							EmitCode::val_false();
						EmitCode::up();
						@<Compile I6 code to enter mid-word parsing if not already in it@>;
						EmitCode::inv(STORE_BIP);
						EmitCode::down();
							EmitCode::ref_symbol(K_value, gprk->x_s);
							EmitCode::val_number(0);
						EmitCode::up();
						EmitCode::inv(STORE_BIP);
						EmitCode::down();
							EmitCode::ref_symbol(K_value, gprk->f_s);
							EmitCode::val_number((inter_ti) M);
						EmitCode::up();
						EmitCode::inv(WHILE_BIP);
						EmitCode::down();
							EmitCode::inv(AND_BIP);
							EmitCode::down();
								EmitCode::inv(GT_BIP);
								EmitCode::down();
									EmitCode::val_symbol(K_value, gprk->f_s);
									EmitCode::val_number(1);
								EmitCode::up();
								EmitCode::inv(AND_BIP);
								EmitCode::down();
									EmitCode::inv(EQ_BIP);
									EmitCode::down();
										EmitCode::inv(MODULO_BIP);
										EmitCode::down();
											EmitCode::val_symbol(K_value, gprk->f_s);
											EmitCode::val_number(10);
										EmitCode::up();
										EmitCode::val_number(0);
									EmitCode::up();
									EmitCode::inv(GE_BIP);
									EmitCode::down();
										EmitCode::call(Hierarchy::find(DIGITTOVALUE_HL));
										EmitCode::down();
											EmitCode::inv(LOOKUPBYTE_BIP);
											EmitCode::down();
												EmitCode::val_symbol(K_value, gprk->cur_addr_s);
												EmitCode::val_symbol(K_value, gprk->wpos_s);
											EmitCode::up();
										EmitCode::up();
										EmitCode::val_number(0);
									EmitCode::up();
								EmitCode::up();
							EmitCode::up();
							EmitCode::code();
							EmitCode::down();
								EmitCode::inv(STORE_BIP);
								EmitCode::down();
									EmitCode::ref_symbol(K_value, gprk->w_s);
									EmitCode::inv(DIVIDE_BIP);
									EmitCode::down();
										EmitCode::inv(TIMES_BIP);
										EmitCode::down();
											EmitCode::call(Hierarchy::find(DIGITTOVALUE_HL));
											EmitCode::down();
												EmitCode::inv(LOOKUPBYTE_BIP);
												EmitCode::down();
													EmitCode::val_symbol(K_value, gprk->cur_addr_s);
													EmitCode::val_symbol(K_value, gprk->wpos_s);
												EmitCode::up();
											EmitCode::up();
											EmitCode::val_symbol(K_value, gprk->f_s);
										EmitCode::up();
										EmitCode::val_number(10);
									EmitCode::up();
								EmitCode::up();
								Kinds::Scalings::compile_scale_and_add(gprk->x_s, gprk->sgn_s,
									1, 0, gprk->w_s, failed_label);
								EmitCode::inv(POSTINCREMENT_BIP);
								EmitCode::down();
									EmitCode::ref_symbol(K_value, gprk->wpos_s);
								EmitCode::up();
								EmitCode::inv(STORE_BIP);
								EmitCode::down();
									EmitCode::ref_symbol(K_value, gprk->f_s);
									EmitCode::inv(DIVIDE_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, gprk->f_s);
										EmitCode::val_number(10);
									EmitCode::up();
								EmitCode::up();
							EmitCode::up();
						EmitCode::up();
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	}

@<Compile I6 code to enter mid-word parsing if not already in it@> =
	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->mid_word_s);
			EmitCode::val_false();
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->mid_word_s);
				EmitCode::val_true();
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->wpos_s);
				EmitCode::val_number(0);
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->cur_addr_s);
				EmitCode::call(Hierarchy::find(WORDADDRESS_HL));
				EmitCode::down();
					EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
				EmitCode::up();
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->cur_len_s);
				EmitCode::call(Hierarchy::find(WORDLENGTH_HL));
				EmitCode::down();
					EmitCode::val_iname(K_value, Hierarchy::find(WN_HL));
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

@<Compile I6 code to exit mid-word parsing if at end of a word@> =
	EmitCode::inv(IF_BIP);
	EmitCode::down();
		EmitCode::inv(EQ_BIP);
		EmitCode::down();
			EmitCode::val_symbol(K_value, gprk->wpos_s);
			EmitCode::val_symbol(K_value, gprk->cur_len_s);
		EmitCode::up();
		EmitCode::code();
		EmitCode::down();
			EmitCode::inv(POSTINCREMENT_BIP);
			EmitCode::down();
				EmitCode::ref_iname(K_value, Hierarchy::find(WN_HL));
			EmitCode::up();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, gprk->mid_word_s);
				EmitCode::val_false();
			EmitCode::up();
		EmitCode::up();
	EmitCode::up();

@h Printing the I6 variable |value| out in an LP's notation at run-time.

=
void RTLiteralPatterns::printing_routine(inter_name *iname, literal_pattern *lp_list) {
	packaging_state save = Functions::begin(iname);

	literal_pattern_name *lpn;
	literal_pattern *lp;
	int k;
	inter_symbol *value_s = LocalVariables::new_other_as_symbol(I"value");
	inter_symbol *which_s = LocalVariables::new_other_as_symbol(I"which");
	inter_symbol *rem_s = LocalVariables::new_internal_as_symbol(I"rem");
	inter_symbol *S_s = LocalVariables::new_internal_as_symbol(I"S");

	LOOP_OVER(lpn, literal_pattern_name) {
		if (Wordings::nonempty(lpn->notation_name)) {
			k = 0;
			for (lp = lp_list; lp; lp = lp->next_for_this_kind)
				lp->marked_for_printing = FALSE;
			literal_pattern_name *lpn2;
			for (lpn2 = lpn; lpn2; lpn2 = lpn2->next)
				for (lp = lp_list; lp; lp = lp->next_for_this_kind)
					if (lp == lpn2->can_use_this_lp) {
						k++; lp->marked_for_printing = TRUE;
					}
			if (k > 0) {
				TEMPORARY_TEXT(C)
				WRITE_TO(C, "The named notation: %W", lpn->notation_name);
				EmitCode::comment(C);
				DISCARD_TEXT(C)
				EmitCode::inv(IF_BIP);
				EmitCode::down();
					EmitCode::inv(EQ_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, which_s);
						EmitCode::val_number((inter_ti) (lpn->allocation_id + 1));
					EmitCode::up();
					EmitCode::code();
					EmitCode::down();
						@<Compile code to jump to the correct printing pattern@>;
					EmitCode::up();
				EmitCode::up();
			}
		}
	}

	@<Choose which patterns are eligible for printing@>;
	@<Compile code to jump to the correct printing pattern@>;

	EmitCode::rtrue();

	for (lp = lp_list; lp; lp = lp->next_for_this_kind) {
		@<Print according to this particular literal pattern@>;
		EmitCode::rtrue();
	}
	Functions::end(save);
}

@ This was at one time a more complicated criterion, which masked bugs in
the sorting measure.

@<Choose which patterns are eligible for printing@> =
	for (k=0, lp = lp_list; lp; lp = lp->next_for_this_kind) {
		int eligible = FALSE;
		if (lp->equivalent_unit == FALSE) eligible = TRUE;
		if (eligible) k++;
		lp->marked_for_printing = eligible;
	}

@<Compile code to jump to the correct printing pattern@> =
	literal_pattern *lpb = NULL;
	for (lp = lp_list; lp; lp = lp->next_for_this_kind)
		if (lp->marked_for_printing)
			if (lp->benchmark)
				lpb = lp;

	if ((lpb) && (lpb->singular_form_only == FALSE)) {
		EmitCode::inv(IF_BIP);
		EmitCode::down();
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_symbol(K_value, value_s);
				EmitCode::val_number(0);
			EmitCode::up();
			EmitCode::code();
			EmitCode::down();
				EmitCode::inv(JUMP_BIP);
				EmitCode::down();
					EmitCode::lab(RTLiteralPatterns::jump_label(lpb));
				EmitCode::up();
			EmitCode::up();
		EmitCode::up();
	}

	literal_pattern *last_lp = NULL, *last_primary = NULL, *last_singular = NULL, *last_plural = NULL;

	for (lp = lp_list; lp; lp = lp->next_for_this_kind) {
		if (lp->marked_for_printing) {
			inter_ti op = GE_BIP; last_lp = lp;
			if (lp->primary_alternative) { last_primary = lp; }
			if (lp->singular_form_only) { last_singular = lp; op = EQ_BIP; }
			if (lp->plural_form_only) { last_plural = lp; op = GT_BIP; }
			EmitCode::inv(IF_BIP);
			EmitCode::down();
				Kinds::Scalings::compile_threshold_test(lp->scaling, value_s, op);
				EmitCode::code();
				EmitCode::down();
					EmitCode::inv(JUMP_BIP);
					EmitCode::down();
						EmitCode::lab(RTLiteralPatterns::jump_label(lp));
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
		}
	}

	if (last_primary) last_lp = last_primary;
	if (last_lp) {
		if ((last_lp->singular_form_only) &&
			(last_plural) &&
			(Kinds::Scalings::compare(last_plural->scaling, last_lp->scaling) == 0)) {
			EmitCode::inv(JUMP_BIP);
			EmitCode::down();
				EmitCode::lab(RTLiteralPatterns::jump_label(last_plural));
			EmitCode::up();
		}
		EmitCode::inv(JUMP_BIP);
		EmitCode::down();
			EmitCode::lab(RTLiteralPatterns::jump_label(last_lp));
		EmitCode::up();
	}

@<Print according to this particular literal pattern@> =
	RTLiteralPatterns::comment_use_of_lp(lp);
	EmitCode::place_label(RTLiteralPatterns::jump_label(lp));

	int ec=0, oc=0;
	for (int tc=0; tc<lp->no_lp_tokens; tc++) {
		if (lp->lp_elements[ec].preamble_optional)
			@<Truncate the printed form here if subsequent numerical parts are zero@>;
		if ((tc>0) && (lp->lp_tokens[tc].new_word_at)) {
			EmitCode::inv(PRINT_BIP);
			EmitCode::down();
				EmitCode::val_text(I" ");
			EmitCode::up();
		}
		switch (lp->lp_tokens[tc].lpt_type) {
			case WORD_LPT: @<Compile I6 code to print a fixed word token within a literal pattern@>; break;
			case CHARACTER_LPT: @<Compile I6 code to print a character token within a literal pattern@>; break;
			case ELEMENT_LPT: @<Compile I6 code to print an element token within a literal pattern@>; break;
			default: internal_error("unknown literal pattern token type");
		}
	}

@<Compile I6 code to print a fixed word token within a literal pattern@> =
	TEMPORARY_TEXT(T)
	TranscodeText::from_wide_string(T, Lexer::word_raw_text(lp->lp_tokens[tc].token_wn), CT_RAW);
	EmitCode::inv(PRINT_BIP);
	EmitCode::down();
		EmitCode::val_text(T);
	EmitCode::up();
	DISCARD_TEXT(T)

@<Compile I6 code to print a character token within a literal pattern@> =
	TEMPORARY_TEXT(T)
	TEMPORARY_TEXT(tiny_string)
	PUT_TO(tiny_string, (int) lp->lp_tokens[tc].token_char);
	TranscodeText::from_stream(T, tiny_string, CT_RAW);
	DISCARD_TEXT(tiny_string)
	EmitCode::inv(PRINT_BIP);
	EmitCode::down();
		EmitCode::val_text(T);
	EmitCode::up();
	DISCARD_TEXT(T)

@<Compile I6 code to print an element token within a literal pattern@> =
	literal_pattern_element *lpe = &(lp->lp_elements[ec]);
	if (lpe->element_optional)
		@<Truncate the printed form here if subsequent numerical parts are zero@>;
	oc = ec + 1;
	if (lp->no_lp_elements == 1) {
		Kinds::Scalings::compile_print_in_quanta(lp->scaling, value_s, rem_s, S_s);
	} else {
		if (ec == 0) {
			if (lp->number_signed) {
				EmitCode::inv(IF_BIP);
				EmitCode::down();
					EmitCode::inv(AND_BIP);
					EmitCode::down();
						EmitCode::inv(LT_BIP);
						EmitCode::down();
							EmitCode::val_symbol(K_value, value_s);
							EmitCode::val_number(0);
						EmitCode::up();
						EmitCode::inv(EQ_BIP);
						EmitCode::down();
							EmitCode::inv(DIVIDE_BIP);
							EmitCode::down();
								EmitCode::val_symbol(K_value, value_s);
								EmitCode::val_number((inter_ti) (lpe->element_multiplier));
							EmitCode::up();
							EmitCode::val_number(0);
						EmitCode::up();
					EmitCode::up();
					EmitCode::code();
					EmitCode::down();
						EmitCode::inv(PRINT_BIP);
						EmitCode::down();
							EmitCode::val_text(I"-");
						EmitCode::up();
					EmitCode::up();
				EmitCode::up();
			}
			EmitCode::inv(PRINTNUMBER_BIP);
			EmitCode::down();
				EmitCode::inv(DIVIDE_BIP);
				EmitCode::down();
					EmitCode::val_symbol(K_value, value_s);
					EmitCode::val_number((inter_ti) (lpe->element_multiplier));
				EmitCode::up();
			EmitCode::up();
			if (lp->number_signed) {
				EmitCode::inv(IF_BIP);
				EmitCode::down();
					EmitCode::inv(LT_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, value_s);
						EmitCode::val_number(0);
					EmitCode::up();
					EmitCode::code();
					EmitCode::down();
						EmitCode::inv(STORE_BIP);
						EmitCode::down();
							EmitCode::ref_symbol(K_value, value_s);
							EmitCode::inv(MINUS_BIP);
							EmitCode::down();
								EmitCode::val_number(0);
								EmitCode::val_symbol(K_value, value_s);
							EmitCode::up();
						EmitCode::up();
					EmitCode::up();
				EmitCode::up();
			}
		} else {
			if ((lp->lp_tokens[tc].new_word_at == FALSE) &&
				(lpe->without_leading_zeros == FALSE)) {
				int pow = 1;
				for (pow = 1000000000; pow>1; pow = pow/10)
					if (lpe->element_range > pow) {
						EmitCode::inv(IF_BIP);
						EmitCode::down();
							EmitCode::inv(LT_BIP);
							EmitCode::down();
								EmitCode::inv(MODULO_BIP);
								EmitCode::down();
									EmitCode::inv(DIVIDE_BIP);
									EmitCode::down();
										EmitCode::val_symbol(K_value, value_s);
										EmitCode::val_number((inter_ti) (lpe->element_multiplier));
									EmitCode::up();
									EmitCode::val_number((inter_ti) (lpe->element_range));
								EmitCode::up();
								EmitCode::val_number((inter_ti) (pow));
							EmitCode::up();
							EmitCode::code();
							EmitCode::down();
								EmitCode::inv(PRINT_BIP);
								EmitCode::down();
									EmitCode::val_text(I"0");
								EmitCode::up();
							EmitCode::up();
						EmitCode::up();

					}
			}
			EmitCode::inv(PRINTNUMBER_BIP);
			EmitCode::down();
				EmitCode::inv(MODULO_BIP);
				EmitCode::down();
					EmitCode::inv(DIVIDE_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, value_s);
						EmitCode::val_number((inter_ti) (lpe->element_multiplier));
					EmitCode::up();
					EmitCode::val_number((inter_ti) (lpe->element_range));
				EmitCode::up();
			EmitCode::up();
		}
	}
	ec++;

@<Truncate the printed form here if subsequent numerical parts are zero@> =
	if (oc == ec) {
		if (ec == 0) {
			EmitCode::inv(IF_BIP);
			EmitCode::down();
				EmitCode::inv(EQ_BIP);
				EmitCode::down();
					EmitCode::inv(DIVIDE_BIP);
					EmitCode::down();
						EmitCode::val_symbol(K_value, value_s);
						EmitCode::val_number((inter_ti) (lp->lp_elements[ec].element_multiplier));
					EmitCode::up();
					EmitCode::val_number(0);
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::rtrue();
				EmitCode::up();
			EmitCode::up();
		} else {
			EmitCode::inv(IF_BIP);
			EmitCode::down();
				EmitCode::inv(EQ_BIP);
				EmitCode::down();
					EmitCode::inv(MODULO_BIP);
					EmitCode::down();
						EmitCode::inv(DIVIDE_BIP);
						EmitCode::down();
							EmitCode::val_symbol(K_value, value_s);
							EmitCode::val_number((inter_ti) (lp->lp_elements[ec].element_multiplier));
						EmitCode::up();
						EmitCode::val_number((inter_ti) (lp->lp_elements[ec].element_range));
					EmitCode::up();
					EmitCode::val_number(0);
				EmitCode::up();
				EmitCode::code();
				EmitCode::down();
					EmitCode::rtrue();
				EmitCode::up();
			EmitCode::up();
		}
		oc = ec + 1;
	}

@ =
inter_symbol *RTLiteralPatterns::jump_label(literal_pattern *lp) {
	if (lp->jump_label == NULL) {
		TEMPORARY_TEXT(N)
		WRITE_TO(N, ".Use_LP_%d", lp->allocation_id);
		lp->jump_label = EmitCode::reserve_label(N);
		DISCARD_TEXT(N)
	}
	return lp->jump_label;
}

@ =
void RTLiteralPatterns::comment_use_of_lp(literal_pattern *lp) {
	TEMPORARY_TEXT(W)
	WRITE_TO(W, "%W, ", lp->prototype_text);
	Kinds::Scalings::describe(W, lp->scaling);
	EmitCode::comment(W);
	DISCARD_TEXT(W)
}
