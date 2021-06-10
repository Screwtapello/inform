[TempLexicon::] Lexicon.

A lexicon for nouns, adjectives and verbs found in an Inter tree.

@ The lexicon is the part of the Index which gives an alphabetised list of
adjectives, nouns, verbs and other words which can be used in descriptions
of things: it's the nearest thing to an index of the meanings inside Inform.
This is in one sense quite an elaborate indexing mechanism, since it brings
together meanings relating to various different Inform structures under a single
umbrella, the "lexicon entry" structure:

@d NOUN_TLEXE 1 /* a kind */
@d PROPER_NOUN_TLEXE 2 /* an instance of "object" */
@d ADJECTIVAL_PHRASE_TLEXE 3 /* the subject of a "Definition:" */
@d ENUMERATED_CONSTANT_TLEXE 4 /* e.g., "green" if colour is a kind of value and green a colour */
@d VERB_TLEXE 5 /* an ordinary verb */
@d ABLE_VERB_TLEXE 6 /* a "to be able to..." verb */
@d PREP_TLEXE 7 /* a "to be upon..." sort of verb */
@d AVERB_TLEXE 8 /* an auxiliary verb */
@d MVERB_TLEXE 9 /* a meaningless verb */
@d MISCELLANEOUS_TLEXE 10 /* a connective, article or determiner */

@ We can set entries either to excerpts of words from the source, or to
any collation of up to 5 vocabulary entries.

=
typedef struct index_tlexicon_entry {
	struct wording wording_of_entry; /* either the text of the entry, or empty, in which case... */
	struct word_assemblage text_of_entry;

	int part_of_speech; /* one of those above */
	char *category; /* textual description of said, e.g., |"adjective"| */
	struct general_pointer entry_refers_to; /* depending on which part of speech */
	struct parse_node *verb_defined_at; /* sentence where defined (verbs only) */
	char *gloss_note; /* gloss on the definition, or |NULL| if none is provided */

	struct text_stream *reduced_to_lower_case; /* text converted to lower case for sorting */
	struct index_tlexicon_entry *sorted_next; /* next in lexicographic order */
	CLASS_DEFINITION
} index_tlexicon_entry;

@

= (early code)
index_tlexicon_entry *sorted_tlexicon = NULL; /* head of list in lexicographic order */
index_tlexicon_entry *current_tmain_verb = NULL; /* when parsing verb declarations */

@ Lexicon entries are created by the following routine:

=
index_tlexicon_entry *TempLexicon::lexicon_new_entry(wording W) {
	index_tlexicon_entry *lex = CREATE(index_tlexicon_entry);
	lex->wording_of_entry = W;
	lex->text_of_entry = WordAssemblages::lit_0();
	lex->part_of_speech = MISCELLANEOUS_TLEXE;
	lex->entry_refers_to = NULL_GENERAL_POINTER;
	lex->category = NULL; lex->gloss_note = NULL; lex->verb_defined_at = NULL;
	lex->reduced_to_lower_case = Str::new();
	return lex;
}

@ The next two routines provide higher-level creators for lexicon entries.
The |current_tmain_verb| setting is used to ensure that inflected forms of the
same verb are grouped together in the verbs table.

=
index_tlexicon_entry *TempLexicon::new_entry_with_details(wording W, int pos,
	word_assemblage wa, char *category, char *gloss) {
	index_tlexicon_entry *lex = TempLexicon::lexicon_new_entry(W);
	lex->part_of_speech = pos;
	lex->text_of_entry = wa;
	lex->category = category; lex->gloss_note = gloss;
	return lex;
}

index_tlexicon_entry *TempLexicon::new_main_verb(word_assemblage infinitive, int part) {
	index_tlexicon_entry *lex = TempLexicon::lexicon_new_entry(EMPTY_WORDING);
	lex->text_of_entry = infinitive;
	lex->part_of_speech = part;
	lex->category = "verb";
//	lex->verb_defined_at = current_sentence;
	current_tmain_verb = lex;
	return lex;
}

@ As we've seen, a lexicon entry's text can be either a word range or a
collection of vocabulary words, and it's therefore convenient to have a utility
routine which extracts the name in plain text from either source.

