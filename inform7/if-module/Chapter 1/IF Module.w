[IFModule::] IF Module.

Setting up the use of this module.

@ This section simoly sets up the module in ways expected by //foundation//, and
contains no code of interest. The following constant exists only in tools
which use this module:

@d IF_MODULE TRUE

@ This module defines the following classes:

@e action_name_CLASS
@e auxiliary_file_CLASS
@e backdrop_found_in_notice_CLASS
@e cached_understanding_CLASS
@e command_index_entry_CLASS
@e connected_submap_CLASS
@e direction_inference_data_CLASS
@e door_dir_notice_CLASS
@e door_to_notice_CLASS
@e EPS_map_level_CLASS
@e found_in_inference_data_CLASS
@e grammar_line_CLASS
@e grammar_verb_CLASS
@e loop_over_scope_CLASS
@e map_data_CLASS
@e named_action_pattern_CLASS
@e noun_filter_token_CLASS
@e parentage_here_inference_data_CLASS
@e parentage_inference_data_CLASS
@e parse_name_notice_CLASS
@e parsing_data_CLASS
@e parsing_pp_data_CLASS
@e part_of_inference_data_CLASS
@e regions_data_CLASS
@e reserved_command_verb_CLASS
@e rubric_holder_CLASS
@e scene_CLASS
@e short_name_notice_CLASS
@e slash_gpr_CLASS
@e spatial_data_CLASS

@e action_name_list_CLASS
@e action_pattern_CLASS
@e ap_optional_clause_CLASS
@e scene_connector_CLASS
@e understanding_item_CLASS
@e understanding_reference_CLASS

=
DECLARE_CLASS(action_name)
DECLARE_CLASS(auxiliary_file)
DECLARE_CLASS(backdrop_found_in_notice)
DECLARE_CLASS(cached_understanding)
DECLARE_CLASS(command_index_entry)
DECLARE_CLASS(connected_submap)
DECLARE_CLASS(direction_inference_data)
DECLARE_CLASS(door_dir_notice)
DECLARE_CLASS(door_to_notice)
DECLARE_CLASS(EPS_map_level)
DECLARE_CLASS(found_in_inference_data)
DECLARE_CLASS(grammar_line)
DECLARE_CLASS(grammar_verb)
DECLARE_CLASS(loop_over_scope)
DECLARE_CLASS(map_data)
DECLARE_CLASS(named_action_pattern)
DECLARE_CLASS(noun_filter_token)
DECLARE_CLASS(parentage_here_inference_data)
DECLARE_CLASS(parentage_inference_data)
DECLARE_CLASS(parse_name_notice)
DECLARE_CLASS(parsing_data)
DECLARE_CLASS(parsing_pp_data)
DECLARE_CLASS(part_of_inference_data)
DECLARE_CLASS(regions_data)
DECLARE_CLASS(reserved_command_verb)
DECLARE_CLASS(rubric_holder)
DECLARE_CLASS(scene)
DECLARE_CLASS(short_name_notice)
DECLARE_CLASS(slash_gpr)
DECLARE_CLASS(spatial_data)

DECLARE_CLASS_ALLOCATED_IN_ARRAYS(action_name_list, 1000)
DECLARE_CLASS_ALLOCATED_IN_ARRAYS(action_pattern, 100)
DECLARE_CLASS_ALLOCATED_IN_ARRAYS(ap_optional_clause, 400)
DECLARE_CLASS_ALLOCATED_IN_ARRAYS(scene_connector, 1000)
DECLARE_CLASS_ALLOCATED_IN_ARRAYS(understanding_item, 100)
DECLARE_CLASS_ALLOCATED_IN_ARRAYS(understanding_reference, 100)

@h The beginning.
(The client doesn't need to call the start and end routines, because the
foundation module does that automatically.)

=
COMPILE_WRITER(action_pattern *, PL::Actions::Patterns::log)
COMPILE_WRITER(grammar_verb *, PL::Parsing::Verbs::log)
COMPILE_WRITER(grammar_line *, PL::Parsing::Lines::log)
COMPILE_WRITER(action_name_list *, PL::Actions::ConstantLists::log)
COMPILE_WRITER(action_name *, PL::Actions::log)

