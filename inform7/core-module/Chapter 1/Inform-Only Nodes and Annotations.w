[ParseTreeUsage::] Inform-Only Nodes and Annotations.

Itemising the baubles on a Christmas tree.

@ 

@e action_meaning_ANNOT /* |action_pattern|: meaning in parse tree when used as noun */
@e predicate_ANNOT /* |unary_predicate|: which adjective is asserted */
@e category_of_I6_translation_ANNOT /* int: what sort of "translates into I6" sentence this is */
@e classified_ANNOT /* |int|: this sentence has been classified */
@e clears_pronouns_ANNOT /* |int|: this sentence erases the current value of "it" */
@e colon_block_command_ANNOT /* int: this COMMAND uses the ":" not begin/end syntax */
@e condition_tense_ANNOT /* |time_period|: for specification nodes */
@e constant_action_name_ANNOT /* |action_name|: for constant values */
@e constant_action_pattern_ANNOT /* |action_pattern|: for constant values */
@e constant_activity_ANNOT /* |activity|: for constant values */
@e constant_binary_predicate_ANNOT /* |binary_predicate|: for constant values */
@e constant_constant_phrase_ANNOT /* |constant_phrase|: for constant values */
@e constant_enumeration_ANNOT /* |int|: which one from an enumerated kind */
@e constant_equation_ANNOT /* |equation|: for constant values */
@e constant_grammar_verb_ANNOT /* |grammar_verb|: for constant values */
@e constant_instance_ANNOT /* |instance|: for constant values */
@e constant_local_variable_ANNOT /* |local_variable|: for constant values */
@e constant_named_action_pattern_ANNOT /* |named_action_pattern|: for constant values */
@e constant_named_rulebook_outcome_ANNOT /* |named_rulebook_outcome|: for constant values */
@e constant_nonlocal_variable_ANNOT /* |nonlocal_variable|: for constant values */
@e constant_number_ANNOT /* |int|: which integer this is */
@e constant_property_ANNOT /* |property|: for constant values */
@e constant_rule_ANNOT /* |rule|: for constant values */
@e constant_rulebook_ANNOT /* |rulebook|: for constant values */
@e constant_scene_ANNOT /* |scene|: for constant values */
@e constant_table_ANNOT /* |table|: for constant values */
@e constant_table_column_ANNOT /* |table_column|: for constant values */
@e constant_text_ANNOT /* |text_stream|: for constant values */
@e constant_use_option_ANNOT /* |use_option|: for constant values */
@e constant_verb_form_ANNOT /* |verb_form|: for constant values */
@e control_structure_used_ANNOT /* |control_structure_phrase|: for CODE BLOCK nodes only */
@e converted_SN_ANNOT /* |int|: marking descriptions */
@e creation_proposition_ANNOT /* |pcalc_prop|: proposition which newly created value satisfies */
@e creation_site_ANNOT /* |int|: whether an instance was created from this node */
@e defn_language_ANNOT /* |inform_language|: what language this definition is in */
@e end_control_structure_used_ANNOT /* |control_structure_phrase|: for CODE BLOCK nodes only */
@e epistemological_status_ANNOT /* |int|: a bitmap of results from checking an ambiguous reading */
@e evaluation_ANNOT /* |parse_node|: result of evaluating the text */
@e explicit_iname_ANNOT /* |inter_name|: is this value explicitly an iname? */
@e explicit_literal_ANNOT /* |int|: my value is an explicit integer or text */
@e explicit_vh_ANNOT /* |value_holster|: used for compiling I6-level properties */
@e from_text_substitution_ANNOT /* |int|: whether this is an implicit say invocation */
@e explicit_gender_marker_ANNOT  /* |int|: used by PROPER NOUN nodes for evident genders */
@e grammar_token_code_ANNOT /* int: used to identify grammar tokens */
@e grammar_token_literal_ANNOT /* int: for grammar tokens which are literal words */
@e grammar_token_relation_ANNOT /* |binary_predicate|: for relation tokens */
@e grammar_value_ANNOT /* |parse_node|: used as a marker when evaluating Understand grammar */
@e implicit_in_creation_of_ANNOT /* |inference_subject|: for assemblies */
@e implicitness_count_ANNOT /* int: keeping track of recursive assemblies */
@e indentation_level_ANNOT /* |int|: for routines written with Pythonesque indentation */
@e interpretation_of_subject_ANNOT /* |inference_subject|: subject, during passes */
@e is_phrase_option_ANNOT /* |int|: this unparsed text is a phrase option */
@e kind_of_new_variable_ANNOT /* |kind|: what if anything is returned */
@e kind_of_value_ANNOT /* |kind|: for specification nodes */
@e kind_required_by_context_ANNOT /* |kind|: what if anything is expected here */
@e kind_resulting_ANNOT /* |kind|: what if anything is returned */
@e kind_variable_declarations_ANNOT /* |kind_variable_declaration|: and of these */
@e rule_placement_sense_ANNOT /* |int|: are we listing a rule into something, or out of it? */
@e lpe_options_ANNOT /* |int|: options set for a literal pattern part */
@e modal_verb_ANNOT /* |verb_conjugation|: relevant only for that: e.g., "might" */
@e multiplicity_ANNOT /* |int|: e.g., 5 for "five gold rings" */
@e new_relation_here_ANNOT /* |binary_predicate|: new relation as subject of "relates" sentence */
@e nothing_object_ANNOT /* |int|: this represents |nothing| at run-time */
@e nowhere_ANNOT /* |int|: used by the spatial plugin to show this represents "nowhere" */
@e phrase_invoked_ANNOT /* |phrase|: the phrase believed to be invoked... */
@e phrase_option_ANNOT /* |int|: $2^i$ where $i$ is the option number, $0\leq i<16$ */
@e phrase_options_invoked_ANNOT /* |invocation_options|: details of any options used */
@e property_name_used_as_noun_ANNOT /* |int|: in ambiguous cases such as "open" */
@e proposition_ANNOT /* |pcalc_prop|: for specification nodes */
@e quant_ANNOT /* |quantifier|: for quantified excerpts like "three baskets" */
@e quantification_parameter_ANNOT /* |int|: e.g., 3 for "three baskets" */
@e record_as_self_ANNOT /* |int|: record recipient as |self| when writing this */
@e refined_ANNOT /* |int|: this subtree has had its nouns parsed */
@e response_code_ANNOT /* |int|: for responses only */
@e results_from_splitting_ANNOT /* |int|: node in a routine's parse tree from comma block notation */
@e row_amendable_ANNOT /* int: a candidate row for a table amendment */
@e save_self_ANNOT /* |int|: this invocation must save and preserve |self| at run-time */
@e say_adjective_ANNOT /* |adjective|: ...or the adjective to be agreed with by "say" */
@e say_verb_ANNOT /* |verb_conjugation|: ...or the verb to be conjugated by "say" */
@e say_verb_negated_ANNOT /* relevant only for that */
@e self_object_ANNOT /* |int|: this represents |self| at run-time */
@e slash_class_ANNOT /* int: used when partitioning grammar tokens */
@e slash_dash_dash_ANNOT /* |int|: used when partitioning grammar tokens */
@e ssp_closing_segment_wn_ANNOT /* |int|: identifier for the last of these, or |-1| */
@e ssp_segment_count_ANNOT /* |int|: number of subsequent complex-say phrases in stream */
@e subject_ANNOT /* |inference_subject|: what this node describes */
@e suppress_newlines_ANNOT /* |int|: whether the next say term runs on */
@e table_cell_unspecified_ANNOT /* int: used to mark table entries as unset */
@e tense_marker_ANNOT /* |grammatical_usage|: for specification nodes */
@e text_unescaped_ANNOT /* |int|: flag used only for literal texts */
@e token_as_parsed_ANNOT /* |parse_node|: what if anything is returned */
@e token_check_to_do_ANNOT /* |parse_node|: what if anything is returned */
@e token_to_be_parsed_against_ANNOT /* |parse_node|: what if anything is returned */
@e turned_already_ANNOT /* |int|: aliasing like "player" to "yourself" performed already */
@e unit_ANNOT /* |compilation_unit|: set only for headings, routines and sentences */
@e unproven_ANNOT /* |int|: this invocation needs run-time typechecking */
@e verb_problem_issued_ANNOT /* |int|: has a problem message about the primary verb been issued already? */
@e you_can_ignore_ANNOT /* |int|: for assertions now drained of meaning */

