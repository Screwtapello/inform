[CodeGen::Assimilate::] Assimilate Linked Matter.

To assimilate the material in parsed non-code splats.

@h Pipeline stage.

=
void CodeGen::Assimilate::create_pipeline_stage(void) {
	ParsingPipelines::new_stage(I"assimilate", CodeGen::Assimilate::run_pipeline_stage, NO_STAGE_ARG, FALSE);
}

int current_assimilation_pass = 0;
int no_assimilated_actions = 0;
int no_assimilated_commands = 0;
int no_assimilated_arrays = 0;

int trace_AME = TRUE;

int CodeGen::Assimilate::run_pipeline_stage(pipeline_step *step) {
	inter_tree *I = step->ephemera.repository;
	++current_assimilation_pass;
	no_assimilated_actions = 0;
	no_assimilated_commands = 0;
	no_assimilated_arrays = 0;
	Site::ensure_assimilation_package(I, RunningPipelines::get_symbol(step, plain_ptype_RPSYM));
		
	RunningPipelines::ensure(step, verb_directive_reverse_RPSYM, I"VERB_DIRECTIVE_REVERSE");
	RunningPipelines::ensure(step, verb_directive_slash_RPSYM, I"VERB_DIRECTIVE_SLASH");
	RunningPipelines::ensure(step, verb_directive_divider_RPSYM, I"VERB_DIRECTIVE_DIVIDER");
	RunningPipelines::ensure(step, verb_directive_result_RPSYM, I"VERB_DIRECTIVE_RESULT");
	RunningPipelines::ensure(step, verb_directive_special_RPSYM, I"VERB_DIRECTIVE_SPECIAL");
	RunningPipelines::ensure(step, verb_directive_number_RPSYM, I"VERB_DIRECTIVE_NUMBER");
	RunningPipelines::ensure(step, verb_directive_noun_RPSYM, I"VERB_DIRECTIVE_NOUN");
	RunningPipelines::ensure(step, verb_directive_multi_RPSYM, I"VERB_DIRECTIVE_MULTI");
	RunningPipelines::ensure(step, verb_directive_multiinside_RPSYM, I"VERB_DIRECTIVE_MULTIINSIDE");
	RunningPipelines::ensure(step, verb_directive_multiheld_RPSYM, I"VERB_DIRECTIVE_MULTIHELD");
	RunningPipelines::ensure(step, verb_directive_held_RPSYM, I"VERB_DIRECTIVE_HELD");
	RunningPipelines::ensure(step, verb_directive_creature_RPSYM, I"VERB_DIRECTIVE_CREATURE");
	RunningPipelines::ensure(step, verb_directive_topic_RPSYM, I"VERB_DIRECTIVE_TOPIC");
	RunningPipelines::ensure(step, verb_directive_multiexcept_RPSYM, I"VERB_DIRECTIVE_MULTIEXCEPT");

	if (Inter::Connectors::find_socket(I, I"self") == NULL) {
		inter_symbol *ss = Veneer::find_by_index(I, SELF_VSYMB, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM));
		if (ss == NULL) internal_error("stuck");
		Inter::Connectors::socket(I, I"self", ss);
	}

	InterTree::traverse(I, CodeGen::Assimilate::visitor1, step, NULL, SPLAT_IST);
	InterTree::traverse(I, CodeGen::Assimilate::visitor2, step, NULL, SPLAT_IST);
	CodeGen::Assimilate::function_bodies(I);
	InterTree::traverse(I, CodeGen::Assimilate::visitor3, step, NULL, SPLAT_IST);
	return TRUE;
}

@h Parsing.

=
inter_bookmark CodeGen::Assimilate::template_submodule(inter_tree *I, pipeline_step *step,
	text_stream *name, inter_tree_node *P) {
	if (RunningPipelines::get_symbol(step, submodule_ptype_RPSYM)) {
		inter_package *template_package = Site::ensure_assimilation_package(I, RunningPipelines::get_symbol(step, plain_ptype_RPSYM));
		inter_package *t_p = Inter::Packages::by_name(template_package, name);
		if (t_p == NULL) {
			inter_bookmark IBM = Inter::Bookmarks::after_this_node(I, P);
			t_p = CodeGen::Assimilate::new_package_named(&IBM, name, RunningPipelines::get_symbol(step, submodule_ptype_RPSYM));
		}
		if (t_p == NULL) internal_error("failed to define");
		return Inter::Bookmarks::at_end_of_this_package(t_p);
	}
	return Inter::Bookmarks::after_this_node(I, P);
}

void CodeGen::Assimilate::visitor1(inter_tree *I, inter_tree_node *P, void *state) {
	pipeline_step *step = (pipeline_step *) state;
	switch (P->W.data[PLM_SPLAT_IFLD]) {
		case PROPERTY_PLM:
			if (RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)) @<Assimilate definition@>;
			break;
		case ATTRIBUTE_PLM:
			if (RunningPipelines::get_symbol(step, truth_state_kind_RPSYM)) @<Assimilate definition@>;
			break;
		case ROUTINE_PLM:
		case STUB_PLM:
			if ((RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)) && (RunningPipelines::get_symbol(step, unchecked_function_RPSYM)))
				@<Assimilate routine@>;
			break;
	}
}

void CodeGen::Assimilate::visitor2(inter_tree *I, inter_tree_node *P, void *state) {
	pipeline_step *step = (pipeline_step *) state;
	switch (P->W.data[PLM_SPLAT_IFLD]) {
		case DEFAULT_PLM:
		case CONSTANT_PLM:
		case FAKEACTION_PLM:
		case OBJECT_PLM:
		case VERB_PLM:
			if (RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)) @<Assimilate definition@>;
			break;
		case ARRAY_PLM:
			if (RunningPipelines::get_symbol(step, list_of_unchecked_kind_RPSYM)) @<Assimilate definition@>;
			break;
	}
}

