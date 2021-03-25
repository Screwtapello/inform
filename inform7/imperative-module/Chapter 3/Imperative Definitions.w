[ImperativeDefinitions::] Imperative Definitions.

Each IMPERATIVE node in the syntax tree makes a definition of a phrase or rule.

@ When this function starts, the tree contains a number of top-level |IMPERATIVE_NT|
nodes with |INVOCATION_LIST_NT| nodes hanging from them, but we haven't looked at
any of the text in the |IMPERATIVE_NT| head nodes and therefore we have no idea what
they define. Some will be rules, some will define To... phrases, and so on.

=
typedef struct imperative_defn {
	struct imperative_defn_family *family;
	struct parse_node *at;
	struct phrase *defines;
	CLASS_DEFINITION
} imperative_defn;

typedef struct imperative_defn_family {
	struct text_stream *family_name;
	struct method_set *methods;
	CLASS_DEFINITION
} imperative_defn_family;

imperative_defn_family *AS_YET_UNKNOWN_EFF_family = NULL; /* used only temporarily */
imperative_defn_family *DEFINITIONAL_PHRASE_EFF_family = NULL; /* "Definition: a container is roomy if: ..." */
imperative_defn_family *RULE_NOT_IN_RULEBOOK_EFF_family = NULL; /* "At 9 PM: ...", "This is the zap rule: ..." */
imperative_defn_family *TO_PHRASE_EFF_family = NULL; /* "To award (some - number) points: ..." */
imperative_defn_family *RULE_IN_RULEBOOK_EFF_family = NULL; /* "Before taking a container, ..." */

imperative_defn_family *ImperativeDefinitions::new_family(text_stream *name) {
	imperative_defn_family *family = CREATE(imperative_defn_family);
	family->family_name = Str::duplicate(name);
	family->methods = Methods::new_set();
	return family;
}

@ |CLAIM_IMP_DEFN_MTID| is for deciding from the syntax of a preamble whether
this definition should belong to the family or not.

@e CLAIM_IMP_DEFN_MTID

=
VOID_METHOD_TYPE(CLAIM_IMP_DEFN_MTID, imperative_defn_family *f, imperative_defn *id)

void ImperativeDefinitions::identify(imperative_defn *id) {
	imperative_defn_family *f;
	LOOP_OVER(f, imperative_defn_family)
		if (id->family == AS_YET_UNKNOWN_EFF_family)
			VOID_METHOD_CALL(f, CLAIM_IMP_DEFN_MTID, id);
}

@

=
void ImperativeDefinitions::create_families(void) {
	AS_YET_UNKNOWN_EFF_family       = ImperativeDefinitions::new_family(I"AS_YET_UNKNOWN_EFF");

	DEFINITIONAL_PHRASE_EFF_family  = ImperativeDefinitions::new_family(I"DEFINITIONAL_PHRASE_EFF");
	METHOD_ADD(DEFINITIONAL_PHRASE_EFF_family, CLAIM_IMP_DEFN_MTID, ImperativeDefinitions::Defn_claim);

	RULE_NOT_IN_RULEBOOK_EFF_family = ImperativeDefinitions::new_family(I"RULE_NOT_IN_RULEBOOK_EFF");
	METHOD_ADD(RULE_NOT_IN_RULEBOOK_EFF_family, CLAIM_IMP_DEFN_MTID, ImperativeDefinitions::RNIR_claim);

	TO_PHRASE_EFF_family            = ImperativeDefinitions::new_family(I"TO_PHRASE_EFF");
	METHOD_ADD(TO_PHRASE_EFF_family, CLAIM_IMP_DEFN_MTID, ImperativeDefinitions::To_claim);

	RULE_IN_RULEBOOK_EFF_family     = ImperativeDefinitions::new_family(I"RULE_IN_RULEBOOK_EFF");
	METHOD_ADD(RULE_IN_RULEBOOK_EFF_family, CLAIM_IMP_DEFN_MTID, ImperativeDefinitions::RIR_claim);
}