= (early code)
DECLARE_ANNOTATION_FUNCTIONS(condition_tense, time_period)
DECLARE_ANNOTATION_FUNCTIONS(constant_activity, activity)
DECLARE_ANNOTATION_FUNCTIONS(constant_binary_predicate, binary_predicate)
DECLARE_ANNOTATION_FUNCTIONS(constant_constant_phrase, constant_phrase)
DECLARE_ANNOTATION_FUNCTIONS(constant_equation, equation)
DECLARE_ANNOTATION_FUNCTIONS(constant_instance, instance)
DECLARE_ANNOTATION_FUNCTIONS(constant_local_variable, local_variable)
DECLARE_ANNOTATION_FUNCTIONS(constant_named_rulebook_outcome, named_rulebook_outcome)
DECLARE_ANNOTATION_FUNCTIONS(constant_nonlocal_variable, nonlocal_variable)
DECLARE_ANNOTATION_FUNCTIONS(constant_property, property)
DECLARE_ANNOTATION_FUNCTIONS(constant_rule, rule)
DECLARE_ANNOTATION_FUNCTIONS(constant_rulebook, rulebook)
DECLARE_ANNOTATION_FUNCTIONS(constant_table_column, table_column)
DECLARE_ANNOTATION_FUNCTIONS(constant_table, table)
DECLARE_ANNOTATION_FUNCTIONS(constant_text, text_stream)
DECLARE_ANNOTATION_FUNCTIONS(constant_use_option, use_option)
DECLARE_ANNOTATION_FUNCTIONS(constant_verb_form, verb_form)
DECLARE_ANNOTATION_FUNCTIONS(control_structure_used, control_structure_phrase)
DECLARE_ANNOTATION_FUNCTIONS(creation_proposition, pcalc_prop)
DECLARE_ANNOTATION_FUNCTIONS(defn_language, inform_language)
DECLARE_ANNOTATION_FUNCTIONS(end_control_structure_used, control_structure_phrase)
DECLARE_ANNOTATION_FUNCTIONS(evaluation, parse_node)
DECLARE_ANNOTATION_FUNCTIONS(explicit_vh, value_holster)
DECLARE_ANNOTATION_FUNCTIONS(grammar_token_relation, binary_predicate)
DECLARE_ANNOTATION_FUNCTIONS(grammar_value, parse_node)
DECLARE_ANNOTATION_FUNCTIONS(implicit_in_creation_of, inference_subject)
DECLARE_ANNOTATION_FUNCTIONS(interpretation_of_subject, inference_subject)
DECLARE_ANNOTATION_FUNCTIONS(kind_of_new_variable, kind)
DECLARE_ANNOTATION_FUNCTIONS(kind_of_value, kind)
DECLARE_ANNOTATION_FUNCTIONS(kind_required_by_context, kind)
DECLARE_ANNOTATION_FUNCTIONS(kind_resulting, kind)
DECLARE_ANNOTATION_FUNCTIONS(kind_variable_declarations, kind_variable_declaration)
DECLARE_ANNOTATION_FUNCTIONS(explicit_iname, inter_name)
DECLARE_ANNOTATION_FUNCTIONS(modal_verb, verb_conjugation)
DECLARE_ANNOTATION_FUNCTIONS(new_relation_here, binary_predicate)
DECLARE_ANNOTATION_FUNCTIONS(phrase_invoked, phrase)
DECLARE_ANNOTATION_FUNCTIONS(phrase_options_invoked, invocation_options)
DECLARE_ANNOTATION_FUNCTIONS(predicate, unary_predicate)
DECLARE_ANNOTATION_FUNCTIONS(proposition, pcalc_prop)
DECLARE_ANNOTATION_FUNCTIONS(quant, quantifier)
DECLARE_ANNOTATION_FUNCTIONS(say_adjective, adjective)
DECLARE_ANNOTATION_FUNCTIONS(say_verb, verb_conjugation)
DECLARE_ANNOTATION_FUNCTIONS(subject, inference_subject)
DECLARE_ANNOTATION_FUNCTIONS(tense_marker, grammatical_usage)
DECLARE_ANNOTATION_FUNCTIONS(token_as_parsed, parse_node)
DECLARE_ANNOTATION_FUNCTIONS(token_check_to_do, parse_node)
DECLARE_ANNOTATION_FUNCTIONS(token_to_be_parsed_against, parse_node)
DECLARE_ANNOTATION_FUNCTIONS(unit, compilation_unit)

@ So we itemise the pointer-valued annotations below, and the macro expands
to provide their get and set functions:

