[Problems::] Problems, Level 2.

To assemble and format problem messages within the problem buffer.

@ Problem messages begin with an indication of where in the source text the
problem occurs, in terms of headings and subheadings written in the
source text, and it is this indication that we consider first. For
example,

>> In Part the First, Chapter 1 - Attic Area:

There can be up to 10 levels in the hierarchy of headings and
subheadings, with level 0 the top level and level 9 the lowest.

When we need to issue a problem at sentence |S|, we work out what the
current heading is (if any) at each of the 10 levels. We do this by
trekking right through the whole linked list of sentences until we reach
|S|, changing the current headings whenever we pass one. This sounds
inefficient, but of course few problems are issued, and in any case we
cannot optimise by simply cacheing the heading level from one problem to
the next because it is not true that problems are always issued in source
code order.

@default NO_HEADING_LEVELS 10

=
void Problems::find_headings_at(parse_node_tree *T, parse_node *sentence, parse_node **problem_headings) {
	for (int i=0; i<NO_HEADING_LEVELS; i++) problem_headings[i] = NULL;
	if (sentence == NULL) return;
	ParseTree::traverse_ppn_nocs(T, Problems::visit_for_headings, &sentence);
	parse_node *p = ParseTree::get_problem_falls_under(sentence);
	while (p) {
		int L = ParseTree::int_annotation(p, heading_level_ANNOT);
		problem_headings[L] = p;
		p = ParseTree::get_problem_falls_under(p);
	}
}

int Problems::visit_for_headings(parse_node *p, parse_node *from, parse_node **sentence) {
	if (p == *sentence) {
		ParseTree::set_problem_falls_under(p, from);
		return TRUE;
	}
	if (ParseTree::get_type(p) == HEADING_NT) {
		ParseTree::set_problem_falls_under(p, from);
	}
	return FALSE;
}

@ A further refinement is that we remember the last set of headings used
for an error message, and only mention what has changed about the location.
Thus we might next print:

>> In Chapter 2 - Cellar Area:

omitting to mention "Part the First" this time, since that part has not
changed. (And we never print internally made level 0, File, headings.)

=
parse_node *last_problem_headings[NO_HEADING_LEVELS];

@ Now for the actual displaying of the location text. The outcome image
is a trickier thing to get right than might appear. By being in this
routine, we know that a problem has been issued: the run will therefore
not have been a success, and we can issue the "Inform failed" outcome
image. A success image cannot be placed until right at the end of the
run, when all possibility of problems has been passed: so there's no
single point in Inform where a single line of code could choose between
the two possibilities.

=
int	do_not_locate_problems = FALSE;

void Problems::show_problem_location(parse_node_tree *T) {
	parse_node *problem_headings[NO_HEADING_LEVELS];
	int i, f = FALSE;
	if (problem_count == 0) {
		#ifdef CORE_MODULE
		if (Problems::Issue::internal_errors_have_occurred())
			HTMLFiles::html_outcome_image(problems_file, "ni_failed_badly", "Failed");
		else
			HTMLFiles::html_outcome_image(problems_file, "ni_failed", "Failed");
		#endif
		for (i=0; i<NO_HEADING_LEVELS; i++) last_problem_headings[i] = NULL;
	}
	if (do_not_locate_problems) return;
	Problems::find_headings_at(T, current_sentence, problem_headings);
	for (i=0; i<NO_HEADING_LEVELS; i++) if (problem_headings[i] != NULL) f = TRUE;
	if (f)
		for (i=1; i<NO_HEADING_LEVELS; i++)
			if (last_problem_headings[i] != problem_headings[i]) {
				@<Print the heading position@>;
				break;
			}
	for (i=0; i<NO_HEADING_LEVELS; i++) last_problem_headings[i] = problem_headings[i];
}

@ We print only the part of the heading position which differs from that
of the previous one quoted: |i| is at this point the highest level at
which they differ.

