[CompileValues::] Compile Values.

To compile specifications of values into Inter value opcodes or array entries.

@h Introduction.
Quite a range of data can be held as specifications: see //values: Specifications//.
Inside the compiler these are stored as |parse_node| pointers. This section of
code aims to provide a single unified way to compile values, even though:

(*) We may need to compile either an array entry or an Inter |val| opcode.
We abstract this using //building: Value Holsters//, holders into which
compiled values are placed.
(*) We sometimes need to compile a value which needs to be converted to a
different kind first, a process called "casting".
(*) Sometimes a fresh copy of a value is needed, and sometimes a reference to
its existing copy. 

This complexity was historically managed by having persistent "compilation
modes" which Inform would enter for short periods and then exit, and during
which specifications would compile difficulty. This had worked well enough
since 2005 but by the 2020s there were 12 different modes, making in principle
1024 different combinations to worry over. Because modes were entered and
exited far away from their consequences, and in dozens of different parts of
the compiler, it became difficult to reason with any confidence about what
would happen, so worrying was about all that could be done.

In April 2021, all modes were removed except |compile_spec_in_constant_mode|,
and even that one is relatively benign: entry and exit into it is managed
automatically by the code below, so that the rest of Inform no longer needs
to think about compilation modes at all.

=
int compile_spec_in_constant_mode = FALSE;
int CompileValues::compiling_in_constant_mode(void) {
	return compile_spec_in_constant_mode;
}

@h An API for compiling specifications.
When the rest of Inform wants to compile a specification, it should call one
of the following functions.

To begin with, compiling to array entries:

=
void CompileValues::to_array_entry_of_kind(parse_node *value, kind *K_wanted) {
	CompileValues::to_array_entry(
		CompileValues::cast_constant(value, K_wanted));
}

void CompileValues::to_array_entry(parse_node *value) {
	inter_ti v1 = 0, v2 = 0;
	value_holster VH = Holsters::new(INTER_DATA_VHMODE);
	CompileValues::to_holster(&VH, value, COMPILE_SPEC_AS_CONSTANT);
	Holsters::unholster_pair(&VH, &v1, &v2);
	Emit::array_generic_entry(v1, v2);
}

@ Now constants, which can be compiled either to a holster or to a pair of |inter_t|
numbers. Use the latter as little as possible.

=
void CompileValues::constant_to_holster(value_holster *VH, parse_node *value,
	kind *K_wanted) {
	CompileValues::to_holster(VH,
		CompileValues::cast_constant(value, K_wanted), COMPILE_SPEC_AS_CONSTANT);
}

void CompileValues::constant_to_pair(inter_ti *v1, inter_ti *v2,
	parse_node *value, kind *K_wanted) {
	value_holster VH = Holsters::new(INTER_DATA_VHMODE);
	CompileValues::constant_to_holster(&VH, value, K_wanted);
	Holsters::unholster_pair(&VH, v1, v2);
}

@ A general method (i.e., not restricted to constant context) for compiling to a
pair of |inter_t| numbers. Use this as little as possible.

=
void CompileValues::to_pair(inter_ti *v1, inter_ti *v2, parse_node *spec) {
	value_holster VH = Holsters::new(INTER_DATA_VHMODE);
	CompileValues::to_holster(&VH, spec, COMPILE_SPEC_AS_VALUE);
	Holsters::unholster_pair(&VH, v1, v2);
}

@ Finally, for compiling to Inter opcodes in a |val| context -- in other words,
for values as they appear in imperative code rather than in data structures.
A "fresh" value should be made when we want the value compiled to be a new,
independent copy of the data in question. Consider:
= (text as Inform 7)
	let T be { 2, 3, 5, 7 };
	let U be T;
	add 11 to T;
=
Clearly |U| must be set to a fresh copy of the data in |T|, not a reference to the
same data. So the |T| in line 2 must be compiled as "fresh", whereas the |T| in
line 3 must not.

=
void CompileValues::to_code_val(parse_node *value) {
	CompileValues::to_code_val_inner(value, NULL, COMPILE_SPEC_AS_VALUE);
}
void CompileValues::to_code_val_of_kind(parse_node *value, kind *K) {
	CompileValues::to_code_val_inner(value, K, COMPILE_SPEC_AS_VALUE);
}
void CompileValues::to_fresh_code_val_of_kind(parse_node *value, kind *K) {
	CompileValues::to_code_val_inner(value, K, COMPILE_SPEC_AS_FRESH_VALUE);
}
void CompileValues::to_code_val_inner(parse_node *value, kind *K, int how) {
	int down = FALSE;
	if (K) value = CompileValues::cast_nonconstant(value, K, &down);
	value_holster VH = Holsters::new(INTER_VAL_VHMODE);
	CompileValues::to_holster(&VH, value, how);
	if (down) Produce::up(Emit::tree());
}