void IFModule::start(void) {
	@<Register this module's debugging log aspects@>;
	@<Register this module's debugging log writers@>;
	WherePredicates::start();
	PL::SpatialRelations::start();
	PL::MapDirections::start();
}
void IFModule::end(void) {
}

@

@e ACTION_CREATIONS_DA
@e ACTION_PATTERN_COMPILATION_DA
@e ACTION_PATTERN_PARSING_DA
@e GRAMMAR_DA
@e GRAMMAR_CONSTRUCTION_DA
@e OBJECT_TREE_DA
@e SPATIAL_MAP_DA
@e SPATIAL_MAP_WORKINGS_DA

@<Register this module's debugging log aspects@> =
	Log::declare_aspect(ACTION_CREATIONS_DA, L"action creations", FALSE, FALSE);
	Log::declare_aspect(ACTION_PATTERN_COMPILATION_DA, L"action pattern compilation", FALSE, FALSE);
	Log::declare_aspect(ACTION_PATTERN_PARSING_DA, L"action pattern parsing", FALSE, FALSE);
	Log::declare_aspect(GRAMMAR_DA, L"grammar", FALSE, FALSE);
	Log::declare_aspect(GRAMMAR_CONSTRUCTION_DA, L"grammar construction", FALSE, FALSE);
	Log::declare_aspect(OBJECT_TREE_DA, L"object tree", FALSE, FALSE);
	Log::declare_aspect(SPATIAL_MAP_DA, L"spatial map", FALSE, FALSE);
	Log::declare_aspect(SPATIAL_MAP_WORKINGS_DA, L"spatial map workings", FALSE, FALSE);

@<Register this module's debugging log writers@> =
	REGISTER_WRITER('A', PL::Actions::Patterns::log);
	REGISTER_WRITER('G', PL::Parsing::Verbs::log);
	REGISTER_WRITER('g', PL::Parsing::Lines::log);
	REGISTER_WRITER('L', PL::Actions::ConstantLists::log);
	REGISTER_WRITER('l', PL::Actions::log);

@ This module uses |syntax|, and adds two node types to the syntax tree:

@e ACTION_NT  /* "taking something closed" */
@e TOKEN_NT   /* used for tokens in grammar */

=
void IFModule::create_node_types(void) {
	NodeType::new(ACTION_NT, I"ACTION_NT", 0, INFTY, L3_NCAT, ASSERT_NFLAG);
	NodeType::new(TOKEN_NT, I"TOKEN_NT",   0, INFTY, L3_NCAT, 0);
}

@ And these annotations to the syntax tree:

@e action_meaning_ANNOT /* |action_pattern|: meaning in parse tree when used as noun */
@e constant_action_name_ANNOT /* |action_name|: for constant values */
@e constant_action_pattern_ANNOT /* |action_pattern|: for constant values */
@e constant_grammar_verb_ANNOT /* |grammar_verb|: for constant values */
@e constant_named_action_pattern_ANNOT /* |named_action_pattern|: for constant values */
@e constant_scene_ANNOT /* |scene|: for constant values */
@e grammar_token_literal_ANNOT /* int: for grammar tokens which are literal words */
@e grammar_token_relation_ANNOT /* |binary_predicate|: for relation tokens */
@e grammar_value_ANNOT /* |parse_node|: used as a marker when evaluating Understand grammar */
@e slash_class_ANNOT /* int: used when partitioning grammar tokens */
@e slash_dash_dash_ANNOT /* |int|: used when partitioning grammar tokens */

= (early code)
DECLARE_ANNOTATION_FUNCTIONS(action_meaning, action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_action_name, action_name)
DECLARE_ANNOTATION_FUNCTIONS(constant_action_pattern, action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_grammar_verb, grammar_verb)
DECLARE_ANNOTATION_FUNCTIONS(constant_named_action_pattern, named_action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_scene, scene)

