[CompileLoops::] Compile Loops.

To compile loop headers from a range of values expressed by a proposition.

@h Domains of loops.
This function ccmpiles the header (and in effect therefore the structure)
of a loop through all values $x$ such that $\phi(x)$ is true, where $\phi$
is the proposition inside the description |desc|. The loop variable will
be |v1|.

=
void CompileLoops::through_matches(parse_node *spec, local_variable *v1) {
	kind *DK = Specifications::to_kind(spec);
	if (Kinds::get_construct(DK) != CON_description)
		internal_error("repeat through non-description");
	kind *K = Kinds::unary_construction_material(DK);
	CodeBlocks::set_scope_to_block_about_to_open(v1);
	local_variable *v2 = LocalVariables::new_let_value(EMPTY_WORDING, K);
	CodeBlocks::set_scope_to_block_about_to_open(v2);

	if (Kinds::Behaviour::is_object(K)) {
		@<Exploit the runtime representation of objects@>
	} else {
		i6_schema loop_schema;
		if (CompileLoops::schema(&loop_schema, K)) @<Compile from the kind's loop schema@>
		else @<Issue bad repeat domain problem@>;
	}
}

@ In the case where we are looping through objects, we can exploit a runtime
ability to move quickly to the next object in a given kind. This requires a
loop construction a little too complex for a schema, so we generate the code
by hand.

In fact we secretly make a second loop variable |v2| as well, though it is
invisible from source text, and construct a loop analogous to:
= (text)
	for (v1=D(0), v2=D(v1); v1; v1=v2, v2=D(v1))
=
where |D| is a function deferred from the proposition which is such that:
(*) |D(0)| produces the first $x$ such that $\phi(x)$, and otherwise
(*) |D(x)| produces either the next match after $x$, or 0 to indicate that
there are no further matches.

This arrangement is possible because object values, and enumerated values, are
never equal to 0 at runtime.

The reason we do not simply compile
= (text)
	for (v1=D(0); v1; v1=D(v1))
=
is to protects us in case the body of the loop takes action which moves |v1| out
of the domain -- e.g., in the case of:
= (text as Inform 7)
	repeat with T running through items on the table:
		now T is in the box.
=
This is the famous "broken |objectloop|" hazard of Inform 6. Experience shows
that authors value safety over the slight speed overhead incurred.

@<Exploit the runtime representation of objects@> =
	inter_symbol *val_var_s = LocalVariables::declare(v1);
	inter_symbol *aux_var_s = LocalVariables::declare(v2);

	if (Deferrals::spec_is_variable_of_kind_description(spec) == FALSE) {
		pcalc_prop *domain_prop = SentencePropositions::from_spec(spec);
		if (CreationPredicates::contains_callings(domain_prop))
			@<Issue called in repeat problem@>;
	}

	Produce::inv_primitive(Emit::tree(), FOR_BIP);
	Produce::down(Emit::tree());
		Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
		Produce::down(Emit::tree());
			Produce::inv_primitive(Emit::tree(), STORE_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, val_var_s);
				CompileLoops::iterate(spec, NULL);
			Produce::up(Emit::tree());
			Produce::inv_primitive(Emit::tree(), STORE_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, aux_var_s);
				CompileLoops::iterate(spec, v1);
			Produce::up(Emit::tree());
		Produce::up(Emit::tree());

		Produce::val_symbol(Emit::tree(), K_value, val_var_s);

		Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
		Produce::down(Emit::tree());
			Produce::inv_primitive(Emit::tree(), STORE_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, val_var_s);
				Produce::val_symbol(Emit::tree(), K_value, aux_var_s);
			Produce::up(Emit::tree());
			Produce::inv_primitive(Emit::tree(), STORE_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, aux_var_s);
				CompileLoops::iterate(spec, v2);
			Produce::up(Emit::tree());
		Produce::up(Emit::tree());

		Produce::code(Emit::tree());
		Produce::down(Emit::tree());

@ It would be nice to generate the whole loop from the schema for the kind,
but of course our description is unlikely to be just ${\it kind}_K(x)$. So
the idea is roughly:
= (text)
	loop over each v1 in K
	    if phi(v1)
	        ...