=
MAKE_ANNOTATION_FUNCTIONS(condition_tense, time_period)
MAKE_ANNOTATION_FUNCTIONS(constant_activity, activity)
MAKE_ANNOTATION_FUNCTIONS(constant_binary_predicate, binary_predicate)
MAKE_ANNOTATION_FUNCTIONS(constant_constant_phrase, constant_phrase)
MAKE_ANNOTATION_FUNCTIONS(constant_equation, equation)
MAKE_ANNOTATION_FUNCTIONS(constant_instance, instance)
MAKE_ANNOTATION_FUNCTIONS(constant_local_variable, local_variable)
MAKE_ANNOTATION_FUNCTIONS(constant_named_rulebook_outcome, named_rulebook_outcome)
MAKE_ANNOTATION_FUNCTIONS(constant_nonlocal_variable, nonlocal_variable)
MAKE_ANNOTATION_FUNCTIONS(constant_property, property)
MAKE_ANNOTATION_FUNCTIONS(constant_rule, rule)
MAKE_ANNOTATION_FUNCTIONS(constant_rulebook, rulebook)
MAKE_ANNOTATION_FUNCTIONS(constant_table_column, table_column)
MAKE_ANNOTATION_FUNCTIONS(constant_table, table)
MAKE_ANNOTATION_FUNCTIONS(constant_text, text_stream)
MAKE_ANNOTATION_FUNCTIONS(constant_use_option, use_option)
MAKE_ANNOTATION_FUNCTIONS(constant_verb_form, verb_form)
MAKE_ANNOTATION_FUNCTIONS(control_structure_used, control_structure_phrase)
MAKE_ANNOTATION_FUNCTIONS(creation_proposition, pcalc_prop)
MAKE_ANNOTATION_FUNCTIONS(defn_language, inform_language)
MAKE_ANNOTATION_FUNCTIONS(end_control_structure_used, control_structure_phrase)
MAKE_ANNOTATION_FUNCTIONS(evaluation, parse_node)
MAKE_ANNOTATION_FUNCTIONS(explicit_vh, value_holster)
MAKE_ANNOTATION_FUNCTIONS(grammar_token_relation, binary_predicate)
MAKE_ANNOTATION_FUNCTIONS(grammar_value, parse_node)
MAKE_ANNOTATION_FUNCTIONS(implicit_in_creation_of, inference_subject)
MAKE_ANNOTATION_FUNCTIONS(interpretation_of_subject, inference_subject)
MAKE_ANNOTATION_FUNCTIONS(kind_of_new_variable, kind)
MAKE_ANNOTATION_FUNCTIONS(kind_of_value, kind)
MAKE_ANNOTATION_FUNCTIONS(kind_required_by_context, kind)
MAKE_ANNOTATION_FUNCTIONS(kind_resulting, kind)
MAKE_ANNOTATION_FUNCTIONS(kind_variable_declarations, kind_variable_declaration)
MAKE_ANNOTATION_FUNCTIONS(modal_verb, verb_conjugation)
MAKE_ANNOTATION_FUNCTIONS(new_relation_here, binary_predicate)
MAKE_ANNOTATION_FUNCTIONS(phrase_invoked, phrase)
MAKE_ANNOTATION_FUNCTIONS(phrase_options_invoked, invocation_options)
MAKE_ANNOTATION_FUNCTIONS(predicate, unary_predicate)
MAKE_ANNOTATION_FUNCTIONS(proposition, pcalc_prop)
MAKE_ANNOTATION_FUNCTIONS(quant, quantifier)
MAKE_ANNOTATION_FUNCTIONS(say_adjective, adjective)
MAKE_ANNOTATION_FUNCTIONS(say_verb, verb_conjugation)
MAKE_ANNOTATION_FUNCTIONS(subject, inference_subject)
MAKE_ANNOTATION_FUNCTIONS(tense_marker, grammatical_usage)
MAKE_ANNOTATION_FUNCTIONS(token_as_parsed, parse_node)
MAKE_ANNOTATION_FUNCTIONS(token_check_to_do, parse_node)
MAKE_ANNOTATION_FUNCTIONS(token_to_be_parsed_against, parse_node)

@ And we have declare all of those:

