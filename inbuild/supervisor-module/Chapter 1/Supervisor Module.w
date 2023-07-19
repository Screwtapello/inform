[SupervisorModule::] Supervisor Module.

Setting up the use of this module.

@ This section simply sets up the module in ways expected by //foundation//, and
contains no code of interest. The following constant exists only in tools
which use this module:

@d SUPERVISOR_MODULE TRUE

@ This module defines the following classes:

@e build_methodology_CLASS
@e build_script_CLASS
@e build_skill_CLASS
@e build_step_CLASS
@e build_vertex_CLASS
@e cdoc_heading_CLASS
@e cdoc_example_CLASS
@e cdoc_passage_CLASS
@e cdoc_phrase_defn_CLASS
@e cdoc_paragraph_CLASS
@e cdoc_code_sample_CLASS
@e cdoc_code_line_CLASS
@e cdoc_source_error_CLASS
@e compiled_documentation_CLASS
@e control_structure_phrase_CLASS
@e copy_error_CLASS
@e element_activation_CLASS
@e extensions_key_item_CLASS
@e heading_CLASS
@e heading_tree_CLASS
@e inbuild_copy_CLASS
@e inbuild_edition_CLASS
@e inbuild_genre_CLASS
@e inbuild_nest_CLASS
@e inbuild_registry_CLASS
@e inbuild_requirement_CLASS
@e inbuild_search_result_CLASS
@e inbuild_work_CLASS
@e inform_extension_CLASS
@e inform_kit_CLASS
@e inform_kit_ittt_CLASS
@e inform_language_CLASS
@e inform_pipeline_CLASS
@e inform_project_CLASS
@e inform_template_CLASS
@e kit_configuration_CLASS
@e kit_dependency_CLASS

=
DECLARE_CLASS(build_methodology)
DECLARE_CLASS(build_script)
DECLARE_CLASS(build_skill)
DECLARE_CLASS(build_step)
DECLARE_CLASS(build_vertex)
DECLARE_CLASS(cdoc_heading)
DECLARE_CLASS(cdoc_example)
DECLARE_CLASS(cdoc_passage)
DECLARE_CLASS(cdoc_phrase_defn)
DECLARE_CLASS(cdoc_paragraph)
DECLARE_CLASS(cdoc_code_sample)
DECLARE_CLASS(cdoc_code_line)
DECLARE_CLASS(cdoc_source_error)
DECLARE_CLASS(control_structure_phrase)
DECLARE_CLASS(compiled_documentation)
DECLARE_CLASS(copy_error)
DECLARE_CLASS(element_activation)
DECLARE_CLASS(extensions_key_item)
DECLARE_CLASS(heading_tree)
DECLARE_CLASS(heading)
DECLARE_CLASS(inbuild_copy)
DECLARE_CLASS(inbuild_edition)
DECLARE_CLASS(inbuild_genre)
DECLARE_CLASS(inbuild_nest)
DECLARE_CLASS(inbuild_registry)
DECLARE_CLASS(inbuild_requirement)
DECLARE_CLASS(inbuild_search_result)
DECLARE_CLASS(inbuild_work)
DECLARE_CLASS(inform_extension)
DECLARE_CLASS(inform_kit_ittt)
DECLARE_CLASS(inform_kit)
DECLARE_CLASS(inform_language)
DECLARE_CLASS(inform_pipeline)
DECLARE_CLASS(inform_project)
DECLARE_CLASS(inform_template)
DECLARE_CLASS(kit_configuration)
DECLARE_CLASS(kit_dependency)

@ Like all modules, this one must define a |start| and |end| function:

@e RESULTS_SORTING_MREASON
@e EXTENSIONS_CENSUS_DA
@e HEADINGS_DA

=
void SupervisorModule::start(void) {
	Memory::reason_name(RESULTS_SORTING_MREASON, "results sorting");
	Writers::register_writer('X', &Works::writer);
	Writers::register_writer('J', &Languages::log);
	Log::declare_aspect(EXTENSIONS_CENSUS_DA, L"extensions census", FALSE, FALSE);
	Log::declare_aspect(HEADINGS_DA, L"headings", FALSE, FALSE);
	Supervisor::start();
	@<Declare the tree annotations@>;
}
void SupervisorModule::end(void) {
}

@ This module uses |syntax|, and adds the following annotations to the
syntax tree.

@e embodying_heading_ANNOT /* |heading|: for parse nodes of headings */
@e inclusion_of_extension_ANNOT /* |inform_extension|: for parse nodes of headings */

=
DECLARE_ANNOTATION_FUNCTIONS(embodying_heading, heading)
MAKE_ANNOTATION_FUNCTIONS(embodying_heading, heading)
DECLARE_ANNOTATION_FUNCTIONS(inclusion_of_extension, inform_extension)
MAKE_ANNOTATION_FUNCTIONS(inclusion_of_extension, inform_extension)

@<Declare the tree annotations@> =
	Annotations::declare_type(embodying_heading_ANNOT,
		SupervisorModule::write_embodying_heading_ANNOT);
	Annotations::declare_type(inclusion_of_extension_ANNOT,
		SupervisorModule::write_inclusion_of_extension_ANNOT);

@ =
void SupervisorModule::write_embodying_heading_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_embodying_heading(p)) {
		heading *H = Node::get_embodying_heading(p);
		WRITE(" {under: H%d'%W'}", H->level, Node::get_text(H->sentence_declaring));
	}
}
void SupervisorModule::write_inclusion_of_extension_ANNOT(text_stream *OUT, parse_node *p) {
	if (Node::get_inclusion_of_extension(p)) {
		inform_extension *E = Node::get_inclusion_of_extension(p);
		WRITE(" {includes: ");
		Copies::write_copy(OUT, E->as_copy);
		WRITE(" }");
	}
}

@d STILL_MORE_ANNOTATION_PERMISSIONS_SYNTAX_CALLBACK SupervisorModule::grant_annotation_permissions

=
void SupervisorModule::grant_annotation_permissions(void) {
	Annotations::allow(HEADING_NT, embodying_heading_ANNOT);
	Annotations::allow(HEADING_NT, inclusion_of_extension_ANNOT);
}
