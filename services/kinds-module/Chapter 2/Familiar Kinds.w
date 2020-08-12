[FamiliarKinds::] Familiar Kinds.

To recognise certain kind names as familiar built-in ones.

@ In the Inform source code, we're clearly going to need to refer to some
kinds explicitly, and we need a way to do that. We adopt two naming conventions:

(i) Kinds are written as |K_source_text_name|, that is, |K_| followed by
the name of the kind in I7 source text, with spaces made into underscores.
For instance, |K_number|. These are all |kind *| global variables
which are initially |NULL|, but which, once set, are never changed.

(ii) Constructors are likewise written as |CON_source_text_name| if they can
be created in source text; or by |CON_TEMPLATE_NAME|, that is, |CON_|
followed by the constructor's identifier as given in the command
which created it (but with the |_TY| suffix removed) if not. These are all
|kind_constructor *| global variables which are initially |NULL|, but which,
once set, are never changed.

We will now define all of the |K_...| and |CON_...| used by the core of
Inform. The //kinds// module does not need all of these to be created: for
example, in a Basic Inform compilation, |stored action| never will be.
The variable |K_stored_action| will then remain |NULL|, but will also never
be used for anything, so no harm is done.

@ We begin with the protocol-like "kinds of kinds", the superheroes of the
kinds world. There are seven, always a good number for this sort of thing:[1]

[1] Compare Samurai, Seals, or Dwarfs.

= (early code)
kind *K_value = NULL;
kind *K_stored_value = NULL;
kind *K_pointer_value = NULL;
kind *K_sayable_value = NULL;
kind *K_arithmetic_value = NULL;
kind *K_real_arithmetic_value = NULL;
kind *K_enumerated_value = NULL;

@ Next, some awkward punctuation-like special base kinds needed in order
to construct things. These are used in combination to make tuples, that is,
collections $(K_1, K_2, ..., K_n)$ of kinds of value.

= (early code)
kind *K_nil = NULL;
kind_constructor *CON_NIL = NULL;
kind_constructor *CON_TUPLE_ENTRY = NULL;

@ Thus we store $(A, B, C)$ as
= (text)
	CON_TUPLE_ENTRY
		A
		CON_TUPLE_ENTRY
			B
			CON_TUPLE_ENTRY
				C
				CON_NIL
=
This traditional LISP-like device enables us to store tuples of arbitrary
size without need for any constructor of arity greater than 2.

@ |K_unknown| plays no role in the type system -- as noted in //What This Module Does//,
the way to express "unknown kind" is to use the value |NULL|. The purpose of
|K_unknown| is purely so that run-time code generated by Inform has a way
to mark out empty lists as having entries of no known kind.

=
kind *K_void = NULL;
kind_constructor *CON_VOID = NULL;
kind *K_unknown = NULL;
kind_constructor *CON_UNKNOWN = NULL;

@ |CON_INTERMEDIATE| is used to represent kinds which are brought into being
through uncompleted arithmetic operations: see //Dimensions// for a full
discussion.

= (early code)
kind_constructor *CON_INTERMEDIATE = NULL;

@ |CON_KIND_VARIABLE| is used to formally represent kind variables, such as
the letter |K|:

= (early code)
kind_constructor *CON_KIND_VARIABLE = NULL;

@ So much for the exotica: back onto familiar ground for anyone who uses
Inform. Some standard kinds:

= (early code)
kind *K_action_name = NULL;
kind *K_equation = NULL;
kind *K_grammatical_gender = NULL;
kind *K_natural_language = NULL;
kind *K_number = NULL;
kind *K_object = NULL;
kind *K_real_number = NULL;
kind *K_response = NULL;
kind *K_snippet = NULL;
kind *K_stored_action = NULL;
kind *K_table = NULL;
kind *K_text = NULL;
kind *K_truth_state = NULL;
kind *K_unicode_character = NULL;
kind *K_use_option = NULL;
kind *K_verb = NULL;

@ And here are two more standard kinds, but which most Inform uses don't
realise are there, because they are omitted from the Kinds index:

(a) |K_rulebook_outcome|. Rulebooks end in success, failure, no outcome, or
possibly one of a range of named alternative outcomes. These all share a
single namespace, and the names in question share a single kind of value.
It's not a very elegant system, and we really don't want people storing
these in variables; we want them to be used only as part of the process of
receiving the outcome back. So although there's no technical reason why this
kind shouldn't be used for storage, it's hidden from the user.

(b) |K_understanding| is used to hold the result of a grammar token. An actual
constant value specification of this kind stores a |grammar_verb *| pointer.

= (early code)
kind *K_rulebook_outcome = NULL;
kind *K_understanding = NULL;

@ Finally, the standard set of constructors:

= (early code)
kind_constructor *CON_list_of = NULL;
kind_constructor *CON_description = NULL;
kind_constructor *CON_relation = NULL;
kind_constructor *CON_rule = NULL;
kind_constructor *CON_rulebook = NULL;
kind_constructor *CON_activity = NULL;
kind_constructor *CON_phrase = NULL;
kind_constructor *CON_property = NULL;
kind_constructor *CON_table_column = NULL;
kind_constructor *CON_combination = NULL;
kind_constructor *CON_variable = NULL;

@h Kind names in Inter code.
We defined some "constant" kinds and constructors above, to provide values
like |K_number| for use in this C source code. We will also want to refer to
these kinds in the Inter code generated by Inform, where they will have
identifiers such as |NUMBER_TY|.

So we need a way of pairing up names in these two source codes, and here
it is. There is no need for speed here.