=
void ParseTreeUsage::declare_annotations(void) {
	Annotations::declare_type(action_meaning_ANNOT, NULL);
	Annotations::declare_type(predicate_ANNOT, NULL);
	Annotations::declare_type(category_of_I6_translation_ANNOT, NULL);
	Annotations::declare_type(classified_ANNOT, NULL);
	Annotations::declare_type(clears_pronouns_ANNOT, NULL);
	Annotations::declare_type(colon_block_command_ANNOT, NULL);
	Annotations::declare_type(condition_tense_ANNOT,
		ParseTreeUsage::write_condition_tense_ANNOT);
	Annotations::declare_type(constant_action_name_ANNOT, NULL);
	Annotations::declare_type(constant_action_pattern_ANNOT, NULL);
	Annotations::declare_type(constant_activity_ANNOT, NULL);
	Annotations::declare_type(constant_binary_predicate_ANNOT, NULL);
	Annotations::declare_type(constant_constant_phrase_ANNOT, NULL);
	Annotations::declare_type(constant_enumeration_ANNOT, NULL);
	Annotations::declare_type(constant_equation_ANNOT, NULL);
	Annotations::declare_type(constant_grammar_verb_ANNOT, NULL);
	Annotations::declare_type(constant_instance_ANNOT,
		ParseTreeUsage::write_constant_instance_ANNOT);
	Annotations::declare_type(constant_local_variable_ANNOT,
		ParseTreeUsage::write_constant_local_variable_ANNOT);
	Annotations::declare_type(constant_named_action_pattern_ANNOT, NULL);
	Annotations::declare_type(constant_named_rulebook_outcome_ANNOT, NULL);
	Annotations::declare_type(constant_nonlocal_variable_ANNOT,
		ParseTreeUsage::write_constant_nonlocal_variable_ANNOT);
	Annotations::declare_type(constant_number_ANNOT, NULL);
	Annotations::declare_type(constant_property_ANNOT, NULL);
	Annotations::declare_type(constant_rule_ANNOT, NULL);
	Annotations::declare_type(constant_rulebook_ANNOT, NULL);
	Annotations::declare_type(constant_scene_ANNOT, NULL);
	Annotations::declare_type(constant_table_ANNOT, NULL);
	Annotations::declare_type(constant_table_column_ANNOT, NULL);
	Annotations::declare_type(constant_text_ANNOT, NULL);
	Annotations::declare_type(constant_use_option_ANNOT, NULL);
	Annotations::declare_type(constant_verb_form_ANNOT, NULL);
	Annotations::declare_type(control_structure_used_ANNOT,
		ParseTreeUsage::write_control_structure_used_ANNOT);
	Annotations::declare_type(converted_SN_ANNOT, NULL);
	Annotations::declare_type(creation_proposition_ANNOT,
		ParseTreeUsage::write_creation_proposition_ANNOT);
	Annotations::declare_type(creation_site_ANNOT,
		ParseTreeUsage::write_creation_site_ANNOT);
	Annotations::declare_type(defn_language_ANNOT,
		ParseTreeUsage::write_defn_language_ANNOT);
	Annotations::declare_type(end_control_structure_used_ANNOT, NULL);
	Annotations::declare_type(epistemological_status_ANNOT, NULL);
	Annotations::declare_type(evaluation_ANNOT,
		ParseTreeUsage::write_evaluation_ANNOT);
	Annotations::declare_type(explicit_iname_ANNOT, NULL);
	Annotations::declare_type(explicit_literal_ANNOT, NULL);
	Annotations::declare_type(explicit_vh_ANNOT, NULL);
	Annotations::declare_type(from_text_substitution_ANNOT, NULL);
	Annotations::declare_type(explicit_gender_marker_ANNOT, NULL);
	Annotations::declare_type(grammar_token_code_ANNOT, NULL);
	Annotations::declare_type(grammar_token_literal_ANNOT, NULL);
	Annotations::declare_type(grammar_token_relation_ANNOT, NULL);
	Annotations::declare_type(grammar_value_ANNOT, NULL);
	Annotations::declare_type(implicit_in_creation_of_ANNOT, NULL);
	Annotations::declare_type(implicitness_count_ANNOT, NULL);
	Annotations::declare_type(indentation_level_ANNOT,
		ParseTreeUsage::write_indentation_level_ANNOT);
	Annotations::declare_type(interpretation_of_subject_ANNOT, NULL);
	Annotations::declare_type(is_phrase_option_ANNOT, NULL);
	Annotations::declare_type(kind_of_new_variable_ANNOT,
		ParseTreeUsage::write_kind_of_new_variable_ANNOT);
	Annotations::declare_type(kind_of_value_ANNOT,
		ParseTreeUsage::write_kind_of_value_ANNOT);
	Annotations::declare_type(kind_required_by_context_ANNOT,
		ParseTreeUsage::write_kind_required_by_context_ANNOT);
	Annotations::declare_type(kind_resulting_ANNOT, NULL);
	Annotations::declare_type(kind_variable_declarations_ANNOT, NULL);
	Annotations::declare_type(rule_placement_sense_ANNOT, NULL);
	Annotations::declare_type(lpe_options_ANNOT, NULL);
	Annotations::declare_type(modal_verb_ANNOT, NULL);
	Annotations::declare_type(multiplicity_ANNOT,
		ParseTreeUsage::write_multiplicity_ANNOT);
	Annotations::declare_type(new_relation_here_ANNOT, NULL);
	Annotations::declare_type(nothing_object_ANNOT,
		ParseTreeUsage::write_nothing_object_ANNOT);
	Annotations::declare_type(nowhere_ANNOT, NULL);
	Annotations::declare_type(phrase_invoked_ANNOT, NULL);
	Annotations::declare_type(phrase_option_ANNOT, NULL);
	Annotations::declare_type(phrase_options_invoked_ANNOT, NULL);
	Annotations::declare_type(property_name_used_as_noun_ANNOT, NULL);
	Annotations::declare_type(proposition_ANNOT,
		ParseTreeUsage::write_proposition_ANNOT);
	Annotations::declare_type(quant_ANNOT, NULL);
	Annotations::declare_type(quantification_parameter_ANNOT, NULL);
	Annotations::declare_type(record_as_self_ANNOT, NULL);
	Annotations::declare_type(refined_ANNOT, NULL);
	Annotations::declare_type(response_code_ANNOT, NULL);
	Annotations::declare_type(results_from_splitting_ANNOT, NULL);
	Annotations::declare_type(row_amendable_ANNOT, NULL);
	Annotations::declare_type(save_self_ANNOT, NULL);
	Annotations::declare_type(say_adjective_ANNOT, NULL);
	Annotations::declare_type(say_verb_ANNOT, NULL);
	Annotations::declare_type(say_verb_negated_ANNOT, NULL);
	Annotations::declare_type(self_object_ANNOT,
		ParseTreeUsage::write_self_object_ANNOT);
	Annotations::declare_type(slash_class_ANNOT,
		ParseTreeUsage::write_slash_class_ANNOT);
	Annotations::declare_type(slash_dash_dash_ANNOT,
		ParseTreeUsage::write_slash_dash_dash_ANNOT);
	Annotations::declare_type(ssp_closing_segment_wn_ANNOT, NULL);
	Annotations::declare_type(ssp_segment_count_ANNOT, NULL);
	Annotations::declare_type(subject_ANNOT, NULL);
	Annotations::declare_type(suppress_newlines_ANNOT, NULL);
	Annotations::declare_type(table_cell_unspecified_ANNOT, NULL);
	Annotations::declare_type(tense_marker_ANNOT, NULL);
	Annotations::declare_type(text_unescaped_ANNOT, NULL);
	Annotations::declare_type(token_as_parsed_ANNOT, NULL);
	Annotations::declare_type(token_check_to_do_ANNOT, NULL);
	Annotations::declare_type(token_to_be_parsed_against_ANNOT, NULL);
	Annotations::declare_type(turned_already_ANNOT, NULL);
	Annotations::declare_type(unit_ANNOT, NULL);
	Annotations::declare_type(unproven_ANNOT, NULL);
	Annotations::declare_type(verb_problem_issued_ANNOT, NULL);
	Annotations::declare_type(you_can_ignore_ANNOT, NULL);
}

