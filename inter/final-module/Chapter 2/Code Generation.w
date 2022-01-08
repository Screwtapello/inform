[CodeGen::] Code Generation.

To generate final code from intermediate code.

@h Pipeline stage.
This whole module exists to provide a single pipeline stage, making the final
generation of code from a tree of fully-linked and generally complete Inter.

It comes in two forms (the optional one writes nothing if no filename is supplied
to it; the compulsory one throws an error in that case), but note that both call
the same function.

=
void CodeGen::create_pipeline_stage(void) {
	ParsingPipelines::new_stage(I"generate", CodeGen::run_pipeline_stage,
		TEXT_OUT_STAGE_ARG, FALSE);
	ParsingPipelines::new_stage(I"optionally-generate", CodeGen::run_pipeline_stage, 
		OPTIONAL_TEXT_OUT_STAGE_ARG, FALSE);
}

int CodeGen::run_pipeline_stage(pipeline_step *step) {
	if (step->generator_argument) {
		code_generation *gen = CodeGen::new_generation(step, step->ephemera.parsed_filename,
			step->ephemera.to_stream, step->ephemera.tree, step->ephemera.package_argument,
			step->generator_argument, step->ephemera.for_VM, FALSE);
		Generators::go(gen);
	}
	return TRUE;
}

@ A "generation" is a single act of translating inter code into final code.
It will be carried out by the "generator", using the data held in the following
object.

=
typedef struct code_generation {
	struct code_generator *generator;
	struct pipeline_step *from_step;
	struct target_vm *for_VM;
	void *generator_private_data; /* depending on the target generated to */

	struct filename *to_file;      /* filename of output, and/or... */
	struct text_stream *to_stream; /* stream for textual output */

	struct inter_tree *from;
	struct inter_package *just_this_package;

	struct segmentation_data segmentation;
	int void_level;
	int literal_text_mode;
	struct linked_list *global_variables;
	struct linked_list *text_literals;
	struct linked_list *assimilated_properties;
	struct linked_list *unassimilated_properties;
	struct linked_list *instances;
	struct linked_list *kinds;
	struct linked_list *kinds_in_declaration_order;
	struct linked_list *instances_in_declaration_order;

	int true_action_count;
	int fake_action_count;
	struct linked_list *actions; /* of |text_stream| */
	int dword_count;
	struct linked_list *words; /* of |vanilla_dword| */
	struct dictionary *dword_dictionary; /* of |vanilla_dword| */
	int verb_count;
	struct linked_list *verbs; /* of |vanilla_dword| */
	struct linked_list *verb_grammar; /* of |text_stream| */

	CLASS_DEFINITION
} code_generation;

code_generation *CodeGen::new_generation(pipeline_step *step, filename *F, 
	text_stream *T, inter_tree *I, inter_package *just, code_generator *generator,
	target_vm *VM, int temp) {
	code_generation *gen = CREATE(code_generation);
	gen->from_step = step;
	gen->to_file = F;
	gen->to_stream = T;
	if ((VM == NULL) && (generator == NULL)) internal_error("no way to determine format");
	if (VM == NULL) VM = TargetVMs::find(generator->generator_name);
	gen->for_VM = VM;
	gen->from = I;
	gen->generator = generator;
	if (just) gen->just_this_package = just;
	else gen->just_this_package = Site::main_package(I);
	gen->segmentation = CodeGen::new_segmentation_data();
	gen->void_level = -1;
	gen->literal_text_mode = REGULAR_LTM;
	gen->global_variables = NEW_LINKED_LIST(inter_symbol);
	gen->text_literals = NEW_LINKED_LIST(text_literal_holder);
	gen->assimilated_properties = NEW_LINKED_LIST(inter_symbol);
	gen->unassimilated_properties = NEW_LINKED_LIST(inter_symbol);
	gen->instances = NEW_LINKED_LIST(inter_symbol);
	gen->kinds = NEW_LINKED_LIST(inter_symbol);
	gen->kinds_in_declaration_order = NEW_LINKED_LIST(inter_symbol);
	gen->instances_in_declaration_order = NEW_LINKED_LIST(inter_symbol);
	gen->true_action_count = 0;
	gen->fake_action_count = 0;
	gen->actions = NEW_LINKED_LIST(text_stream);
	gen->dword_count = 0;
	gen->words = NEW_LINKED_LIST(vanilla_dword);
	gen->dword_dictionary = Dictionaries::new(1024, FALSE);
	gen->verb_count = 0;
	gen->verbs = NEW_LINKED_LIST(vanilla_dword);
	gen->verb_grammar = NEW_LINKED_LIST(text_stream);
	if (temp == FALSE) @<Traverse for global bric-a-brac@>;
	return gen;
}

