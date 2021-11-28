[ParsingStages::] Parsing Stages.

Two stages which accept raw I6-syntax material in the parse tree, either from
imsertions made using Inform 7's low-level features, or after reading the
source code for a kit.

@ These stages have more in common than first appears. Both convert I6T-syntax
source code into a series of |SPLAT_IST| nodes in the Inter tree, with one
such node for each different directive in the I6T source.

The T in "I6T" stands for "template", which in the 2010s was a mechanism for
providing I6 code to I7. That's not the arrangement any more, but the syntax
(mostly) lives on, and so does the name I6T. Still, it's really just the same
thing as Inform 6 code in an Inweb-style literate programming notation.

=
void ParsingStages::create_pipeline_stage(void) {
	ParsingPipelines::new_stage(I"load-kit-source", ParsingStages::run_load_kit_source,
		TEMPLATE_FILE_STAGE_ARG, TRUE);	
	ParsingPipelines::new_stage(I"parse-insertions", ParsingStages::run_parse_insertions,
		NO_STAGE_ARG, FALSE);
}

@ The stage |load-kit-source K| takes the kit |K|, looks for its source code
(text files written in I6T syntax) and reads this in to the current Inter tree,
placing the resulting nodes in a new top-level module.

=
int ParsingStages::run_load_kit_source(pipeline_step *step) {
	inter_tree *I = step->ephemera.repository;
	inter_package *main_package = Site::main_package_if_it_exists(I);
	if (main_package) @<Create a module to hold the Inter read in from this kit@>;
	simple_tangle_docket docket;
	@<Make a suitable simple tangler docket@>;
	SimpleTangler::tangle_web(&docket);
	return TRUE;
}

@ So for example if we are reading the source for WorldModelKit, then the
following creates the package |/main/WorldModelKit|, with package type |_module|.
It's into this module that the resulting |SPLAT_IST| nodes will be put.

@<Create a module to hold the Inter read in from this kit@> =
	inter_bookmark IBM = Inter::Bookmarks::at_end_of_this_package(main_package);
	inter_symbol *module_name = PackageTypes::get(I, I"_module");
	inter_package *template_p = NULL;
	Inter::Package::new_package_named(&IBM, step->step_argument, FALSE,
		module_name, 1, NULL, &template_p);
	Site::set_assimilation_package(I, template_p);

@ The stage |parse-insertions| does the same thing, but on a much smaller scale,
and reading raw I6T source code from |LINK_IST| nodes in the Inter tree rather
than from an external file. There will only be a few of these, and with not much
code in them, when the tree has been compiled by Inform: they arise from
features such as
= (text as Inform 7)
Include (-
	[ CuriousFunction;
		print "Curious!";
	];
-).
=
The //inform7// code does not contain a compiler from I6T down to Inter, so
it can only leave us these unparsed fragments as |LINK_IST| nodes. We take
it from there.

=
int ParsingStages::run_parse_insertions(pipeline_step *step) {
	inter_tree *I = step->ephemera.repository;
	simple_tangle_docket docket;
	@<Make a suitable simple tangler docket@>;
	InterTree::traverse(I, ParsingStages::visit_insertions, &docket, NULL, LINK_IST);
	return TRUE;
}

void ParsingStages::visit_insertions(inter_tree *I, inter_tree_node *P, void *state) {
	text_stream *insertion = Inode::ID_to_text(P, P->W.data[TO_RAW_LINK_IFLD]);
	#ifdef CORE_MODULE
	current_sentence = (parse_node *) Inode::ID_to_ref(P, P->W.data[REF_LINK_IFLD]);
	#endif
	simple_tangle_docket *docket = (simple_tangle_docket *) state;
	SimpleTangler::tangle_text(docket, insertion);
}

@ So, then, both of those stages rely on making something called an simple
tangler docket, which is really just a collection of settings for the
simple tangler. That comes down to:

(a) the place to put any nodes generated,
(b) what to do with I6 source code, or with commands embedded in it, or errors
thrown by bad syntax in it, and
(c) which file-system paths to look inside when reading from files rather
than raw text in memory.

For (c), note that if a kit is in directory |K| then its source files are
in |K/Sections|.