void CodeGen::Assimilate::visitor3(inter_tree *I, inter_tree_node *P, void *state) {
	pipeline_step *step = (pipeline_step *) state;
	switch (P->W.data[PLM_SPLAT_IFLD]) {
		case GLOBAL_PLM:
			if (RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)) @<Assimilate definition@>;
			break;
	}
}

@

@d MAX_ASSIMILATED_ARRAY_ENTRIES 2048

@<Assimilate definition@> =
	inter_ti plm = P->W.data[PLM_SPLAT_IFLD];
	match_results mr = Regexp::create_mr();
	text_stream *identifier = NULL;
	text_stream *value = NULL;
	int proceed = FALSE;

	@<Parse text of splat for identifier and value@>;
	if ((proceed) && (RunningPipelines::get_symbol(step, unchecked_kind_RPSYM))) {
		if ((plm == DEFAULT_PLM) && (Inter::Connectors::find_socket(I, identifier) == NULL))
			plm = CONSTANT_PLM;
		if (plm != DEFAULT_PLM) @<Act on parsed constant definition@>;
		InterTree::remove_node(P);
	}
	Regexp::dispose_of(&mr);

@<Parse text of splat for identifier and value@> =
	text_stream *S = Inode::ID_to_text(P, P->W.data[MATTER_SPLAT_IFLD]);
	if (plm == VERB_PLM) {
		if (Regexp::match(&mr, S, L" *%C+ (%c*?) *;%c*")) {
			identifier = I"assim_gv"; value = mr.exp[0]; proceed = TRUE;
		} else LOG("Stuck on this! %S\n", S);
	} else {
		if (Regexp::match(&mr, S, L" *%C+ *(%C+?)(--> *%c*?) *;%c*")) {
			identifier = mr.exp[0]; value = mr.exp[1]; proceed = TRUE;
		} else if (Regexp::match(&mr, S, L" *%C+ *(%C+?)(-> *%c*?) *;%c*")) {
			identifier = mr.exp[0]; value = mr.exp[1]; proceed = TRUE;
		} else if (Regexp::match(&mr, S, L" *%C+ (%C*?) *;%c*")) {
			identifier = mr.exp[0]; proceed = TRUE;
		} else if (Regexp::match(&mr, S, L" *%C+ (%C*) *= *(%c*?) *;%c*")) {
			identifier = mr.exp[0]; value = mr.exp[1]; proceed = TRUE;
		} else if (Regexp::match(&mr, S, L" *%C+ (%C*) (%c*?) *;%c*")) {
			identifier = mr.exp[0]; value = mr.exp[1]; proceed = TRUE;
		} else LOG("Stuck on this! %S\n", S);
	}
	if (identifier) Str::trim_all_white_space_at_end(identifier);
	if (plm == FAKEACTION_PLM) {
		text_stream *old = identifier;
		identifier = Str::new();
		WRITE_TO(identifier, "##%S", old);
	}
	if (plm == OBJECT_PLM) value = NULL;

