[CodeGen::Stage::] Stages.

To create the stages through which code generation proceeds.

@h Stages.
Each possible pipeline stage is represented by a single instance of the
following. Some stages are invoked with an argument, often the filename to
write output to; others are not.

@e NO_STAGE_ARG from 1
@e GENERAL_STAGE_ARG
@e FILE_STAGE_ARG
@e TEXT_OUT_STAGE_ARG
@e EXT_FILE_STAGE_ARG
@e EXT_TEXT_OUT_STAGE_ARG
@e TEMPLATE_FILE_STAGE_ARG

=
typedef struct pipeline_stage {
	struct text_stream *stage_name;
	int (*execute)(void *);
	int stage_arg; /* one of the |*_ARG| values above */
	int takes_repository;
	MEMORY_MANAGEMENT
} pipeline_stage;

pipeline_stage *CodeGen::Stage::new(text_stream *name, int (*X)(struct pipeline_step *), int arg, int tr) {
	pipeline_stage *stage = CREATE(pipeline_stage);
	stage->stage_name = Str::duplicate(name);
	stage->execute = (int (*)(void *)) X;
	stage->stage_arg = arg;
	stage->takes_repository = tr;
	return stage;
}

@h Creation.
To add a new pipeline stage, put the code for it into a new section in
Chapter 2, and then add a call to its |create_pipeline_stage| routine
to the routine below.

=
int stages_made = FALSE;
void CodeGen::Stage::make_stages(void) {
	if (stages_made == FALSE) {
		stages_made = TRUE;
		CodeGen::Stage::new(I"stop", CodeGen::Stage::run_stop_stage, NO_STAGE_ARG, FALSE);

		CodeGen::Stage::new(I"prepare-z", CodeGen::Stage::run_preparez_stage, NO_STAGE_ARG, FALSE);
		CodeGen::Stage::new(I"prepare-zd", CodeGen::Stage::run_preparezd_stage, NO_STAGE_ARG, FALSE);
		CodeGen::Stage::new(I"prepare-g", CodeGen::Stage::run_prepareg_stage, NO_STAGE_ARG, FALSE);
		CodeGen::Stage::new(I"prepare-gd", CodeGen::Stage::run_preparegd_stage, NO_STAGE_ARG, FALSE);
		CodeGen::Stage::new(I"read", CodeGen::Stage::run_read_stage, FILE_STAGE_ARG, TRUE);
		CodeGen::Stage::new(I"move", CodeGen::Stage::run_move_stage, GENERAL_STAGE_ARG, TRUE);

		CodeGen::create_pipeline_stage();
		CodeGen::Assimilate::create_pipeline_stage();
		CodeGen::Eliminate::create_pipeline_stage();
		CodeGen::Externals::create_pipeline_stage();
		CodeGen::Labels::create_pipeline_stage();
		CodeGen::MergeTemplate::create_pipeline_stage();
		CodeGen::PLM::create_pipeline_stage();
		CodeGen::RCC::create_pipeline_stage();
		CodeGen::ReconcileVerbs::create_pipeline_stage();
		CodeGen::Uniqueness::create_pipeline_stage();
	}	
}

@ The "stop" stage is special, in that it always returns false, thus stopping
the pipeline:

=
int CodeGen::Stage::run_stop_stage(pipeline_step *step) {
	return FALSE;
}

int CodeGen::Stage::run_preparez_stage(pipeline_step *step) {
	return CodeGen::Stage::run_prepare_stage_inner(step, TRUE, FALSE);
}
int CodeGen::Stage::run_preparezd_stage(pipeline_step *step) {
	return CodeGen::Stage::run_prepare_stage_inner(step, TRUE, TRUE);
}
int CodeGen::Stage::run_prepareg_stage(pipeline_step *step) {
	return CodeGen::Stage::run_prepare_stage_inner(step, FALSE, FALSE);
}
int CodeGen::Stage::run_preparegd_stage(pipeline_step *step) {
	return CodeGen::Stage::run_prepare_stage_inner(step, FALSE, TRUE);
}