@ =
void ParseTreeUsage::write_action_meaning_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_predicate_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_category_of_I6_translation_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_classified_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_clears_pronouns_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_colon_block_command_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_condition_tense_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_condition_tense(p)) {
		WRITE(" {condition tense: ");
		Occurrence::log(OUT, Node::get_condition_tense(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_constant_action_name_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_action_pattern_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_activity_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_binary_predicate_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_constant_phrase_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_enumeration_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_equation_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_grammar_verb_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_instance_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_constant_instance(p)) {
		WRITE(" {instance: ");
		Instances::write(OUT, Node::get_constant_instance(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_constant_local_variable_ANNOT(text_stream *OUT, parse_node *p) {
	local_variable *lvar = Node::get_constant_local_variable(p);
	if (lvar) {
		WRITE(" {local: ");
		LocalVariables::write(OUT, lvar);
		WRITE(" ");
		Kinds::Textual::write(OUT, LocalVariables::unproblematic_kind(lvar));
		WRITE("}");
	}
}
void ParseTreeUsage::write_constant_named_action_pattern_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_named_rulebook_outcome_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_nonlocal_variable_ANNOT(text_stream *OUT, parse_node *p) {
	nonlocal_variable *q = Node::get_constant_nonlocal_variable(p);
	if (q) {
		WRITE(" {nonlocal: ");
		NonlocalVariables::write(OUT, q);
		WRITE("}");
	}
}
void ParseTreeUsage::write_constant_number_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_property_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_rule_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_rulebook_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_scene_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_table_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_table_column_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_text_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_use_option_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_constant_verb_form_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_control_structure_used_ANNOT(text_stream *OUT, parse_node *p) {
	control_structure_phrase *csp = Node::get_control_structure_used(p);
	if (csp) {
		WRITE(" {"); ControlStructures::log(OUT, csp); WRITE("}");
	}
}
void ParseTreeUsage::write_converted_SN_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_creation_proposition_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_creation_proposition(p))
		WRITE(" {creation: $D}", Node::get_creation_proposition(p));
}
void ParseTreeUsage::write_creation_site_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, creation_site_ANNOT))
		WRITE(" {created here}");
}
void ParseTreeUsage::write_defn_language_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_defn_language(p))
		WRITE(" {language: %J}", Node::get_defn_language(p));
}
void ParseTreeUsage::write_end_control_structure_used_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_epistemological_status_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_evaluation_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_evaluation(p))
		WRITE(" {eval: $P}", Node::get_evaluation(p));
}
void ParseTreeUsage::write_explicit_iname_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_explicit_literal_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_explicit_vh_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_from_text_substitution_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_explicit_gender_marker_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_grammar_token_code_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_grammar_token_literal_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_grammar_token_relation_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_grammar_value_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_implicit_in_creation_of_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_implicitness_count_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_indentation_level_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, indentation_level_ANNOT) > 0)
		WRITE(" {indent: %d}", Annotations::read_int(p, indentation_level_ANNOT));
}
void ParseTreeUsage::write_interpretation_of_subject_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_is_phrase_option_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_kind_of_new_variable_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_kind_of_new_variable(p)) {
		WRITE(" {new var: ");
		Kinds::Textual::write(OUT, Node::get_kind_of_new_variable(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_kind_of_value_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_kind_of_value(p)) {
		WRITE(" {kind: ");
		Kinds::Textual::write(OUT, Node::get_kind_of_value(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_kind_required_by_context_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_kind_required_by_context(p)) {
		WRITE(" {required: ");
		Kinds::Textual::write(OUT, Node::get_kind_required_by_context(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_kind_resulting_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_kind_variable_declarations_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_rule_placement_sense_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_lpe_options_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_modal_verb_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_multiplicity_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, multiplicity_ANNOT))
		WRITE(" {multiplicity %d}", Annotations::read_int(p, multiplicity_ANNOT));
}
void ParseTreeUsage::write_new_relation_here_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_nothing_object_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, nothing_object_ANNOT)) LOG(" {nothing}");
}
void ParseTreeUsage::write_nowhere_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_phrase_invoked_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_phrase_option_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_phrase_options_invoked_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_property_name_used_as_noun_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_proposition_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_proposition(p)) {
		WRITE(" {proposition: ");
		Propositions::write(OUT, Node::get_proposition(p));
		WRITE("}");
	}
}
void ParseTreeUsage::write_quant_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_quantification_parameter_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_record_as_self_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_refined_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_response_code_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_results_from_splitting_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_row_amendable_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_save_self_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_say_adjective_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_say_verb_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_say_verb_negated_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_self_object_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, self_object_ANNOT)) LOG(" {self}");
}
void ParseTreeUsage::write_slash_class_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, slash_class_ANNOT) > 0)
		WRITE(" {slash: %d}", Annotations::read_int(p, slash_class_ANNOT));
}
void ParseTreeUsage::write_slash_dash_dash_ANNOT(text_stream *OUT, parse_node *p) {
	if (Annotations::read_int(p, slash_dash_dash_ANNOT) > 0)
		WRITE(" {slash-dash-dash: %d}", Annotations::read_int(p, slash_dash_dash_ANNOT));
}
void ParseTreeUsage::write_ssp_closing_segment_wn_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_ssp_segment_count_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_subject_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_subject(p))
		WRITE(" {refers: $j}", Node::get_subject(p));
}
void ParseTreeUsage::write_suppress_newlines_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_table_cell_unspecified_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_tense_marker_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_text_unescaped_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_token_as_parsed_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_token_check_to_do_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_token_to_be_parsed_against_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_turned_already_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_unit_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_unproven_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_verb_problem_issued_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}
void ParseTreeUsage::write_you_can_ignore_ANNOT(text_stream *OUT, parse_node *p) {
	WRITE("{}", Annotations::read_int(p, heading_level_ANNOT));
}

@

@d ANNOTATION_COPY_SYNTAX_CALLBACK ParseTreeUsage::copy_annotations

=
void ParseTreeUsage::copy_annotations(parse_node_annotation *to, parse_node_annotation *from) {
	if (from->annotation_id == proposition_ANNOT)
		to->annotation_pointer =
			STORE_POINTER_pcalc_prop(
				Propositions::copy(
					RETRIEVE_POINTER_pcalc_prop(
						from->annotation_pointer)));
}

@

@e ALLOWED_NT           			/* "An animal is allowed to have a description" */
@e EVERY_NT             			/* "every container" */
@e ACTION_NT            			/* "taking something closed" */
@e ADJECTIVE_NT         			/* "open" */
@e PROPERTYCALLED_NT    			/* "A man has a number called age" */
@e CREATED_NT           			/* "a vehicle called Sarah Jane's car" */

@e TOKEN_NT             			/* Used for tokens in grammar */

@e CODE_BLOCK_NT       			/* Holds a block of source material */
@e INVOCATION_LIST_SAY_NT		/* Single thing to be said */
@e INVOCATION_NT      			/* Usage of a phrase */
@e VOID_CONTEXT_NT  				/* When a void phrase is required */
@e RVALUE_CONTEXT_NT  			/* Arguments, in effect */
@e LVALUE_CONTEXT_NT 			/* Named storage location */
@e LVALUE_TR_CONTEXT_NT 			/* Table reference */
@e SPECIFIC_RVALUE_CONTEXT_NT 	/* Argument must be an exact value */
@e MATCHING_RVALUE_CONTEXT_NT 	/* Argument must match a description */
@e NEW_LOCAL_CONTEXT_NT			/* Argument which creates a local */
@e LVALUE_LOCAL_CONTEXT_NT		/* Argument which names a local */
@e CONDITION_CONTEXT_NT          /* Used for "now" conditions */

@ The next specification nodes are the rvalues. These express I6 values --
numbers, objects, text and so on -- but cannot be assigned to, so that in an
assignment of the form "change L to R" they can be used only as R, not L. This
is not the same thing as a constant: for instance, "location of the player"
evaluates differently at different times, but cannot be changed in an
assignment.

@e CONSTANT_NT					/* "7", "the can't lock a locked door rule", etc. */
@e PHRASE_TO_DECIDE_VALUE_NT		/* "holder of the black box" */

@ Lvalue nodes represent stored I6 data at run-time, which means that they can
be assigned to. (The traditional terms "lvalue" and "rvalue" refer to the left
and right hand side of assignment statements written |A = B|.) For instance, a
table entry qualifies as an lvalue because it can be both read and changed. To
qualify as an lvalue, text must exactly specify the storage location referred
to: "Table of Corvettes" only indicates a table, not an entry in a table, so
is merely an rvalue. Similarly, "carrying capacity" (as a property name not
indicating an owner) is a mere rvalue.

