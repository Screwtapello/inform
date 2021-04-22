[RTActionPatterns::] Action Patterns.

Compiling APs.

@h Compiling action tries.

=
void RTActionPatterns::emit_try(explicit_action *ea, int store_instead) {
	parse_node *spec0 = ea->first_noun; /* the noun */
	parse_node *spec1 = ea->second_noun; /* the second noun */
	parse_node *spec2 = ea->actor; /* the actor */

	if ((K_understanding) && (Rvalues::is_CONSTANT_of_kind(spec0, K_understanding)) &&
		(<subject-pronoun>(Node::get_text(spec0)) == FALSE))
		spec0 = Rvalues::from_wording(Node::get_text(spec0));
	if ((K_understanding) && (Rvalues::is_CONSTANT_of_kind(spec1, K_understanding)) &&
		(<subject-pronoun>(Node::get_text(spec1)) == FALSE))
		spec1 = Rvalues::from_wording(Node::get_text(spec1));

	action_name *an = ea->action;

	int flag_bits = 0;
	if (Kinds::eq(Specifications::to_kind(spec0), K_text)) flag_bits += 16;
	if (Kinds::eq(Specifications::to_kind(spec1), K_text)) flag_bits += 32;
	if (flag_bits > 0) RTKinds::ensure_basic_heap_present();

	if (ea->request) flag_bits += 1;

	EmitCode::call(Hierarchy::find(TRYACTION_HL));
	EmitCode::down();
		EmitCode::val_number((inter_ti) flag_bits);
		if (spec2) RTActionPatterns::emit_try_action_parameter(spec2, K_object);
		else EmitCode::val_iname(K_object, Hierarchy::find(PLAYER_HL));
		EmitCode::val_iname(K_action_name, RTActions::double_sharp(an));
		if (spec0) RTActionPatterns::emit_try_action_parameter(spec0, ActionSemantics::kind_of_noun(an));
		else EmitCode::val_number(0);
		if (spec1) RTActionPatterns::emit_try_action_parameter(spec1, ActionSemantics::kind_of_second(an));
		else EmitCode::val_number(0);
		if (store_instead) {
			EmitCode::call(Hierarchy::find(STORED_ACTION_TY_CURRENT_HL));
			EmitCode::down();
				Frames::emit_new_local_value(K_stored_action);
			EmitCode::up();
		}
	EmitCode::up();
}

@ Which requires the following. As ever, there have to be hacks to ensure that
text as an action parameter is correctly read as parsing grammar rather than
text when the action expects that.

=
void RTActionPatterns::emit_try_action_parameter(parse_node *spec, kind *required_kind) {
	if ((K_understanding) && (Kinds::eq(required_kind, K_understanding))) {
		kind *K = Specifications::to_kind(spec);
		if ((Kinds::compatible(K, K_understanding)) ||
			(Kinds::compatible(K, K_text))) {
			required_kind = NULL;
		}
	}

	if (Dash::check_value(spec, required_kind))
		CompileValues::to_code_val_of_kind(spec, K_object);
}

@h Compiling action patterns.
In the following routines, we compile a single clause in what may be a
complex condition which determines whether a rule should fire. The flag
|f| indicates whether any condition has already been printed, and is
updated as the return value of the routine. (Thus, it's permissible for
the routines to compile nothing and return |f| unchanged.) The simple
case first:

@ The more complex clauses mostly act on a single I6 global variable.
In almost all cases, this falls through to the standard method for
testing a condition: we force it to propositional form, substituting the
global in for the value of free variable 0. However, rule clauses are
allowed a few syntaxes not permitted to ordinary conditions, and these
are handled as exceptional cases first:

(a) A table reference such as "a Queen listed in the Table of Monarchs"
expands.

(b) Writing "from R", where R is a region, tests if the room being gone
from is in R, not if it is equal to R. Similarly for other room-related
clauses such as "through" and "in".

(c) Given a piece of run-time parser grammar, we compile a test against
the standard I6 topic variables: there are two of these, so this is the
exceptional case where the clause doesn't act on a single I6 global,
and in this case we therefore ignore |I6_global_name|.

=
void RTActionPatterns::compile_pattern_match_clause(value_holster *VH,
	nonlocal_variable *I6_global_variable,
	parse_node *spec, kind *verify_as_kind, int adapt_region) {
	if (spec == NULL) return;

	parse_node *I6_var_TS = NULL;
	if (I6_global_variable)
		I6_var_TS = Lvalues::new_actual_NONLOCAL_VARIABLE(I6_global_variable);

	int is_parameter = FALSE;
	if (I6_global_variable == parameter_object_VAR) is_parameter = TRUE;

	RTActionPatterns::compile_pattern_match_clause_inner(VH,
		I6_var_TS, is_parameter, spec, verify_as_kind, adapt_region);
}