int CodeGen::Stage::run_prepare_stage_inner(pipeline_step *step, int Z, int D) {
	inter_tree *I = step->repository;
	Packaging::initialise_state(I);
	Packaging::outside_all_packages();
	inter_bookmark IBM = Inter::Bookmarks::at_start_of_this_repository(I);
	inter_error_message *E = NULL;
	inter_symbol *plain_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_plain", &E);
	Inter::PackageType::new_packagetype(&IBM, plain_name, 0, NULL);
	inter_symbol *code_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_code", &E);
	Inter::PackageType::new_packagetype(&IBM, code_name, 0, NULL);
	inter_symbol *linkage_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_linkage", &E);
	Inter::PackageType::new_packagetype(&IBM, linkage_name, 0, NULL);
	inter_symbol *module_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_module", &E);
	Inter::PackageType::new_packagetype(&IBM, module_name, 0, NULL);
	inter_symbol *submodule_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_submodule", &E);
	Inter::PackageType::new_packagetype(&IBM, submodule_name, 0, NULL);
	inter_symbol *function_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_function", &E);
	Inter::PackageType::new_packagetype(&IBM, function_name, 0, NULL);
	inter_symbol *action_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_action", &E);
	Inter::PackageType::new_packagetype(&IBM, action_name, 0, NULL);
	inter_symbol *command_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_command", &E);
	Inter::PackageType::new_packagetype(&IBM, command_name, 0, NULL);
	inter_symbol *property_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_property", &E);
	Inter::PackageType::new_packagetype(&IBM, property_name, 0, NULL);
	inter_symbol *to_phrase_name = Inter::Textual::new_symbol(NULL, Inter::Bookmarks::scope(&IBM), I"_to_phrase", &E);
	Inter::PackageType::new_packagetype(&IBM, to_phrase_name, 0, NULL);
	Primitives::emit(I, &IBM);
	inter_bookmark at_tail = Inter::Bookmarks::at_start_of_this_repository(I);
	inter_package *main_p = NULL;
	Inter::Package::new_package_named(&at_tail, I"main", FALSE, plain_name, 0, NULL, &main_p);
	inter_bookmark in_main = Inter::Bookmarks::at_end_of_this_package(main_p);
	inter_package *veneer_p = NULL;
	Inter::Package::new_package_named(&in_main, I"veneer", FALSE, module_name, 1, NULL, &veneer_p);
	inter_package *generic_p = NULL;
	Inter::Package::new_package_named(&in_main, I"generic", FALSE, module_name, 1, NULL, &generic_p);
	inter_bookmark in_generic = Inter::Bookmarks::at_end_of_this_package(generic_p);
	inter_symbol *unchecked_kind_symbol = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_generic), I"K_unchecked");
	Inter::Kind::new(&in_generic,
		Inter::SymbolsTables::id_from_symbol(I, generic_p, unchecked_kind_symbol),
		UNCHECKED_IDT,
		0,
		BASE_ICON, 0, NULL,
		(inter_t) Inter::Bookmarks::baseline(&in_generic) + 1, NULL);
	inter_symbol *typeless_int_symbol = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_generic), I"K_typeless_int");
	Inter::Kind::new(&in_generic,
		Inter::SymbolsTables::id_from_symbol(I, generic_p, typeless_int_symbol),
		INT32_IDT,
		0,
		BASE_ICON, 0, NULL,
		(inter_t) Inter::Bookmarks::baseline(&in_generic) + 1, NULL);
	inter_symbol *truth_state_kind_symbol = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_generic), I"K_truth_state");
	Inter::Kind::new(&in_generic,
		Inter::SymbolsTables::id_from_symbol(I, generic_p, truth_state_kind_symbol),
		INT2_IDT,
		0,
		BASE_ICON, 0, NULL,
		(inter_t) Inter::Bookmarks::baseline(&in_generic) + 1, NULL);
	inter_t operands[2];
	operands[0] = Inter::SymbolsTables::id_from_IRS_and_symbol(&in_generic, unchecked_kind_symbol);
	operands[1] = Inter::SymbolsTables::id_from_IRS_and_symbol(&in_generic, unchecked_kind_symbol);
	inter_symbol *unchecked_function_symbol = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_generic), I"K_unchecked_function");
	Inter::Kind::new(&in_generic,
		Inter::SymbolsTables::id_from_symbol(I, generic_p, unchecked_function_symbol),
		ROUTINE_IDT,
		0,
		FUNCTION_ICON, 2, operands,
		(inter_t) Inter::Bookmarks::baseline(&in_generic) + 1, NULL);
	inter_symbol *list_of_unchecked_kind_symbol = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_generic), I"K_list_of_values");
	Inter::Kind::new(&in_generic,
		Inter::SymbolsTables::id_from_symbol(I, generic_p, list_of_unchecked_kind_symbol),
		LIST_IDT,
		0,
		LIST_ICON, 1, operands,
		(inter_t) Inter::Bookmarks::baseline(&in_generic) + 1, NULL);
	
	inter_package *template_p = NULL;
	Inter::Package::new_package_named(&in_main, I"template", FALSE, module_name, 1, NULL, &template_p);

	inter_bookmark in_veneer = Inter::Bookmarks::at_end_of_this_package(veneer_p);
	inter_symbol *vi_unchecked = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_veneer), I"K_unchecked");
	Inter::SymbolsTables::equate(vi_unchecked, unchecked_kind_symbol);
	inter_symbol *con_name = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_veneer), I"WORDSIZE");
	Inter::Constant::new_numerical(&in_veneer,
		Inter::SymbolsTables::id_from_symbol(I, veneer_p, con_name),
		Inter::SymbolsTables::id_from_symbol(I, veneer_p, vi_unchecked),
		LITERAL_IVAL, (Z)?2:4,
		(inter_t) Inter::Bookmarks::baseline(&in_veneer) + 1, NULL);
	inter_symbol *target_name;
	if (Z) target_name = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_veneer), I"TARGET_ZCODE");
	else target_name = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_veneer), I"TARGET_GLULX");
	Inter::Constant::new_numerical(&in_veneer,
		Inter::SymbolsTables::id_from_symbol(I, veneer_p, target_name),
		Inter::SymbolsTables::id_from_symbol(I, veneer_p, vi_unchecked),
		LITERAL_IVAL, 1,
		(inter_t) Inter::Bookmarks::baseline(&in_veneer) + 1, NULL);
	if (D) {
		inter_symbol *D_name = Inter::SymbolsTables::create_with_unique_name(Inter::Bookmarks::scope(&in_veneer), I"DEBUG");
		Inter::Constant::new_numerical(&in_veneer,
			Inter::SymbolsTables::id_from_symbol(I, veneer_p, D_name),
			Inter::SymbolsTables::id_from_symbol(I, veneer_p, vi_unchecked),
			LITERAL_IVAL, 1,
			(inter_t) Inter::Bookmarks::baseline(&in_veneer) + 1, NULL);
	}
	return TRUE;
}

int CodeGen::Stage::run_read_stage(pipeline_step *step) {
	filename *F = step->parsed_filename;
	if (Inter::Binary::test_file(F)) Inter::Binary::read(step->repository, F);
	else Inter::Textual::read(step->repository, F);
	return TRUE;
}

int CodeGen::Stage::run_move_stage(pipeline_step *step) {
	LOG("Arg is %S.\n", step->step_argument);
	match_results mr = Regexp::create_mr();
	inter_package *pack = NULL;
	if (Regexp::match(&mr, step->step_argument, L"(%d):(%c+)")) {
		int from_rep = Str::atoi(mr.exp[0], 0);
		if (step->pipeline->repositories[from_rep] == NULL)
			internal_error("no such repository");
		pack = Inter::Packages::by_url(
			step->pipeline->repositories[from_rep], mr.exp[1]);
	}
	Regexp::dispose_of(&mr);
	if (pack == NULL) internal_error("not a package");
	Inter::Transmigration::move(pack, Inter::Tree::main_package(step->repository), TRUE);

	return TRUE;
}