@e LOCAL_VARIABLE_NT				/* "the running total", say */
@e NONLOCAL_VARIABLE_NT			/* "the location" */
@e PROPERTY_VALUE_NT				/* "the carrying capacity of the cedarwood box" */
@e TABLE_ENTRY_NT				/* "tonnage in row X of the Table of Corvettes" */
@e LIST_ENTRY_NT					/* "item 4 in L" */

@ Condition nodes represent atomic conditions, and also Boolean operations on
them. It's convenient to represent these operations as nodes in their own right
rather than as (for example) phrases: this reduces parsing ambiguities, but
also makes it easier for us to manipulate the results.

@e LOGICAL_NOT_NT				/* "not A" */
@e LOGICAL_TENSE_NT				/* in the past, A */
@e LOGICAL_AND_NT				/* "A and B" */
@e LOGICAL_OR_NT					/* "A or B" */
@e TEST_PROPOSITION_NT			/* if "the cat is on the mat" */
@e TEST_PHRASE_OPTION_NT			/* "giving full details", say */
@e TEST_VALUE_NT					/* when a value is used as a condition */

@

@e LVALUE_NCAT
@e RVALUE_NCAT
@e COND_NCAT


@

@d MORE_NODE_METADATA_SETUP_SYNTAX_CALLBACK ParseTreeUsage::md

=
void ParseTreeUsage::md(void) {
    /* first, the structural nodes: */
	NodeType::new(ALLOWED_NT, I"ALLOWED_NT",				   				1, 1,		L3_NCAT, ASSERT_NFLAG);
	NodeType::new(EVERY_NT, I"EVERY_NT", 				   					0, INFTY,	L3_NCAT, ASSERT_NFLAG);
	NodeType::new(ACTION_NT, I"ACTION_NT",				   					0, INFTY,	L3_NCAT, ASSERT_NFLAG);
	NodeType::new(ADJECTIVE_NT, I"ADJECTIVE_NT",			   				0, INFTY,	L3_NCAT, ASSERT_NFLAG);
	NodeType::new(PROPERTYCALLED_NT, I"PROPERTYCALLED_NT",  				2, 2,		L3_NCAT, 0);
	NodeType::new(TOKEN_NT, I"TOKEN_NT",					   				0, INFTY,	L3_NCAT, 0);
	NodeType::new(CREATED_NT, I"CREATED_NT",				  				0, 0,		L3_NCAT, ASSERT_NFLAG);

	NodeType::new(CODE_BLOCK_NT, I"CODE_BLOCK_NT",	       					0, INFTY,	L4_NCAT, 0);
	NodeType::new(INVOCATION_LIST_NT, I"INVOCATION_LIST_NT",		   		0, INFTY,	L4_NCAT, 0);
	NodeType::new(INVOCATION_LIST_SAY_NT, I"INVOCATION_LIST_SAY_NT",		0, INFTY,	L4_NCAT, 0);
	NodeType::new(INVOCATION_NT, I"INVOCATION_NT",		   					0, INFTY,	L4_NCAT, 0);
	NodeType::new(VOID_CONTEXT_NT, I"VOID_CONTEXT_NT", 						0, INFTY,	L4_NCAT, 0);
	NodeType::new(RVALUE_CONTEXT_NT, I"RVALUE_CONTEXT_NT", 					0, INFTY,	L4_NCAT, 0);
	NodeType::new(LVALUE_CONTEXT_NT, I"LVALUE_CONTEXT_NT", 					0, INFTY,	L4_NCAT, 0);
	NodeType::new(LVALUE_TR_CONTEXT_NT, I"LVALUE_TR_CONTEXT_NT", 			0, INFTY,	L4_NCAT, 0);
	NodeType::new(SPECIFIC_RVALUE_CONTEXT_NT, I"SPECIFIC_RVALUE_CONTEXT_NT",	0, INFTY,	L4_NCAT, 0);
	NodeType::new(MATCHING_RVALUE_CONTEXT_NT, I"MATCHING_RVALUE_CONTEXT_NT",	0, INFTY,	L4_NCAT, 0);
	NodeType::new(NEW_LOCAL_CONTEXT_NT, I"NEW_LOCAL_CONTEXT_NT",			0, INFTY,	L4_NCAT, 0);
	NodeType::new(LVALUE_LOCAL_CONTEXT_NT, I"LVALUE_LOCAL_CONTEXT_NT",		0, INFTY,	L4_NCAT, 0);
	NodeType::new(CONDITION_CONTEXT_NT, I"CONDITION_CONTEXT_NT",			0, INFTY,	L4_NCAT, 0);

	/* now the specification nodes: */
	NodeType::new(CONSTANT_NT, I"CONSTANT_NT", 								0, 0,		RVALUE_NCAT, 0);
	NodeType::new(PHRASE_TO_DECIDE_VALUE_NT, I"PHRASE_TO_DECIDE_VALUE_NT",	1, 1,		RVALUE_NCAT, PHRASAL_NFLAG);

	NodeType::new(LOCAL_VARIABLE_NT, I"LOCAL_VARIABLE_NT", 					0, 0,		LVALUE_NCAT, 0);
	NodeType::new(NONLOCAL_VARIABLE_NT, I"NONLOCAL_VARIABLE_NT", 			0, 0,		LVALUE_NCAT, 0);
	NodeType::new(PROPERTY_VALUE_NT, I"PROPERTY_VALUE_NT", 					2, 2,		LVALUE_NCAT, 0);
	NodeType::new(TABLE_ENTRY_NT, I"TABLE_ENTRY_NT", 						1, 4,		LVALUE_NCAT, 0);
	NodeType::new(LIST_ENTRY_NT, I"LIST_ENTRY_NT", 							2, 2,		LVALUE_NCAT, 0);

	NodeType::new(LOGICAL_NOT_NT, I"LOGICAL_NOT_NT", 						1, 1,		COND_NCAT, 0);
	NodeType::new(LOGICAL_TENSE_NT, I"LOGICAL_TENSE_NT", 					1, 1,		COND_NCAT, 0);
	NodeType::new(LOGICAL_AND_NT, I"LOGICAL_AND_NT", 						2, 2,		COND_NCAT, 0);
	NodeType::new(LOGICAL_OR_NT, I"LOGICAL_OR_NT", 							2, 2,		COND_NCAT, 0);
	NodeType::new(TEST_PROPOSITION_NT, I"TEST_PROPOSITION_NT", 				0, 0,		COND_NCAT, 0);
	NodeType::new(TEST_PHRASE_OPTION_NT, I"TEST_PHRASE_OPTION_NT", 			0, 0, 		COND_NCAT, 0);
	NodeType::new(TEST_VALUE_NT, I"TEST_VALUE_NT", 							1, 1,		COND_NCAT, 0);
}

@

@d PARENTAGE_PERMISSIONS_SYNTAX_CALLBACK ParseTreeUsage::write_parentage_permissions