@<Traverse for global bric-a-brac@> =
	InterTree::traverse(gen->from, CodeGen::gather_up, gen, NULL, 0);
	CodeGen::sort_symbol_list(gen->kinds_in_declaration_order, gen->kinds,
		CodeGen::in_declaration_order);
	CodeGen::sort_symbol_list(gen->instances_in_declaration_order, gen->instances,
		CodeGen::in_declaration_order);

@ =
void CodeGen::gather_up(inter_tree *I, inter_tree_node *P, void *state) {
	code_generation *gen = (code_generation *) state;
	switch (P->W.data[ID_IFLD]) {
		case VARIABLE_IST: {
			inter_symbol *var_name = InterSymbolsTables::symbol_from_frame_data(P, DEFN_VAR_IFLD);
			ADD_TO_LINKED_LIST(var_name, inter_symbol, gen->global_variables);
			break;
		}
		case PROPERTY_IST: {
			inter_symbol *prop_name = InterSymbolsTables::symbol_from_frame_data(P, DEFN_PROP_IFLD);
			if (Inter::Symbols::read_annotation(prop_name, ASSIMILATED_IANN) == 1)
				ADD_TO_LINKED_LIST(prop_name, inter_symbol, gen->assimilated_properties);
			else
				ADD_TO_LINKED_LIST(prop_name, inter_symbol, gen->unassimilated_properties);
			break;
		}
		case INSTANCE_IST: {
			inter_symbol *inst_name = InterSymbolsTables::symbol_from_frame_data(P, DEFN_KIND_IFLD);
			ADD_TO_LINKED_LIST(inst_name, inter_symbol, gen->instances);
			break;
		}
		case KIND_IST: {
			inter_symbol *kind_name = InterSymbolsTables::symbol_from_frame_data(P, DEFN_INST_IFLD);
			ADD_TO_LINKED_LIST(kind_name, inter_symbol, gen->kinds);
			break;
		}
	}
}

void CodeGen::sort_symbol_list(linked_list *to_L, linked_list *L,
	int (*sorter)(const void *elem1, const void *elem2)) {
	int N = LinkedLists::len(L);
	if (N > 0) {
		inter_symbol **array = (inter_symbol **)
			(Memory::calloc(N, sizeof(inter_symbol *), CODE_GENERATION_MREASON));
		int i=0;
		inter_symbol *sym;
		LOOP_OVER_LINKED_LIST(sym, inter_symbol, L) array[i++] = sym;
		qsort(array, (size_t) N, sizeof(inter_symbol *), sorter);
		for (int j=0; j<N; j++) ADD_TO_LINKED_LIST(array[j], inter_symbol, to_L);
		Memory::I7_array_free(array, CODE_GENERATION_MREASON, N, sizeof(inter_symbol *));
	}
}

int CodeGen::in_source_order(const void *elem1, const void *elem2) {
	return CodeGen::in_annotation_order(elem1, elem2, SOURCE_ORDER_IANN);
}
int CodeGen::in_declaration_order(const void *elem1, const void *elem2) {
	return CodeGen::in_annotation_order(elem1, elem2, DECLARATION_ORDER_IANN);
}
int CodeGen::in_annotation_order(const void *elem1, const void *elem2, inter_ti annot) {
	const inter_symbol **e1 = (const inter_symbol **) elem1;
	const inter_symbol **e2 = (const inter_symbol **) elem2;
	if ((*e1 == NULL) || (*e2 == NULL))
		internal_error("Disaster while sorting kinds");
	int s1 = CodeGen::sequence_number(*e1, annot);
	int s2 = CodeGen::sequence_number(*e2, annot);
	if (s1 != s2) return s1-s2;
	return Inter::Symbols::sort_number(*e1) - Inter::Symbols::sort_number(*e2);
}
int CodeGen::sequence_number(const inter_symbol *kind_name, inter_ti annot) {
	int N = Inter::Symbols::read_annotation(kind_name, annot);
	if (N >= 0) return N;
	return 100000000;
}