@<Print the heading position@> =
	source_file *pos = NULL;
	Problems::Buffer::clear();
	if (problem_count > 0) WRITE_TO(PBUFF, ">---> ");
	WRITE_TO(PBUFF, "In");
	for (f=FALSE; i<NO_HEADING_LEVELS; i++)
		if (problem_headings[i] != NULL) {
			wording W = ParseTree::get_text(problem_headings[i]);
			#ifdef SUPERVISOR_MODULE
			W = Headings::get_text(Headings::from_node(problem_headings[i]));
			#endif
			pos = Lexer::file_of_origin(Wordings::first_wn(W));
			if (f) WRITE_TO(PBUFF, ", ");
			else WRITE_TO(PBUFF, " ");
			f = TRUE;
			Problems::Buffer::copy_text_into_problem_buffer(W);
		}
	if (f == FALSE) WRITE_TO(PBUFF, " the main source text");
	if (pos) {
		#ifdef SUPERVISOR_MODULE
		inform_extension *E = Extensions::corresponding_to(pos);
		if (E) WRITE_TO(PBUFF, " in the extension %X", E->as_copy->edition->work);
		#endif
	}
	WRITE_TO(PBUFF, ":");
	Problems::Buffer::output_problem_buffer(0);
	Problems::Buffer::clear();

@h Problem quotations.
Problem messages are printed using a printf-like formatting system.
Unlike printf, though, where |%s| means a string and |%d| a number, here
the escape codes do not indicate the type of the data: they are simply
|%1|, |%2|, |%3|, ..., |%9|. This is to prevent horrendous crashes when
type mismatches occur: using a pointer to a phrase when trying to print a
source code reference, for instance.

The texts to be substituted in place of |%1|, |%2|, ..., are called the
"quotations". The value is either a range of words in the source text, or
else a pointer to some data structure, depending on the type. The type is a
single character code. (This coding system is used only here, and could
easily be changed, but there seems no reason to.)

The type codes are S(ource), W(ords), B(inary predicate), E(xtension),
(p)H(rase), I(nvocation), N(umber), O(bject), P(roperty name), T(ext),
(t)Y(pe specification).

=
typedef struct problem_quotation {
	char quotation_type; /* one of the above */
	int wording_based; /* which of the following: */
	void *structure_quoted; /* if false */
	void (*expander)(text_stream *, void *); /* if false */
	struct wording text_quoted; /* if true */
} problem_quotation;

problem_quotation problem_quotations[10];

@ When some higher-level part of Inform wants to issue a formatted problem
message, it first declares the contents of any quotations it will make.
It does this using the routines |Problems::quote_object|, |Problems::quote_spec|, ...
below. Thus |Problems::quote_spec(2, SP)| specifies that |%2| should be
printed as the inference |SP|.

=
void Problems::problem_quote(int t, void *v, void (*f)(text_stream *, void *)) {
	if ((t<0) || (t > 10)) internal_error("problem quotation number out of range");
	problem_quotations[t].structure_quoted = v;
	problem_quotations[t].expander = f;
	problem_quotations[t].quotation_type = '?';
	problem_quotations[t].wording_based = FALSE;
	problem_quotations[t].text_quoted = EMPTY_WORDING;
}

void Problems::problem_quote_textual(int t, char type, wording W) {
	if ((t<0) || (t > 10)) internal_error("problem quotation number out of range");
	problem_quotations[t].structure_quoted = NULL;
	problem_quotations[t].quotation_type = type;
	problem_quotations[t].wording_based = TRUE;
	problem_quotations[t].text_quoted = W;
}

@ Here are the three public routines for quoting from text: either via a node
in the parse tree, or with a literal word range.