@h Implementation.
All of the functions in the above API make use of these private ones:

@d COMPILE_SPEC_AS_CONSTANT    1
@d COMPILE_SPEC_AS_VALUE       2
@d COMPILE_SPEC_AS_FRESH_VALUE 3

=
void CompileValues::to_holster(value_holster *VH, parse_node *value, int how) {
	switch (how) {
		case COMPILE_SPEC_AS_CONSTANT:    LOGIF(EXPRESSIONS, "Compiling (const): $P\n", value); break;
		case COMPILE_SPEC_AS_VALUE:       LOGIF(EXPRESSIONS, "Compiling (value): $P\n", value); break;
		case COMPILE_SPEC_AS_FRESH_VALUE: LOGIF(EXPRESSIONS, "Compiling (fresh): $P\n", value); break;
	}
	int s = compile_spec_in_constant_mode;
	if (how == COMPILE_SPEC_AS_CONSTANT) compile_spec_in_constant_mode = TRUE;
	else compile_spec_in_constant_mode = FALSE;
	LOG_INDENT;
	@<Take care of any freshness@>;
	LOG_OUTDENT;
	compile_spec_in_constant_mode = s;
}

@ This implements "fresh" mode. For regular values like numbers there's no
difference, but if our value is a block value such as a list then we evaluate to
a copy of it, not to the original. Making that copy means calling |BlkValueCopy|
at runtime, so it cannot be done in a data holster (i.e., when |VH| is an
|INTER_DATA_VHMODE| holster).

@<Take care of any freshness@> =	
	value = NonlocalVariables::substitute_constants(value);
	kind *K_found = Specifications::to_kind(value);
	RTKinds::notify_of_use(K_found);
	int made_fresh = FALSE;
	if (how == COMPILE_SPEC_AS_FRESH_VALUE) {
		if (VH->vhmode_wanted == INTER_DATA_VHMODE)
			internal_error("must compile by reference in INTER_DATA_VHMODE"); 
		kind *K = Specifications::to_kind(value);
		if ((K) && (Kinds::Behaviour::uses_pointer_values(K))) {
			Produce::inv_call_iname(Emit::tree(), Hierarchy::find(BLKVALUECOPY_HL));
			Produce::down(Emit::tree());
				Frames::emit_new_local_value(K);
			made_fresh = TRUE;
		}
	}
	@<Actually compile@>;
	if (made_fresh) {
		Produce::up(Emit::tree());
	}

@<Actually compile@> =
	if (Lvalues::is_lvalue(value)) {
		Lvalues::compile(VH, value);
	} else if (Rvalues::is_rvalue(value)) {
		Rvalues::compile(VH, value);
		if ((VH->vhmode_provided == INTER_DATA_VHMODE) &&
			(VH->vhmode_wanted == INTER_VAL_VHMODE)) {
			Holsters::unholster_to_code_val(Emit::tree(), VH);
		}
	} else if (Specifications::is_condition(value)) {
		Conditions::compile(VH, value);
	}

@ "Casting" is converting a value of one kind to a value of another but which has
the same meaning, give or take. In a constant context, the main cast we can
perform is from literal |K_number| values like |31| to turn them into literal
|K_real_number| values, a process called "promotion".

=
parse_node *CompileValues::cast_constant(parse_node *value, kind *K_wanted) {
	value = NonlocalVariables::substitute_constants(value);
	RTKinds::notify_of_use(K_wanted);
	value = LiteralReals::promote_number_if_necessary(value, K_wanted);
	kind *K_found = Specifications::to_kind(value);
	if ((K_understanding) &&
		(Kinds::eq(K_wanted, K_understanding)) && (Kinds::eq(K_found, K_text)))
		Node::set_kind_of_value(value, K_understanding);
	return value;
}

@ In a value context we can additionally compile code to perform the conversion
at runtime, which extends the range of promotions we can make.

=
parse_node *CompileValues::cast_nonconstant(parse_node *value, kind *K_wanted,
	int *down) {
	value = CompileValues::cast_constant(value, K_wanted);
	kind *K_found = Specifications::to_kind(value);
	RTKinds::notify_of_use(K_found);
	RTKinds::emit_cast_call(K_found, K_wanted, down);
	return value;
}