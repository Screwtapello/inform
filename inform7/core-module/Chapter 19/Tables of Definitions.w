[Tables::Defining::] Tables of Definitions.

To support tables which amount to massed groups of assertions.

@h Kinds defined by table.
Tables lie behind the special "defined by" sentence. These come in three
subtly different versions:

>> (1) Some animals are defined by the Table of Specimens.
>> (2) Some men in the Zoo are defined by the Table of Zookeepers.
>> (3) Some kinds of animal are defined by the Table of Zoology.

The subject in (1) is the name of a kind; in (2), it's a description which
incorporates a kind, but can include relative clauses and adjectives; in (3),
it's something second-order -- a kind of a kind. Given this variety of
possibilities, we treat "defined by" sentences as if they were abbreviations
for a mass of assertion sentences, one for each row of the table. We do
however reject:

>> The okapi is defined by the Table of Short-Necked Giraffes.

where the "okapi" is an existing single animal (or indeed where it's a new
name, meaning as yet unknown).

The subject must match:

=
<defined-by-sentence-subject> ::=
	kind/kinds of <s-type-expression> |  ==> { TRUE, RP[1] }
	<s-type-expression> |                ==> { TRUE, RP[1] }
	...                                  ==> @<Issue PM_TableDefiningTheImpossible problem@>

@<Issue PM_TableDefiningTheImpossible problem@> =
	@<Actually issue PM_TableDefiningTheImpossible problem@>;
	==> { FALSE, - };

@ (We're going to need this twice.)

@<Actually issue PM_TableDefiningTheImpossible problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_TableDefiningTheImpossible),
		"you can only use 'defined by' to set up values and things",
		"as created with sentences like 'The tree species are defined by Table 1.' "
		"or 'Some men are defined by the Table of Eligible Bachelors.'");

@ And the object, which in fact is required to be a table name value:

=
<defined-by-sentence-object-inner> ::=
	<s-value> |    ==> @<Allow if a table name@>
	...											==> @<Issue PM_TableUndefined problem@>

@<Allow if a table name@> =
	if (!(Rvalues::is_CONSTANT_of_kind(RP[1], K_table))) {
		==> { fail };
	} else {
		==> { TRUE, RP[1] };
	}

@<Issue PM_TableUndefined problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_TableUndefined),
	"you can only use 'defined by' in terms of a table",
	"which lists the value names in the first column.");
	==> { FALSE, - };

@h Handling definition-by-table sentences.
The timing of when to act on defined-by sentences is not completely
straightforward; if it's wrong, entries making cross-references may sometimes
be rejected by Inform for what seem very opaque reasons. Here's the timeline:

(a) Inform looks for tables in the source text, creating the table names
and columns, though it doesn't know the column kinds yet. (The point of
this is to make sure table column names are in place before properties
begin to be used in assertion sentence, since these names can overlap.)

(b) Main assertion traverse 1: Nothing is done with most tables, but with
defined-by tables, the names in column 1 are created, and their identities
are asserted.

(c) All tables are "stocked", a process which involves parsing their cell
values. This finally settles the kind of any columns where this has to be
inferred from the contents.

(d) Main assertion traverse 2: Nothing is done with most tables, but with
defined-by tables, property values in columns 2 onwards are assigned to
whatever is named in column 1.

@ So this handles the special meaning "X is defined by Y".

=
<defined-by-sentence-object> ::=
	defined by <np-as-object>  ==> { pass 1 }

@ =
int Tables::Defining::defined_by_SMF(int task, parse_node *V, wording *NPs) {
	wording SW = (NPs)?(NPs[0]):EMPTY_WORDING;
	wording OW = (NPs)?(NPs[1]):EMPTY_WORDING;
	switch (task) { /* "The colours are defined by Table 1." */
		case ACCEPT_SMFT:
			if (<defined-by-sentence-object>(OW)) {
				Annotations::write_int(V, examine_for_ofs_ANNOT, TRUE);
				parse_node *O = <<rp>>;
				<np-unparsed>(SW);
				V->next = <<rp>>;
				V->next->next = O;
				return TRUE;
			}
			break;
		case TRAVERSE1_SMFT:
		case TRAVERSE2_SMFT:
			Tables::Defining::kind_defined_by_table(V);
			break;
	}
	return FALSE;
}


