[Kinds::Knowledge::] Knowledge about Kinds.

How kinds can be inference subjects.

@h In principle every base kind gets its own inference subject, making it possible
to draw inferences from sentences such as:

>> A scene has a number called the witness count. The witness count of a scene is usually 4.

In practice we never need inferences for intermediate kinds, since they
don't last enough and aren't visible enough to have properties. We do need
exactly one inference subject per base kind: one for "scene" (as in the
above example), one for "text" and so on.

Constructed kinds like "list of scenes" have no properties, and no inferences
are drawn about them.

=
inference_subject *Kinds::Knowledge::as_subject(kind *K) {
	if (K == NULL) return NULL;
	return K->construct->dt_knowledge;
}

void Kinds::Knowledge::set_subject(kind *K, inference_subject *infs) {
	if (K == NULL) return;
	K->construct->dt_knowledge = infs;
}

inference_subject *Kinds::Knowledge::create_for_constructor(kind_constructor *con) {
	return InferenceSubjects::new(global_constants,
		KIND_SUB, STORE_POINTER_kind_constructor(con), LIKELY_CE);
}

@ Some values can have properties attached -- scenes, for instance -- while
others can't -- numbers or times, for instance. In general a value can have
properties only if its kind passes this test:

=
int Kinds::Knowledge::has_properties(kind *K) {
	if (K == NULL) return FALSE;
	if (Kinds::Behaviour::is_an_enumeration(K)) return TRUE;
	if (Kinds::Behaviour::is_object(K)) return TRUE;
	return FALSE;
}

@ This is one of Inform's sets of inference subjects, and here are the
routines to support them:

=
wording Kinds::Knowledge::get_name_text(inference_subject *from) {
	kind *K = InferenceSubjects::as_kind(from);
	return Kinds::Behaviour::get_name(K, FALSE);
}
void Kinds::Knowledge::complete_model(inference_subject *infs) { }
void Kinds::Knowledge::check_model(inference_subject *infs) { }

int Kinds::Knowledge::emit_element_of_condition(inference_subject *infs, inter_symbol *t0_s) {
	kind *K = InferenceSubjects::as_kind(infs);
	if (Kinds::Behaviour::is_subkind_of_object(K)) {
		Produce::inv_primitive(Emit::tree(), OFCLASS_BIP);
		Produce::down(Emit::tree());
			Produce::val_symbol(Emit::tree(), K_value, t0_s);
			Produce::val_iname(Emit::tree(), K_value, Kinds::RunTime::I6_classname(K));
		Produce::up(Emit::tree());
		return TRUE;
	}
	if (Kinds::eq(K, K_object)) {
		Produce::val_symbol(Emit::tree(), K_value, t0_s);
		return TRUE;
	}
	return FALSE;
}

@ As noted above, a POVS structure is attached to every property permission
concerning our kind.

=
general_pointer Kinds::Knowledge::new_permission_granted(inference_subject *from) {
	return STORE_POINTER_property_of_value_storage(
		Properties::OfValues::get_storage());
}

@ When a property value comes along which might have an adjectival use -- say,
"green" out of a range of possible colour nouns -- the following is called.
We simply pass the request along to the appropriate code.

=
void Kinds::Knowledge::make_adj_const_domain(inference_subject *infs,
	instance *nc, property *prn) {
	kind *K = InferenceSubjects::as_kind(infs);
	Instances::make_adj_const_domain(nc, prn, K, NULL);
}

@ These routines do actually do something big -- they emit the great stream
of Inter commands needed to define the kinds and their properties.

First, we will call |Properties::Emit::emit_subject| for all kinds of object,
beginning with object and working downwards through the tree of its subkinds.
After that, we call it for all other kinds able to have properties, in no
particular order.

=
int Kinds::Knowledge::emit_all(void) {
	inter_name *iname = Hierarchy::find(MAX_WEAK_ID_HL);
	Emit::named_numeric_constant(iname, (inter_ti) next_free_data_type_ID);
	Kinds::Knowledge::emit_recursive(Kinds::Knowledge::as_subject(K_object));
	return FALSE;
}

void Kinds::Knowledge::emit_recursive(inference_subject *within) {
	Properties::Emit::emit_subject(within);
	inference_subject *subj;
	LOOP_OVER(subj, inference_subject)
		if ((InferenceSubjects::narrowest_broader_subject(subj) == within) &&
			(InferenceSubjects::is_a_kind_of_object(subj))) {
			Kinds::Knowledge::emit_recursive(subj);
		}
}

void Kinds::Knowledge::emit(inference_subject *infs) {
	kind *K = InferenceSubjects::as_kind(infs);
	if ((Kinds::Knowledge::has_properties(K)) &&
		(Kinds::Behaviour::is_object(K) == FALSE))
		Properties::Emit::emit_subject(infs);
	Properties::OfValues::check_allowable(K);
}