@ =
MAKE_ANNOTATION_FUNCTIONS(action_meaning, action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_action_name, action_name)
MAKE_ANNOTATION_FUNCTIONS(constant_action_pattern, action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_grammar_verb, grammar_verb)
MAKE_ANNOTATION_FUNCTIONS(constant_named_action_pattern, named_action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_scene, scene)

@ =
void IFModule::declare_annotations(void) {
	Annotations::declare_type(action_meaning_ANNOT, IFModule::write_action_meaning_ANNOT);
	Annotations::declare_type(constant_action_name_ANNOT, IFModule::write_constant_action_name_ANNOT);
	Annotations::declare_type(constant_action_pattern_ANNOT, IFModule::write_constant_action_pattern_ANNOT);
	Annotations::declare_type(constant_grammar_verb_ANNOT, IFModule::write_constant_grammar_verb_ANNOT);
	Annotations::declare_type(constant_named_action_pattern_ANNOT, IFModule::write_constant_named_action_pattern_ANNOT);
	Annotations::declare_type(constant_scene_ANNOT, IFModule::write_constant_scene_ANNOT);
	Annotations::declare_type(grammar_token_literal_ANNOT, IFModule::write_grammar_token_literal_ANNOT);
	Annotations::declare_type(grammar_token_relation_ANNOT, IFModule::write_grammar_token_relation_ANNOT);
	Annotations::declare_type(grammar_value_ANNOT, IFModule::write_grammar_value_ANNOT);
	Annotations::declare_type(slash_class_ANNOT, IFModule::write_slash_class_ANNOT);
	Annotations::declare_type(slash_dash_dash_ANNOT, IFModule::write_slash_dash_dash_ANNOT);
}
void IFModule::write_action_meaning_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_action_meaning(p)) {
		WRITE(" {action meaning: ");
		PL::Actions::Patterns::write(OUT, Node::get_action_meaning(p));
		WRITE("}");
	} 
}
void IFModule::write_constant_action_name_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_action_name(p))
		WRITE(" {action name: %W}", Node::get_constant_action_name(p)->present_name);
}
void IFModule::write_constant_action_pattern_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_action_pattern(p)) {
		WRITE(" {action pattern: ");
		PL::Actions::Patterns::write(OUT, Node::get_constant_action_pattern(p));
		WRITE("}");
	} 
}
void IFModule::write_constant_grammar_verb_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_grammar_verb(p))
		WRITE(" {grammar verb: GV%d}", Node::get_constant_grammar_verb(p)->allocation_id);
}
void IFModule::write_constant_named_action_pattern_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_named_action_pattern(p)) {
		WRITE(" {named action pattern: ");
		Nouns::write(OUT, Node::get_constant_named_action_pattern(p)->name);
		WRITE("}");
	} 
}
void IFModule::write_constant_scene_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_scene(p))
		WRITE(" {scene: %I}", Node::get_constant_scene(p)->as_instance);
}
void IFModule::write_grammar_token_literal_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE(" {grammar token literal: %d}",
		Annotations::read_int(p, grammar_token_literal_ANNOT));
}
void IFModule::write_grammar_token_relation_ANNOT(text_stream *OUT, parse_node *p) {
	binary_predicate *bp = Node::get_grammar_token_relation(p);
	if (bp) WRITE(" {grammar token relation: %S}", bp->debugging_log_name);
}
void IFModule::write_grammar_value_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE(" {grammar value: $P}", Node::get_grammar_value(p));
}
void IFModule::write_slash_class_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, slash_class_ANNOT) > 0)
		WRITE(" {slash: %d}", Annotations::read_int(p, slash_class_ANNOT));
}
void IFModule::write_slash_dash_dash_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, slash_dash_dash_ANNOT) > 0)
		WRITE(" {slash-dash-dash: %d}", Annotations::read_int(p, slash_dash_dash_ANNOT));
}

void IFModule::grant_annotation_permissions(void) {
	Annotations::allow(ACTION_NT, action_meaning_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, action_meaning_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_action_name_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_action_pattern_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_grammar_verb_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_named_action_pattern_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_scene_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_token_literal_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_token_relation_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_value_ANNOT);
	Annotations::allow(TOKEN_NT, slash_class_ANNOT);
}