void RTActionPatterns::compile_pattern_match_clause_inner(value_holster *VH,
	parse_node *I6_var_TS, int is_parameter,
	parse_node *spec, kind *verify_as_kind, int adapt_region) {
	int force_proposition = FALSE;

	if (spec == NULL) return;

	LOGIF(ACTION_PATTERN_COMPILATION, "[MPE on $P: $P]\n", I6_var_TS, spec);
	kind *K = Specifications::to_kind(spec);
	if (Kinds::Behaviour::definite(K) == FALSE) {
		StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_APClauseIndefinite),
			"that action seems to involve a value which is unclear about "
			"its kind",
			"and that's not allowed. For example, you're not allowed to just "
			"say 'Instead of taking a value: ...' because the taking action "
			"applies to objects; the vaguest you're allowed to be is 'Instead "
			"of taking an object: ...'.");
		return;
	}

	wording C = Descriptions::get_calling(spec);
	if (Wordings::nonempty(C)) {
		local_variable *lvar =
			LocalVariables::ensure_calling(C,
				Specifications::to_kind(spec));
		CompileConditions::add_calling(lvar);
		EmitCode::inv(SEQUENTIAL_BIP);
		EmitCode::down();
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				inter_symbol *lvar_s = LocalVariables::declare(lvar);
				EmitCode::ref_symbol(K_value, lvar_s);
				CompileValues::to_code_val(I6_var_TS);
			EmitCode::up();
	}

	force_proposition = TRUE;

	if (Node::is(spec, UNKNOWN_NT)) {
		if (problem_count == 0) internal_error("MPE found unknown SP");
		force_proposition = FALSE;
	}
	else if (Lvalues::is_lvalue(spec)) {
		force_proposition = TRUE;
		if (Node::is(spec, TABLE_ENTRY_NT)) {
			if (Node::no_children(spec) != 2) internal_error("MPE with bad no of args");
			LocalVariables::add_table_lookup();

			local_variable *ct_0_lv = LocalVariables::find_internal(I"ct_0");
			inter_symbol *ct_0_s = LocalVariables::declare(ct_0_lv);
			local_variable *ct_1_lv = LocalVariables::find_internal(I"ct_1");
			inter_symbol *ct_1_s = LocalVariables::declare(ct_1_lv);
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_symbol(K_value, ct_1_s);
				EmitCode::call(Hierarchy::find(EXISTSTABLEROWCORR_HL));
				EmitCode::down();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, ct_0_s);
						CompileValues::to_code_val(spec->down->next);
					EmitCode::up();
					CompileValues::to_code_val(spec->down);
					CompileValues::to_code_val(I6_var_TS);
				EmitCode::up();
			EmitCode::up();
			force_proposition = FALSE;
		}
	}
	else if ((Specifications::is_kind_like(spec)) &&
			(Kinds::Behaviour::is_object(Specifications::to_kind(spec)) == FALSE)) {
			force_proposition = FALSE;
		}
	else if (Rvalues::is_rvalue(spec)) {
		if ((K_understanding) && (Rvalues::is_CONSTANT_of_kind(spec, K_understanding))) {
			if ((<understanding-action-irregular-operand>(Node::get_text(spec))) &&
				(<<r>> == TRUE)) {
				EmitCode::val_true();
			} else {
				EmitCode::inv(NE_BIP);
				EmitCode::down();
					EmitCode::inv(INDIRECT2_BIP);
					EmitCode::down();
						CompileValues::to_code_val(spec);
						EmitCode::val_iname(K_number, Hierarchy::find(CONSULT_FROM_HL));
						EmitCode::val_iname(K_number, Hierarchy::find(CONSULT_WORDS_HL));
					EmitCode::up();
					EmitCode::val_iname(K_number, Hierarchy::find(GPR_FAIL_HL));
				EmitCode::up();
			}
			force_proposition = FALSE;
		}
		if ((is_parameter == FALSE) &&
			(Rvalues::is_object(spec))) {
			instance *I = Specifications::object_exactly_described_if_any(spec);
			if ((I) && (Instances::of_kind(I, K_region))) {
				LOGIF(ACTION_PATTERN_PARSING,
					"$P on %u : $T\n", spec, verify_as_kind, current_sentence);
				if (adapt_region) {
					EmitCode::call(Hierarchy::find(TESTREGIONALCONTAINMENT_HL));
					EmitCode::down();
						CompileValues::to_code_val(I6_var_TS);
						CompileValues::to_code_val(spec);
					EmitCode::up();
					force_proposition = FALSE;
				}
			}
		}
	}
	else if (Specifications::is_description(spec)) {
		if ((is_parameter == FALSE) &&
			((Descriptions::to_instance(spec)) &&
			(adapt_region) &&
			(Instances::of_kind(Descriptions::to_instance(spec), K_region)))) {
			EmitCode::call(Hierarchy::find(TESTREGIONALCONTAINMENT_HL));
			EmitCode::down();
				CompileValues::to_code_val(I6_var_TS);
				CompileValues::to_code_val(spec);
			EmitCode::up();
		}
		force_proposition = FALSE;
	}

	pcalc_prop *prop = NULL;
	if (Specifications::is_description(spec))
		prop = Descriptions::to_proposition(spec);

	if (Lvalues::is_lvalue(spec))
		LOGIF(ACTION_PATTERN_COMPILATION, "Storage has $D\n", prop);

	if ((force_proposition) && (prop == NULL)) {
		prop = SentencePropositions::from_spec(spec);
		LOGIF(ACTION_PATTERN_COMPILATION, "[MPE forced proposition: $D]\n", prop);
		if (prop == NULL) internal_error("MPE unable to force proposition");
		if (verify_as_kind) {
			prop = Propositions::concatenate(prop,
				KindPredicates::new_atom(
					verify_as_kind, Terms::new_variable(0)));
			CompilePropositions::verify_descriptive(prop,
				"an action or activity to apply to things matching a given "
				"description", spec);
		}
	}

	if (prop) {
		LOGIF(ACTION_PATTERN_COMPILATION, "[MPE faces proposition: $D]\n", prop);
		TypecheckPropositions::type_check(prop, TypecheckPropositions::tc_no_problem_reporting());
		CompilePropositions::to_test_as_condition(I6_var_TS, prop);
	}

	if (Wordings::nonempty(C)) {
		EmitCode::up();
	}
}