=
We can optimise out the "if" part in the case when $\phi(x) = {\it kind}_K(x)$.

@<Compile from the kind's loop schema@> =
	CompileSchemas::from_local_variables_in_void_context(&loop_schema, v1, v2);
	if (Lvalues::is_lvalue(spec) == FALSE) {
		if (Specifications::is_kind_like(spec) == FALSE) {
			pcalc_prop *prop = Specifications::to_proposition(spec);
			if (prop) {
				Produce::inv_primitive(Emit::tree(), IF_BIP);
				Produce::down(Emit::tree());
					CompilePropositions::to_test_as_condition(
						Lvalues::new_LOCAL_VARIABLE(EMPTY_WORDING, v1), prop);
					Produce::code(Emit::tree());
					Produce::down(Emit::tree());
			}
		}
	} else {
		Produce::inv_primitive(Emit::tree(), IF_BIP);
		Produce::down(Emit::tree());
			Produce::inv_primitive(Emit::tree(), INDIRECT2_BIP);
			Produce::down(Emit::tree());
				CompileValues::to_code_val(spec);
				Produce::val(Emit::tree(), K_number, LITERAL_IVAL,
					(inter_ti) CONDITION_DUSAGE);
				CompileValues::to_code_val(
					Lvalues::new_LOCAL_VARIABLE(EMPTY_WORDING, v1));
			Produce::up(Emit::tree());
			Produce::code(Emit::tree());
			Produce::down(Emit::tree());
	}

@<Issue called in repeat problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_CalledInRepeat),
		"this tries to use '(called ...)' to give names to values "
		"arising in the course of working out what to repeat through",
		"but this is not allowed. (Sorry: it's too hard to get right.)");

@<Issue bad repeat domain problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_BadRepeatDomain),
		"this describes a collection of values which can't be repeated through",
		"because the possible range is too large (or has no sensible ordering). "
		"For instance, you can 'repeat with D running through doors' because "
		"there are only a small number of doors and they can be put in order "
		"of creation. But you can't 'repeat with N running through numbers' "
		"because numbers are without end.");

@ Here we compile code to call |D(v)|, on the variable |fromv|, or |D(0)| if
|fromv| is |NULL|. As in //Deciding to Defer//, we are forced to call |D| as
a multipurpose description function if it is not known at compile time; but
we can more efficiently defer for this single purpose if it is.

=
void CompileLoops::iterate(parse_node *spec, local_variable *fromv) {
	if (Deferrals::spec_is_variable_of_kind_description(spec)) {
		Produce::inv_primitive(Emit::tree(), INDIRECT2_BIP);
		Produce::down(Emit::tree());
			CompileValues::to_code_val(spec);
			Produce::val(Emit::tree(), K_number, LITERAL_IVAL,
				(inter_ti) LOOP_DOMAIN_DUSAGE);
			if (fromv) {
				inter_symbol *fromv_s = LocalVariables::declare(fromv);
				Produce::val_symbol(Emit::tree(), K_value, fromv_s);
			} else {
				Produce::val(Emit::tree(), K_number, LITERAL_IVAL, 0);
			}
		Produce::up(Emit::tree());
	} else {
		pcalc_prop *prop = SentencePropositions::from_spec(spec);
		pcalc_prop_deferral *pdef = Deferrals::defer_loop_domain(prop);
		int arity = Cinders::count(prop, pdef) + 1;
		switch (arity) {
			case 0: Produce::inv_primitive(Emit::tree(), INDIRECT0_BIP); break;
			case 1: Produce::inv_primitive(Emit::tree(), INDIRECT1_BIP); break;
			case 2: Produce::inv_primitive(Emit::tree(), INDIRECT2_BIP); break;
			case 3: Produce::inv_primitive(Emit::tree(), INDIRECT3_BIP); break;
			case 4: Produce::inv_primitive(Emit::tree(), INDIRECT4_BIP); break;
			default: internal_error("indirect function call with too many arguments");
		}
		Produce::down(Emit::tree());
			Produce::val_iname(Emit::tree(), K_value, pdef->ppd_iname);
			Cinders::compile_cindered_values(prop, pdef);
			if (fromv) {
				inter_symbol *fromv_s = LocalVariables::declare(fromv);
				Produce::val_symbol(Emit::tree(), K_value, fromv_s);
			} else {
				Produce::val(Emit::tree(), K_number, LITERAL_IVAL, 0);
			}
		Produce::up(Emit::tree());
	}
}