=
void TempLexicon::lexicon_copy_to_stream(index_tlexicon_entry *lex, text_stream *text) {
	if (Wordings::nonempty(lex->wording_of_entry))
		WRITE_TO(text, "%+W", lex->wording_of_entry);
	else
		WRITE_TO(text, "%A", &(lex->text_of_entry));
}

@h Producing the lexicon.
The lexicon is by no means empty when the following routine is called:
lexicon entries have already been created for verbs and determiners. But
it doesn't yet contain nouns or adjectives.

=
@<TempLexicon::index@> =
	@<Stock the lexicon with nouns from names of objects@>;
	@<Stock the lexicon with nouns from kinds of object@>;
	@<Stock the lexicon with adjectives from names of adjectival phrases@>;
	@<Stock the lexicon with nouns from named values@>;
	@<Stock the lexicon with meaningless verbs@>;
	@<Stock the lexicon with miscellaneous bits and pieces@>;

	@<Create lower-case forms of all lexicon entries@>;
	@<Sort the lexicon into alphabetical order@>;

	int common_nouns_only = FALSE;
	Index::anchor(OUT, I"LEXICON");
	@<Explanatory head-note at the top of the lexicon@>;
	@<Main body of the lexicon@>;
}

@ And here is a cut-down version which prints a lexicon of common nouns
only, for the foot of the World index.

=
@<TempLexicon::index_common_nouns@> =
	int common_nouns_only = TRUE;
	@<Main body of the lexicon@>;
}

@h Stocking the lexicon.

@<Stock the lexicon with nouns from names of objects@> =
	instance *I;
	LOOP_OVER_INSTANCES(I, K_object) {
		wording W = Instances::get_name(I, FALSE);
		if (Wordings::nonempty(W)) {
			index_tlexicon_entry *lex = TempLexicon::lexicon_new_entry(W);
			lex->part_of_speech = PROPER_NOUN_TLEXE;
			lex->category = "noun";
			lex->entry_refers_to = STORE_POINTER_instance(I);
		}
	}

@ Despite the implication of the over-cautious code below, kinds of object do
always have creation nodes -- i.e., their names always derive from the
source text.

@<Stock the lexicon with nouns from kinds of object@> =
	kind *K;
	LOOP_OVER_BASE_KINDS(K)
		if (Kinds::Behaviour::is_subkind_of_object(K)) {
			wording W = Kinds::Behaviour::get_name(K, FALSE);
			if (Wordings::nonempty(W)) {
				index_tlexicon_entry *lex = TempLexicon::lexicon_new_entry(W);
				lex->part_of_speech = NOUN_TLEXE;
				lex->category = "noun";
				lex->entry_refers_to = STORE_POINTER_kind(K);
			}
		}

@ These are adjectives set up by "Definition:".

@<Stock the lexicon with adjectives from names of adjectival phrases@> =
	index_tlexicon_entry *lex;
	adjective *adj;
	LOOP_OVER(adj, adjective) {
		wording W = Adjectives::get_nominative_singular(adj);
		if (Wordings::nonempty(W)) {
			lex = TempLexicon::lexicon_new_entry(W);
			lex->part_of_speech = ADJECTIVAL_PHRASE_TLEXE;
			lex->category = "adjective";
			lex->entry_refers_to = STORE_POINTER_adjective(adj);
		}
	}

@ The idea here is that if a new kind of value such as "colour" is created,
then its values should be indexed as nouns -- "red", "blue" and so
on. (Sometimes these will also be listed separately with an adjectival sense.)

@<Stock the lexicon with nouns from named values@> =
	index_tlexicon_entry *lex;
	instance *qn;
	LOOP_OVER(qn, instance)
		if (Kinds::Behaviour::is_an_enumeration(Instances::to_kind(qn))) {
			property *prn =
				Properties::property_with_same_name_as(Instances::to_kind(qn));
			if ((prn) && (ConditionsOfSubjects::of_what(prn))) continue;
			wording NW = Instances::get_name(qn, FALSE);
			lex = TempLexicon::lexicon_new_entry(NW);
			lex->part_of_speech = ENUMERATED_CONSTANT_TLEXE;
			lex->category = "noun";
			lex->entry_refers_to = STORE_POINTER_instance(qn);
		}

@<Stock the lexicon with meaningless verbs@> =
	verb_conjugation *vc;
	LOOP_OVER(vc, verb_conjugation)
		if ((vc->vc_conjugates == NULL) && (vc->auxiliary_only == FALSE) && (vc->instance_of_verb))
			TempLexicon::new_main_verb(vc->infinitive, MVERB_TLEXE);