@ =
void RTActionPatterns::as_stored_action(value_holster *VH, explicit_action *ea) {
	inter_name *N = Enclosures::new_small_block_for_constant();
	packaging_state save = EmitArrays::begin_late(N, K_value);

	RTKinds::emit_block_value_header(K_stored_action, FALSE, 6);
	action_name *an = ea->action;
	RTActions::action_array_entry(an);

	int request_bits = (ea->request)?1:0;
	if (ea->first_noun) {
		if ((K_understanding) && (Rvalues::is_CONSTANT_of_kind(ea->first_noun, K_understanding))) {
			request_bits = request_bits | 16;
			TEMPORARY_TEXT(BC)
			inter_name *iname = TextLiterals::to_value(Node::get_text(ea->first_noun));
			EmitArrays::iname_entry(iname);
			DISCARD_TEXT(BC)
		} else CompileValues::to_array_entry(ea->first_noun);
	} else {
		EmitArrays::numeric_entry(0);
	}
	if (ea->second_noun) {
		if ((K_understanding) && (Rvalues::is_CONSTANT_of_kind(ea->second_noun, K_understanding))) {
			request_bits = request_bits | 32;
			inter_name *iname = TextLiterals::to_value(Node::get_text(ea->second_noun));
			EmitArrays::iname_entry(iname);
		} else CompileValues::to_array_entry(ea->second_noun);
	} else {
		EmitArrays::numeric_entry(0);
	}
	if (ea->actor) {
		CompileValues::to_array_entry(ea->actor);
	} else
		EmitArrays::iname_entry(RTInstances::iname(I_yourself));
	EmitArrays::numeric_entry((inter_ti) request_bits);
	EmitArrays::numeric_entry(0);
	EmitArrays::end(save);
	if (N) Emit::holster_iname(VH, N);
}

void RTActionPatterns::emit_pattern_match(action_pattern *ap, int naming_mode) {
	value_holster VH = Holsters::new(INTER_VAL_VHMODE);
	RTActionPatterns::compile_pattern_match(&VH, ap, naming_mode);
}

@