@h Ad hoc generation.
This module would be more elegant if the following function did not exist. But
it is a consequence of the |(+| ... |+)| feature of Inform, which plunges
right through all kinds of conceptual barriers better left unplunged-through.
Happily, it's both limited and little-used. The task is to turn a single Inter
value-pair into the text of an expression which will represent it at run-time.

This is called by Inform 7 during a drastically earlier phase of compilation,
long before the //final// module would otherwise be involved, and there's no
question of performing a full generation of an entire Inter tree. So we make
a sort of mock-generation object, the |ad_hoc_generation|, just for the purpose
of this function call. We could make a new mock object every time, because there
aren't such a lot of calls to this function, but instead we make just one and
re-use it.

The mock generator makes no use of segmentation (see below) except for the
single temporary segement, which is set to |OUT|.

=
code_generation *ad_hoc_generation = NULL;

void CodeGen::val_to_text(OUTPUT_STREAM, inter_bookmark *IBM,
	inter_ti val1, inter_ti val2, target_vm *VM) {
	if (ad_hoc_generation == NULL) {
		if (VM == NULL) internal_error("no VM given");
		code_generator *generator = Generators::find_for(VM);
		if (generator == NULL) internal_error("VM family with no generator");
		ad_hoc_generation =
			CodeGen::new_generation(NULL, NULL, NULL, Inter::Bookmarks::tree(IBM),
				NULL, generator, VM, TRUE);
	}
	code_generator *generator = Generators::find_for(VM);
	if (generator == NULL) internal_error("VM family with no generator");
	ad_hoc_generation->for_VM = VM;
	ad_hoc_generation->generator = generator;
	
	CodeGen::select_temporary(ad_hoc_generation, OUT);
	CodeGen::pair_at_bookmark(ad_hoc_generation, IBM, val1, val2);
	CodeGen::deselect_temporary(ad_hoc_generation);
}

@h Literal text modes.
There are three of these. |PRINTING_LTM| is used when text is needed only
immediately as an operand for, say, |!print| and will therefore never be a
value at runtime; |BOX_LTM| for "quotation box" text; |REGULAR_LTM| for
everything else.

@d REGULAR_LTM 0
@d BOX_LTM 1
@d PRINTING_LTM 2

=
void CodeGen::lt_mode(code_generation *gen, int m) {
	gen->literal_text_mode = m;
}

@h Segmentation.
Generators have flexibility in how they go about their business, but if they are
making what amounts to a text file with a lot of internal structure then the
following system may be a convenience. It allows text to be assembled as a set
of "segments" which can be appended to in any order, and which are then put
together in a logical order at the end.

Segments are identified by ID numbers counting up from 0, 1, 2, ...: but
ID number 0 is |no_I7CGS|, reserved to mean "not a segment".

A segment is itself internally stratified into numbered "layers", and these
are used to help generators cope with more nuanced ordering issues -- e.g.,
where two declarations are of basically the same sort of thing, and should
be in the same segment as each other; but where one must nevertheless precede
the other. This can be achieved by putting the one to come first at a
lower-numbered level.

@e no_I7CGS from 0

@d MAX_LAYERS_PER_SEGMENT 128

=
typedef struct generated_segment {
	int layers;
	struct text_stream *generated_code[MAX_LAYERS_PER_SEGMENT];
	CLASS_DEFINITION
} generated_segment;

generated_segment *CodeGen::new_segment(void) {
	generated_segment *seg = CREATE(generated_segment);
	seg->layers = MAX_LAYERS_PER_SEGMENT;
	for (int i=0; i<seg->layers; i++) seg->generated_code[i] = Str::new();
	return seg;
}

@ Each generation has its own copy of every possible numbered segment, though
by default those are |NULL|.

=
typedef struct segmentation_data {
	struct generated_segment *segments[NO_DEFINED_I7CGS_VALUES];
	struct linked_list *segment_sequence; /* of |generated_segment| */
	struct linked_list *additional_segment_sequence; /* of |generated_segment| */
	struct text_stream *temporarily_diverted_to;
	int temporarily_diverted; /* to the temporary segment */
	struct segmentation_pos pos;
} segmentation_data;

typedef struct segmentation_pos {
	struct generated_segment *current_segment; /* the one currently being written to */
	int current_layer; /* within that segment: in the range 0 to current_segment->layers - 1 */
} segmentation_pos;