@<Make a suitable simple tangler docket@> =
	inter_package *assimilation_package = Site::ensure_assimilation_package(I,
		RunningPipelines::get_symbol(step, plain_ptype_RPSYM));
	inter_bookmark assimilation_point =
		Inter::Bookmarks::at_end_of_this_package(assimilation_package);
	docket = SimpleTangler::new_docket(
		&(ParsingStages::receive_raw),
		&(ParsingStages::receive_command),
		&(ParsingStages::receive_bplus),
		&(PipelineErrors::kit_error),
		step->ephemera.the_kit, &assimilation_point);

@ Once the I6T reader has unpacked the literate-programming notation, it will
reduce the I6T code to pure Inform 6 source together with (perhaps) a handful of
commands in braces. Our docket must say what to do with each of these outputs.

The easy part: what to do when we find a command in I6T source. In pre-Inter
versions of Inform, when I6T was just a way of expressing Inform 6 code but
with some braced commands mixed in, there were lots of legal if enigmatic
syntaxes in use. Now those have all gone, so in all cases we issue an error:

=
void ParsingStages::receive_command(OUTPUT_STREAM, text_stream *command,
	text_stream *argument, simple_tangle_docket *docket) {
	if ((Str::eq_wide_string(command, L"plugin")) ||
		(Str::eq_wide_string(command, L"type")) ||
		(Str::eq_wide_string(command, L"open-file")) ||
		(Str::eq_wide_string(command, L"close-file")) ||
		(Str::eq_wide_string(command, L"lines")) ||
		(Str::eq_wide_string(command, L"endlines")) ||
		(Str::eq_wide_string(command, L"open-index")) ||
		(Str::eq_wide_string(command, L"close-index")) ||
		(Str::eq_wide_string(command, L"index-page")) ||
		(Str::eq_wide_string(command, L"index-element")) ||
		(Str::eq_wide_string(command, L"index")) ||
		(Str::eq_wide_string(command, L"log")) ||
		(Str::eq_wide_string(command, L"log-phase")) ||
		(Str::eq_wide_string(command, L"progress-stage")) ||
		(Str::eq_wide_string(command, L"counter")) ||
		(Str::eq_wide_string(command, L"value")) ||
		(Str::eq_wide_string(command, L"read-assertions")) ||
		(Str::eq_wide_string(command, L"callv")) ||
		(Str::eq_wide_string(command, L"call")) ||
		(Str::eq_wide_string(command, L"array")) ||
		(Str::eq_wide_string(command, L"marker")) ||
		(Str::eq_wide_string(command, L"testing-routine")) ||
		(Str::eq_wide_string(command, L"testing-command"))) {
		LOG("command: <%S> argument: <%S>\n", command, argument);
		(*(docket->error_callback))(
			"the template command '{-%S}' has been withdrawn in this version of Inform",
			command);
	} else {
		LOG("command: <%S> argument: <%S>\n", command, argument);
		(*(docket->error_callback))("no such {-command} as '%S'", command);
	}
}

@ We have similarly withdrawn the ability to write |(+| ... |+)| material
in kit files:

=
void ParsingStages::receive_bplus(text_stream *material, simple_tangle_docket *docket) {
	(*(docket->error_callback))(
		"use of (+ ... +) in kit source has been withdrawn: '%S'", material);
}

@ We very much do not ignore the raw I6 code read in, though. When the reader
gives us a chunk of this, we parse through it with a simple finite-state machine.
This can be summarised as "divide the code up at |;| boundaries, sending each
piece in turn to //ParsingStages::splat//". But of course we do not want to
react to semicolons in quoted text or comments, and in fact we also do not
want to react to semicolons used as statement dividers inside I6 routines (i.e.,
functions). So for example
= (text as Inform 6)
Global aspic = "this; and that";
! Don't react to this; I'm only a comment
[ Hello; print "Hello; goodbye.^"; ];
=
would be divided into just two splats,
= (text as Inform 6)
Global aspic = "this; and that";
=
and
= (text as Inform 6)
[ Hello; print "Hello; goodbye.^"; ];
=
(And the comment would be stripped out entirely.)

