[InterNames::] Inter Namespace.

To manage identifiers, which have names and positions in the Inter hierarchy.

@h Families.
Each inter name comes from a "generator". Some are one-shot, and produce just
one name before being discarded; others produce a numbered sequence of names
in a given pattern, counting upwards from 1 (|example_1|, |example_2|, ...);
and others still derive new names from existing ones (for example, turning
|fish| and |rumour| into |fishmonger| and |rumourmonger|).

@e UNIQUE_INGEN from 1
@e MULTIPLE_INGEN
@e DERIVED_INGEN

=
typedef struct inter_name_generator {
	int ingen;
	struct text_stream *name_stem;
	int no_generated; /* relevamt only for |MULTIPLE_INGEN| */
	struct text_stream *derived_prefix; /* relevamt only for |DERIVED_INGEN| */
	struct text_stream *derived_suffix; /* relevamt only for |DERIVED_INGEN| */
} inter_name_generator;

inter_name_generator *InterNames::single_use_generator(text_stream *name) {
	inter_name_generator *F = CREATE(inter_name_generator);
	F->ingen = UNIQUE_INGEN;
	F->name_stem = Str::duplicate(name);
	F->derived_prefix = NULL;
	return F;
}

inter_name_generator *InterNames::multiple_use_generator(text_stream *prefix, text_stream *stem, text_stream *suffix) {
	inter_name_generator *gen = InterNames::single_use_generator(stem);
	if (Str::len(prefix) > 0) {
		gen->ingen = DERIVED_INGEN;
		gen->derived_prefix = Str::duplicate(prefix);
	} else if (Str::len(suffix) > 0) {
		gen->ingen = DERIVED_INGEN;
		gen->derived_suffix = Str::duplicate(suffix);
	} else gen->ingen = MULTIPLE_INGEN;
	return gen;
}

@h Printing inames.
Inter names are stored not in textual form, but in terms of what would be
required to generate that text. (The memo field, which in principle allows
any text to be stored, is used only for a small proportion of inames.)

=
typedef struct inter_name {
	struct inter_name_generator *generated_by;
	int unique_number;
	struct inter_symbol *symbol;
	struct package_request *location_in_hierarchy;
	struct text_stream *memo;
	struct inter_name *derived_from;
} inter_name;

@ This implements the |%n| escape, which prints an iname:

=
void InterNames::writer(OUTPUT_STREAM, char *format_string, void *vI) {
	inter_name *iname = (inter_name *) vI;
	if (iname == NULL) WRITE("<no-inter-name>");
	else {
		if (iname->generated_by == NULL) internal_error("bad inter_name");
		switch (iname->generated_by->ingen) {
			case DERIVED_INGEN:
				WRITE("%S", iname->generated_by->derived_prefix);
				InterNames::writer(OUT, format_string, iname->derived_from);
				WRITE("%S", iname->generated_by->derived_suffix);
				break;
			case UNIQUE_INGEN:
				WRITE("%S", iname->generated_by->name_stem);
				break;
			case MULTIPLE_INGEN:
				WRITE("%S", iname->generated_by->name_stem);
				if (iname->unique_number >= 0) WRITE("%d", iname->unique_number);
				break;
			default: internal_error("unknown ingen");
		}
		if (Str::len(iname->memo) > 0) WRITE("_%S", iname->memo);
	}
}

@h Making new inames.
We can now make a new iname, which is easy unless there's a memo to attach.
For example, attaching the wording "printing the name of a dark room" to
an iname which would otherwise just be |V12| produces |V12_printing_the_name_of_a_da|.
Memos exist largely to make the Inter code easier for human eyes to read,
as in this case, but sometimes, as with kind names like |K2_thing|, they're
needed because template or explicit I6 inclusion code makes references to them.

Although most inter names are eventually used to create symbols in the
Inter hierarchy's symbols table, this does not happen immediately, and
for some inames it never will.

=
inter_name *InterNames::new(inter_name_generator *F, package_request *R, wording W) {
	inter_name *iname = CREATE(inter_name);
	iname->generated_by = F;
	iname->unique_number = 0;
	iname->symbol = NULL;
	iname->derived_from = NULL;
	iname->location_in_hierarchy = R;
	if (Wordings::empty(W)) {
		iname->memo = NULL;
	} else {
		iname->memo = Str::new();
		@<Fill the memo with up to 28 characters of text from the given wording@>;
		@<Ensure that the name, as now extended by the memo, is a legal Inter identifier@>;
	}
	return iname;
}