@h Loop schemas over a whole kind.
If |K| is a kind, this function generates a schema for a loop over all instances
of the kind, or returns |FALSE| if that is impossible or unreasonable.

In the situation above, this function was needed only for non-object kinds; but
other parts of Inform also use it, so it needs to work for object kinds too.

Choosing an efficient schema here makes a big difference to Inform's runtime
performance.

@d MAX_LOOP_DOMAIN_SCHEMA_LENGTH 1000

=
int CompileLoops::schema(i6_schema *sch, kind *K) {
	if (K == NULL) return FALSE;
	if (Kinds::Behaviour::is_subkind_of_object(K)) {
		if (PL::Counting::optimise_loop(sch, K) == FALSE)
			Calculus::Schemas::modify(sch, "objectloop (*1 ofclass %n)",
				RTKinds::I6_classname(K));
		return TRUE;
	}
	if (Kinds::eq(K, K_object)) {
		Calculus::Schemas::modify(sch, "objectloop (*1 ofclass Object)");
		return TRUE;
	}
	if (Kinds::Behaviour::is_an_enumeration(K)) {
		Calculus::Schemas::modify(sch,
			"for (*1=1: *1<=%d: *1++)",
				Kinds::Behaviour::get_highest_valid_value_as_integer(K));
		return TRUE;
	}
	text_stream *p = K->construct->loop_domain_schema;
	if (p == NULL) return FALSE;
	Calculus::Schemas::modify(sch, "%S", p);
	return TRUE;
}

@h Loops through list values.
This is a quite different kind of loop: for iterating through the members of
a list (whose contents are not known at compile time).

We need three variables, of which only |val_var| is visible in source text:
(*) |index_var_s| is the position in the list -- 0, 1, 2, ...;
(*) |val_var_s| is the entry at that position;
(*) |copy_var_s| is the list itself -- which we stash into this temporary
variable to avoid having to evaluate it more than once.

