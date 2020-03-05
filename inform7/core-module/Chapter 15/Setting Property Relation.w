[Properties::SettingRelations::] Setting Property Relation.

Each value property has an associated relation to set its value.

@h Initial stock.
There is no initial stock of these, since there are no value properties yet
when Inform starts up.

=
void Properties::SettingRelations::REL_create_initial_stock(void) {
}

@h Subsequent creations.
Relations like this lead to a timing problem, because we have to create the
relation early enough that we can make sense of the sentences in the source
text; but at that early time, the properties haven't been created yet. We
therefore store the text of the property name (say, "weight") in
|property_pending_text| and come back to it later on.

=
binary_predicate *Properties::SettingRelations::make_set_property_BP(wording W) {
	binary_predicate *bp = BinaryPredicates::make_pair(PROPERTY_SETTING_KBP,
		BinaryPredicates::new_term(Kinds::Knowledge::as_subject(K_object)),
		BinaryPredicates::new_term(NULL),
		I"set-property", NULL, NULL, NULL, NULL, WordAssemblages::lit_0());
	bp->property_pending_text = W;
	bp->reversal->property_pending_text = W;
	return bp;
}

@ Meanwhile, we can't look up the BP with reference to the property, since
the property may not exist yet; we have to use the text of the name of the
property as a key, clumsy as that may seem.

=
binary_predicate *Properties::SettingRelations::find_set_property_BP(wording W) {
	binary_predicate *bp;
	LOOP_OVER(bp, binary_predicate)
		if (Wordings::match(W, bp->property_pending_text))
			if (bp->right_way_round)
				return bp;
	return NULL;
}

@ ...And now it's "later on". We fix these BPs in original-reversal pairs, so
that the two can never fall out of step.

=
void Properties::SettingRelations::fix_property_bp(binary_predicate *bp) {
	binary_predicate *bpr = bp->reversal;
	wording W = bp->property_pending_text;
	if (Wordings::nonempty(W)) {
		bp->property_pending_text = EMPTY_WORDING;
		bpr->property_pending_text = EMPTY_WORDING;
		current_sentence = bp->bp_created_at;
		<relation-property-name>(W);
		if (<<r>> == FALSE) return; /* a problem was issued */
		property *prn = <<rp>>;
		bp->set_property = prn; bpr->set_property = prn;
		if (bp->right_way_round) Properties::SettingRelations::set_property_BP_schemas(bp, prn);
		else Properties::SettingRelations::set_property_BP_schemas(bpr, prn);
	}
}

@ When properties are named as part of relation definitions, for instance, like so:

>> The verb to weigh (it weighs, they weigh, it is weighing) implies the weight property.

...then its name (in this case "weight") is required to pass:

=
<relation-property-name> ::=
	<either-or-property-name> |		==> @<Issue PM_RelationWithEitherOrProperty problem@>
	<value-property-name> |			==> TRUE; *XP = RP[1];
	...								==> @<Issue PM_RelationWithBadProperty problem@>

@<Issue PM_RelationWithEitherOrProperty problem@> =
	*X = FALSE;
	Problems::Issue::sentence_problem(Task::syntax_tree(), _p_(PM_RelationWithEitherOrProperty),
		"verbs can only set properties with values",
		"not either/or properties like this one.");

@<Issue PM_RelationWithBadProperty problem@> =
	*X = FALSE;
	Problems::Issue::sentence_problem(Task::syntax_tree(), _p_(PM_RelationWithBadProperty),
		"that doesn't seem to be a property",
		"perhaps because you haven't defined it yet?");

@ No such funny business is necessary for a nameless property created within
Inform:

=
binary_predicate *Properties::SettingRelations::make_set_nameless_property_BP(property *prn) {
	binary_predicate *bp = Properties::SettingRelations::make_set_property_BP(EMPTY_WORDING);
	binary_predicate *bpr = bp->reversal;
	bp->set_property = prn; bpr->set_property = prn;
	Properties::SettingRelations::set_property_BP_schemas(bp, prn);
	return bp;
}

@h Second stock.
The following is called after all properties have been created, making it
the perfect opportunity to go over all of the property-setting BPs:

=
void Properties::SettingRelations::REL_create_second_stock(void) {
	binary_predicate *bp;
	LOOP_OVER(bp, binary_predicate)
		if (Wordings::nonempty(bp->property_pending_text))
			Properties::SettingRelations::fix_property_bp(bp);
}

@ Note that we read and write to the property directly, without asking the
template layer to check if the given object has permission to possess that
property. We can afford to do this because type-checking at compile time
guarantees that it does have permission, and as a result we gain some speed
and simplicity.

=
void Properties::SettingRelations::set_property_BP_schemas(binary_predicate *bp, property *prn) {
	bp->test_function =
		Calculus::Schemas::new("*1.%n == *2", Properties::iname(prn));
	bp->make_true_function =
		Calculus::Schemas::new("*1.%n = *2", Properties::iname(prn));
	BinaryPredicates::set_term_domain(&(bp->term_details[1]),
		Properties::Valued::kind(prn));
}

@h Typechecking.
Suppose we are setting property $P$ of subject $S$ to value $V$. Then the setting
relation has terms $S$ and $V$. To pass typechecking, we require that $V$ be
valid for the kind of value stored in $P$, and that $S$ have a kind a value
allowing it to possess properties in general. But we don't require
that it possesses this one.