@<Fill the memo with up to 28 characters of text from the given wording@> =
	int c = 0;
	LOOP_THROUGH_WORDING(j, W) {
		/* identifier is at this point 32 chars or fewer in length: add at most 30 more */
		if (c++ > 0) WRITE_TO(iname->memo, " ");
		if (Wide::len(Lexer::word_text(j)) > 30)
			WRITE_TO(iname->memo, "etc");
		else WRITE_TO(iname->memo, "%N", j);
		if (Str::len(iname->memo) > 32) break;
	}
	Str::truncate(iname->memo, 28); /* it was at worst 62 chars in size, but is now truncated to 28 */

@<Ensure that the name, as now extended by the memo, is a legal Inter identifier@> =
	Identifiers::purify(iname->memo);
	TEMPORARY_TEXT(NBUFF);
	WRITE_TO(NBUFF, "%n", iname);
	int L = Str::len(NBUFF);
	DISCARD_TEXT(NBUFF);
	if (L > 28) Str::truncate(iname->memo, Str::len(iname->memo) - (L - 28));

@ That creation function should be called only by these, which in turn must
be called only from within the current chapter. First, the single-shot cases,
where the caller wants a single name with fixed wording (but possibly with
a memo to attach):

=
inter_name *InterNames::explicitly_named_with_memo(text_stream *name, package_request *R, wording W) {
	return InterNames::new(InterNames::single_use_generator(name), R, W);
}

inter_name *InterNames::explicitly_named(text_stream *name, package_request *R) {
	return InterNames::explicitly_named_with_memo(name, R, EMPTY_WORDING);
}

inter_name *InterNames::explicitly_named_in_template(text_stream *name) {
	inter_name *iname = InterNames::explicitly_named(name, Hierarchy::template());
	packaging_state save = Packaging::enter_home_of(iname);		
	iname->symbol = Emit::extern(name, K_value);
	Packaging::exit(save);
	return iname;
}

@ Second, the generated or derived cases:

=
inter_name *InterNames::multiple(inter_name_generator *G, package_request *R, wording W) {
	if (G == NULL) internal_error("no generator");
	if (G->ingen == UNIQUE_INGEN) internal_error("not a generator name");
	inter_name *iname = InterNames::new(G, R, W);
	if (G->ingen != DERIVED_INGEN) iname->unique_number = ++G->no_generated;
	return iname;
}

inter_name *InterNames::generated_in(inter_name_generator *G, int fix, wording W, package_request *R) {
	inter_name *iname = InterNames::multiple(G, R, W);
	if (fix != -1) iname->unique_number = fix;
	return iname;
}

inter_name *InterNames::generated(inter_name_generator *G, int fix, wording W) {
	return InterNames::generated_in(G, fix, W, NULL);
}

inter_name *InterNames::derived(inter_name_generator *G, inter_name *from, wording W) {
	if (G->ingen != DERIVED_INGEN) internal_error("not a derived generator");
	inter_name *iname = InterNames::multiple(G, from->location_in_hierarchy, W);
	iname->derived_from = from;
	return iname;
}

@ Now that inames have been created, we allow their locations to be read:

=
package_request *InterNames::location(inter_name *iname) {
	if (iname == NULL) return NULL;
	return iname->location_in_hierarchy;
}

inter_symbols_table *InterNames::scope(inter_name *iname) {
	if (iname == NULL) internal_error("can't determine scope of null name");
	package_request *P = InterNames::location(iname);
	if (P == NULL) return Inter::get_global_symbols(Emit::tree());
	return Inter::Packages::scope(Packaging::incarnate(P));
}

@h Conversion of inames to symbols.
The purpose of inames is not quite to represent identifier names occurring in
given packages inside the Inter hierarchy: it would be more accurate to say
that they represent potential identifiers, which may or may not be used.
At some point they will probably (but not certainly) undergo "conversion",
when they are matched up with actual symbols in the symbols tables of the
given packages. An exception to this is that inames pointing to externally
defined resources in the template are never converted: see above.

Conversion is done on-demand, and thus left as late as possible. It happens
automatically here:

=
inter_symbol *InterNames::to_symbol(inter_name *iname) {
	if (iname->symbol == NULL) {
		TEMPORARY_TEXT(NBUFF);
		WRITE_TO(NBUFF, "%n", iname);
		inter_symbols_table *T = InterNames::scope(iname);
		iname->symbol = Emit::new_symbol(T, NBUFF);
		DISCARD_TEXT(NBUFF);
	}
	return iname->symbol;
}