segmentation_data CodeGen::new_segmentation_data(void) {
	segmentation_data sd;
	sd.segment_sequence = NEW_LINKED_LIST(generated_segment);
	sd.additional_segment_sequence = NEW_LINKED_LIST(generated_segment);
	sd.temporarily_diverted = FALSE;
	sd.temporarily_diverted_to = NULL;
	for (int i=0; i<NO_DEFINED_I7CGS_VALUES; i++) sd.segments[i] = NULL;
	sd.pos.current_segment = NULL;
	sd.pos.current_layer = 1;
	return sd;
}

@ If a generator wants to use this system, it should call //CodeGen::create_segments//
to say which segments it wants to be created, passing an array of ID numbers. The
order of these is significant -- it's the order in which they will appear in the final
output.

=
void CodeGen::create_segments(code_generation *gen, void *data, int codes[]) {
	gen->segmentation.segment_sequence = NEW_LINKED_LIST(generated_segment);
	for (int i=0; codes[i] >= 0; i++) {
		if ((codes[i] >= NO_DEFINED_I7CGS_VALUES) ||
			(codes[i] == no_I7CGS)) internal_error("bad segment sequence");
		gen->segmentation.segments[codes[i]] = CodeGen::new_segment();
		ADD_TO_LINKED_LIST(gen->segmentation.segments[codes[i]], generated_segment,
			gen->segmentation.segment_sequence);
	}
	gen->generator_private_data = data;
}

@ An optional "alternative" set can also be created.

=
void CodeGen::additional_segments(code_generation *gen, int codes[]) {
	gen->segmentation.additional_segment_sequence = NEW_LINKED_LIST(generated_segment);
	for (int i=0; codes[i] >= 0; i++) {
		if ((codes[i] >= NO_DEFINED_I7CGS_VALUES) ||
			(codes[i] == no_I7CGS)) internal_error("bad segment sequence");
		gen->segmentation.segments[codes[i]] = CodeGen::new_segment();
		ADD_TO_LINKED_LIST(gen->segmentation.segments[codes[i]], generated_segment,
			gen->segmentation.additional_segment_sequence);
	}
}

@ At any given time, a generation has a "current" segment, to which output is
being written. The generator should use //CodeGen::select// to switch to a given
segment, which must be one of those it has created, and then use //CodeGen::deselect//
to go back to where it was. These calls must be made in properly nested pairs.

At some point we may want to make the cap on the number of layers flexible,
but for now about 10 layers is plenty.

=
segmentation_pos CodeGen::select(code_generation *gen, int i) {
	return CodeGen::select_layered(gen, i, 1);
}

segmentation_pos CodeGen::select_layered(code_generation *gen, int i, int layer) {
	segmentation_pos previous_pos = gen->segmentation.pos;
	if (gen->segmentation.temporarily_diverted) internal_error("poorly timed selection");
	if ((i < 0) || (i >= NO_DEFINED_I7CGS_VALUES)) internal_error("out of range");
	if (gen->segmentation.segments[i] == NULL)
		internal_error("generator does not use this segment ID");
	if (layer >= gen->segmentation.segments[i]->layers)
		internal_error("too many layers");
	gen->segmentation.pos.current_segment = gen->segmentation.segments[i];
	gen->segmentation.pos.current_layer = layer;
	return previous_pos;
}

void CodeGen::deselect(code_generation *gen, segmentation_pos saved) {
	if (gen->segmentation.temporarily_diverted) internal_error("poorly timed deselection");
	gen->segmentation.pos = saved;
}

@ However, we can also temporarily divert the whole system to send its text to
some temporary stream somewhere. For that, use the following pair:

=
void CodeGen::select_temporary(code_generation *gen, text_stream *T) {
	if (gen->segmentation.temporarily_diverted) internal_error("nested temporary segments");
	gen->segmentation.temporarily_diverted_to = T;
	gen->segmentation.temporarily_diverted = TRUE;
}

void CodeGen::deselect_temporary(code_generation *gen) {
	gen->segmentation.temporarily_diverted_to = NULL;
	gen->segmentation.temporarily_diverted = FALSE;
}

@ The following returns the text stream a generator should write to. Note that
if it has been "temporarily diverted" then the regiular selection is ignored.

=
text_stream *CodeGen::current(code_generation *gen) {
	if (gen->segmentation.temporarily_diverted)
		return gen->segmentation.temporarily_diverted_to;
	if (gen->segmentation.pos.current_segment == NULL) return NULL;
	return gen->segmentation.pos.current_segment->
		generated_code[gen->segmentation.pos.current_layer];
}