@ =
<definition-preamble> ::=
	definition                                                ==> { -, DEFINITIONAL_PHRASE_EFF_family }

@ =
void ImperativeDefinitions::Defn_claim(imperative_defn_family *self, imperative_defn *id) {
	wording W = Node::get_text(id->at);
	if (<definition-preamble>(W)) {
		id->family = DEFINITIONAL_PHRASE_EFF_family;
		if ((id->at->next) && (id->at->down == NULL) &&
			(Node::get_type(id->at->next) == IMPERATIVE_NT)) {
			ImperativeSubtrees::accept_body(id->at->next);
			Node::set_type(id->at->next, DEFN_CONT_NT);
		}
		Phrases::Adjectives::look_for_headers(id->at);
	}
}

@ =
<rnir-preamble> ::=
	this is the {... rule} |                                  ==> { TRUE, - }
	this is the rule |                                        ==> @<Issue PM_NamelessRule problem@>
	this is ... rule |                                        ==> @<Issue PM_UnarticledRule problem@>
	this is ... rules |                                       ==> @<Issue PM_PluralisedRule problem@>
	<event-rule-preamble>                                     ==> { FALSE, - }

=
void ImperativeDefinitions::RNIR_claim(imperative_defn_family *self, imperative_defn *id) {
	wording W = Node::get_text(id->at);
	if (<rnir-preamble>(W)) {
		id->family = RULE_NOT_IN_RULEBOOK_EFF_family;
		if (<<r>>) {
			wording RW = GET_RW(<rnir-preamble>, 1);
			if (Rules::vet_name(RW)) Rules::obtain(RW, TRUE);
		}
	}
}

@ =
<to-phrase-preamble> ::=
	to |                                                      ==> @<Issue PM_BareTo problem@>
	to ... ( called ... ) |                                   ==> @<Issue PM_DontCallPhrasesWithCalled problem@>
	{to ...} ( this is the {### function} inverse to ### ) |  ==> { TRUE, -, <<written>> = TRUE, <<inverted>> = TRUE }
	{to ...} ( this is the {### function} ) |                 ==> { TRUE, -, <<written>> = TRUE, <<inverted>> = FALSE }
	{to ...} ( this is ... ) |                                ==> { TRUE, -, <<written>> = FALSE }
	to ...                                                    ==> { FALSE, - }

@<Issue PM_BareTo problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_BareTo),
		"'to' what? No name is given",
		"which means that this would not define a new phrase.");
	==> { FALSE, - };

@<Issue PM_DontCallPhrasesWithCalled problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_DontCallPhrasesWithCalled),
		"phrases aren't named using 'called'",
		"and instead use 'this is...'. For example, 'To salute (called saluting)' "
		"isn't allowed, but 'To salute (this is saluting)' is.");
	==> { FALSE, - };

@ =
void ImperativeDefinitions::To_claim(imperative_defn_family *self, imperative_defn *id) {
	wording W = Node::get_text(id->at);
	if (<to-phrase-preamble>(W)) {
		id->family = TO_PHRASE_EFF_family;
		if (<<r>>) {
			wording RW = GET_RW(<to-phrase-preamble>, 2);
			if (<s-type-expression>(RW))
				StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_PhraseNameDuplicated),
					"that name for this new phrase is not allowed",
					"because it already has a meaning.");
			if (Phrases::Constants::parse(RW) == NULL)
				Phrases::Constants::create(RW, GET_RW(<to-phrase-preamble>, 1));
		}
	}
}

@ =
<rir-preamble> ::=
	... ( this is the {... rule} ) |                          ==> { TRUE, - }
	... ( this is the rule ) |                                ==> @<Issue PM_NamelessRule problem@>
	... ( this is ... rule ) |                                ==> @<Issue PM_UnarticledRule problem@>
	... ( this is ... rules ) |                               ==> @<Issue PM_PluralisedRule problem@>
	...                                                       ==> { FALSE, - }

