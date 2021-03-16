[ParsingPlugin::] Parsing Plugin.

A plugin for command-parser support.

@ Inform provides extensive support for a command parser at runtime, and all of
that support is contained in the "parsing" plugin, which occupies this entire
chapter.

=
void ParsingPlugin::start(void) {
	ParsingNodes::nodes_and_annotations();

	PluginManager::plug(PRODUCTION_LINE_PLUG, ParsingPlugin::production_line);
	PluginManager::plug(MAKE_SPECIAL_MEANINGS_PLUG, Understand::make_special_meanings);
	PluginManager::plug(COMPARE_CONSTANT_PLUG, ParsingPlugin::compare_CONSTANT);
	PluginManager::plug(NEW_VARIABLE_NOTIFY_PLUG, ParsingPlugin::new_variable_notify);
	PluginManager::plug(NEW_SUBJECT_NOTIFY_PLUG, ParsingPlugin::new_subject_notify);
	PluginManager::plug(NEW_PERMISSION_NOTIFY_PLUG, Visibility::new_permission_notify);
	PluginManager::plug(COMPLETE_MODEL_PLUG, ParsingPlugin::complete_model);
}

@ This will also need extensive amounts of run-time code, and the sequence
for generating that is a little delicate.

=
int ParsingPlugin::production_line(int stage, int debugging,
	stopwatch_timer *sequence_timer) {
	if (stage == TABLES_CSEQ) {
		BENCH(Understand::traverse);
	}
	if (stage == INTER2_CSEQ) {
		BENCH(UnderstandGeneralTokens::write_parse_name_routines);
		BENCH(UnderstandLines::MistakeActionSub_routine);
		BENCH(CommandGrammars::prepare);
		BENCH(RTCommandGrammars::compile_conditions);
		BENCH(UnderstandValueTokens::number);
		BENCH(UnderstandValueTokens::truth_state);
		BENCH(UnderstandValueTokens::time);
		BENCH(UnderstandValueTokens::compile_type_gprs);
		if (debugging) {
			BENCH(TestCommand::write_text);
			BENCH(TestCommand::TestScriptSub_routine);
		} else {
			BENCH(TestCommand::TestScriptSub_stub_routine);
		}
	}
	if (stage == INTER3_CSEQ) {
		BENCH(UnderstandFilterTokens::compile);
	}
	if (stage == INTER4_CSEQ) {
		BENCH(RTCommandGrammars::compile_all);
		BENCH(UnderstandFilterTokens::compile);
	}
	return FALSE;
}

@ This plugin attaches a //parsing_data// object to every inference subject,
and in particular, to every object instance and every kind of object.

@d PARSING_DATA(I) PLUGIN_DATA_ON_INSTANCE(parsing, I)
@d PARSING_DATA_FOR_SUBJ(S) PLUGIN_DATA_ON_SUBJECT(parsing, S)

=
typedef struct parsing_data {
	struct command_grammar *understand_as_this_object; /* grammar for parsing the name at run-time */
	CLASS_DEFINITION
} parsing_data;

int ParsingPlugin::new_subject_notify(inference_subject *subj) {
	ATTACH_PLUGIN_DATA_TO_SUBJECT(parsing, subj, Visibility::new_data(subj));
	return FALSE;
}

@ We make use of a new kind of rvalue in this plugin: |K_understanding|. This
is created in //kinds: Familiar Kinds//, not here, but we do have to provide
the following functions to handle its constant rvalues. These correspond to
//command_grammar// objects, so comparing them, and producing rvalues, is easy:

=
int ParsingPlugin::compare_CONSTANT(parse_node *spec1, parse_node *spec2, int *rv) {
	kind *K = Node::get_kind_of_value(spec1);
	if (Kinds::eq(K, K_understanding)) {
		if (ParsingPlugin::rvalue_to_command_grammar(spec1) == ParsingPlugin::rvalue_to_command_grammar(spec2)) {
			*rv = TRUE;
		}
		*rv = FALSE;
		return TRUE;
	}
	return FALSE;
}

parse_node *ParsingPlugin::rvalue_from_command_grammar(command_grammar *val) { 
		CONV_FROM(command_grammar, K_understanding) }
command_grammar *ParsingPlugin::rvalue_to_command_grammar(parse_node *spec) { 
		CONV_TO(command_grammar) }