@<Act on parsed constant definition@> =
	inter_bookmark IBM_d = Inter::Bookmarks::after_this_node(I, P);
	inter_bookmark *IBM = &IBM_d;

	text_stream *submodule_name = NULL;
	text_stream *suffix = NULL;
	inter_symbol *subpackage_type = RunningPipelines::get_symbol(step, plain_ptype_RPSYM);

	switch (plm) {
		case VERB_PLM:
			if (RunningPipelines::get_symbol(step, command_ptype_RPSYM)) subpackage_type = RunningPipelines::get_symbol(step, command_ptype_RPSYM);
			submodule_name = I"commands"; suffix = NULL; break;
		case ARRAY_PLM:
			submodule_name = I"arrays"; suffix = I"arr"; break;
		case CONSTANT_PLM:
		case FAKEACTION_PLM:
		case OBJECT_PLM:
			submodule_name = I"constants"; suffix = I"con"; break;
		case GLOBAL_PLM:
			submodule_name = I"variables"; suffix = I"var"; break;
		case ATTRIBUTE_PLM:
		case PROPERTY_PLM:
			if (RunningPipelines::get_symbol(step, property_ptype_RPSYM)) subpackage_type = RunningPipelines::get_symbol(step, property_ptype_RPSYM);
			submodule_name = I"properties"; suffix = I"prop"; break;
	}

	if (submodule_name) {
		IBM_d = CodeGen::Assimilate::template_submodule(I, step, submodule_name, P);

		TEMPORARY_TEXT(subpackage_name)
		if (suffix) {
			WRITE_TO(subpackage_name, "%S_%S", identifier, suffix);
		} else {
			WRITE_TO(subpackage_name, "assim_command_%d", ++no_assimilated_commands);
		}
		Inter::Bookmarks::set_current_package(IBM,
			CodeGen::Assimilate::new_package_named(IBM, subpackage_name, subpackage_type));
		DISCARD_TEXT(subpackage_name)

	}

	inter_symbol *con_name = CodeGen::Assimilate::make_socketed_symbol(I, identifier, Inter::Bookmarks::scope(IBM));
	Inter::Symbols::annotate_i(con_name, ASSIMILATED_IANN, 1);
	if (plm == VERB_PLM)
		Inter::Symbols::set_flag(con_name, MAKE_NAME_UNIQUE);
	if (plm == FAKEACTION_PLM)
		Inter::Symbols::annotate_i(con_name, FAKE_ACTION_IANN, 1);
	if (plm == OBJECT_PLM)
		Inter::Symbols::annotate_i(con_name, OBJECT_IANN, 1);

	inter_symbol *id_s = NULL;
	if ((plm == ATTRIBUTE_PLM) || (plm == PROPERTY_PLM)) {
		id_s = CodeGen::Assimilate::make_socketed_symbol(I, I"property_id", Inter::Bookmarks::scope(IBM));	
	}
	if (id_s) {
		Inter::Symbols::set_flag(id_s, MAKE_NAME_UNIQUE);
		Produce::guard(Inter::Constant::new_numerical(IBM,
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), id_s),
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)),
			LITERAL_IVAL, 0,
			(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
	}
	
	if (con_name->equated_to) {
		inter_symbol *external_name = con_name->equated_to;
		external_name->equated_to = con_name;
		con_name->equated_to = NULL;
	}

	inter_ti v1 = 0, v2 = 0;

	switch (plm) {
		case CONSTANT_PLM:
		case FAKEACTION_PLM:
		case OBJECT_PLM: {
			@<Assimilate a value@>;
			Produce::guard(Inter::Constant::new_numerical(IBM,
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), con_name),
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), v1, v2,
				(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
			CodeGen::Assimilate::install_socket(I, con_name, identifier);
			break;
		}
		case GLOBAL_PLM:
			@<Assimilate a value@>;
			Produce::guard(Inter::Variable::new(IBM,
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), con_name),
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), v1, v2,
				(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
			CodeGen::Assimilate::install_socket(I, con_name, identifier);
			break;
		case ATTRIBUTE_PLM: {

			TEMPORARY_TEXT(A)
			WRITE_TO(A, "P_%S", con_name->symbol_name);
			inter_symbol *attr_symbol = InterSymbolsTables::symbol_from_name(Inter::Bookmarks::scope(IBM), A);
			
			if ((attr_symbol == NULL) || (!Inter::Symbols::is_defined(attr_symbol))) {
				if (attr_symbol == NULL) attr_symbol = con_name;
				Produce::guard(Inter::Property::new(IBM,
					InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), attr_symbol),
					InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, truth_state_kind_RPSYM)),
					(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
				Inter::Symbols::annotate_i(attr_symbol, EITHER_OR_IANN, 1);
				Inter::Symbols::set_translate(attr_symbol, con_name->symbol_name);
				if (Str::ne(attr_symbol->symbol_name, con_name->symbol_name)) {
					inter_symbol *alias_symbol = InterSymbolsTables::symbol_from_name_creating(Inter::Bookmarks::scope(IBM), con_name->symbol_name);
					InterSymbolsTables::equate(alias_symbol, attr_symbol);
				}
			} else {
				Inter::Symbols::annotate_i(attr_symbol, ASSIMILATED_IANN, 1);
				if (Str::ne(attr_symbol->symbol_name, Inter::Symbols::get_translate(attr_symbol))) {
					inter_symbol *alias_symbol = InterSymbolsTables::symbol_from_name_creating(Inter::Bookmarks::scope(IBM), Inter::Symbols::get_translate(attr_symbol));
					InterSymbolsTables::equate(alias_symbol, attr_symbol);
				}
			}
			CodeGen::Assimilate::install_socket(I, attr_symbol, A);
			CodeGen::Assimilate::install_socket(I, attr_symbol, con_name->symbol_name);
			if (Str::ne(attr_symbol->symbol_name, Inter::Symbols::get_translate(attr_symbol)))
				CodeGen::Assimilate::install_socket(I, attr_symbol, Inter::Symbols::get_translate(attr_symbol));
			DISCARD_TEXT(A)

			break;
		}
		case PROPERTY_PLM: {
			Produce::guard(Inter::Property::new(IBM,
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), con_name),
				InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)),
				(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
			CodeGen::Assimilate::install_socket(I, con_name, identifier);
			if (Str::eq(identifier, I"absent"))
				CodeGen::Assimilate::install_socket(I, con_name, I"P_absent");
			break;
		}
		case VERB_PLM:
		case ARRAY_PLM: {
			inter_ti annot = 0;
			match_results mr2 = Regexp::create_mr();
			text_stream *conts = NULL;
			if (plm == ARRAY_PLM) {
				if (Regexp::match(&mr2, value, L" *--> *(%c*?) *")) conts = mr2.exp[0];
				else if (Regexp::match(&mr2, value, L" *-> *(%c*?) *")) { conts = mr2.exp[0]; annot = BYTEARRAY_IANN; }
				else if (Regexp::match(&mr2, value, L" *table *(%c*?) *")) { conts = mr2.exp[0]; annot = TABLEARRAY_IANN; }
				else if (Regexp::match(&mr2, value, L" *buffer *(%c*?) *")) { conts = mr2.exp[0]; annot = BUFFERARRAY_IANN; }
				else {
					LOG("Identifier = <%S>, Value = <%S>", identifier, value);
					PipelineErrors::kit_error("invalid Inform 6 array declaration in the template", NULL);
				}
			} else {
				conts = value; annot = VERBARRAY_IANN;
			}

			if (annot != 0) Inter::Symbols::annotate_i(con_name, annot, 1);

			inter_ti v1_pile[MAX_ASSIMILATED_ARRAY_ENTRIES];
			inter_ti v2_pile[MAX_ASSIMILATED_ARRAY_ENTRIES];
			int no_assimilated_array_entries = 0;

			string_position spos = Str::start(conts);
			int NT = 0, next_is_action = FALSE;
			while (TRUE) {
				TEMPORARY_TEXT(value)
				if (next_is_action) WRITE_TO(value, "##");
				@<Extract a token@>;
				if ((next_is_action) && (RunningPipelines::get_symbol(step, action_kind_RPSYM))) {
					CodeGen::Assimilate::ensure_action(I, step, P, value);
				}
				next_is_action = FALSE;
				if (plm == ARRAY_PLM) {
					if (Str::eq(value, I"+")) PipelineErrors::kit_error("Inform 6 array declaration in the template using operator '+'", NULL);
					if (Str::eq(value, I"-")) PipelineErrors::kit_error("Inform 6 array declaration in the template using operator '-'", NULL);
					if (Str::eq(value, I"*")) PipelineErrors::kit_error("Inform 6 array declaration in the template using operator '*'", NULL);
					if (Str::eq(value, I"/")) PipelineErrors::kit_error("Inform 6 array declaration in the template using operator '/'", NULL);
				}
				if ((NT == 0) && (plm == VERB_PLM) && (Str::eq(value, I"meta"))) {
					Inter::Symbols::annotate_i(con_name, METAVERB_IANN, 1);
				} else {
					@<Assimilate a value@>;
					if (Str::len(value) == 0) break;
					NT++;
					if (no_assimilated_array_entries >= MAX_ASSIMILATED_ARRAY_ENTRIES) {
						PipelineErrors::kit_error("excessively long Inform 6 array in the template", NULL);
						break;
					}
					v1_pile[no_assimilated_array_entries] = v1;
					v2_pile[no_assimilated_array_entries] = v2;
					no_assimilated_array_entries++;
					if ((plm == VERB_PLM) && (RunningPipelines::get_symbol(step, verb_directive_result_RPSYM)) &&
						(InterSymbolsTables::symbol_from_data_pair_and_table(v1, v2, Inter::Bookmarks::scope(IBM)) == RunningPipelines::get_symbol(step, verb_directive_result_RPSYM)))
						next_is_action = TRUE;
				}
				DISCARD_TEXT(value)
			}

			inter_tree_node *array_in_progress =
				Inode::fill_3(IBM, CONSTANT_IST,
					InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), con_name),
					InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, list_of_unchecked_kind_RPSYM)),
					CONSTANT_INDIRECT_LIST, NULL, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1);
			int pos = array_in_progress->W.extent;
			if (Inode::extend(array_in_progress, (unsigned int) (2*no_assimilated_array_entries)) == FALSE)
				internal_error("can't extend frame");
			for (int i=0; i<no_assimilated_array_entries; i++) {
				array_in_progress->W.data[pos++] = v1_pile[i];
				array_in_progress->W.data[pos++] = v2_pile[i];
			}
			Produce::guard(Inter::Defn::verify_construct(Inter::Bookmarks::package(IBM), array_in_progress));
			Inter::Bookmarks::insert(IBM, array_in_progress);
			
			if (plm == ARRAY_PLM) {
				CodeGen::Assimilate::install_socket(I, con_name, identifier);
			}
			
			break;
		}
	}