@d IDENTIFIERS_CORRESPOND(text_of_I6_name, what_have_you)
	if ((sn) && (Str::eq_narrow_string(sn, text_of_I6_name))) return what_have_you;

=
kind_constructor **FamiliarKinds::known_con(text_stream *sn) {
	IDENTIFIERS_CORRESPOND("ACTIVITY_TY", &CON_activity);
	IDENTIFIERS_CORRESPOND("COMBINATION_TY", &CON_combination);
	IDENTIFIERS_CORRESPOND("DESCRIPTION_OF_TY", &CON_description);
	IDENTIFIERS_CORRESPOND("INTERMEDIATE_TY", &CON_INTERMEDIATE);
	IDENTIFIERS_CORRESPOND("KIND_VARIABLE_TY", &CON_KIND_VARIABLE);
	IDENTIFIERS_CORRESPOND("LIST_OF_TY", &CON_list_of);
	IDENTIFIERS_CORRESPOND("PHRASE_TY", &CON_phrase);
	IDENTIFIERS_CORRESPOND("NIL_TY", &CON_NIL);
	IDENTIFIERS_CORRESPOND("VOID_TY", &CON_VOID);
	IDENTIFIERS_CORRESPOND("PROPERTY_TY", &CON_property);
	IDENTIFIERS_CORRESPOND("RELATION_TY", &CON_relation);
	IDENTIFIERS_CORRESPOND("RULE_TY", &CON_rule);
	IDENTIFIERS_CORRESPOND("RULEBOOK_TY", &CON_rulebook);
	IDENTIFIERS_CORRESPOND("TABLE_COLUMN_TY", &CON_table_column);
	IDENTIFIERS_CORRESPOND("TUPLE_ENTRY_TY", &CON_TUPLE_ENTRY);
	IDENTIFIERS_CORRESPOND("UNKNOWN_TY", &CON_UNKNOWN);
	IDENTIFIERS_CORRESPOND("VARIABLE_TY", &CON_variable);
	return NULL;
}

kind **FamiliarKinds::known_kind(text_stream *sn) {
	IDENTIFIERS_CORRESPOND("ARITHMETIC_VALUE_TY", &K_arithmetic_value);
	IDENTIFIERS_CORRESPOND("ENUMERATED_VALUE_TY", &K_enumerated_value);
	IDENTIFIERS_CORRESPOND("EQUATION_TY", &K_equation);
	IDENTIFIERS_CORRESPOND("TEXT_TY", &K_text);
	IDENTIFIERS_CORRESPOND("NUMBER_TY", &K_number);
	IDENTIFIERS_CORRESPOND("OBJECT_TY", &K_object);
	IDENTIFIERS_CORRESPOND("POINTER_VALUE_TY", &K_pointer_value);
	IDENTIFIERS_CORRESPOND("STORED_VALUE_TY", &K_stored_value);
	IDENTIFIERS_CORRESPOND("REAL_ARITHMETIC_VALUE_TY", &K_real_arithmetic_value);
	IDENTIFIERS_CORRESPOND("REAL_NUMBER_TY", &K_real_number);
	IDENTIFIERS_CORRESPOND("RESPONSE_TY", &K_response);
	IDENTIFIERS_CORRESPOND("RULEBOOK_OUTCOME_TY", &K_rulebook_outcome);
	IDENTIFIERS_CORRESPOND("SAYABLE_VALUE_TY", &K_sayable_value);
	IDENTIFIERS_CORRESPOND("SNIPPET_TY", &K_snippet);
	IDENTIFIERS_CORRESPOND("TABLE_TY", &K_table);
	IDENTIFIERS_CORRESPOND("TRUTH_STATE_TY", &K_truth_state);
	IDENTIFIERS_CORRESPOND("UNDERSTANDING_TY", &K_understanding);
	IDENTIFIERS_CORRESPOND("UNKNOWN_TY", &K_unknown);
	IDENTIFIERS_CORRESPOND("UNICODE_CHARACTER_TY", &K_unicode_character);
	IDENTIFIERS_CORRESPOND("USE_OPTION_TY", &K_use_option);
	IDENTIFIERS_CORRESPOND("VALUE_TY", &K_value);
	IDENTIFIERS_CORRESPOND("VERB_TY", &K_verb);
	IDENTIFIERS_CORRESPOND("NIL_TY", &K_nil);
	IDENTIFIERS_CORRESPOND("VOID_TY", &K_void);
	return NULL;
}

int FamiliarKinds::is_known(text_stream *sn) {
	if (FamiliarKinds::known_con(sn)) return TRUE;
	if (FamiliarKinds::known_kind(sn)) return TRUE;
	return FALSE;
}

@h Kind names in source text.
Inform creates the "natural language" kind in source text, not by loading it
from a file, but we still need to refer to it in the compiler. Similarly for
"grammatical gender". The others here are not referred to in the compiler,
but are indexed together.

=
<notable-linguistic-kinds> ::=
	natural language |
	grammatical gender |
	grammatical tense |
	narrative viewpoint |
	grammatical case

@ =
void FamiliarKinds::notice_new_kind(kind *K, wording W) {
	if (<notable-linguistic-kinds>(W)) {
		Kinds::Constructors::mark_as_linguistic(K->construct);
		switch (<<r>>) {
			case 0: K_natural_language = K;
				#ifdef NOTIFY_NATURAL_LANGUAGE_KINDS_CALLBACK
				NOTIFY_NATURAL_LANGUAGE_KINDS_CALLBACK(K);
				#endif
				break;
			case 1: K_grammatical_gender = K; break;
		}
	}
}