@ It seems unfitting for a dictionary to omit "a", "an", "the", "some",
"which" or "who".

@<Stock the lexicon with miscellaneous bits and pieces@> =
	PreformUtilities::enter_lexicon(<indefinite-article>, MISCELLANEOUS_TLEXE,
		"indefinite article", NULL);
	PreformUtilities::enter_lexicon(<definite-article>, MISCELLANEOUS_TLEXE,
		"definite article", NULL);
	PreformUtilities::enter_lexicon(<rc-marker>, MISCELLANEOUS_TLEXE,
		"connective",
		"used to place a further condition on a description: like 'which' in "
		"'A which is B', or 'A which carries B', for instance.");

@h Processing the lexicon.
Before we can sort the lexicon, we need to turn its disparate forms of name
into a single, canonical, lower-case representation.

@<Create lower-case forms of all lexicon entries@> =
	index_tlexicon_entry *lex;
	LOOP_OVER(lex, index_tlexicon_entry) {
		TempLexicon::lexicon_copy_to_stream(lex, lex->reduced_to_lower_case);
		LOOP_THROUGH_TEXT(pos, lex->reduced_to_lower_case)
			Str::put(pos, Characters::tolower(Str::get(pos)));
	}

@ The lexicon is sorted by insertion sort, which is not ideally fast, but
which is convenient when dealing with linked lists: there are unlikely to be
more than 1000 or so entries, so the speed penalty for insertion rather
than (say) quicksort is not great.

@<Sort the lexicon into alphabetical order@> =
	index_tlexicon_entry *lex;
	LOOP_OVER(lex, index_tlexicon_entry) {
		index_tlexicon_entry *lex2, *last_lex;
		if (sorted_tlexicon == NULL) {
			sorted_tlexicon = lex; lex->sorted_next = NULL; continue;
		}
		for (last_lex = NULL, lex2 = sorted_tlexicon; lex2;
			last_lex = lex2, lex2 = lex2->sorted_next)
			if (Str::cmp(lex->reduced_to_lower_case, lex2->reduced_to_lower_case) < 0) {
				if (last_lex == NULL) sorted_tlexicon = lex;
				else last_lex->sorted_next = lex;
				lex->sorted_next = lex2; goto Inserted;
			}
		last_lex->sorted_next = lex; lex->sorted_next = NULL;
		Inserted: ;
	}

@h Printing the lexicon out in HTML format.

@<Explanatory head-note at the top of the lexicon@> =
	HTML_OPEN("p");
	HTML_OPEN_WITH("span", "class=\"smaller\"");
	WRITE("For instance, the description 'an unlocked door' is made "
		"up from the adjective 'unlocked' and the noun 'door', both of which "
		"can be found below. Property adjectives, like 'open', can be used "
		"when creating things - 'In the Ballroom is an open container' is "
		"allowed because 'open' is a property - but those with complicated "
		"definitions, like 'empty', can only be tested during play, e.g. "
		"with rules like 'Instead of taking an empty container, ...'.");
	HTML_CLOSE("span");
	HTML_CLOSE("p");

@ Now for the bulk of the work. Entries appear in CSS paragraphs with hanging
indentation and no interparagraph spacing, so we need to insert regular
paragraphs between the As and the Bs, then between the Bs and the Cs, and so
on. Each entry consists of the wording, then maybe some icons, then an
explanation of what it is: for instance,

>> player's holdall [icon]\quad {\it noun, a kind of} container

In a few cases, there is a further textual gloss to add.