=
void ParseTreeUsage::write_parentage_permissions(void) {
	NodeType::allow_parentage_for_categories(L2_NCAT, L3_NCAT);
	NodeType::allow_parentage_for_categories(L3_NCAT, L3_NCAT);
	NodeType::allow_parentage_for_categories(L2_NCAT, L4_NCAT);
	NodeType::allow_parentage_for_categories(L4_NCAT, L4_NCAT);
	NodeType::allow_parentage_for_categories(L4_NCAT, UNKNOWN_NCAT);

	NodeType::allow_parentage_for_categories(L4_NCAT, LVALUE_NCAT);
	NodeType::allow_parentage_for_categories(L4_NCAT, RVALUE_NCAT);
	NodeType::allow_parentage_for_categories(L4_NCAT, COND_NCAT);

	NodeType::allow_parentage_for_categories(LVALUE_NCAT, UNKNOWN_NCAT);
	NodeType::allow_parentage_for_categories(RVALUE_NCAT, UNKNOWN_NCAT);
	NodeType::allow_parentage_for_categories(COND_NCAT, UNKNOWN_NCAT);
	NodeType::allow_parentage_for_categories(LVALUE_NCAT, LVALUE_NCAT);
	NodeType::allow_parentage_for_categories(RVALUE_NCAT, LVALUE_NCAT);
	NodeType::allow_parentage_for_categories(COND_NCAT, LVALUE_NCAT);
	NodeType::allow_parentage_for_categories(LVALUE_NCAT, RVALUE_NCAT);
	NodeType::allow_parentage_for_categories(RVALUE_NCAT, RVALUE_NCAT);
	NodeType::allow_parentage_for_categories(COND_NCAT, RVALUE_NCAT);
	NodeType::allow_parentage_for_categories(LVALUE_NCAT, COND_NCAT);
	NodeType::allow_parentage_for_categories(RVALUE_NCAT, COND_NCAT);
	NodeType::allow_parentage_for_categories(COND_NCAT, COND_NCAT);
}

@

@d ANNOTATION_PERMISSIONS_SYNTAX_CALLBACK ParseTreeUsage::write_permissions

=
void ParseTreeUsage::write_permissions(void) {
	Annotations::allow_for_category(L1_NCAT, clears_pronouns_ANNOT);
	Annotations::allow(HEADING_NT, embodying_heading_ANNOT);
	Annotations::allow(HEADING_NT, inclusion_of_extension_ANNOT);
	Annotations::allow(HEADING_NT, interpretation_of_subject_ANNOT);
	Annotations::allow(HEADING_NT, suppress_heading_dependencies_ANNOT);
	Annotations::allow(HEADING_NT, implied_heading_ANNOT);
	Annotations::allow_for_category(L1_NCAT, unit_ANNOT);

	Annotations::allow_for_category(L2_NCAT, clears_pronouns_ANNOT);
	Annotations::allow_for_category(L2_NCAT, interpretation_of_subject_ANNOT);
	Annotations::allow_for_category(L2_NCAT, verb_problem_issued_ANNOT);
	Annotations::allow(RULE_NT, indentation_level_ANNOT);
	Annotations::allow(SENTENCE_NT, implicit_in_creation_of_ANNOT);
	Annotations::allow(SENTENCE_NT, implicitness_count_ANNOT);
	Annotations::allow(SENTENCE_NT, you_can_ignore_ANNOT);
	Annotations::allow(SENTENCE_NT, classified_ANNOT);
	Annotations::allow_for_category(L2_NCAT, unit_ANNOT);
	LOOP_OVER_ENUMERATED_NTS(t)
		if (NodeType::has_flag(t, ASSERT_NFLAG))
			Annotations::allow(t, refined_ANNOT);

	Annotations::allow_for_category(L3_NCAT, unit_ANNOT);
	Annotations::allow_for_category(L3_NCAT, creation_proposition_ANNOT);
	Annotations::allow_for_category(L3_NCAT, evaluation_ANNOT);
	Annotations::allow_for_category(L3_NCAT, subject_ANNOT);
	Annotations::allow_for_category(L3_NCAT, explicit_gender_marker_ANNOT);
	Annotations::allow(ACTION_NT, action_meaning_ANNOT);
	Annotations::allow(ADJECTIVE_NT, predicate_ANNOT);
	Annotations::allow(VERB_NT, category_of_I6_translation_ANNOT);
	Annotations::allow(VERB_NT, rule_placement_sense_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, action_meaning_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, creation_site_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, multiplicity_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, quant_ANNOT);
	Annotations::allow(COMMON_NOUN_NT, quantification_parameter_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, predicate_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, creation_site_ANNOT);
	Annotations::allow(UNPARSED_NOUN_NT, defn_language_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, defn_language_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, lpe_options_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, multiplicity_ANNOT);
	Annotations::allow(UNPARSED_NOUN_NT, new_relation_here_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, new_relation_here_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, nowhere_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, quant_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, quantification_parameter_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, row_amendable_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, slash_dash_dash_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, table_cell_unspecified_ANNOT);
	Annotations::allow(PROPER_NOUN_NT, turned_already_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_token_literal_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_token_relation_ANNOT);
	Annotations::allow(TOKEN_NT, grammar_value_ANNOT);
	Annotations::allow(TOKEN_NT, slash_class_ANNOT);

	Annotations::allow_for_category(L4_NCAT, colon_block_command_ANNOT);
	Annotations::allow_for_category(L4_NCAT, control_structure_used_ANNOT);
	Annotations::allow_for_category(L4_NCAT, end_control_structure_used_ANNOT);
	Annotations::allow_for_category(L4_NCAT, evaluation_ANNOT);
	Annotations::allow_for_category(L4_NCAT, indentation_level_ANNOT);
	Annotations::allow_for_category(L4_NCAT, kind_of_new_variable_ANNOT);
	Annotations::allow_for_category(L4_NCAT, kind_required_by_context_ANNOT);
	Annotations::allow_for_category(L4_NCAT, results_from_splitting_ANNOT);
	Annotations::allow_for_category(L4_NCAT, token_as_parsed_ANNOT);
	Annotations::allow_for_category(L4_NCAT, token_check_to_do_ANNOT);
	Annotations::allow_for_category(L4_NCAT, token_to_be_parsed_against_ANNOT);
	Annotations::allow_for_category(L4_NCAT, verb_problem_issued_ANNOT);
	Annotations::allow_for_category(L4_NCAT, problem_falls_under_ANNOT);
	Annotations::allow_for_category(L4_NCAT, unit_ANNOT);
	Annotations::allow(INVOCATION_LIST_NT, from_text_substitution_ANNOT);
	Annotations::allow(INVOCATION_LIST_SAY_NT, suppress_newlines_ANNOT);
	Annotations::allow(INVOCATION_NT, epistemological_status_ANNOT);
	Annotations::allow(INVOCATION_NT, kind_resulting_ANNOT);
	Annotations::allow(INVOCATION_NT, kind_variable_declarations_ANNOT);
	Annotations::allow(INVOCATION_NT, modal_verb_ANNOT);
	Annotations::allow(INVOCATION_NT, phrase_invoked_ANNOT);
	Annotations::allow(INVOCATION_NT, phrase_options_invoked_ANNOT);
	Annotations::allow(INVOCATION_NT, say_adjective_ANNOT);
	Annotations::allow(INVOCATION_NT, say_verb_ANNOT);
	Annotations::allow(INVOCATION_NT, say_verb_negated_ANNOT);
	Annotations::allow(INVOCATION_NT, ssp_closing_segment_wn_ANNOT);
	Annotations::allow(INVOCATION_NT, ssp_segment_count_ANNOT);
	Annotations::allow(INVOCATION_NT, suppress_newlines_ANNOT);
	Annotations::allow(INVOCATION_NT, save_self_ANNOT);
	Annotations::allow(INVOCATION_NT, unproven_ANNOT);

	ParseTreeUsage::allow_annotation_to_specification(meaning_ANNOT);
	ParseTreeUsage::allow_annotation_to_specification(converted_SN_ANNOT);
	ParseTreeUsage::allow_annotation_to_specification(subject_term_ANNOT);
	ParseTreeUsage::allow_annotation_to_specification(epistemological_status_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_action_name_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_action_pattern_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_activity_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_binary_predicate_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_constant_phrase_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_enumeration_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_equation_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_grammar_verb_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_instance_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_named_action_pattern_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_named_rulebook_outcome_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_number_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_property_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_rule_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_rulebook_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_scene_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_table_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_table_column_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_text_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_use_option_ANNOT);
	Annotations::allow(CONSTANT_NT, constant_verb_form_ANNOT);
	Annotations::allow(CONSTANT_NT, explicit_literal_ANNOT);
	Annotations::allow(CONSTANT_NT, explicit_vh_ANNOT);
	Annotations::allow(CONSTANT_NT, grammar_token_code_ANNOT);
	Annotations::allow(CONSTANT_NT, kind_of_value_ANNOT);
	Annotations::allow(CONSTANT_NT, nothing_object_ANNOT);
	Annotations::allow(CONSTANT_NT, property_name_used_as_noun_ANNOT);
	Annotations::allow(CONSTANT_NT, proposition_ANNOT);
	Annotations::allow(CONSTANT_NT, response_code_ANNOT);
	Annotations::allow(CONSTANT_NT, self_object_ANNOT);
	Annotations::allow(CONSTANT_NT, text_unescaped_ANNOT);
	Annotations::allow(LOCAL_VARIABLE_NT, constant_local_variable_ANNOT);
	Annotations::allow(LOCAL_VARIABLE_NT, kind_of_value_ANNOT);
	Annotations::allow(LOGICAL_TENSE_NT, condition_tense_ANNOT);
	Annotations::allow(LOGICAL_TENSE_NT, tense_marker_ANNOT);
	Annotations::allow(NONLOCAL_VARIABLE_NT, constant_nonlocal_variable_ANNOT);
	Annotations::allow(NONLOCAL_VARIABLE_NT, kind_of_value_ANNOT);
	Annotations::allow(PROPERTY_VALUE_NT, record_as_self_ANNOT);
	Annotations::allow(TEST_PHRASE_OPTION_NT, phrase_option_ANNOT);
	Annotations::allow(TEST_PROPOSITION_NT, proposition_ANNOT);
	Annotations::allow(UNKNOWN_NT, preposition_ANNOT);
	Annotations::allow(UNKNOWN_NT, verb_ANNOT);
}
void ParseTreeUsage::allow_annotation_to_specification(int annot) {
	Annotations::allow(UNKNOWN_NT, annot);
	Annotations::allow_for_category(LVALUE_NCAT, annot);
	Annotations::allow_for_category(RVALUE_NCAT, annot);
	Annotations::allow_for_category(COND_NCAT, annot);
}