@<Extract a token@> =
	int squoted = FALSE, dquoted = FALSE, bracketed = 0;
	while ((Str::in_range(spos)) && (Characters::is_whitespace(Str::get(spos))))
		spos = Str::forward(spos);
	while (Str::in_range(spos)) {
		wchar_t c = Str::get(spos);
		if ((Characters::is_whitespace(c)) && (squoted == FALSE) && (dquoted == FALSE) && (bracketed == 0)) break;
		if ((c == '\'') && (dquoted == FALSE)) squoted = (squoted)?FALSE:TRUE;
		if ((c == '\"') && (squoted == FALSE)) dquoted = (dquoted)?FALSE:TRUE;
		if ((c == '(') && (dquoted == FALSE) && (squoted == FALSE)) bracketed++;
		if ((c == ')') && (dquoted == FALSE) && (squoted == FALSE)) bracketed--;
		PUT_TO(value, c);
		spos = Str::forward(spos);
	}

@<Assimilate a value@> =
	if (Str::len(value) > 0) {
		CodeGen::Assimilate::value(I, step, Inter::Bookmarks::package(IBM), IBM, value, &v1, &v2,
			(plm == VERB_PLM)?TRUE:FALSE);
	} else {
		v1 = LITERAL_IVAL; v2 = 0;
	}

@<Assimilate routine@> =
	text_stream *identifier = NULL, *chain = NULL, *body = NULL;
	match_results mr = Regexp::create_mr();
	@<Parse the routine or stub header@>;
	if (identifier) @<Act on parsed header@>;

@<Parse the routine or stub header@> =
	text_stream *S = Inode::ID_to_text(P, P->W.data[MATTER_SPLAT_IFLD]);
	if (P->W.data[PLM_SPLAT_IFLD] == ROUTINE_PLM) {
		if (Regexp::match(&mr, S, L" *%[ *(%i+) *; *(%c*)")) {
			identifier = mr.exp[0]; body = mr.exp[1];
		} else if (Regexp::match(&mr, S, L" *%[ *(%i+) *(%c*?); *(%c*)")) {
			identifier = mr.exp[0]; chain = mr.exp[1]; body = mr.exp[2];
		} else {
			PipelineErrors::kit_error("invalid Inform 6 routine declaration in the template", NULL);
		}
	} else {
		if (Regexp::match(&mr, S, L" *%C+ *(%i+) (%d+);%c*")) {
			identifier = mr.exp[0];
			chain = Str::new();
			int N = Str::atoi(mr.exp[1], 0);
			if ((N<0) || (N>15)) N = 1;
			for (int i=1; i<=N; i++) WRITE_TO(chain, "x%d ", i);
			body = Str::duplicate(I"rfalse; ];");
		} else PipelineErrors::kit_error("invalid Inform 6 Stub declaration in the template", NULL);
	}