@<Main body of the lexicon@> =
	index_tlexicon_entry *lex;
	wchar_t current_initial_letter = '?';
	int verb_count = 0, entry_count = 0, c;
	for (lex = sorted_tlexicon; lex; lex = lex->sorted_next)
		if (lex->part_of_speech == PROPER_NOUN_TLEXE)
			entry_count++;
	if (common_nouns_only) {
		HTML::begin_html_table(OUT, NULL, TRUE, 0, 0, 0, 0, 0);
		HTML::first_html_column(OUT, 0);
	}
	for (c = 0, lex = sorted_tlexicon; lex; lex = lex->sorted_next) {
		if (common_nouns_only) { if (lex->part_of_speech != PROPER_NOUN_TLEXE) continue; }
		else { if (lex->part_of_speech == PROPER_NOUN_TLEXE) continue; }
		if ((common_nouns_only) && (c == entry_count/2)) HTML::next_html_column(OUT, 0);
		if (current_initial_letter != Str::get_first_char(lex->reduced_to_lower_case)) {
			if (c > 0) { HTML_OPEN("p"); HTML_CLOSE("p"); }
			current_initial_letter = Str::get_first_char(lex->reduced_to_lower_case);
		}
		c++;
		HTML_OPEN_WITH("p", "class=\"hang\"");

		@<Text of the actual lexicon entry@>;
		@<Icon with link to documentation, source or verb table, if any@>;

		switch(lex->part_of_speech) {
			case ADJECTIVAL_PHRASE_TLEXE:
				@<Definition of adjectival phrase entry@>; break;
			case ENUMERATED_CONSTANT_TLEXE:
				@<Definition of enumerated instance entry@>; break;
			case PROPER_NOUN_TLEXE:
				@<Definition of proper noun entry@>; break;
			case NOUN_TLEXE:
				@<Definition of noun entry@>; break;
		}
		if (lex->gloss_note) WRITE(" <i>%s</i>", lex->gloss_note);
		HTML_CLOSE("p");
	}
	if (common_nouns_only) { HTML::end_html_row(OUT); HTML::end_html_table(OUT); }