=
void CompileLoops::through_list(parse_node *spec, local_variable *val_var) {
	local_variable *index_var = LocalVariables::new_let_value(EMPTY_WORDING, K_number);
	local_variable *copy_var = LocalVariables::new_let_value(EMPTY_WORDING, K_number);
	kind *K = Specifications::to_kind(spec);
	kind *CK = Kinds::unary_construction_material(K);

	int pointery = FALSE;
	if (Kinds::Behaviour::uses_pointer_values(CK)) {
		pointery = TRUE;
		LocalVariableSlates::free_at_end_of_scope(val_var);
	}

	CodeBlocks::set_scope_to_block_about_to_open(val_var);
	LocalVariables::set_kind(val_var, CK);
	CodeBlocks::set_scope_to_block_about_to_open(index_var);

	inter_symbol *val_var_s = LocalVariables::declare(val_var);
	inter_symbol *index_var_s = LocalVariables::declare(index_var);
	inter_symbol *copy_var_s = LocalVariables::declare(copy_var);

	Produce::inv_primitive(Emit::tree(), FOR_BIP);
	Produce::down(Emit::tree());
		Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
		Produce::down(Emit::tree());
			Produce::inv_primitive(Emit::tree(), STORE_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, copy_var_s);
				CompileValues::to_code_val(spec);
			Produce::up(Emit::tree());
			Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
			Produce::down(Emit::tree());
				Produce::inv_primitive(Emit::tree(), STORE_BIP);
				Produce::down(Emit::tree());
					Produce::ref_symbol(Emit::tree(), K_value, index_var_s);
					Produce::val(Emit::tree(), K_number, LITERAL_IVAL, 1);
				Produce::up(Emit::tree());
				if (pointery) {
					Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
					Produce::down(Emit::tree());
						Produce::inv_primitive(Emit::tree(), STORE_BIP);
						Produce::down(Emit::tree());
							Produce::ref_symbol(Emit::tree(), K_value, val_var_s);
							Produce::inv_call_iname(Emit::tree(), Hierarchy::find(BLKVALUECREATE_HL));
							Produce::down(Emit::tree());
								RTKinds::emit_strong_id_as_val(CK);
							Produce::up(Emit::tree());
						Produce::up(Emit::tree());
						Produce::inv_call_iname(Emit::tree(), Hierarchy::find(BLKVALUECOPYAZ_HL));
						Produce::down(Emit::tree());
							Produce::val_symbol(Emit::tree(), K_value, val_var_s);
							Produce::inv_call_iname(Emit::tree(), Hierarchy::find(LIST_OF_TY_GETITEM_HL));
							Produce::down(Emit::tree());
								Produce::val_symbol(Emit::tree(), K_value, copy_var_s);
								Produce::val_symbol(Emit::tree(), K_value, index_var_s);
								Produce::val(Emit::tree(), K_truth_state, LITERAL_IVAL, 1);
							Produce::up(Emit::tree());
						Produce::up(Emit::tree());
					Produce::up(Emit::tree());
				} else {
					Produce::inv_primitive(Emit::tree(), STORE_BIP);
					Produce::down(Emit::tree());
						Produce::ref_symbol(Emit::tree(), K_value, val_var_s);
						Produce::inv_call_iname(Emit::tree(), Hierarchy::find(LIST_OF_TY_GETITEM_HL));
						Produce::down(Emit::tree());
							Produce::val_symbol(Emit::tree(), K_value, copy_var_s);
							Produce::val_symbol(Emit::tree(), K_value, index_var_s);
							Produce::val(Emit::tree(), K_truth_state, LITERAL_IVAL, 1);
						Produce::up(Emit::tree());
					Produce::up(Emit::tree());
				}
			Produce::up(Emit::tree());
		Produce::up(Emit::tree());

		Produce::inv_primitive(Emit::tree(), LE_BIP);
		Produce::down(Emit::tree());
			Produce::val_symbol(Emit::tree(), K_value, index_var_s);
			Produce::inv_call_iname(Emit::tree(), Hierarchy::find(LIST_OF_TY_GETLENGTH_HL));
			Produce::down(Emit::tree());
				Produce::val_symbol(Emit::tree(), K_value, copy_var_s);
			Produce::up(Emit::tree());
		Produce::up(Emit::tree());

		Produce::inv_primitive(Emit::tree(), SEQUENTIAL_BIP);
		Produce::down(Emit::tree());
			Produce::inv_primitive(Emit::tree(), POSTINCREMENT_BIP);
			Produce::down(Emit::tree());
				Produce::ref_symbol(Emit::tree(), K_value, index_var_s);
			Produce::up(Emit::tree());
			if (pointery) {
				Produce::inv_call_iname(Emit::tree(), Hierarchy::find(BLKVALUECOPYAZ_HL));
				Produce::down(Emit::tree());
					Produce::val_symbol(Emit::tree(), K_value, val_var_s);
					Produce::inv_call_iname(Emit::tree(), Hierarchy::find(LIST_OF_TY_GETITEM_HL));
					Produce::down(Emit::tree());
						Produce::val_symbol(Emit::tree(), K_value, copy_var_s);
						Produce::val_symbol(Emit::tree(), K_value, index_var_s);
						Produce::val(Emit::tree(), K_truth_state, LITERAL_IVAL, 1);
					Produce::up(Emit::tree());
				Produce::up(Emit::tree());
			} else {
				Produce::inv_primitive(Emit::tree(), STORE_BIP);
				Produce::down(Emit::tree());
					Produce::ref_symbol(Emit::tree(), K_value, val_var_s);
					Produce::inv_call_iname(Emit::tree(), Hierarchy::find(LIST_OF_TY_GETITEM_HL));
					Produce::down(Emit::tree());
						Produce::val_symbol(Emit::tree(), K_value, copy_var_s);
						Produce::val_symbol(Emit::tree(), K_value, index_var_s);
						Produce::val(Emit::tree(), K_truth_state, LITERAL_IVAL, 1);
					Produce::up(Emit::tree());
				Produce::up(Emit::tree());
			}
		Produce::up(Emit::tree());

		Produce::code(Emit::tree());
			Produce::down(Emit::tree());
}
