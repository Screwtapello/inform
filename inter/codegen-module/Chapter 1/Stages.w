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

		CodeGen::Stage::new(I"prepare", CodeGen::Stage::run_prepare_stage, NO_STAGE_ARG, FALSE);
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

int CodeGen::Stage::run_prepare_stage(pipeline_step *step) {
	inter_tree *I = step->repository;
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
	Primitives::emit(I, &IBM);
	inter_bookmark at_tail = Inter::Bookmarks::at_start_of_this_repository(I);
	inter_package *main_p = NULL;
	Inter::Package::new_package_named(&at_tail, I"main", FALSE, plain_name, 0, NULL, &main_p);
	inter_bookmark in_main = Inter::Bookmarks::at_end_of_this_package(main_p);
	inter_package *template_p = NULL;
	Inter::Package::new_package_named(&in_main, I"template", FALSE, module_name, 1, NULL, &template_p);
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