@ In traditional dictionary fashion, we present the text in what may not be
the most normal ordering, in order to place the alphabetically important
part first: thus "see, to be able to" rather than "to be able to see".
(Compare "Gallifreyan High Council, continual incidences of madness and
treachery amongst the" in "Doctor Who: The Completely Useless
Encyclopaedia", eds. Howarth and Lyons (1996).)

@<Text of the actual lexicon entry@> =
	TempLexicon::lexicon_copy_to_stream(lex, OUT);
	if (lex->part_of_speech == ABLE_VERB_TLEXE) WRITE(", to be able to");
	if (lex->part_of_speech == PREP_TLEXE) WRITE(", to be");

@ Main lexicon entries to do with verbs link further down the index page
to the corresponding entries in the verb table. We want to use numbered
anchors for these links, but we want to avoid colliding with numbered
anchors already used for other purposes higher up on the Phrasebook index
page. So we use a set of anchors numbered 10000 and up, which is guaranteed
not to coincide with any of those.

We omit source links to an adjectival phrase because these are polymorphic,
that is, the phrase may have multiple definitions in different parts of the
source text: so any single link would be potentially misleading.

@<Icon with link to documentation, source or verb table, if any@> =
	switch(lex->part_of_speech) {
		case NOUN_TLEXE: {
			kind *K = RETRIEVE_POINTER_kind(lex->entry_refers_to);
			if ((K) && (Kinds::Behaviour::get_documentation_reference(K)))
				Index::DocReferences::link(OUT, Kinds::Behaviour::get_documentation_reference(K));
			break;
		}
		case VERB_TLEXE:
		case ABLE_VERB_TLEXE:
		case PREP_TLEXE:
			Index::below_link_numbered(OUT, 10000+verb_count++);
			break;
	}
	if ((lex->part_of_speech != ADJECTIVAL_PHRASE_TLEXE) && (Wordings::nonempty(lex->wording_of_entry)))
		Index::link(OUT, Wordings::first_wn(lex->wording_of_entry));

@<Definition of noun entry@> =
	kind *K = RETRIEVE_POINTER_kind(lex->entry_refers_to);
	if (Kinds::Behaviour::is_subkind_of_object(K)) {
		K = Latticework::super(K);
		wording W = Kinds::Behaviour::get_name(K, FALSE);
		if (Wordings::nonempty(W)) {
			@<Begin definition text@>;
			WRITE(", a kind of ");
			@<End definition text@>;
			WRITE("%+W", W);
		}
	} else {
		@<Begin definition text@>;
		WRITE(", a kind");
		@<End definition text@>;
	}

@ Simply the name of an instance.

@<Definition of proper noun entry@> =
	instance *I = RETRIEVE_POINTER_instance(lex->entry_refers_to);
	kind *K = Instances::to_kind(I);
	int define_noun = TRUE;
	#ifdef IF_MODULE
	if (Kinds::eq(K, K_thing)) define_noun = FALSE;
	#endif
	if (define_noun) {
		wording W = Kinds::Behaviour::get_name(K, FALSE);
		if (Wordings::nonempty(W)) {
			@<Begin definition text@>;
			WRITE("%+W", W);
			@<End definition text@>;
		}
	}

@ As mentioned above, an adjectival phrase can be multiply defined in
different contexts. We want to quote all of those.

@<Definition of adjectival phrase entry@> =
	int ac = 0, nc;
	adjective_meaning *am;
	adjective *adj = RETRIEVE_POINTER_adjective(lex->entry_refers_to);
	@<Begin definition text@>;
	WRITE(": ");
	LOOP_OVER_LINKED_LIST(am, adjective_meaning, adj->adjective_meanings.in_precedence_order)
		ac++;
	nc = ac;
	LOOP_OVER_LINKED_LIST(am, adjective_meaning, adj->adjective_meanings.in_precedence_order) {
		ac--;
		if (nc > 1) {
			HTML_TAG("br");
			WRITE("%d. ", nc-ac);
		}
		IXAdjectives::print(OUT, am);
		if (ac >= 1) WRITE("; ");
	}
	@<End definition text@>;

@ Lastly and most easily, the name of an enumerated value of some kind
of value.

@<Definition of enumerated instance entry@> =
	instance *qn = RETRIEVE_POINTER_instance(lex->entry_refers_to);
	kind *K = Instances::to_kind(qn);
	@<Begin definition text@>;
	WRITE(", value of ");
	@<End definition text@>;
	WRITE("%+W", Kinds::Behaviour::get_name(K, FALSE));

@<Begin definition text@> =
	WRITE(" ... <i>");
	if ((common_nouns_only == FALSE) && (lex->category))
		WRITE("%s", lex->category);

@<End definition text@> =
	WRITE("</i>");

@h The table of verbs.
This is used in two different ways: firstly, at the foot of the lexicon --

=
void TempLexicon::index_verbs(OUTPUT_STREAM) {
	HTML_OPEN("p"); HTML_CLOSE("p"); /* for spacing */
	HTML_OPEN("p"); WRITE("Verbs listed as \"for saying only\" are values of the kind \"verb\" "
		"and can be used in adaptive text, but they have no meaning to Inform, so "
		"they can't be used in sentences about what's in the story.");
	HTML_CLOSE("p");
	index_tlexicon_entry *lex = sorted_tlexicon;
//	int verb_count = 0;
	for (lex = sorted_tlexicon; lex; lex = lex->sorted_next)
		if ((lex->part_of_speech == VERB_TLEXE) ||
			(lex->part_of_speech == MVERB_TLEXE) ||
			(lex->part_of_speech == PREP_TLEXE) ||
			(lex->part_of_speech == ABLE_VERB_TLEXE)) {
/*			TEMPORARY_TEXT(entry_text)
			HTML_OPEN_WITH("p", "class=\"hang\"");
			Index::anchor_numbered(OUT, 10000+verb_count++);
			TempLexicon::lexicon_copy_to_stream(lex, entry_text);
			if (lex->part_of_speech == VERB_TLEXE) WRITE("To <b>%S</b>", entry_text);
			else if (lex->part_of_speech == MVERB_TLEXE) WRITE("To <b>%S</b>", entry_text);
			else if (lex->part_of_speech == AVERB_TLEXE) WRITE("<b>%S</b>", entry_text);
			else if (lex->part_of_speech == PREP_TLEXE) WRITE("To be <b>%S</b>", entry_text);
			else WRITE("To be able to <b>%S</b>", entry_text);
			if (Wordings::nonempty(lex->wording_of_entry))
				Index::link(OUT, Wordings::first_wn(lex->wording_of_entry));
			if (lex->part_of_speech == AVERB_TLEXE) WRITE(" ... <i>auxiliary verb</i>");
			else if (lex->part_of_speech == MVERB_TLEXE) WRITE(" ... for saying only");
			else TempLexicon::tabulate_meanings(OUT, lex);
			HTML_CLOSE("p");
			TempLexicon::tabulate_verbs(OUT, lex, IS_TENSE, "present");
			TempLexicon::tabulate_verbs(OUT, lex, WAS_TENSE, "past");
			TempLexicon::tabulate_verbs(OUT, lex, HASBEEN_TENSE, "present perfect");
			TempLexicon::tabulate_verbs(OUT, lex, HADBEEN_TENSE, "past perfect");
			DISCARD_TEXT(entry_text)
*/
		}
}

@ -- and secondly, in the documentation for extensions, where we want to
be able to print out a table of just those verbs created in that extension.

=
void TempLexicon::list_verbs_in_file(OUTPUT_STREAM, source_file *sf, inter_package *E) {
/*
	int verb_count = 0;
	index_tlexicon_entry *lex;
	LOOP_OVER(lex, index_tlexicon_entry)
		if (((lex->part_of_speech == VERB_TLEXE) || (lex->part_of_speech == ABLE_VERB_TLEXE))
			&& (lex->verb_defined_at)
			&& (Lexer::file_of_origin(Wordings::first_wn(Node::get_text(lex->verb_defined_at))) == sf)) {
			TEMPORARY_TEXT(entry_text)
			TempLexicon::lexicon_copy_to_stream(lex, entry_text);
			if (verb_count++ == 0) { HTML_OPEN("p"); WRITE("Verbs: "); } else WRITE(", ");
			if (lex->part_of_speech == VERB_TLEXE) WRITE("to <b>%S</b>", entry_text);
			else WRITE("to be able to <b>%S</b>", entry_text);
			ExtensionDictionary::new_entry(I"verb", E, entry_text);
			DISCARD_TEXT(entry_text)
		}
	if (verb_count > 0) HTML_CLOSE("p");
*/
}

@h Index tabulation.
The following produces the table of verbs in the Phrasebook Index page.

=
void TempLexicon::tabulate_verbs(OUTPUT_STREAM, index_tlexicon_entry *lex, int tense, char *tensename) {
/*	verb_usage *vu; int f = TRUE;
	LOOP_OVER(vu, verb_usage)
		if ((vu->vu_lex_entry == lex) && (VerbUsages::is_used_negatively(vu) == FALSE)
			 && (VerbUsages::get_tense_used(vu) == tense)) {
			vocabulary_entry *lastword = WordAssemblages::last_word(&(vu->vu_text));
			if (f) {
				HTML::open_indented_p(OUT, 2, "tight");
				WRITE("<i>%s:</i>&nbsp;", tensename);
			} else WRITE("; ");
			if (Wide::cmp(Vocabulary::get_exemplar(lastword, FALSE), L"by") == 0) WRITE("B ");
			else WRITE("A ");
			WordAssemblages::index(OUT, &(vu->vu_text));
			if (Wide::cmp(Vocabulary::get_exemplar(lastword, FALSE), L"by") == 0) WRITE("A");
			else WRITE("B");
			f = FALSE;
		}
	if (f == FALSE) HTML_CLOSE("p");
*/
}

void TempLexicon::tabulate_meanings(OUTPUT_STREAM, index_tlexicon_entry *lex) {
/*	verb_usage *vu;
	LOOP_OVER(vu, verb_usage)
		if (vu->vu_lex_entry == lex) {
			if (vu->where_vu_created)
				Index::link(OUT, Wordings::first_wn(Node::get_text(vu->where_vu_created)));
			binary_predicate *bp = VerbMeanings::get_regular_meaning_of_form(Verbs::base_form(VerbUsages::get_verb(vu)));
			if (bp) TempLexicon::show_relation(OUT, bp);
			return;
		}
	preposition *prep;
	LOOP_OVER(prep, preposition)
		if (prep->prep_lex_entry == lex) {
			if (prep->where_prep_created)
				Index::link(OUT, Wordings::first_wn(Node::get_text(prep->where_prep_created)));
			binary_predicate *bp = VerbMeanings::get_regular_meaning_of_form(Verbs::find_form(copular_verb, prep, NULL));
			if (bp) TempLexicon::show_relation(OUT, bp);
			return;
		}
*/
}

void TempLexicon::show_relation(OUTPUT_STREAM, inter_package *bp) {
/*
	WRITE(" ... <i>");
	if (bp == NULL) WRITE("(a meaning internal to Inform)");
	else {
		if (bp->right_way_round == FALSE) {
			bp = bp->reversal;
			WRITE("reversed ");
		}
		WordAssemblages::index(OUT, &(bp->relation_name));
	}
	WRITE("</i>");
*/
}