@<Act on parsed header@> =
	inter_bookmark IBM_d = CodeGen::Assimilate::template_submodule(I, step, I"functions", P);
	inter_bookmark *IBM = &IBM_d;

	inter_symbol *fnt = RunningPipelines::get_symbol(step, function_ptype_RPSYM);
	if (fnt == NULL) fnt = RunningPipelines::get_symbol(step, plain_ptype_RPSYM);

	TEMPORARY_TEXT(fname)
	WRITE_TO(fname, "%S_fn", identifier);
	inter_package *FP = CodeGen::Assimilate::new_package_named(IBM, fname, fnt);
	DISCARD_TEXT(fname)

	inter_bookmark outer_save = Inter::Bookmarks::snapshot(IBM);
	Inter::Bookmarks::set_current_package(IBM, FP);

	TEMPORARY_TEXT(bname)
	WRITE_TO(bname, "%S_B", identifier);
	inter_package *IP = CodeGen::Assimilate::new_package_named(IBM, bname, RunningPipelines::get_symbol(step, code_ptype_RPSYM));
	DISCARD_TEXT(bname)

	inter_bookmark inner_save = Inter::Bookmarks::snapshot(IBM);
	Inter::Bookmarks::set_current_package(IBM, IP);
	inter_bookmark block_bookmark = Inter::Bookmarks::snapshot(IBM);

	if (chain) {
		string_position spos = Str::start(chain);
		while (TRUE) {
			TEMPORARY_TEXT(value)
			@<Extract a token@>;
			if (Str::len(value) == 0) break;
			inter_symbol *loc_name = InterSymbolsTables::create_with_unique_name(Inter::Packages::scope(IP), value);
			Inter::Symbols::local(loc_name);
			Produce::guard(Inter::Local::new(IBM, loc_name, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM), 0, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
			DISCARD_TEXT(value)
		}
	}

	Produce::guard(Inter::Code::new(IBM, (int) (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
	if (Str::len(body) > 0) {
		int L = Str::len(body) - 1;
		while ((L>0) && (Str::get_at(body, L) != ']')) L--;
		while ((L>0) && (Characters::is_whitespace(Str::get_at(body, L-1)))) L--;
		Str::truncate(body, L);
		CodeGen::Assimilate::routine_body(IBM, IP, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, body, block_bookmark);
	}

	*IBM = inner_save;

	inter_symbol *rsymb = CodeGen::Assimilate::make_socketed_symbol(I, identifier, Inter::Bookmarks::scope(IBM));
	Inter::Symbols::annotate_i(rsymb, ASSIMILATED_IANN, 1);
	Produce::guard(Inter::Constant::new_function(IBM,
		InterSymbolsTables::id_from_symbol(I, FP, rsymb),
		InterSymbolsTables::id_from_symbol(I, FP, RunningPipelines::get_symbol(step, unchecked_function_RPSYM)),
		IP,
		(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));

	*IBM = outer_save;

	CodeGen::Assimilate::install_socket(I, rsymb, rsymb->symbol_name);
	InterTree::remove_node(P);

@ =
inter_package *CodeGen::Assimilate::new_package_named(inter_bookmark *IBM, text_stream *name, inter_symbol *ptype) {
	inter_package *P = NULL;
	Produce::guard(Inter::Package::new_package_named(IBM, name, TRUE,
		ptype, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL, &P));
	return P;
}

void CodeGen::Assimilate::install_socket(inter_tree *I, inter_symbol *con_name, text_stream *aka_text) {
	inter_symbol *socket = Inter::Connectors::find_socket(I, aka_text);
	if (socket == NULL) Inter::Connectors::socket(I, aka_text, con_name);
}

inter_symbol *CodeGen::Assimilate::make_socketed_symbol(inter_tree *I, text_stream *identifier, inter_symbols_table *into_scope) {
	inter_symbol *new_symbol = InterSymbolsTables::create_with_unique_name(into_scope, identifier);
	CodeGen::Assimilate::install_socket(I, new_symbol, identifier);
	return new_symbol;
}

@ =
void CodeGen::Assimilate::ensure_action(inter_tree *I, pipeline_step *step, inter_tree_node *P, text_stream *value) {
	if (Inter::Connectors::find_socket(I, value) == NULL) {
		inter_bookmark IBM_d = CodeGen::Assimilate::template_submodule(I, step, I"actions", P);
		inter_bookmark *IBM = &IBM_d;
		inter_symbol *ptype = RunningPipelines::get_symbol(step, action_ptype_RPSYM);
		if (ptype == NULL) ptype = RunningPipelines::get_symbol(step, plain_ptype_RPSYM);
		TEMPORARY_TEXT(an)
		WRITE_TO(an, "assim_action_%d", ++no_assimilated_actions);
		Inter::Bookmarks::set_current_package(IBM, CodeGen::Assimilate::new_package_named(IBM, an, ptype));
		DISCARD_TEXT(an)
		inter_symbol *aid_s = InterSymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(IBM), I"action_id");
		Produce::guard(Inter::Constant::new_numerical(IBM,
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), aid_s),
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)),
			LITERAL_IVAL, 0, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
		Inter::Symbols::set_flag(aid_s, MAKE_NAME_UNIQUE);
		inter_symbol *asymb = CodeGen::Assimilate::make_socketed_symbol(I, value, Inter::Bookmarks::scope(IBM));
		TEMPORARY_TEXT(unsharped)
		WRITE_TO(unsharped, "%SSub", value);
		Str::delete_first_character(unsharped);
		Str::delete_first_character(unsharped);
		inter_symbol *txsymb = Inter::Connectors::find_socket(I, unsharped);
		inter_symbol *xsymb = InterSymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(IBM), unsharped);
		if (txsymb) InterSymbolsTables::equate(xsymb, txsymb);
		DISCARD_TEXT(unsharped)
		Produce::guard(Inter::Constant::new_numerical(IBM,
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), asymb),
			InterSymbolsTables::id_from_symbol(I, Inter::Bookmarks::package(IBM), RunningPipelines::get_symbol(step, action_kind_RPSYM)),
			LITERAL_IVAL, 10000, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
		Inter::Symbols::annotate_i(asymb, ACTION_IANN, 1);
	}
}

@ =
void CodeGen::Assimilate::value(inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, text_stream *S, inter_ti *val1, inter_ti *val2, int Verbal) {
	int sign = 1, base = 10, from = 0, to = Str::len(S)-1, bad = FALSE;
	if ((Str::get_at(S, from) == '\'') && (Str::get_at(S, to) == '\'')) {
		from++;
		to--;
		TEMPORARY_TEXT(dw)
		LOOP_THROUGH_TEXT(pos, S) {
			if (pos.index < from) continue;
			if (pos.index > to) continue;
			int c = Str::get(pos);
			PUT_TO(dw, c);
		}
		inter_ti ID = Inter::Warehouse::create_text(InterTree::warehouse(I), pack);
		text_stream *glob_storage = Inter::Warehouse::get_text(InterTree::warehouse(I), ID);
		Str::copy(glob_storage, dw);
		*val1 = DWORD_IVAL; *val2 = ID;
		DISCARD_TEXT(dw)
		return;
	}
	if ((Str::get_at(S, from) == '"') && (Str::get_at(S, to) == '"')) {
		from++;
		to--;
		TEMPORARY_TEXT(dw)
		LOOP_THROUGH_TEXT(pos, S) {
			if (pos.index < from) continue;
			if (pos.index > to) continue;
			int c = Str::get(pos);
			PUT_TO(dw, c);
		}
		inter_ti ID = Inter::Warehouse::create_text(InterTree::warehouse(I), pack);
		text_stream *glob_storage = Inter::Warehouse::get_text(InterTree::warehouse(I), ID);
		Str::copy(glob_storage, dw);
		*val1 = LITERAL_TEXT_IVAL; *val2 = ID;
		DISCARD_TEXT(dw)
		return;
	}
	if ((Str::get_at(S, from) == '(') && (Str::get_at(S, to) == ')')) { from++; to--; }
	while (Characters::is_whitespace(Str::get_at(S, from))) from++;
	while (Characters::is_whitespace(Str::get_at(S, to))) to--;
	if (Str::get_at(S, from) == '-') { sign = -1; from++; }
	else if (Str::get_at(S, from) == '$') {
		from++; base = 16;
		if (Str::get_at(S, from) == '$') {
			from++; base = 2;
		}
	}
	long long int N = 0;
	LOOP_THROUGH_TEXT(pos, S) {
		if (pos.index < from) continue;
		if (pos.index > to) continue;
		int c = Str::get(pos), d = 0;
		if ((c >= 'a') && (c <= 'z')) d = c-'a'+10;
		else if ((c >= 'A') && (c <= 'Z')) d = c-'A'+10;
		else if ((c >= '0') && (c <= '9')) d = c-'0';
		else { bad = TRUE; break; }
		if (d > base) { bad = TRUE; break; }
		N = base*N + (long long int) d;
		if (pos.index > 34) { bad = TRUE; break; }
	}
	if (bad == FALSE) {
		N = sign*N;
		*val1 = LITERAL_IVAL; *val2 = (inter_ti) N; return;
	}
	if (Str::eq(S, I"true")) {
		*val1 = LITERAL_IVAL; *val2 = 1; return;
	}
	if (Str::eq(S, I"false")) {
		*val1 = LITERAL_IVAL; *val2 = 0; return;
	}

	if (Verbal) {
		if ((Str::eq(S, I"*")) && (RunningPipelines::get_symbol(step, verb_directive_divider_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_divider_RPSYM), val1, val2); return;
		}
		if ((Str::eq(S, I"->")) && (RunningPipelines::get_symbol(step, verb_directive_result_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_result_RPSYM), val1, val2); return;
		}
		if ((Str::eq(S, I"reverse")) && (RunningPipelines::get_symbol(step, verb_directive_reverse_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_reverse_RPSYM), val1, val2); return;
		}
		if ((Str::eq(S, I"/")) && (RunningPipelines::get_symbol(step, verb_directive_slash_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_slash_RPSYM), val1, val2); return;
		}
		if ((Str::eq(S, I"special")) && (RunningPipelines::get_symbol(step, verb_directive_special_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_special_RPSYM), val1, val2); return;
		}
		if ((Str::eq(S, I"number")) && (RunningPipelines::get_symbol(step, verb_directive_number_RPSYM))) {
			Inter::Symbols::to_data(I, pack, RunningPipelines::get_symbol(step, verb_directive_number_RPSYM), val1, val2); return;
		}
		match_results mr = Regexp::create_mr();
		if (Regexp::match(&mr, S, L"scope=(%i+)")) {
			inter_symbol *symb = Inter::Connectors::find_socket(I, mr.exp[0]);
			while ((symb) && (symb->equated_to)) symb = symb->equated_to;
			if (symb) {
				if (Inter::Symbols::read_annotation(symb, SCOPE_FILTER_IANN) != 1)
					Inter::Symbols::annotate_i(symb, SCOPE_FILTER_IANN, 1);
				Inter::Symbols::to_data(I, pack, symb, val1, val2); return;
			}
		}
		if (Regexp::match(&mr, S, L"noun=(%i+)")) {
			inter_symbol *symb = Inter::Connectors::find_socket(I, mr.exp[0]);
			while ((symb) && (symb->equated_to)) symb = symb->equated_to;
			if (symb) {
				if (Inter::Symbols::read_annotation(symb, NOUN_FILTER_IANN) != 1)
					Inter::Symbols::annotate_i(symb, NOUN_FILTER_IANN, 1);
				Inter::Symbols::to_data(I, pack, symb, val1, val2); return;
			}
		}
	}

	inter_symbol *symb = Inter::Connectors::find_socket(I, S);
	if (symb) {
		Inter::Symbols::to_data(I, pack, symb, val1, val2); return;
	}

	inter_schema *sch = InterSchemas::from_text(S, FALSE, 0, NULL);
	inter_symbol *mcc_name = CodeGen::Assimilate::compute_constant(I, step, pack, IBM, sch);
	Inter::Symbols::to_data(I, pack, mcc_name, val1, val2);
}

inter_symbol *CodeGen::Assimilate::compute_constant(inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, inter_schema *sch) {

	inter_symbol *try = CodeGen::Assimilate::compute_constant_r(I, step, pack, IBM, sch->node_tree);
	if (try) return try;

	InterSchemas::log(DL, sch);
	LOG("Forced to glob: %S\n", sch->converted_from);
	WRITE_TO(STDERR, "Forced to glob: %S\n", sch->converted_from);
	internal_error("Reduced to glob in assimilation");

	inter_ti ID = Inter::Warehouse::create_text(InterTree::warehouse(I), pack);
	text_stream *glob_storage = Inter::Warehouse::get_text(InterTree::warehouse(I), ID);
	Str::copy(glob_storage, sch->converted_from);

	inter_symbol *mcc_name = CodeGen::Assimilate::computed_constant_symbol(pack);
	Produce::guard(Inter::Constant::new_numerical(IBM,
		InterSymbolsTables::id_from_symbol(I, pack, mcc_name),
		InterSymbolsTables::id_from_symbol(I, pack, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), GLOB_IVAL, ID,
		(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));

	return mcc_name;
}

inter_symbol *CodeGen::Assimilate::compute_constant_r(inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, inter_schema_node *isn) {
	if (isn->isn_type == SUBEXPRESSION_ISNT) 
		return CodeGen::Assimilate::compute_constant_r(I, step, pack, IBM, isn->child_node);
	if (isn->isn_type == OPERATION_ISNT) {
		inter_ti op = 0;
		if (isn->isn_clarifier == PLUS_BIP) op = CONSTANT_SUM_LIST;
		else if (isn->isn_clarifier == TIMES_BIP) op = CONSTANT_PRODUCT_LIST;
		else if (isn->isn_clarifier == MINUS_BIP) op = CONSTANT_DIFFERENCE_LIST;
		else if (isn->isn_clarifier == DIVIDE_BIP) op = CONSTANT_QUOTIENT_LIST;
		else if (isn->isn_clarifier == UNARYMINUS_BIP)
			return CodeGen::Assimilate::compute_constant_unary_operation(I, step, pack, IBM, isn->child_node);
		else return NULL;
		inter_symbol *i1 = CodeGen::Assimilate::compute_constant_r(I, step, pack, IBM, isn->child_node);
		inter_symbol *i2 = CodeGen::Assimilate::compute_constant_r(I, step, pack, IBM, isn->child_node->next_node);
		if ((i1 == NULL) || (i2 == NULL)) return NULL;
		return CodeGen::Assimilate::compute_constant_binary_operation(op, I, step, pack, IBM, i1, i2);
	}
	if (isn->isn_type == EXPRESSION_ISNT) {
		inter_schema_token *t = isn->expression_tokens;
		if (t->next) {
			if (t->next->next) return NULL;
			inter_symbol *i1 = CodeGen::Assimilate::compute_constant_eval(I, step, pack, IBM, t);
			inter_symbol *i2 = CodeGen::Assimilate::compute_constant_eval(I, step, pack, IBM, t->next);
			if ((i1 == NULL) || (i2 == NULL)) return NULL;
			return CodeGen::Assimilate::compute_constant_binary_operation(CONSTANT_SUM_LIST, I, step, pack, IBM, i1, i2);
		}
		return CodeGen::Assimilate::compute_constant_eval(I, step, pack, IBM, t);
	}
	return NULL;
}

inter_symbol *CodeGen::Assimilate::compute_constant_eval(inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, inter_schema_token *t) {
	inter_ti v1 = UNDEF_IVAL, v2 = 0;
	switch (t->ist_type) {
		case IDENTIFIER_ISTT: {
			inter_symbol *symb = Inter::Connectors::find_socket(I, t->material);
			if (symb) return symb;
			return Inter::Connectors::plug(I, t->material);
		}
		case NUMBER_ISTT:
		case BIN_NUMBER_ISTT:
		case HEX_NUMBER_ISTT:
			if (t->constant_number >= 0) { v1 = LITERAL_IVAL; v2 = (inter_ti) t->constant_number; }
			else if (Inter::Types::read_int_in_I6_notation(t->material, &v1, &v2) == FALSE)
				internal_error("bad number");
			break;
	}
	if (v1 == UNDEF_IVAL) return NULL;
	inter_symbol *mcc_name = CodeGen::Assimilate::computed_constant_symbol(pack);
	Produce::guard(Inter::Constant::new_numerical(IBM,
		InterSymbolsTables::id_from_symbol(I, pack, mcc_name),
		InterSymbolsTables::id_from_symbol(I, pack, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), v1, v2,
		(inter_ti) Inter::Bookmarks::baseline(IBM) + 1, NULL));
	return mcc_name;
}

inter_symbol *CodeGen::Assimilate::compute_constant_unary_operation(inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, inter_schema_node *operand1) {
	inter_symbol *i1 = CodeGen::Assimilate::compute_constant_r(I, step, pack, IBM, operand1);
	if (i1 == NULL) return NULL;
	inter_symbol *mcc_name = CodeGen::Assimilate::computed_constant_symbol(pack);
	inter_tree_node *array_in_progress =
		Inode::fill_3(IBM, CONSTANT_IST, InterSymbolsTables::id_from_IRS_and_symbol(IBM, mcc_name), InterSymbolsTables::id_from_symbol(I, pack, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), CONSTANT_DIFFERENCE_LIST, NULL, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1);
	int pos = array_in_progress->W.extent;
	if (Inode::extend(array_in_progress, 4) == FALSE)
		internal_error("can't extend frame");
	array_in_progress->W.data[pos] = LITERAL_IVAL; array_in_progress->W.data[pos+1] = 0;
	Inter::Symbols::to_data(I, pack, i1, &(array_in_progress->W.data[pos+2]), &(array_in_progress->W.data[pos+3]));
	Produce::guard(Inter::Defn::verify_construct(Inter::Bookmarks::package(IBM), array_in_progress));
	Inter::Bookmarks::insert(IBM, array_in_progress);
	return mcc_name;
}

inter_symbol *CodeGen::Assimilate::compute_constant_binary_operation(inter_ti op, inter_tree *I, pipeline_step *step, inter_package *pack, inter_bookmark *IBM, inter_symbol *i1, inter_symbol *i2) {
	inter_symbol *mcc_name = CodeGen::Assimilate::computed_constant_symbol(pack);
	inter_tree_node *array_in_progress =
		Inode::fill_3(IBM, CONSTANT_IST, InterSymbolsTables::id_from_IRS_and_symbol(IBM, mcc_name), InterSymbolsTables::id_from_symbol(I, pack, RunningPipelines::get_symbol(step, unchecked_kind_RPSYM)), op, NULL, (inter_ti) Inter::Bookmarks::baseline(IBM) + 1);
	int pos = array_in_progress->W.extent;
	if (Inode::extend(array_in_progress, 4) == FALSE)
		internal_error("can't extend frame");
	Inter::Symbols::to_data(I, pack, i1, &(array_in_progress->W.data[pos]), &(array_in_progress->W.data[pos+1]));
	Inter::Symbols::to_data(I, pack, i2, &(array_in_progress->W.data[pos+2]), &(array_in_progress->W.data[pos+3]));
	Produce::guard(Inter::Defn::verify_construct(Inter::Bookmarks::package(IBM), array_in_progress));
	Inter::Bookmarks::insert(IBM, array_in_progress);
	return mcc_name;
}

int ccs_count = 0;
inter_symbol *CodeGen::Assimilate::computed_constant_symbol(inter_package *pack) {
	TEMPORARY_TEXT(NN)
	WRITE_TO(NN, "Computed_Constant_Value_%d", ccs_count++);
	inter_symbol *mcc_name = InterSymbolsTables::symbol_from_name_creating(Inter::Packages::scope(pack), NN);
	Inter::Symbols::set_flag(mcc_name, MAKE_NAME_UNIQUE);
	DISCARD_TEXT(NN)
	return mcc_name;
}

typedef struct routine_body_request {
	int assimilation_pass;
	struct inter_bookmark position;
	struct inter_bookmark block_bookmark;
	struct package_request *enclosure;
	struct inter_package *block_package;
	int pass2_offset;
	struct text_stream *body;
	CLASS_DEFINITION
} routine_body_request;

int rb_splat_count = 1;
int CodeGen::Assimilate::routine_body(inter_bookmark *IBM, inter_package *block_package, inter_ti offset, text_stream *body, inter_bookmark bb) {
	if (Str::is_whitespace(body)) return FALSE;
	routine_body_request *req = CREATE(routine_body_request);
	req->assimilation_pass = current_assimilation_pass;
	req->block_bookmark = bb;
	req->enclosure = Packaging::enclosure(Inter::Bookmarks::tree(IBM));
	req->position = Packaging::bubble_at(IBM);
	req->block_package = block_package;
	req->pass2_offset = (int) offset - 2;
	req->body = Str::duplicate(body);
	return TRUE;
}

void CodeGen::Assimilate::function_bodies(inter_tree *I) {
	routine_body_request *req;
	LOOP_OVER(req, routine_body_request)
		if (req->assimilation_pass == current_assimilation_pass) {
			LOGIF(SCHEMA_COMPILATION, "=======\n\nRoutine (%S) len %d: '%S'\n\n", Inter::Packages::name(req->block_package), Str::len(req->body), req->body);
			inter_schema *sch = InterSchemas::from_text(req->body, FALSE, 0, NULL);
		
			if (Log::aspect_switched_on(SCHEMA_COMPILATION_DA)) {
				if (sch == NULL) LOG("NULL SCH\n");
				else if (sch->node_tree == NULL) {
					LOG("Lint fail: Non-empty text but empty scheme\n");
					internal_error("inter schema empty");
				} else InterSchemas::log(DL, sch);
			}
		
			Site::set_cir(I, req->block_package);
			Packaging::set_state(I, &(req->position), req->enclosure);
			Produce::push_code_position(I, Produce::new_cip(I, &(req->position)), Inter::Bookmarks::snapshot(Packaging::at(I)));
			value_holster VH = Holsters::new(INTER_VOID_VHMODE);
			inter_symbols_table *scope1 = Inter::Packages::scope(req->block_package);
			inter_package *template_package = Site::assimilation_package(I);
			inter_symbols_table *scope2 = Inter::Packages::scope(template_package);
			EmitInterSchemas::emit(I, &VH, sch, NULL, scope1, scope2, NULL, NULL);
			Produce::pop_code_position(I);
			Site::set_cir(I, NULL);
		}
}