=
void Problems::quote_source(int t, parse_node *p) {
	if (p == NULL) Problems::problem_quote_textual(t, 'S', EMPTY_WORDING);
	else Problems::quote_wording_as_source(t, ParseTree::get_text(p));
}
void Problems::quote_source_eliding_begin(int t, parse_node *p) {
	if (p == NULL) Problems::problem_quote_textual(t, 'S', EMPTY_WORDING);
	else {
		wording W = ParseTree::get_text(p);
		#ifdef CORE_MODULE
		if (<phrase-beginning-block>(W)) W = GET_RW(<phrase-beginning-block>, 1);
		#endif
		Problems::problem_quote_textual(t, 'S', W);
	}
}
void Problems::quote_wording(int t, wording W) { Problems::problem_quote_textual(t, 'W', W); }
void Problems::quote_wording_tinted_green(int t, wording W) { Problems::problem_quote_textual(t, 'g', W); }
void Problems::quote_wording_tinted_red(int t, wording W) { Problems::problem_quote_textual(t, 'r', W); }
void Problems::quote_wording_as_source(int t, wording W) { Problems::problem_quote_textual(t, 'S', W); }

void Problems::quote_text(int t, char *p) {
	Problems::problem_quote(t, (void *) p, Problems::expand_text);
}
void Problems::expand_text(OUTPUT_STREAM, void *p) {
	WRITE("%s", (char *) p);
}
void Problems::quote_wide_text(int t, wchar_t *p) {
	Problems::problem_quote(t, (void *) p, Problems::expand_wide_text);
}
void Problems::expand_wide_text(OUTPUT_STREAM, void *p) {
	WRITE("%w", (wchar_t *) p);
}
void Problems::quote_stream(int t, text_stream *p) {
	Problems::problem_quote(t, (void *) p, Problems::expand_stream);
}
void Problems::expand_stream(OUTPUT_STREAM, void *p) {
	WRITE("%S", (text_stream *) p);
}
void Problems::quote_wa(int t, word_assemblage *p) {
	Problems::problem_quote(t, (void *) p, Problems::expand_wa);
}
void Problems::expand_wa(OUTPUT_STREAM, void *p) {
	WRITE("%A", (word_assemblage *) p);
}

void Problems::expand_text_within_reason(OUTPUT_STREAM, wording W) {
	W = Wordings::truncate(W, QUOTATION_TOLERANCE_LIMIT);
	WRITE("%<W", W);
}

void Problems::quote_number(int t, int *p) {
	Problems::problem_quote(t, (void *) p, Problems::expand_number);
}
void Problems::expand_number(OUTPUT_STREAM, void *p) {
	WRITE("%d", *((int *) p));
}

@h Short and long forms.
Most of the error messages have a short form, giving the main factual
information, and a long form which also has an explanation attached.
Some of the text is common to both versions, but other parts are specific
to either one or the other, and variables record the status of our current
position in scanning and transcribing the problem message.

=
int shorten_problem_message; /* give short form of this previously-seen problem */
int reading_text_specific_to_short_version; /* modes during problem message writing */
int reading_text_specific_to_long_version;

@ We do not want to keep wittering on with the same old explanations,
so we remember which ones we've given before (i.e., in previous problem
messages during the same run of Inform). Eventually our patience is exhausted
and we give no further explanation in any circumstances.

@d PATIENCE_EXHAUSTION_POINT 100

=
char *explanations[PATIENCE_EXHAUSTION_POINT];
int no_explanations = 0;

int Problems::explained_before(char *explanation) {
	int i;
	if (no_explanations == PATIENCE_EXHAUSTION_POINT) return TRUE;
	for (i=0; i<no_explanations; i++)
		if (explanation == explanations[i]) return TRUE;
	explanations[no_explanations++] = explanation;
	return FALSE;
}

@h How problems begin and end.
During the construction of a problem message, we will be running through a
standard text, and at any point might be considering matter which should
appear only in the long form, or only in the short form.

If the text of a message begins with an asterisk, then it is a
continuation of a message already partly issued. Otherwise we can
sensibly find out whether this is one we've seen before. Either way, we
set |shorten_problem_message| to remember whether to use the short or long
form.