This is because we can't know whether it does or not until model completion,
much later on, because we don't necessarily know the kind of value of $S$.
It might be an object which will eventually be deduced to be a room, for
instance, but hasn't been yet.

=
int Properties::SettingRelations::REL_typecheck(binary_predicate *bp,
		kind **kinds_of_terms, kind **kinds_required, tc_problem_kit *tck) {
	property *prn = bp->set_property;
	kind *val_kind = Properties::Valued::kind(prn);
	@<Require the value to be type-safe for storage in the property@>;
	@<Require the subject to be able to have properties@>;
	return ALWAYS_MATCH;
}

@ The following lets just a few type-unsafe cases fall through the net. It's
superficially attractive to reject them here, but (a) that would result in
less specific problem messages which can be issued later on, notably for
the "opposite" property of directions; and (b) we must be careful because
in assertion traverse 2 not every object yet has its final kind -- for
many implicitly created objects, they have yet to be declared as room,
container and supporter.

As a result, type-unsafe property assertions do occur, and these have to
be caught later on Inform's run.

@<Require the value to be type-safe for storage in the property@> =
	int safe = FALSE;
	int compatible = Kinds::Compare::compatible(kinds_of_terms[1], val_kind);
	if (compatible == ALWAYS_MATCH) safe = TRUE;
	if (compatible == SOMETIMES_MATCH) {
		if (Kinds::Compare::le(val_kind, K_object) == FALSE) safe = TRUE;
		#ifdef IF_MODULE
		if ((Kinds::Compare::eq(val_kind, K_direction)) ||
			(Kinds::Compare::eq(val_kind, K_room)) ||
			(Kinds::Compare::eq(val_kind, K_container)) ||
			(Kinds::Compare::eq(val_kind, K_supporter))) safe = TRUE;
		#endif
	}

	if (safe == FALSE) {
		LOG("Property value given as $u not $u\n", kinds_of_terms[1], val_kind);
		Problems::quote_kind(4, kinds_of_terms[1]);
		Problems::quote_kind(5, val_kind);
		if (Kinds::get_construct(kinds_of_terms[1]) == CON_property)
			Problems::Issue::tcp_problem(_p_(PM_PropertiesEquated), tck,
				"that seems to say that two different properties are the same - "
				"like saying 'The indefinite article is the printed name': that "
				"might be true for some things, some of the time, but it makes no "
				"sense in a general statement like this one.");
		else if (prn == NULL)
			Problems::Issue::tcp_problem(_p_(PM_UnknownPropertyType), tck,
				"that tries to set the value of an unknown property to %4.");
		else {
			Problems::quote_property(6, prn);
			Problems::Issue::tcp_problem(_p_(PM_PropertyType), tck,
				"that tries to set the value of the '%6' property to %4 - which "
				"must be wrong because this property has to be %5.");
		}
		return NEVER_MATCH;
	}

@<Require the subject to be able to have properties@> =
	if (Kinds::Behaviour::has_properties(kinds_of_terms[0]) == FALSE) {
		LOG("Property value for impossible domain $u\n", kinds_of_terms[0]);
		Problems::quote_kind(4, kinds_of_terms[0]);
		Problems::quote_property(5, prn);
		Problems::Issue::tcp_problem(_p_(BelievedImpossible), tck,
			"that tries to set the property '%5' for %4. Values of that kind "
			"are not allowed to have properties. (Some kinds of value are, "
			"some aren't - see the Kinds index for details. It's a matter "
			"of what is practical in terms of how much memory is needed.)");
		return NEVER_MATCH;
	}

@h Assertion.

=
int Properties::SettingRelations::REL_assert(binary_predicate *bp,
		inference_subject *infs0, parse_node *spec0,
		inference_subject *infs1, parse_node *spec1) {
	World::Inferences::draw_property(infs0, bp->set_property, spec1);
	return TRUE;
}

@h Compilation.
We need do nothing special: these relations can be compiled from their schemas.

=
int Properties::SettingRelations::REL_compile(int task,
	binary_predicate *bp, annotated_i6_schema *asch) {
	kind *K = Calculus::Deferrals::Cinders::kind_of_value_of_term(asch->pt0);

	if (Kinds::Compare::le(K, K_object)) return FALSE;

	property *prn = bp->set_property;
	switch (task) {
		case TEST_ATOM_TASK:
			Calculus::Schemas::modify(asch->schema,
				"GProperty(%k, *1, %n) == *2", K, Properties::iname(prn));
			break;
		case NOW_ATOM_FALSE_TASK:
			break;
		case NOW_ATOM_TRUE_TASK:
			Calculus::Schemas::modify(asch->schema,
				"WriteGProperty(%k, *1, %n, *2)", K, Properties::iname(prn));
			break;
	}
	return TRUE;
}

@ =
int Properties::SettingRelations::bp_sets_a_property(binary_predicate *bp) {
	if ((bp->set_property) || (Wordings::nonempty(bp->property_pending_text))) return TRUE;
	return FALSE;
}

@h Problem message text.

=
int Properties::SettingRelations::REL_describe_for_problems(OUTPUT_STREAM, binary_predicate *bp) {
	return FALSE;
}