@ Stages (a) and (c) above are both handled by the following routine,
which is called on "defined by" sentences, and thus is never called in
connection with ordinary tables.

=
void Tables::Defining::kind_defined_by_table(parse_node *pn) {
	wording LTW = Node::get_text(pn->next->next);
	wording SPW = Node::get_text(pn->next);
	LOGIF(TABLES, "Traverse %d: I now want to define <%W> by table <%W>\n",
		traverse, SPW, LTW);

	<defined-by-sentence-object-inner>(LTW); if (<<r>> == FALSE) return;
	table *t = Rvalues::to_table(<<rp>>);

	if (traverse == 1) {
		int abstract = NOT_APPLICABLE;
		kind *K = NULL;
		@<Decide whether this will be an abstract or a concrete creation@>;
		@<Check that this is a kind where it makes sense to enumerate new values@>;
		K = Kinds::weaken(K);
		if (!(Kinds::Compare::le(K, K_object))) Tables::Defining::set_defined_by_table(K, t);
		t->kind_defined_in_this_table = K;
		Tables::Columns::set_kind(t->columns[0].column_identity, t, K);

		@<Create values for this kind as enumerated by names in the first column@>;
	}
	@<Assign properties for these values as enumerated in subsequent columns@>;
}

@<Decide whether this will be an abstract or a concrete creation@> =
	<defined-by-sentence-subject>(SPW); if (<<r>> == FALSE) return;
	parse_node *what = <<rp>>;
	if (Specifications::is_kind_like(what)) {
		K = Specifications::to_kind(what);
		if (Kinds::Compare::le(K, K_object)) abstract = FALSE;
		else {
			abstract = TRUE;
			t->contains_property_values_at_run_time = TRUE;
			t->fill_in_blanks = TRUE;
			t->preserve_row_order_at_run_time = TRUE;
			t->disable_block_constant_correction = TRUE;
		}
	} else if (Specifications::object_exactly_described_if_any(what)) {
		@<Issue PM_TableDefiningObject problem@>
		return;
	} else if (Specifications::is_description(what)) {
		@<Check that this is a description which in principle can be asserted@>;
		abstract = FALSE;
		K = Specifications::to_kind(what);
	} else {
		LOG("Error at: $T", what);
		@<Actually issue PM_TableDefiningTheImpossible problem@>;
		return;
	}
	if ((t) && (t->has_been_amended) && (Kinds::Compare::le(K, K_object))) {
		StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_TableCantDefineAndAmend),
			"you can't use 'defined by' to define objects using a table "
			"which is amended by another table",
			"since that could too easily lead to ambiguities about what "
			"the property values are.");
		return;
	}
	t->first_column_by_definition = TRUE;
	t->where_used_to_define = pn->next;

@<Issue PM_TableDefiningObject problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_TableDefiningObject),
		"you can only use 'defined by' to set up values and things",
		"as created with sentences like 'The tree species are defined by Table 1.' "
		"or 'Some men are defined by the Table of Eligible Bachelors.' - trying to "
		"define a single specific object, as here, is not allowed.");