@<Issue PM_NamelessRule problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_NamelessRule),
		"there are many rules in Inform",
		"so you need to give a name: 'this is the abolish dancing rule', say, "
		"not just 'this is the rule'.");
	==> { FALSE, - }

@<Issue PM_UnarticledRule problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_UnarticledRule),
		"a rule must be given a definite name",
		"which begins with 'the', just to emphasise that it is the only one "
		"with this name: 'this is the promote dancing rule', say, not just "
		"'this is promote dancing rule'.");
	==> { FALSE, - }

@<Issue PM_PluralisedRule problem@> =
	StandardProblems::sentence_problem(Task::syntax_tree(), _p_(PM_PluralisedRule),
		"a rule must be given a definite name ending in 'rule' not 'rules'",
		"since the plural is only used for rulebooks, which can of course "
		"contain many rules at once.");
	==> { FALSE, - }

@ =
void ImperativeDefinitions::RIR_claim(imperative_defn_family *self, imperative_defn *id) {
	wording W = Node::get_text(id->at);
	if (<rir-preamble>(W)) {
		id->family = RULE_IN_RULEBOOK_EFF_family;
		if (<<r>>) {
			wording RW = GET_RW(<rir-preamble>, 2);
			if (Rules::vet_name(RW)) Rules::obtain(RW, TRUE);
		}
	}
}

@

=
imperative_defn *ImperativeDefinitions::make_imperative_definition(parse_node *p) {
	imperative_defn *id = CREATE(imperative_defn);
	id->at = p;
	id->defines = NULL;
	id->family = AS_YET_UNKNOWN_EFF_family;
	current_sentence = p;
	ImperativeDefinitions::identify(id);
	return id;
}

@ Here we look at the preamble for a rule name: if we find it, we declare this
as a rule.