@e ACTOR_IS_PLAYER_CPMC from 1
@e ACTOR_ISNT_PLAYER_CPMC
@e REQUESTER_EXISTS_CPMC
@e REQUESTER_DOESNT_EXIST_CPMC
@e ACTOR_MATCHES_CPMC
@e ACTION_MATCHES_CPMC
@e SET_SELF_TO_ACTOR_CPMC
@e WHEN_CONDITION_HOLDS_CPMC
@e NOUN_EXISTS_CPMC
@e NOUN_IS_INP1_CPMC
@e SECOND_EXISTS_CPMC
@e SECOND_IS_INP1_CPMC
@e NOUN_MATCHES_AS_OBJECT_CPMC
@e NOUN_MATCHES_AS_VALUE_CPMC
@e SECOND_MATCHES_AS_OBJECT_CPMC
@e SECOND_MATCHES_AS_VALUE_CPMC
@e PLAYER_LOCATION_MATCHES_CPMC
@e ACTOR_IN_RIGHT_PLACE_CPMC
@e ACTOR_LOCATION_MATCHES_CPMC
@e PARAMETER_MATCHES_CPMC
@e OPTIONAL_CLAUSE_CPMC
@e PRESENCE_OF_MATCHES_CPMC
@e PRESENCE_OF_IN_SCOPE_CPMC
@e LOOP_OVER_SCOPE_WITH_CALLING_CPMC
@e LOOP_OVER_SCOPE_WITHOUT_CALLING_CPMC

@d MAX_CPM_CLAUSES 256

@d CPMC_NEEDED(C, A) {
	if (cpm_count >= MAX_CPM_CLAUSES) internal_error("action pattern grossly overcomplex");
	needed[cpm_count] = C;
	needed_apoc[cpm_count] = A;
	cpm_count++;
}