@ A number of global variables are given special treatment by this plugin,
including a whole family with names like "the K understood", for different
kinds K.[1]

[1] This is an awkward contrivance to bridge Inform 7, which is typed, with
the Inter command parser at runtime, whose data is typeless.

=
<notable-parsing-variables> ::=
	<k-kind> understood |  ==> { 0, RP[1] }
	noun |                 ==> { 1, - }
	location |             ==> { 2, - }
	actor-location |       ==> { 3, - }
	second noun |          ==> { 4, - }
	person asked           ==> { 5, - }

@

= (early code)
nonlocal_variable *real_location_VAR = NULL;
nonlocal_variable *actor_location_VAR = NULL;

nonlocal_variable *Inter_noun_VAR = NULL;
nonlocal_variable *Inter_second_noun_VAR = NULL;
nonlocal_variable *Inter_actor_VAR = NULL;

@ =
int ParsingPlugin::new_variable_notify(nonlocal_variable *var) {
	if (<notable-parsing-variables>(var->name)) {
		switch (<<r>>) {
			case 0:
				if (Kinds::eq(<<rp>>, NonlocalVariables::kind(var))) {
					RTParsing::understood_variable(var);
					NonlocalVariables::allow_to_be_zero(var);
				}
				break;
			case 1: Inter_noun_VAR = var; break;
			case 2: real_location_VAR = var; break;
			case 3: actor_location_VAR = var; break;
			case 4: Inter_second_noun_VAR = var; break;
			case 5: Inter_actor_VAR = var; break;
		}
	}
	return FALSE;
}

@ The Inter-level property |name| provides words by which to recognise an
object in the command parser. It doesn't correspond to any I7-level property,
and is in that sense (okay, ironically) "nameless".

=
property *P_name = NULL;

property *ParsingPlugin::name_property(void) {
	if (P_name == NULL) {
		P_name = ValueProperties::new_nameless(I"name", K_text);
		Hierarchy::make_available(Emit::tree(), RTParsing::name_iname());
	}
	return P_name;
}

@ At model completion time, we need to give every object instance the |name|
property and also any |parse_name| routine it may need; and we similarly
define |parse_name| routines for kinds of objects. Note that kinds never
get the |name| property.

=
int ParsingPlugin::complete_model(int stage) {
	if (stage == WORLD_STAGE_V) {
		instance *I;
		P_parse_name = ValueProperties::new_nameless(I"parse_name", K_value);

		LOOP_OVER_INSTANCES(I, K_object) {
			inference_subject *subj = Instances::as_subject(I);
			@<Assert the Inter name property@>;
			@<Assert the Inter parse-name property@>;
		}

		kind *K;
		LOOP_OVER_BASE_KINDS(K)
			if (Kinds::Behaviour::is_subkind_of_object(K)) {
				inference_subject *subj = KindSubjects::from_kind(K);
				@<Assert the Inter parse-name property@>;
			}
	}
	return FALSE;
}

@ Values for the |name| property are actually small arrays of dictionary words.

@<Assert the Inter name property@> =
	if (Naming::object_is_privately_named(I) == FALSE) {
		int from_kind = FALSE;
		kind *K = Instances::to_kind(I);
		wording W = Instances::get_name_in_play(I, FALSE);
		if (Wordings::empty(W))
			W = Kinds::Behaviour::get_name_in_play(K, FALSE,
				Projects::get_language_of_play(Task::project()));
		wording PW = Instances::get_name_in_play(I, TRUE);
		if (Wordings::empty(PW)) {
			from_kind = TRUE;
			PW = Kinds::Behaviour::get_name_in_play(K, TRUE,
				Projects::get_language_of_play(Task::project()));
		}
		ValueProperties::assert(ParsingPlugin::name_property(), Instances::as_subject(I),
			RTParsing::name_property_array(I, W, PW, from_kind), CERTAIN_CE);
	}

@ We attach numbered parse name routines as properties for any object
where grammar has specified a need. (By default, this will not happen.)

@<Assert the Inter parse-name property@> =
	inter_name *S = UnderstandGeneralTokens::compile_parse_name_property(subj);
	if (S)
		ValueProperties::assert(P_parse_name, subj,
			Rvalues::from_iname(S), CERTAIN_CE);