=
<rule-preamble-name> ::=
	{to ...} ( this is the {### function} inverse to ### ) |  ==> { 2, - }
	{to ...} ( this is the {### function} ) |                 ==> { 2, - }
	{to ...} ( this is ... ) |                                ==> { 2, - }
	this is the {... rule} |        ==> { -1, - }
	... ( this is the {... rule} )  ==> { -2, - }

@ =
void ImperativeDefinitions::find_phrases_and_rules(void) {
	int initial_problem_count = problem_count;

	int total = NUMBER_CREATED(imperative_defn), created = 0;
	imperative_defn *id;
	LOOP_OVER(id, imperative_defn) {
		created++;
		if ((created % 10) == 0)
			ProgressBar::update(3,
				((float) (created))/((float) (total)));
		current_sentence = id->at;			
		Phrases::create_from_preamble(id);
	}
	if (initial_problem_count < problem_count) return;

	Routines::ToPhrases::register_all();
	if (initial_problem_count < problem_count) return;

	phrase *ph;
	LOOP_OVER(ph, phrase) {
		current_sentence = ph->from->at;
		Frames::make_current(&(ph->stack_frame));
		ph->runtime_context_data =
			Phrases::Usage::to_runtime_context_data(&(ph->usage_data));
		Frames::remove_current();
	}
	if (initial_problem_count < problem_count) return;

	RuleBookings::make_automatic_placements();
	if (initial_problem_count < problem_count) return;

	SyntaxTree::traverse(Task::syntax_tree(), ImperativeDefinitions::visit_to_parse_placements);
}

@

@e TRAVERSE_FOR_RULE_FILING_SMFT

=
void ImperativeDefinitions::visit_to_parse_placements(parse_node *p) {
	if ((Node::get_type(p) == SENTENCE_NT) &&
		(p->down) &&
		(Node::get_type(p->down) == VERB_NT)) {
		prevailing_mood = Annotations::read_int(p->down, verbal_certainty_ANNOT);
		MajorNodes::try_special_meaning(TRAVERSE_FOR_RULE_FILING_SMFT, p->down);
	}
}

@ The rulebooks are now complete and final. It is time to
compile the Inter code which will provide the run-time definitions of all
these phrases. This will be a long task, and we can only do most of it now,
because more phrases will appear later.

=
int total_phrases_to_compile = 0;
int total_phrases_compiled = 0;
void ImperativeDefinitions::compile_first_block(void) {
	@<Count up the scale of the task@>;
	@<Compile definitions of rules in rulebooks@>;
	@<Compile definitions of rules left out of rulebooks@>;
	@<Compile phrases which define adjectives@>;
	@<Mark To... phrases which have definite kinds for future compilation@>;
	@<Throw problems for phrases with return kinds too vaguely defined@>;
	@<Throw problems for inline phrases named as constants@>;
}

@<Count up the scale of the task@> =
	total_phrases_compiled = 0;
	phrase *ph;
	LOOP_OVER(ph, phrase)
		if (ph->at_least_one_compiled_form_needed)
			total_phrases_to_compile++;

@<Compile definitions of rules in rulebooks@> =
	rulebook *rb;
	LOOP_OVER(rb, rulebook)
		RTRules::compile_rule_phrases(rb,
			&total_phrases_compiled, total_phrases_to_compile);

@<Compile definitions of rules left out of rulebooks@> =
	rule *R;
	LOOP_OVER(R, rule)
		RTRules::compile_definition(R,
			&total_phrases_compiled, total_phrases_to_compile);

@ This doesn't compile all adjective definitions, only the ones which supply
a whole multi-step phrase to define them -- a relatively little-used feature
of Inform.

@<Compile phrases which define adjectives@> =
	imperative_defn *id;
	LOOP_OVER(id, imperative_defn)
		if (id->family == DEFINITIONAL_PHRASE_EFF_family)
			Phrases::compile(id->defines, &total_phrases_compiled,
				total_phrases_to_compile, NULL, NULL, NULL);
	RTAdjectives::compile_support_code();

@ As we'll see, it's legal in Inform to define "To..." phrases with vague
kinds: "To expose (X - a value)", for example. This can't be compiled as
vaguely as the definition implies, since there would be no way to know how
to store X. Instead, for each different kind of X which is actually needed,
a fresh version of the phrase is compiled -- one where X is a number, one
where it's a text, and so on. This is handled by making a "request" for the
phrase, indicating that a compiled version of it will be needed.

Since "To..." phrases are only compiled on request, we must remember to
request the boring ones with straightforward kinds ("To award (N - a number)
points", say). This is where we do it:

@<Mark To... phrases which have definite kinds for future compilation@> =
	phrase *ph;
	LOOP_OVER(ph, phrase) {
		kind *K = Phrases::TypeData::kind(&(ph->type_data));
		if (Kinds::Behaviour::definite(K)) {
			if (ph->at_least_one_compiled_form_needed)
				Routines::ToPhrases::make_request(ph, K, NULL, EMPTY_WORDING);
		}
	}

@<Throw problems for phrases with return kinds too vaguely defined@> =
	phrase *ph;
	LOOP_OVER(ph, phrase) {
		kind *KR = Phrases::TypeData::get_return_kind(&(ph->type_data));
		if ((Kinds::Behaviour::semidefinite(KR) == FALSE) &&
			(Phrases::TypeData::arithmetic_operation(ph) == -1)) {
			current_sentence = Phrases::declaration_node(ph);
			Problems::quote_source(1, current_sentence);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_ReturnKindVague));
			Problems::issue_problem_segment(
				"The declaration %1 tries to set up a phrase which decides a "
				"value which is too vaguely described. For example, 'To decide "
				"which number is the target: ...' is fine, because 'number' "
				"is clear about what kind of value should emerge; but 'To "
				"decide which value is the target: ...' is not clear enough.");
			Problems::issue_problem_end();
		}
		for (int k=1; k<=26; k++)
			if ((Kinds::Behaviour::involves_var(KR, k)) &&
				(Phrases::TypeData::tokens_contain_variable(&(ph->type_data), k) == FALSE)) {
				current_sentence = Phrases::declaration_node(ph);
				TEMPORARY_TEXT(var_letter)
				PUT_TO(var_letter, 'A'+k-1);
				Problems::quote_source(1, current_sentence);
				Problems::quote_stream(2, var_letter);
				StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_ReturnKindUndetermined));
				Problems::issue_problem_segment(
					"The declaration %1 tries to set up a phrase which decides a "
					"value which is too vaguely described, because it involves "
					"a kind variable (%2) which it can't determine through "
					"usage.");
				Problems::issue_problem_end();
				DISCARD_TEXT(var_letter)
		}
	}

@<Throw problems for inline phrases named as constants@> =
	phrase *ph;
	LOOP_OVER(ph, phrase)
		if ((Phrases::TypeData::invoked_inline(ph)) &&
			(Phrases::Usage::has_name_as_constant(&(ph->usage_data)))) {
			current_sentence = Phrases::declaration_node(ph);
			Problems::quote_source(1, current_sentence);
			StandardProblems::handmade_problem(Task::syntax_tree(), _p_(PM_NamedInline));
			Problems::issue_problem_segment(
				"The declaration %1 tries to give a name to a phrase which is "
				"defined using inline Inform 6 code in (- markers -). Such "
				"phrases can't be named and used as constants because they "
				"have no independent existence, being instead made fresh "
				"each time they are used.");
			Problems::issue_problem_end();
		}

@ The twilight gathers, but our work is far from done. Recall that we have
accumulated compilation requests for "To..." phrases, but haven't actually
acted on them yet.

We have to do this in quite an open-ended way, because compiling one phrase
can easily generate fresh requests for others. For instance, suppose we have
the definition "To expose (X - a value)" in play, and suppose that when
compiling the phrase "To advertise", Inform runs into the line "expose the
hoarding text". This causes it to issue a compilation request for "To expose
(X - a text)". Perhaps we've compiled such a form already, but perhaps we
haven't. Compilation therefore goes on until all requests have been dealt
with.

Compiling phrases also produces the need for other pieces of code to be
generated -- for example, suppose our phrase being compiled, "To advertise",
includes the text:

>> let Z be "Two for the price of one! Just [expose price]!";

We are going to need to compile "Two for the price of one! Just [expose price]!"
later on, in its own text substitution routine; but notice that it contains
the need for "To expose (X - a number)", and that will generate a further
phrase request.

Because of this and similar problems, it's impossible to compile all the
phrases alone: we must compile phrases, then things arising from them, then
phrases arising from those, then things arising from the phrases arising
from those, and so on, until we're done. The process is therefore structured
as a set of "coroutines" which each carry out as much as they can and then
hand over to the others to generate more work.

=
void ImperativeDefinitions::compile_as_needed(void) {
	rule *R;
	LOOP_OVER(R, rule)
		RTRules::compile_definition(R,
			&total_phrases_compiled, total_phrases_to_compile);
	int repeat = TRUE;
	while (repeat) {
		repeat = FALSE;
		if (Routines::ToPhrases::compilation_coroutine(
			&total_phrases_compiled, total_phrases_to_compile) > 0)
			repeat = TRUE;
		if (ListTogether::compilation_coroutine() > 0)
			repeat = TRUE;
		#ifdef IF_MODULE
		if (LoopingOverScope::compilation_coroutine() > 0)
			repeat = TRUE;
		#endif
		if (Strings::TextSubstitutions::compilation_coroutine(FALSE) > 0)
			repeat = TRUE;
		if (Propositions::Deferred::compilation_coroutine() > 0)
			repeat = TRUE;
	}
}