@<Check that this is a kind where it makes sense to enumerate new values@> =
	if ((Kinds::Compare::le(K, K_object) == FALSE) &&
		(Kinds::Behaviour::has_named_constant_values(K) == FALSE)) {
		LOG("K is $u\n", K);
		Problems::quote_source(1, current_sentence);
		Problems::quote_kind(2, K);
		StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_TableOfBuiltInKind));
		Problems::issue_problem_segment(
			"You wrote %1, but this would mean making each of the names in "
			"the first column %2 that's new. This is a kind which can't have "
			"entirely new values, so I can't make these definitions.");
		Problems::issue_problem_end();
		return;
	}
	if ((Kinds::Behaviour::has_named_constant_values(K)) &&
		(Kinds::Behaviour::is_uncertainly_defined(K) == FALSE)) {
		Problems::quote_source(1, current_sentence);
		Problems::quote_kind(2, K);
		StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_TableOfExistingKind));
		Problems::issue_problem_segment(
			"You wrote %1, but this would mean making each of the names in "
			"the first column %2 that's new. That looks reasonable, since this is a "
			"kind which does have named values, but one of the restrictions on "
			"definitions-by-table is that all of the values of the kind have "
			"to be made by the table: you can't have some defined in ordinary "
			"sentences and others in the table.");
		Problems::issue_problem_end();
		return;
	}

@<Check that this is a description which in principle can be asserted@> =
	if (Calculus::Propositions::contains_quantifier(
		Specifications::to_proposition(what))) {
		StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_TableOfQuantifiedKind),
			"you can't use 'defined by' a table while also talking about the "
			"number of things to be defined",
			"since that could too easily lead to contradictions. (So 'Six doors are "
			"defined by the Table of Portals' is not allowed - suppose there are ten "
			"rows in the Table, making ten doors?)");
		return;
	}

@h Name creation.
The following code has a curious history: it has evolved backwards from
something much higher-level. When definition by tables began, it was a device
to create new instances -- the names in column 1 would be, say, the instances
of the kind "colour". Inform did this by writing propositions to assert their
existence, in an elegantly high-level way; and all was well. But people also
wanted things like this:

>> Some people on the dais are defined by the Table of Presenters.

and the process of converting that to propositional form, while issuing
a range of intelligible problem messages if anything went wrong, would end
up duplicating what's already done in the assertion parser.

So Inform now handles rows in defined-by tables by handing them over to
the assertions system directly. If the name N is in column 1, and the
original sentence read "D are defined by...", then Inform calls the
assertion-maker on the parse tree nodes for N and D exactly as if the
user had written "N is D". Since this explicitly changes the meaning of N
(that's the point), we then re-parse N, and check that it does now refer
to an instance or kind; if it doesn't, then some assertion problem must
have occurred, but if it does then the creation has worked.

@<Create values for this kind as enumerated by names in the first column@> =
	parse_node *name_entry;
	int objections = 0, blank_objections = 0, row_count;
	for (name_entry = t->columns[0].entries->down, row_count = 1; name_entry;
		name_entry=name_entry->next, row_count++) {
		wording NW = Node::get_text(name_entry);
		LOGIF(TABLES, "So I want to create: <%W>\n", NW);
		if (<table-cell-blank>(NW))
			@<Issue a problem for trying to create a blank name@>;
		parse_node *evaluation = NULL;
		if (<s-type-expression>(Node::get_text(name_entry))) evaluation = <<rp>>;
		Assertions::Refiner::noun_from_value(name_entry, evaluation);
		if (Specifications::is_kind_like(evaluation))
			@<Issue a problem for trying to create an existing kind as a new instance@>;
		if ((evaluation) && (Node::is(evaluation, UNKNOWN_NT) == FALSE))
			@<Issue a problem for trying to create any existing meaning as a new instance@>;

		Assertions::Creator::tabular_definitions(t);
		NounPhrases::annotate_by_articles(name_entry);
		ProblemBuffer::redirect_problem_sentence(current_sentence, name_entry, pn->next);
		Assertions::Copular::make_assertion(name_entry, pn->next);
		ProblemBuffer::redirect_problem_sentence(NULL, NULL, NULL);
		Node::set_text(name_entry, NW);
		evaluation = NULL;
		if (<k-kind>(NW))
			evaluation = Specifications::from_kind(<<rp>>);
		else if (<s-type-expression>(Node::get_text(name_entry)))
			evaluation = <<rp>>;
		Assertions::Refiner::noun_from_value(name_entry, evaluation);
		Assertions::Creator::tabular_definitions(NULL);

		if (Node::get_subject(name_entry) == NULL)
			@<Issue a problem to say that the creation failed@>;
	}
	if (objections > 0) return;

@ Usually if the source text makes this mistake in one row, it makes it in
lots of rows, so we issue the problem just once.

@<Issue a problem for trying to create a blank name@> =
	if (blank_objections == 0) {
		Problems::quote_number(4, &row_count);
		StandardProblems::table_problem(_p_(PM_TableWithBlankNames),
			t, NULL, name_entry,
			"%1 is being used to create values, so that the first column needs "
			"to contain names for these new things. It's not allowed to contain "
			"blanks, but row %4 does (see %3).");
	}
	objections++; blank_objections++; continue;

@ This is a special case of the next problem, but enables a clearer problem
message to be issued. (It's not as unlikely a mistake as it looks, since
kind names can legally be written into other columns to indicate the kinds
of the contents.)

@<Issue a problem for trying to create an existing kind as a new instance@> =
	Problems::quote_number(4, &row_count);
	StandardProblems::table_problem(_p_(PM_TableEntryGeneric),
		t, NULL, name_entry,
		"In row %4 of %1, the entry %3 is the name of a kind of value, "
		"so it can't be the name of a new object.");
	objections++; continue;

@<Issue a problem for trying to create any existing meaning as a new instance@> =
	LOG("Existing meaning was: $P\n", evaluation);
	Problems::quote_source(1, current_sentence);
	Problems::quote_source(2, name_entry);
	Problems::quote_kind_of(3, evaluation);
	Problems::quote_kind(4, K);
	Problems::quote_number(5, &row_count);
	StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_TableCreatedClash));
	Problems::issue_problem_segment(
		"You wrote %1, and row %5 of the first column of that table is %2, which "
		"I ought to create as a new value of %4. But I can't do that: it already "
		"has a meaning (as %3).");
	Problems::issue_problem_end();
	objections++; continue;