@

@d PARENTAGE_EXCEPTIONS_SYNTAX_CALLBACK ParseTreeUsage::parentage_exceptions

=
int ParseTreeUsage::parentage_exceptions(node_type_t t_parent, int cat_parent,
	node_type_t t_child, int cat_child) {
	if ((t_parent == PHRASE_TO_DECIDE_VALUE_NT) && (t_child == INVOCATION_LIST_NT)) return TRUE;
	return FALSE;
}

@ Further classification:

@d IMMUTABLE_NODE ParseTreeUsage::immutable
@d IS_SENTENCE_NODE_SYNTAX_CALLBACK ParseTreeUsage::second_level

=
int ParseTreeUsage::second_level(node_type_t t) {
	node_type_metadata *metadata = NodeType::get_metadata(t);
	if ((metadata) && (metadata->category == L2_NCAT)) return TRUE;
	return FALSE;
}

int ParseTreeUsage::immutable(node_type_t t) {
	if (ParseTreeUsage::is_specification_node_type(t)) return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_specification_node_type(node_type_t t) {
	if (t == UNKNOWN_NT) return TRUE;
	node_type_metadata *metadata = NodeType::get_metadata(t);
	if ((metadata) &&
		((metadata->category == RVALUE_NCAT) ||
		(metadata->category == LVALUE_NCAT) ||
		(metadata->category == COND_NCAT))) return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_lvalue(parse_node *pn) {
	node_type_metadata *metadata = NodeType::get_metadata(Node::get_type(pn));
	if ((metadata) && (metadata->category == LVALUE_NCAT)) return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_rvalue(parse_node *pn) {
	node_type_metadata *metadata = NodeType::get_metadata(Node::get_type(pn));
	if ((metadata) && (metadata->category == RVALUE_NCAT)) return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_value(parse_node *pn) {
	node_type_metadata *metadata = NodeType::get_metadata(Node::get_type(pn));
	if ((metadata) &&
		((metadata->category == LVALUE_NCAT) || (metadata->category == RVALUE_NCAT)))
		return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_condition(parse_node *pn) {
	node_type_metadata *metadata = NodeType::get_metadata(Node::get_type(pn));
	if ((metadata) && (metadata->category == COND_NCAT)) return TRUE;
	return FALSE;
}

int ParseTreeUsage::is_phrasal(parse_node *pn) {
	if (NodeType::has_flag(Node::get_type(pn), PHRASAL_NFLAG)) return TRUE;
	return FALSE;
}

void ParseTreeUsage::add_kind_inventions(void) {
	StarTemplates::transcribe_all(Task::syntax_tree());
}

void ParseTreeUsage::verify(void) {
	VerifyTree::verify_integrity(Task::syntax_tree());
	VerifyTree::verify_structure(Task::syntax_tree());
}