=
void RTActionPatterns::compile_pattern_match(value_holster *VH, action_pattern *ap, int naming_mode) {
	if (ap == NULL) return;

	int cpm_count = 0, needed[MAX_CPM_CLAUSES];
	ap_clause *needed_apoc[MAX_CPM_CLAUSES];
	LOGIF(ACTION_PATTERN_COMPILATION, "Compiling action pattern:\n  $A\n", ap);

	if (ap->duration) {
		LOGIF(ACTION_PATTERN_COMPILATION, "As past action\n");
		Chronology::compile_past_action_pattern(VH, ap->duration, *ap);
	} else {
		kind *kind_of_noun = K_object;
		kind *kind_of_second = K_object;

		if (naming_mode == FALSE) {
			if (APClauses::actor_is_anyone_except_player(ap) == FALSE) {
				int impose = FALSE;
				if (APClauses::spec(ap, ACTOR_AP_CLAUSE) != NULL) {
					impose = TRUE;
					nonlocal_variable *var = Lvalues::get_nonlocal_variable_if_any(APClauses::spec(ap, ACTOR_AP_CLAUSE));
					if ((var) && (var == player_VAR)) impose = FALSE;
					instance *I = Rvalues::to_object_instance(APClauses::spec(ap, ACTOR_AP_CLAUSE));
					if ((I) && (I == I_yourself)) impose = FALSE;
				}
				if (impose) {
					CPMC_NEEDED(ACTOR_ISNT_PLAYER_CPMC, NULL);
					if (APClauses::is_request(ap)) {
						CPMC_NEEDED(REQUESTER_EXISTS_CPMC, NULL);
					} else {
						CPMC_NEEDED(REQUESTER_DOESNT_EXIST_CPMC, NULL);
					}
					if (APClauses::spec(ap, ACTOR_AP_CLAUSE)) {
						CPMC_NEEDED(ACTOR_MATCHES_CPMC, NULL);
					}
				} else {
					CPMC_NEEDED(ACTOR_IS_PLAYER_CPMC, NULL);
				}
			} else {
				if (APClauses::is_request(ap)) {
					CPMC_NEEDED(REQUESTER_EXISTS_CPMC, NULL);
				} else {
					CPMC_NEEDED(REQUESTER_DOESNT_EXIST_CPMC, NULL);
				}
			}
		}
		if (ActionNameLists::testing(ap->action_list)) {
			CPMC_NEEDED(ACTION_MATCHES_CPMC, NULL);
		}
		if ((ap->action_list == NULL) && (APClauses::spec(ap, NOUN_AP_CLAUSE))) {
			CPMC_NEEDED(NOUN_EXISTS_CPMC, NULL);
			CPMC_NEEDED(NOUN_IS_INP1_CPMC, NULL);
		}
		if ((ap->action_list == NULL) && (APClauses::spec(ap, SECOND_AP_CLAUSE))) {
			CPMC_NEEDED(SECOND_EXISTS_CPMC, NULL);
			CPMC_NEEDED(SECOND_IS_INP1_CPMC, NULL);
		}
		anl_item *item = ActionNameLists::first_item(ap->action_list);
		if ((item) && (item->action_listed)) {
			kind_of_noun = ActionSemantics::kind_of_noun(item->action_listed);
			if (kind_of_noun == NULL) kind_of_noun = K_object;
		}

		if (Kinds::Behaviour::is_object(kind_of_noun)) {
			if (APClauses::spec(ap, NOUN_AP_CLAUSE)) {
				CPMC_NEEDED(NOUN_MATCHES_AS_OBJECT_CPMC, NULL);
			}
		} else {
			if (APClauses::spec(ap, NOUN_AP_CLAUSE)) {
				CPMC_NEEDED(NOUN_MATCHES_AS_VALUE_CPMC, NULL);
			}
		}
		if ((item) && (item->action_listed)) {
			kind_of_second = ActionSemantics::kind_of_second(item->action_listed);
			if (kind_of_second == NULL) kind_of_second = K_object;
		}
		if (Kinds::Behaviour::is_object(kind_of_second)) {
			if (APClauses::spec(ap, SECOND_AP_CLAUSE)) {
				CPMC_NEEDED(SECOND_MATCHES_AS_OBJECT_CPMC, NULL);
			}
		} else {
			if (APClauses::spec(ap, SECOND_AP_CLAUSE)) {
				CPMC_NEEDED(SECOND_MATCHES_AS_VALUE_CPMC, NULL);
			}
		}

		if (APClauses::spec(ap, IN_AP_CLAUSE)) {
			if ((APClauses::actor_is_anyone_except_player(ap) == FALSE) && (naming_mode == FALSE) &&
				(APClauses::spec(ap, ACTOR_AP_CLAUSE) == NULL)) {
				CPMC_NEEDED(PLAYER_LOCATION_MATCHES_CPMC, NULL);
			} else {
				CPMC_NEEDED(ACTOR_IN_RIGHT_PLACE_CPMC, NULL);
				CPMC_NEEDED(ACTOR_LOCATION_MATCHES_CPMC, NULL);
			}
		}

		if (APClauses::spec(ap, PARAMETRIC_AP_CLAUSE)) {
			CPMC_NEEDED(PARAMETER_MATCHES_CPMC, NULL);
		}

		LOOP_OVER_AP_CLAUSES(apoc, ap)
			if ((apoc->stv_to_match) && (apoc->clause_spec)) {
				CPMC_NEEDED(OPTIONAL_CLAUSE_CPMC, apoc);
			}

		PluginCalls::set_pattern_match_requirements(ap, &cpm_count, needed, needed_apoc);

		if (APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE) != NULL) {
			instance *to_be_present =
				Specifications::object_exactly_described_if_any(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			if (to_be_present) {
				CPMC_NEEDED(PRESENCE_OF_MATCHES_CPMC, NULL);
				CPMC_NEEDED(PRESENCE_OF_IN_SCOPE_CPMC, NULL);
			} else {
				wording PC = Descriptions::get_calling(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
				if (Wordings::nonempty(PC)) {
					CPMC_NEEDED(LOOP_OVER_SCOPE_WITH_CALLING_CPMC, NULL);
				} else {
					CPMC_NEEDED(LOOP_OVER_SCOPE_WITHOUT_CALLING_CPMC, NULL);
				}
			}
		}
		if (APClauses::spec(ap, WHEN_AP_CLAUSE) != NULL) {
			CPMC_NEEDED(SET_SELF_TO_ACTOR_CPMC, NULL);
			CPMC_NEEDED(WHEN_CONDITION_HOLDS_CPMC, NULL);
		}

		@<Compile the condition from these instructions@>;
	}
}

@

@d CPMC_RANGE(ix, F, T) {
	ranges_from[ix] = F; ranges_to[ix] = T; ranges_count[ix] = 0;
	for (int i=0; i<cpm_count; i++)
		if ((needed[i] >= F) && (needed[i] <= T))
			ranges_count[ix]++;
}

@<Compile the condition from these instructions@> =
	int ranges_from[4], ranges_to[4], ranges_count[4];
	CPMC_RANGE(0, ACTOR_IS_PLAYER_CPMC, ACTOR_MATCHES_CPMC);
	CPMC_RANGE(1, ACTION_MATCHES_CPMC, ACTION_MATCHES_CPMC);
	CPMC_RANGE(2, NOUN_EXISTS_CPMC, NO_DEFINED_CPMC_VALUES);
	CPMC_RANGE(3, SET_SELF_TO_ACTOR_CPMC, WHEN_CONDITION_HOLDS_CPMC);

	int range_to_compile = 0;
	CompileConditions::begin();

	if (ActionNameLists::listwise_negated(ap->action_list)) {
		if (ranges_count[0] > 0) {
			EmitCode::inv(AND_BIP);
			EmitCode::down();
				range_to_compile = 0;
				@<Emit CPM range@>;
		}
		if (ranges_count[3] > 0) {
			EmitCode::inv(AND_BIP);
			EmitCode::down();
		}
		EmitCode::inv(NOT_BIP);
		EmitCode::down();
		if ((ranges_count[1] == 0) && (ranges_count[2] == 0))
			EmitCode::val_false();
		else {
			if ((ranges_count[1] > 0) && (ranges_count[2] > 0)) {
				EmitCode::inv(AND_BIP);
				EmitCode::down();
			}
			if (ranges_count[1] > 0) {
				range_to_compile = 1;
				@<Emit CPM range@>;
			}
			if (ranges_count[2] > 0) {
				range_to_compile = 2;
				@<Emit CPM range@>;
			}
			if ((ranges_count[1] > 0) && (ranges_count[2] > 0)) EmitCode::up();
		}
		EmitCode::up();
		if (ranges_count[3] > 0) {
			range_to_compile = 3;
			@<Emit CPM range@>;
		}
		if (ranges_count[3] > 0) EmitCode::up();
		if (ranges_count[0] > 0) EmitCode::up();
	} else {
		int downs = 0;
		if (ranges_count[1] > 0) {
			if (ranges_count[0]+ranges_count[2]+ranges_count[3] > 0) {
				EmitCode::inv(AND_BIP);
				EmitCode::down(); downs++;
			}
			range_to_compile = 1;
			@<Emit CPM range@>;
		}
		if (ranges_count[0] > 0) {
			if (ranges_count[2]+ranges_count[3] > 0) {
				EmitCode::inv(AND_BIP);
				EmitCode::down(); downs++;
			}
			range_to_compile = 0;
			@<Emit CPM range@>;
		}
		if (ranges_count[2] > 0) {
			if (ranges_count[3] > 0) {
				EmitCode::inv(AND_BIP);
				EmitCode::down(); downs++;
			}
			range_to_compile = 2;
			@<Emit CPM range@>;
		}
		if (ranges_count[3] > 0) {
			range_to_compile = 3;
			@<Emit CPM range@>;
		}
		while (downs > 0) { EmitCode::up(); downs--; }
	}

	if ((ranges_count[0] + ranges_count[1] + ranges_count[2] + ranges_count[3] == 0) &&
		(ActionNameLists::listwise_negated(ap->action_list) == FALSE)) {
		EmitCode::val_true();
	}
	CompileConditions::end();

@<Emit CPM range@> =
	int downs = 0;
	for (int i=0, done=0; i<cpm_count; i++) {
		int cpmc = needed[i];
		if ((cpmc >= ranges_from[range_to_compile]) && (cpmc <= ranges_to[range_to_compile])) {
			done++;
			if (done < ranges_count[range_to_compile]) {
				EmitCode::inv(AND_BIP);
				EmitCode::down(); downs++;
			}
			ap_clause *apoc = needed_apoc[i];
			@<Emit CPM condition piece@>;
		}
	}
	while (downs > 0) { EmitCode::up(); downs--; }

@<Emit CPM condition piece@> =
	if (PluginCalls::compile_pattern_match_clause(VH, ap, cpmc) == FALSE)
	switch (cpmc) {
		case ACTOR_IS_PLAYER_CPMC:
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
				EmitCode::val_iname(K_object, Hierarchy::find(PLAYER_HL));
			EmitCode::up();
			break;
		case ACTOR_ISNT_PLAYER_CPMC:
			EmitCode::inv(NE_BIP);
			EmitCode::down();
				EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
				EmitCode::val_iname(K_object, Hierarchy::find(PLAYER_HL));
			EmitCode::up();
			break;
		case REQUESTER_EXISTS_CPMC:
			EmitCode::val_iname(K_object, Hierarchy::find(ACT_REQUESTER_HL));
			break;
		case REQUESTER_DOESNT_EXIST_CPMC:
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_iname(K_object, Hierarchy::find(ACT_REQUESTER_HL));
				EmitCode::val_number(0);
			EmitCode::up();
			break;
		case ACTOR_MATCHES_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH, Inter_actor_VAR, APClauses::spec(ap, ACTOR_AP_CLAUSE), K_object, FALSE);
			break;
		case ACTION_MATCHES_CPMC:
			RTActions::emit_anl(ap->action_list);
			break;
		case NOUN_EXISTS_CPMC:
			EmitCode::val_iname(K_object, Hierarchy::find(NOUN_HL));
			break;
		case NOUN_IS_INP1_CPMC:
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_iname(K_object, Hierarchy::find(NOUN_HL));
				EmitCode::val_iname(K_object, Hierarchy::find(INP1_HL));
			EmitCode::up();
			break;
		case SECOND_EXISTS_CPMC:
			EmitCode::val_iname(K_object, Hierarchy::find(SECOND_HL));
			break;
		case SECOND_IS_INP1_CPMC:
			EmitCode::inv(EQ_BIP);
			EmitCode::down();
				EmitCode::val_iname(K_object, Hierarchy::find(SECOND_HL));
				EmitCode::val_iname(K_object, Hierarchy::find(INP2_HL));
			EmitCode::up();
			break;
		case NOUN_MATCHES_AS_OBJECT_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH, Inter_noun_VAR, APClauses::spec(ap, NOUN_AP_CLAUSE),
				kind_of_noun, FALSE);
			break;
		case NOUN_MATCHES_AS_VALUE_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH,
				RTTemporaryVariables::from_iname(Hierarchy::find(PARSED_NUMBER_HL), kind_of_noun),
				APClauses::spec(ap, NOUN_AP_CLAUSE), kind_of_noun, FALSE);
			break;
		case SECOND_MATCHES_AS_OBJECT_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH, Inter_second_noun_VAR, APClauses::spec(ap, SECOND_AP_CLAUSE),
				kind_of_second, FALSE);
			break;
		case SECOND_MATCHES_AS_VALUE_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH,
				RTTemporaryVariables::from_iname(Hierarchy::find(PARSED_NUMBER_HL), kind_of_second),
				APClauses::spec(ap, SECOND_AP_CLAUSE), kind_of_second, FALSE);
			break;
		case PLAYER_LOCATION_MATCHES_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH, real_location_VAR, APClauses::spec(ap, IN_AP_CLAUSE), K_object, TRUE);
			break;
		case ACTOR_IN_RIGHT_PLACE_CPMC:
			EmitCode::inv(STORE_BIP);
			EmitCode::down();
				EmitCode::ref_iname(K_object, Hierarchy::find(ACTOR_LOCATION_HL));
				EmitCode::call(Hierarchy::find(LOCATIONOF_HL));
				EmitCode::down();
					EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
				EmitCode::up();
			EmitCode::up();
			break;
		case ACTOR_LOCATION_MATCHES_CPMC:
			RTActionPatterns::compile_pattern_match_clause(VH, actor_location_VAR,
				APClauses::spec(ap, IN_AP_CLAUSE), K_object, TRUE);
			break;
		case PARAMETER_MATCHES_CPMC: {
			kind *saved_kind = NonlocalVariables::kind(parameter_object_VAR);
			NonlocalVariables::set_kind(parameter_object_VAR, ap->parameter_kind);
			RTActionPatterns::compile_pattern_match_clause(VH,
				parameter_object_VAR, APClauses::spec(ap, PARAMETRIC_AP_CLAUSE), ap->parameter_kind, FALSE);
			NonlocalVariables::set_kind(parameter_object_VAR, saved_kind);
			break;
		}
		case OPTIONAL_CLAUSE_CPMC: {
			kind *K = SharedVariables::get_kind(apoc->stv_to_match);
			RTActionPatterns::compile_pattern_match_clause(VH,
				RTTemporaryVariables::from_existing_variable(apoc->stv_to_match->underlying_var, K),
				apoc->clause_spec, K, APClauses::opt(apoc, ALLOW_REGION_AS_ROOM_APCOPT));
			break;
		}
		case PRESENCE_OF_MATCHES_CPMC: {
			instance *to_be_present =
				Specifications::object_exactly_described_if_any(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			RTActionPatterns::compile_pattern_match_clause(VH,
				RTTemporaryVariables::from_iname(RTInstances::iname(to_be_present), K_object),
				APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE), K_object, FALSE);
			break;
		}
		case PRESENCE_OF_IN_SCOPE_CPMC: {
			instance *to_be_present =
				Specifications::object_exactly_described_if_any(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			EmitCode::call(Hierarchy::find(TESTSCOPE_HL));
			EmitCode::down();
				EmitCode::val_iname(K_value, RTInstances::iname(to_be_present));
				EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
			EmitCode::up();
			break;
		}
		case LOOP_OVER_SCOPE_WITH_CALLING_CPMC: {
			loop_over_scope *los = LoopingOverScope::new(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			wording PC = Descriptions::get_calling(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			local_variable *lvar = LocalVariables::ensure_calling(PC,
				Specifications::to_kind(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE)));
			inter_symbol *lvar_s = LocalVariables::declare(lvar);
			EmitCode::inv(SEQUENTIAL_BIP);
			EmitCode::down();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(LOS_RV_HL));
					EmitCode::val_number(0);
				EmitCode::up();
				EmitCode::inv(SEQUENTIAL_BIP);
				EmitCode::down();
					EmitCode::call(Hierarchy::find(LOOPOVERSCOPE_HL));
					EmitCode::down();
						EmitCode::val_iname(K_value, los->los_iname);
						EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
					EmitCode::up();
					EmitCode::inv(STORE_BIP);
					EmitCode::down();
						EmitCode::ref_symbol(K_value, lvar_s);
						EmitCode::val_iname(K_value, Hierarchy::find(LOS_RV_HL));
					EmitCode::up();
				EmitCode::up();
			EmitCode::up();
			break;
		}
		case LOOP_OVER_SCOPE_WITHOUT_CALLING_CPMC: {
			loop_over_scope *los = LoopingOverScope::new(APClauses::spec(ap, IN_THE_PRESENCE_OF_AP_CLAUSE));
			EmitCode::inv(SEQUENTIAL_BIP);
			EmitCode::down();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(LOS_RV_HL));
					EmitCode::val_number(0);
				EmitCode::up();
				EmitCode::inv(SEQUENTIAL_BIP);
				EmitCode::down();
					EmitCode::call(Hierarchy::find(LOOPOVERSCOPE_HL));
					EmitCode::down();
						EmitCode::val_iname(K_value, los->los_iname);
						EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
					EmitCode::up();
					EmitCode::val_iname(K_value, Hierarchy::find(LOS_RV_HL));
				EmitCode::up();
			EmitCode::up();
			break;
		}
		case SET_SELF_TO_ACTOR_CPMC:
			EmitCode::inv(SEQUENTIAL_BIP);
			EmitCode::down();
				EmitCode::inv(STORE_BIP);
				EmitCode::down();
					EmitCode::ref_iname(K_value, Hierarchy::find(SELF_HL));
					EmitCode::val_iname(K_object, Hierarchy::find(ACTOR_HL));
				EmitCode::up();
				EmitCode::val_true();
			EmitCode::up();
			break;
		case WHEN_CONDITION_HOLDS_CPMC:
			CompileValues::to_code_val(APClauses::spec(ap, WHEN_AP_CLAUSE));
			break;
	}