@<Issue a problem to say that the creation failed@> =
	LOG("Eval is $P\n", evaluation);
	Problems::quote_source(4, name_entry);
	Problems::quote_number(5, &row_count);
	StandardProblems::table_problem(_p_(PM_TableDefiningNothing),
		t, NULL, name_entry,
		"In row %5 of %1, the entry %4 seems not to have defined "
		"a thing there, so perhaps the first column did not consist "
		"of new names?");
	objections++; continue;

@h Property assignment.
Suppose column 3, say, is called "alarm call" and contains times. Clearly
this is a property, and we have to give those property values to whatever
has been created in their corresponding column 1s. That means those
individual values need permission to have the "alarm call" property. But
what about other values of the same kind which aren't mentioned in the
table: do they get permission as well? We're going to say that they do.

@<Assign properties for these values as enumerated in subsequent columns@> =
	for (int i=1; i<t->no_columns; i++) {
		property *P = NULL;
		@<Ensure that a property with the same name as the column name exists@>;
		if (traverse == 1)
			Calculus::Propositions::Assert::assert_true_about(
				Calculus::Propositions::Abstract::to_provide_property(P),
				Kinds::Knowledge::as_subject(t->kind_defined_in_this_table),
				prevailing_mood);
		if (t->contains_property_values_at_run_time)
			@<Passively allow the column to become the property values@>
		else @<Actively assert the column entries as property values@>;
	}

@ It's probably, but not certainly, the case that the column name is new, and
not yet known to be a property. If so, this is where it becomes one. By
traverse 2, if not before, we will be able to give it a kind, since after
table-stocking the column will have a kind for its entries.