@ We use the hierarchy of inference subjects to represent the hierarchy of
kinds:

@d HIERARCHY_GET_SUPER_KINDS_CALLBACK Kinds::Knowledge::super
@d HIERARCHY_ALLOWS_SOMETIMES_MATCH_KINDS_CALLBACK Kinds::Knowledge::allow_sometimes
@d HIERARCHY_MOVE_KINDS_CALLBACK Kinds::Knowledge::move_within

=
kind *Kinds::Knowledge::super(kind *K) {
	inference_subject *infs = Kinds::Knowledge::as_subject(K);
	return InferenceSubjects::as_kind(InferenceSubjects::narrowest_broader_subject(infs));
}

void Kinds::Knowledge::move_within(kind *sub, kind *super) {
	if (Kinds::Behaviour::is_object(super))
		InferenceSubjects::falls_within(
			Kinds::Knowledge::as_subject(sub), Kinds::Knowledge::as_subject(super));
}

int Kinds::Knowledge::allow_sometimes(kind *from) {
	while (from) {
		if (Kinds::eq(from, K_object)) return TRUE;
		from = Latticework::super(from);
	}
	return FALSE;
}

@h Problems with kinds.

@d PROBLEM_KINDS_CALLBACK Kinds::Knowledge::kinds_problem_handler

=
void Kinds::Knowledge::kinds_problem_handler(int err_no, parse_node *pn, text_stream *E,
	kind *K1, kind *K2) {
	switch (err_no) {
		case DimensionRedundant_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_DimensionRedundant),
				"multiplication rules can only be given once",
				"and this combination is already established.");
			break;
		case DimensionNotBaseKOV_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_DimensionNotBaseKOV),
				"multiplication rules can only involve simple kinds of value",
				"rather than complicated ones such as lists of other values.");
			break;
		case NonDimensional_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_NonDimensional),
				"multiplication rules can only be given between kinds of "
				"value which are known to be numerical",
				"and not all of these are. Saying something like 'Pressure is a "
				"kind of value.' is not enough - you may think 'pressure' ought "
				"to be numerical, but Inform doesn't know that yet. You need "
				"to add something like '100 Pa specifies a pressure.' before "
				"Inform will realise.");
			break;
		case UnitSequenceOverflow_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_UnitSequenceOverflow),
				"reading that sentence led me into calculating such a complicated "
				"kind of value that I ran out of memory",
				"which my programmer really didn't expect to happen. I think you "
				"must have made an awful lot of numerical kinds of value, and "
				"then specified how they multiply so that one of them became "
				"weirdly tricky. Can you simplify?");
			break;
		case DimensionsInconsistent_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_DimensionsInconsistent),
				"this is inconsistent with what is already known about those kinds of value",
				"all three of which already have well-established relationships - see the "
				"Kinds index for more.");
			break;
		case KindUnalterable_KINDERROR:
			Problems::quote_source(1, current_sentence);
			Problems::quote_source(2, pn);
			Problems::quote_kind(3, K1);
			Problems::quote_kind(4, K2);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_KindUnalterable));
			Problems::issue_problem_segment(
				"You wrote %1, but that seems to contradict %2, as %3 and %4 "
				"are incompatible. (If %3 were a kind of %4 or vice versa "
				"there'd be no problem, but they aren't.)");
			Problems::issue_problem_end();
			break;
		case KindsCircular_KINDERROR:
			Problems::quote_source(1, current_sentence);
			Problems::quote_source(2, pn);
			Problems::quote_kind(3, K1);
			Problems::quote_kind(4, K2);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_KindsCircular));
			Problems::issue_problem_segment(
				"You wrote %1, but that seems to contradict %2, as it would "
				"make a circularity with %3 and %4 each being kinds of the "
				"other.");
			Problems::issue_problem_end();
			break;
		case LPCantScaleYet_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_LPCantScaleYet),
				"this tries to scale up or down a value which so far has no point of "
				"reference to scale from",
				"which is impossible.");
			break;
		case LPCantScaleTwice_KINDERROR:
			StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_LPCantScaleTwice),
				"this tries to specify the scaling for a kind of value whose "
				"scaling is already established",
				"which is impossible.");
			break;
		case NeptuneError_KINDERROR:
			Problems::quote_stream(1, E);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(Untestable));
			Problems::issue_problem_segment(
				"One of the so-called Neptune files used to configure the kinds of value "
				"built into Inform contained an error. Either there is something wrong with "
				"this installation of Inform, or new Neptune files are being tried out but "
				"do not yet work. Specifically: '%1'.");
			Problems::issue_problem_end();
			break;
		default: internal_error("unimplemented problem message");
	}
}