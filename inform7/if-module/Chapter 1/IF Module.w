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
@e door_dir_notice_CLASS
@e door_to_notice_CLASS
@e EPS_map_level_CLASS
@e grammar_line_CLASS
@e grammar_verb_CLASS
@e loop_over_scope_CLASS
@e map_data_CLASS
@e named_action_pattern_CLASS
@e noun_filter_token_CLASS
@e parse_name_notice_CLASS
@e parsing_data_CLASS
@e parsing_pp_data_CLASS
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
DECLARE_CLASS(door_dir_notice)
DECLARE_CLASS(door_to_notice)
DECLARE_CLASS(EPS_map_level)
DECLARE_CLASS(grammar_line)
DECLARE_CLASS(grammar_verb)
DECLARE_CLASS(loop_over_scope)
DECLARE_CLASS(map_data)
DECLARE_CLASS(named_action_pattern)
DECLARE_CLASS(noun_filter_token)
DECLARE_CLASS(parse_name_notice)
DECLARE_CLASS(parsing_data)
DECLARE_CLASS(parsing_pp_data)
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

MAKE_ANNOTATION_FUNCTIONS(action_meaning, action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_action_name, action_name)
MAKE_ANNOTATION_FUNCTIONS(constant_action_pattern, action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_grammar_verb, grammar_verb)
MAKE_ANNOTATION_FUNCTIONS(constant_named_action_pattern, named_action_pattern)
MAKE_ANNOTATION_FUNCTIONS(constant_scene, scene)

@h The beginning.
(The client doesn't need to call the start and end routines, because the
foundation module does that automatically.)

=
COMPILE_WRITER(action_pattern *, PL::Actions::Patterns::log)
COMPILE_WRITER(grammar_verb *, PL::Parsing::Verbs::log)
COMPILE_WRITER(grammar_line *, PL::Parsing::Lines::log)
COMPILE_WRITER(action_name_list *, PL::Actions::Lists::log)
COMPILE_WRITER(action_name *, PL::Actions::log)

void IFModule::start(void) {
	@<Register this module's memory allocation reasons@>;
	@<Register this module's stream writers@>;
	@<Register this module's debugging log aspects@>;
	@<Register this module's debugging log writers@>;
	PL::SpatialRelations::start();
	PL::MapDirections::start();
}
void IFModule::end(void) {
}

@<Register this module's memory allocation reasons@> =
	;

@<Register this module's stream writers@> =
	;

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
	REGISTER_WRITER('L', PL::Actions::Lists::log);
	REGISTER_WRITER('l', PL::Actions::log);

@ This module uses |syntax|, and adds the following annotations to the
syntax tree.

= (early code)
DECLARE_ANNOTATION_FUNCTIONS(action_meaning, action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_action_name, action_name)
DECLARE_ANNOTATION_FUNCTIONS(constant_action_pattern, action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_grammar_verb, grammar_verb)
DECLARE_ANNOTATION_FUNCTIONS(constant_named_action_pattern, named_action_pattern)
DECLARE_ANNOTATION_FUNCTIONS(constant_scene, scene)

@ =
void IFModule::declare_annotations(void) {
	Annotations::declare_type(constant_action_name_ANNOT, NULL);
	Annotations::declare_type(constant_action_pattern_ANNOT, NULL);
	Annotations::declare_type(constant_grammar_verb_ANNOT, NULL);
	Annotations::declare_type(constant_named_action_pattern_ANNOT, NULL);
	Annotations::declare_type(constant_scene_ANNOT, NULL);
}