@<Ensure that a property with the same name as the column name exists@> =
	<unfortunate-table-column-property>(Nouns::nominative_singular(t->columns[i].column_identity->name));
	P = Properties::Valued::obtain(Nouns::nominative_singular(t->columns[i].column_identity->name));
	if (Properties::Valued::kind(P) == NULL) {
		kind *CK = Tables::Columns::get_kind(t->columns[i].column_identity);
		if ((Kinds::get_construct(CK) == CON_rule) ||
			(Kinds::get_construct(CK) == CON_rulebook)) {
			kind *K1 = NULL, *K2 = NULL;
			Kinds::binary_construction_material(CK, &K1, &K2);
			if ((Kinds::Compare::eq(K1, K_value)) && (Kinds::Compare::eq(K1, K_value))) {
				CK = Kinds::binary_construction(
					Kinds::get_construct(CK), K_action_name, K_nil);
				Tables::Columns::set_kind(t->columns[i].column_identity, t, CK);
			}
		}
		if (CK) Properties::Valued::set_kind(P, CK);
	}

@ When a table column is used to create a property of an object, its name
becomes the name of a new property. To avoid confusion, though, there are
some misleading names we don't want to allow for these properties.

=
<unfortunate-table-column-property> ::=
	location						==> @<Issue PM_TableColumnLocation problem@>

@<Issue PM_TableColumnLocation problem@> =
	Problems::quote_wording(3, W);
	StandardProblems::table_problem(_p_(PM_TableColumnLocation),
		table_being_examined, NULL, table_cell_node,
		"In %1, the column name %3 cannot be used, because there would be too "
		"much ambiguity arising from its ordinary meaning referring to the "
		"physical position of something.");
	==> { NEW_TC_PROBLEM, - };

@ Now for something sneaky. There are two ways we can actually assign the
property values: active, and passive. The passive way is the sneaky one, and
it relies on the observation that if we're going to store the property values
in this same table at run-time then we don't need to do anything at all: the
values are already in their correct places. All we need to do is notify the
property storage mechanisms that we intend this to happen.

(Take care editing this: the call works in quite an ugly way and relies on
following immediately after a permission grant.)

@<Passively allow the column to become the property values@> =
	if (traverse == 1)
		Properties::OfValues::pp_set_table_storage(t->columns[i].tcu_iname);

@ Active assertions of properties are, once again, a matter of calling the
assertion handler, simulating sentences like "The P of X is Y".

@<Actively assert the column entries as property values@> =
	parse_node *name_entry, *data_entry;
	for (name_entry = t->columns[0].entries->down,
			data_entry = t->columns[i].entries->down;
		name_entry && data_entry;
		name_entry = name_entry->next,
			data_entry = data_entry->next) {
		ProblemBuffer::redirect_problem_sentence(current_sentence, name_entry, data_entry);
		@<Make an assertion that this name has that property@>;
	}
	ProblemBuffer::redirect_problem_sentence(current_sentence, NULL, NULL);

@ Note that a blank means "don't assert this property", it doesn't mean
"assert a default value for this property". The difference is very small,
but the latter might cause contradiction problem messages if there are
also ordinary sentences about the property value, and the former won't.

@<Make an assertion that this name has that property@> =
	inference_subject *subj = Node::get_subject(name_entry);
	if (traverse == 2) {
		if ((Wordings::nonempty(Node::get_text(data_entry))) &&
			(<table-cell-blank>(Node::get_text(data_entry)) == FALSE)) {
			parse_node *val = Node::get_evaluation(data_entry);
			if (Node::is(val, UNKNOWN_NT)) {
				if (problem_count == 0) internal_error("misevaluated cell");
			} else {
				Assertions::Refiner::noun_from_value(data_entry, val);
				Assertions::PropertyKnowledge::assert_property_value_from_property_subtree_infs(
					P, subj, data_entry);
			}
		}
	}

@ =
table *Tables::Defining::defined_by_table(kind *K) {
	if (K == NULL) return NULL;
	return K->construct->named_values_created_with_table;
}

void Tables::Defining::set_defined_by_table(kind *K, table *t) {
	if (K == NULL) internal_error("no such kind");
	K->construct->named_values_created_with_table = t;
}