@d IGNORE_WS_I6TBIT 1
@d DQUOTED_I6TBIT 2
@d SQUOTED_I6TBIT 4
@d COMMENTED_I6TBIT 8
@d ROUTINED_I6TBIT 16
@d CONTENT_ON_LINE_I6TBIT 32

@d SUBORDINATE_I6TBITS
	(COMMENTED_I6TBIT + SQUOTED_I6TBIT + DQUOTED_I6TBIT + ROUTINED_I6TBIT)

=
void ParsingStages::receive_raw(text_stream *S, simple_tangle_docket *docket) {
	text_stream *R = Str::new();
	int mode = IGNORE_WS_I6TBIT;
	LOOP_THROUGH_TEXT(pos, S) {
		wchar_t c = Str::get(pos);
		if ((c == 10) || (c == 13)) c = '\n';
		if (mode & IGNORE_WS_I6TBIT) {
			if ((c == '\n') || (Characters::is_whitespace(c))) continue;
			mode -= IGNORE_WS_I6TBIT;
		}
		if ((c == '!') && (!(mode & (DQUOTED_I6TBIT + SQUOTED_I6TBIT)))) {
			mode = mode | COMMENTED_I6TBIT;
		}
		if (mode & COMMENTED_I6TBIT) {
			if (c == '\n') {
				mode -= COMMENTED_I6TBIT;
				if (!(mode & CONTENT_ON_LINE_I6TBIT)) continue;
			}
			else continue;
		}
		if ((c == '[') && (!(mode & SUBORDINATE_I6TBITS))) {
			mode = mode | ROUTINED_I6TBIT;
		}
		if (mode & ROUTINED_I6TBIT) {
			if ((c == ']') && (!(mode & (DQUOTED_I6TBIT + SQUOTED_I6TBIT + COMMENTED_I6TBIT))))
				mode -= ROUTINED_I6TBIT;
		}
		if ((c == '\'') && (!(mode & (DQUOTED_I6TBIT + COMMENTED_I6TBIT)))) {
			if (mode & SQUOTED_I6TBIT) mode -= SQUOTED_I6TBIT;
			else mode = mode | SQUOTED_I6TBIT;
		}
		if ((c == '\"') && (!(mode & (SQUOTED_I6TBIT + COMMENTED_I6TBIT)))) {
			if (mode & DQUOTED_I6TBIT) mode -= DQUOTED_I6TBIT;
			else mode = mode | DQUOTED_I6TBIT;
		}
		if (c != '\n') {
			if (Characters::is_whitespace(c) == FALSE)
				mode = mode | CONTENT_ON_LINE_I6TBIT;
		} else {
			if (mode & CONTENT_ON_LINE_I6TBIT) mode = mode - CONTENT_ON_LINE_I6TBIT;
			else if (!(mode & SUBORDINATE_I6TBITS)) continue;
		}
		PUT_TO(R, c);
		if ((c == ';') && (!(mode & SUBORDINATE_I6TBITS))) {
			ParsingStages::splat(R, docket);
			mode = IGNORE_WS_I6TBIT;
		}
	}
	ParsingStages::splat(R, docket);
	Str::clear(S);
}

@ Each of those "splats" becomes a |SPLAT_IST| node in the tree at the
current insertion point recorded in the state being carried in the docket.

Note that this function empties the splat buffer |R| before exiting.

=
void ParsingStages::splat(text_stream *R, simple_tangle_docket *docket) {
	if (Str::len(R) > 0) {
		inter_bookmark *IBM = (inter_bookmark *) docket->state;
		PUT_TO(R, '\n');
		inter_ti SID = Inter::Warehouse::create_text(
			Inter::Bookmarks::warehouse(IBM), Inter::Bookmarks::package(IBM));
		text_stream *textual_storage =
			Inter::Warehouse::get_text(Inter::Bookmarks::warehouse(IBM), SID);
		Str::copy(textual_storage, R);
		Produce::guard(Inter::Splat::new(IBM, SID, 0,
			(inter_ti) (Inter::Bookmarks::baseline(IBM) + 1), 0, NULL));
		Str::clear(R);
	}
}

@ And that's it: the result of these stages is just to break the I6T source they
found up into individual directives, and put them into the tree as |SPLAT_IST| nodes.
No effort has been made yet to see what directives they are. Subsequent stages
will handle that.