=
void Problems::issue_problem_begin(parse_node_tree *T, char *message) {
	Problems::Buffer::clear();
	if (strcmp(message, "*") == 0) {
		WRITE_TO(PBUFF, ">++>");
		shorten_problem_message = FALSE;
	} else if (strcmp(message, "****") == 0) {
		WRITE_TO(PBUFF, ">++++>");
		shorten_problem_message = FALSE;
	} else if (strcmp(message, "***") == 0) {
		WRITE_TO(PBUFF, ">+++>");
		shorten_problem_message = FALSE;
	} else if (strcmp(message, "**") == 0) {
		shorten_problem_message = FALSE;
	} else {
		if (T) Problems::show_problem_location(T);
		problem_count++;
		WRITE_TO(PBUFF, ">--> ");
		shorten_problem_message = Problems::explained_before(message);
	}
	reading_text_specific_to_short_version = FALSE;
	reading_text_specific_to_long_version = FALSE;
}

void Problems::issue_problem_end(void) {
	#ifdef CORE_MODULE
	if (compiling_text_routines_mode) Strings::TextSubstitutions::append_text_substitution_proviso();
	#endif
	Problems::Buffer::output_problem_buffer(1);
	Problems::Issue::problem_documentation_links(problems_file);
	if (crash_on_all_errors) Problems::Fatal::force_crash();
}

@h Appending source.

=
wording appended_source = EMPTY_WORDING;
void Problems::append_source(wording W) {
	appended_source = W;
}
void Problems::transcribe_appended_source(void) {
	if (Wordings::nonempty(appended_source))
		Problems::Buffer::copy_source_reference_into_problem_buffer(appended_source);
}

@h Issuing a segment of a problem message.
Here is the routine which performs the substitution of quotations into
problem messages and sends them on their way: which is called
|Problems::issue_problem_segment| since it only appends a further piece of text, and may
be used several times to build up complicated messages.

We have seen that, within problem message texts, the escapes |%1| to |%9|
are to produce quotations. Four further escape codes switch between problem
message versions, as follows: we have |%L|, which indicates that the text
which follows should only be used in the long form of the error message;
|%S|, the same for the short form; |%%|, which cancels either of these
settings and restores the text to appearing in both forms, which is the
default. A percentage sign followed by a vertical stroke acts more simply
as a divider between the brief message and the explanation text in many
simple problem messages which do not use the elaborations of the other
three escapes.

=
void Problems::issue_problem_segment(char *message) {
	for (int i=0; message[i]; i++) {
		if (message[i] == '%') {
			switch (message[i+1]) {
				case 'L': reading_text_specific_to_long_version = TRUE; i++; continue;
				case 'S': reading_text_specific_to_short_version = TRUE; i++; continue;
				case '%': reading_text_specific_to_short_version = FALSE;
					reading_text_specific_to_long_version = FALSE; i++; continue;
				case '|': reading_text_specific_to_short_version = FALSE;
					reading_text_specific_to_long_version = TRUE;
					if (shorten_problem_message) WRITE_TO(PBUFF, ".");
					i++; continue;
			}
		}

		if ((reading_text_specific_to_short_version) &&
			(shorten_problem_message == FALSE)) continue;
		if ((reading_text_specific_to_long_version) &&
			(shorten_problem_message == TRUE)) continue;

		@<Act on the problem message text, since it is now contextually allowed@>;
	}
}

@ Ordinarily we just append the new character, but we also act on the escapes
|%P| and |%1| to |%9|. |%P| forces a paragraph break, or at any rate, it does
in the eventual HTML version of the problem message. Note that these escapes
are acted on only if they occur in a contextually allowed part of the problem
message (e.g., if they occur in the short form only, they will only be acted
on when the shortened form is the one being issued).