@ =
void RTActionPatterns::emit_past_tense(action_pattern *ap) {
	int bad_form = FALSE;
	EmitCode::call(Hierarchy::find(TESTACTIONBITMAP_HL));
	EmitCode::down();
	if (APClauses::spec(ap, NOUN_AP_CLAUSE) == NULL)
		EmitCode::val_number(0);
	else
		CompileValues::to_code_val(APClauses::spec(ap, NOUN_AP_CLAUSE));
	int L = ActionNameLists::length(ap->action_list);
	if (L == 0)
		EmitCode::val_number((inter_ti) -1);
	else {
		anl_item *item = ActionNameLists::first_item(ap->action_list);
		if (L >= 2) bad_form = TRUE;
		if (ActionSemantics::can_be_compiled_in_past_tense(item->action_listed) == FALSE)
			bad_form = TRUE;
		EmitCode::val_iname(K_value, RTActions::double_sharp(item->action_listed));
	}
	EmitCode::up();
	if (APClauses::viable_in_past_tense(ap) == FALSE) bad_form = TRUE;
	if (bad_form)
		@<Issue too complex PT problem@>;
}

@<Issue too complex PT problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_PTAPTooComplex),
		"that is too complex a past tense action",
		"at least for this version of Inform to handle: we may improve "
		"matters in later releases. The restriction is that the "
		"actions used in the past tense may take at most one "
		"object, and that this must be a physical thing (not a "
		"value, in other words). And no details of where or what "
		"else was then happening can be specified.");