@ And then all we do is concatenate them in order:

=
void CodeGen::write_segments(OUTPUT_STREAM, code_generation *gen) {
	generated_segment *seg;
	LOOP_OVER_LINKED_LIST(seg, generated_segment,
		gen->segmentation.segment_sequence)
			CodeGen::write_segment(OUT, seg);
}

void CodeGen::write_additional_segments(OUTPUT_STREAM, code_generation *gen) {
	generated_segment *seg;
	LOOP_OVER_LINKED_LIST(seg, generated_segment,
		gen->segmentation.additional_segment_sequence)
			CodeGen::write_segment(OUT, seg);
}

void CodeGen::write_segment(OUTPUT_STREAM, generated_segment *seg) {
	for (int i=0; i<seg->layers; i++)
		WRITE("%S", seg->generated_code[i]);
}

@h Transients.
Transient flags on symbols are used temporarily during code generation, but do
not change the meaning of the tree: they're just a way to keep track of, say,
what we've worked on so far.

=
void CodeGen::clear_all_transients(inter_tree *I) {
	InterTree::traverse(I, CodeGen::clear_transients, NULL, NULL, PACKAGE_IST);
}

void CodeGen::clear_transients(inter_tree *I, inter_tree_node *P, void *state) {
	inter_package *pack = Inter::Package::defined_by_frame(P);
	inter_symbols_table *T = Inter::Packages::scope(pack);
	for (int i=0; i<T->size; i++)
		if (T->symbol_array[i])
			Inter::Symbols::clear_transient_flags(T->symbol_array[i]);
}

@ In particular the |TRAVERSE_MARK_BIT| flag is sometimes convenient to use.

=
int CodeGen::marked(inter_symbol *symb_name) {
	return Inter::Symbols::get_flag(symb_name, TRAVERSE_MARK_BIT);
}

void CodeGen::mark(inter_symbol *symb_name) {
	Inter::Symbols::set_flag(symb_name, TRAVERSE_MARK_BIT);
}

void CodeGen::unmark(inter_symbol *symb_name) {
	Inter::Symbols::clear_flag(symb_name, TRAVERSE_MARK_BIT);
}

@h Value pairs.
We will very often need to compile an expression from a pair |val1|, |val2|
extracted from some Inter instruction.

=
void CodeGen::pair_at_bookmark(code_generation *gen, inter_bookmark *IBM,
	inter_ti val1, inter_ti val2) {
	inter_symbols_table *T = IBM?(Inter::Bookmarks::scope(IBM)):NULL;
	@<Generate from a value pair@>;
}

void CodeGen::pair(code_generation *gen, inter_tree_node *P,
	inter_ti val1, inter_ti val2) {
	inter_symbols_table *T = P?(Inter::Packages::scope_of(P)):NULL;
	@<Generate from a value pair@>;
}

@<Generate from a value pair@> =
	inter_tree *I = gen->from;
	text_stream *OUT = CodeGen::current(gen);
	if (val1 == LITERAL_IVAL) {
		Generators::compile_literal_number(gen, val2, FALSE);
	} else if (Inter::Symbols::is_stored_in_data(val1, val2)) {
		inter_symbol *s = InterSymbolsTables::symbol_from_data_pair_and_table(val1, val2, T);
		if (s == NULL) internal_error("bad symbol in Inter pair");
		Generators::compile_literal_symbol(gen, s);
	} else if (val1 == DIVIDER_IVAL) {
		text_stream *divider_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		WRITE(" ! %S\n\t", divider_text);
	} else if (val1 == REAL_IVAL) {
		text_stream *glob_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		Generators::compile_literal_real(gen, glob_text);
	} else if (val1 == DWORD_IVAL) {
		text_stream *glob_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		Generators::compile_dictionary_word(gen, glob_text, FALSE);
	} else if (val1 == PDWORD_IVAL) {
		text_stream *glob_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		Generators::compile_dictionary_word(gen, glob_text, TRUE);
	} else if (val1 == LITERAL_TEXT_IVAL) {
		text_stream *glob_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		Generators::compile_literal_text(gen, glob_text, TRUE);
	} else if (val1 == GLOB_IVAL) {
		text_stream *glob_text = Inter::Warehouse::get_text(InterTree::warehouse(I), val2);
		WRITE("%S", glob_text);
	} else internal_error("unimplemented data pair");