@<Act on the problem message text, since it is now contextually allowed@> =
	if (message[i] == '%') {
		switch (message[i+1]) {
			case 'P': PUT_TO(PBUFF, FORCE_NEW_PARA_CHAR);
				i++; continue;
		}
		if (Characters::isdigit(message[i+1])) {
			int t = ((int) (message[i+1]))-((int) '0'); i++;
			if ((t>=1) && (t<=9)) {
				if (problem_quotations[t].wording_based)
					@<Expand wording-based escape@>
				else
					@<Expand structure-based escape@>
			}
			continue;
		}
	}
	PUT_TO(PBUFF, message[i]);

@ This is where a quotation escape, such as |%2|, is expanded: by looking up
its type, stored internally as a single character.

@<Expand wording-based escape@> =
	switch(problem_quotations[t].quotation_type) {
		/* Monochrome wording */
		case 'S': Problems::Buffer::copy_source_reference_into_problem_buffer(
				problem_quotations[t].text_quoted);
			break;
		case 'W': Problems::Buffer::copy_text_into_problem_buffer(
				problem_quotations[t].text_quoted);
			break;

		/* Tinted wording */
		case 'r': @<Quote a red-tinted word range in a problem message@>;
			break;
		case 'g': @<Quote a green-tinted word range in a problem message@>;
			break;
		default: internal_error("unknown error token type");
	}

@ Tinting text involves some HTML, of course:

@<Quote a red-tinted word range in a problem message@> =
	TEMPORARY_TEXT(OUT);
	HTML::begin_colour(OUT, I"800000");
	WRITE("%W", problem_quotations[t].text_quoted);
	HTML::end_colour(OUT);
	@<Spool temporary stream text to the problem buffer@>;
	DISCARD_TEXT(OUT);

@ And:

@<Quote a green-tinted word range in a problem message@> =
	TEMPORARY_TEXT(OUT);
	HTML::begin_colour(OUT, I"008000");
	WRITE("%W", problem_quotations[t].text_quoted);
	HTML::end_colour(OUT);
	@<Spool temporary stream text to the problem buffer@>;
	DISCARD_TEXT(OUT);

@ More generally, the reference is to some structure we can't write
ourselves, and must delegate to:

@<Expand structure-based escape@> =
	Problems::append_source(EMPTY_WORDING);
	TEMPORARY_TEXT(OUT);
	(problem_quotations[t].expander)(OUT, problem_quotations[t].structure_quoted);
	@<Spool temporary stream text to the problem buffer@>;
	DISCARD_TEXT(OUT);
	Problems::transcribe_appended_source();

@<Spool temporary stream text to the problem buffer@> =
	LOOP_THROUGH_TEXT(pos, OUT) {
		wchar_t c = Str::get(pos);
		if (c == '<') c = PROTECTED_LT_CHAR;
		if (c == '>') c = PROTECTED_GT_CHAR;
		PUT_TO(PBUFF, c);
	}

@ This version is much shorter, since escapes aren't allowed:

=
void Problems::issue_problem_segment_from_stream(text_stream *message) {
	WRITE_TO(PBUFF, "%S", message);
}

@h Problems report and index.
That gives us enough infrastructure to produce the final report. Note the use
of error redirection to in order to put pseudo-problem messages -- actually
informational -- into the report. In the case where the run was successful and
there we no Problem messages, we have to be careful to reset |problem_count|
-- it will have been increased by the issuing of these pseudo-problems, and we
need it to remain 0 so that |main()| can finally return back to the operating
system without an error code.

=
int tail_of_report_written = FALSE;
void Problems::write_reports(int disaster_struck) {
	if (tail_of_report_written) return;
	tail_of_report_written = TRUE;

	crash_on_all_errors = FALSE;
	#ifdef PROBLEMS_FINAL_REPORTER
	int pc = problem_count;
	PROBLEMS_FINAL_REPORTER(disaster_struck, problem_count);
	problem_count = pc;
	#endif
	HTML::end_body(problems_file);
}
