[CopyErrors::] Copy Errors.

A copy error is attached to a copy when scanning it reveals some malformation.

@ Copies can sometimes exist in a damaged form: for example, they are purportedly
extension files but have a mangled identification line. Each copy structure
therefore has a list attached of errors which occurred in reading it.

Each copy error has one of the following categories, and some are divided into
subcategories too. Otherwise an error has no real contents: only a ragbag of
contextual data -- exactly what word it is that is too long, where the
sentence is which is mis-punctuated, and such. In every case most of these
fields are blank.

@e OPEN_FAILED_CE from 1
@e METADATA_MALFORMED_CE
@e EXT_MISWORDED_CE
@e EXT_TITLE_TOO_LONG_CE
@e EXT_AUTHOR_TOO_LONG_CE
@e LEXER_CE /* an error generated by the |words| module */
@e SYNTAX_CE /* an error generated by the |syntax| module, or by our reading of the tree */

=
typedef struct copy_error {
	struct inbuild_copy *copy;

	int error_category;
	int error_subcategory;

	struct text_stream *details;
	struct filename *details_file;
	int details_N;
	struct wording details_W;
	struct parse_node *details_node;
	struct parse_node *details_node2;
	struct inbuild_work *details_work;
	struct inbuild_work *details_work2;
	wchar_t *details_word;

	CLASS_DEFINITION
} copy_error;

@ And now some creators.

=
copy_error *CopyErrors::new(int cat, int subcat) {
	copy_error *CE = CREATE(copy_error);
	CE->copy = NULL;
	CE->error_category = cat;
	CE->error_subcategory = subcat;
	CE->details = NULL;
	CE->details_file = NULL;
	CE->details_N = -1;
	CE->details_W = EMPTY_WORDING;
	CE->details_node = NULL;
	CE->details_node2 = NULL;
	CE->details_work = NULL;
	CE->details_work2 = NULL;
	CE->details_word = NULL;
	return CE;
}

copy_error *CopyErrors::new_T(int cat, int subcat, text_stream *NB) {
	copy_error *CE = CopyErrors::new(cat, subcat);
	CE->details = Str::duplicate(NB);
	return CE;
}

copy_error *CopyErrors::new_N(int cat, int subcat, int N) {
	copy_error *CE = CopyErrors::new(cat, subcat);
	CE->details_N = N;
	return CE;
}

copy_error *CopyErrors::new_F(int cat, int subcat, filename *F) {
	copy_error *CE = CopyErrors::new(cat, subcat);
	CE->details_file = F;
	return CE;
}

copy_error *CopyErrors::new_WT(int cat, int subcat, wchar_t *details_word, text_stream *NB) {
	copy_error *CE = CopyErrors::new(cat, subcat);
	CE->details_word = details_word;
	CE->details = Str::duplicate(NB);
	return CE;
}

@ It becomes tiresome to make creators for every conceivable possibility, so
we also offer these functions to tack extra details on:

=
void CopyErrors::supply_wording(copy_error *CE, wording details_W) {
	CE->details_W = details_W;
}

void CopyErrors::supply_work(copy_error *CE, inbuild_work *w) {
	CE->details_work = w;
}

void CopyErrors::supply_works(copy_error *CE, inbuild_work *w1, inbuild_work *w2) {
	CE->details_work = w1;
	CE->details_work2 = w2;
}

void CopyErrors::supply_node(copy_error *CE, parse_node *n) {
	CE->details_node = n;
}

void CopyErrors::supply_nodes(copy_error *CE, parse_node *n1, parse_node *n2) {
	CE->details_node = n1;
	CE->details_node2 = n2;
}

@ The following should only be called from Copies.

=
void CopyErrors::supply_attached_copy(copy_error *CE, inbuild_copy *C) {
	CE->copy = C;
}

@ This produces a textual summary of the issue described. It wouldn't do for
a proper Inform problem message, but it's fine for the Inbuild command line
output.

=
void CopyErrors::write(OUTPUT_STREAM, copy_error *CE) {
	switch (CE->error_category) {
		case OPEN_FAILED_CE: WRITE("unable to open file %f", CE->details_file); break;
		case EXT_MISWORDED_CE: WRITE("extension misworded: %S", CE->details); break;
		case METADATA_MALFORMED_CE: WRITE("%S has incorrect metadata: %S",
			CE->copy->edition->work->genre->genre_name, CE->details); break;
		case EXT_TITLE_TOO_LONG_CE: WRITE("title too long: %d characters (max is %d)",
			CE->details_N, MAX_EXTENSION_TITLE_LENGTH); break;
		case EXT_AUTHOR_TOO_LONG_CE: WRITE("author name too long: %d characters (max is %d)",
			CE->details_N, MAX_EXTENSION_AUTHOR_LENGTH); break;
		case LEXER_CE: @<Write a lexer error@>; break;
		case SYNTAX_CE: @<Write a syntax error@>; break;
		default: internal_error("an unknown error occurred");
	}
}

@<Write a lexer error@> =
	switch (CE->error_subcategory) {
		case STRING_TOO_LONG_LEXERERROR:
			WRITE("Too much text in quotation marks: %w", CE->details_word); break;
		case WORD_TOO_LONG_LEXERERROR:
			WRITE("Word too long: %w", CE->details_word); break;
		case I6_TOO_LONG_LEXERERROR:
			WRITE("I6 inclusion too long: %w", CE->details_word); break;
		case STRING_NEVER_ENDS_LEXERERROR:
			WRITE("Quoted text never ends: %S", CE->details); break;
		case COMMENT_NEVER_ENDS_LEXERERROR:
			WRITE("Square-bracketed text never ends: %S", CE->details); break;
		case I6_NEVER_ENDS_LEXERERROR:
			WRITE("I6 inclusion text never ends: %S", CE->details); break;
		default:
			WRITE("lexer error"); break;
	}

@<Write a syntax error@> =
	switch (CE->error_subcategory) {
		case UnexpectedSemicolon_SYNERROR:
			WRITE("unexpected semicolon in sentence"); break;
		case ParaEndsInColon_SYNERROR:
			WRITE("paragraph ends with a colon"); break;
		case SentenceEndsInColon_SYNERROR:
			WRITE("paragraph ends with a colon and full stop"); break;
		case SentenceEndsInSemicolon_SYNERROR:
			WRITE("paragraph ends with a semicolon and full stop"); break;
		case SemicolonAfterColon_SYNERROR:
			WRITE("paragraph ends with a colon and semicolon"); break;
		case SemicolonAfterStop_SYNERROR:
			WRITE("paragraph ends with a full stop and semicolon"); break;
		case HeadingOverLine_SYNERROR:
			WRITE("heading contains a line break"); break;
		case HeadingStopsBeforeEndOfLine_SYNERROR:
			WRITE("heading stops before end of line"); break;
		case ExtNoBeginsHere_SYNERROR:
			WRITE("extension has no beginning"); break;
		case ExtNoEndsHere_SYNERROR:
			WRITE("extension has no end"); break;
		case ExtSpuriouslyContinues_SYNERROR:
			WRITE("extension continues after end"); break;
		case ExtMultipleBeginsHere_SYNERROR:
			WRITE("extension has multiple 'begins here' sentences"); break;
		case ExtBeginsAfterEndsHere_SYNERROR:
			WRITE("extension has a 'begins here' after its 'ends here'"); break;
		case ExtEndsWithoutBegins_SYNERROR:
			WRITE("extension has an 'ends here' but no 'begins here'"); break;
		case ExtMultipleEndsHere_SYNERROR:
			WRITE("extension has multiple 'ends here' sentences"); break;
		case BadTitleSentence_SYNERROR:
			WRITE("bibliographic sentence at the start is malformed"); break;
		case UnknownLanguageElement_SYNERROR:
			WRITE("unrecognised stipulation about Inform language elements"); break;
		case UnknownVirtualMachine_SYNERROR:
			WRITE("unrecognised stipulation about virtual machine"); break;
		case UseElementWithdrawn_SYNERROR:
			WRITE("use language element is no longer supported"); break;
		case IncludeExtQuoted_SYNERROR:
			WRITE("extension name should not be double-quoted"); break;
		case BogusExtension_SYNERROR:
			WRITE("can't find this extension"); break;
		case ExtVersionTooLow_SYNERROR:
			WRITE("extension version too low"); break;
		case ExtVersionMalformed_SYNERROR:
			WRITE("extension version is malformed"); break;
		case ExtInadequateVM_SYNERROR:
			WRITE("extension is not compatible with the target virtual machine"); break;
		case ExtMisidentifiedEnds_SYNERROR:
			WRITE("extension has an 'ends here' which doesn't match the 'begins here'"); break;
		case HeadingInPlaceOfUnincluded_SYNERROR:
			WRITE("heading is in place of an extension not included"); break;
		case UnequalHeadingInPlaceOf_SYNERROR:
			WRITE("heading is in place of another heading but of a different level"); break;
		case HeadingInPlaceOfSubordinate_SYNERROR:
			WRITE("heading is in place of another heading subordinate to itself"); break;
		case HeadingInPlaceOfUnknown_SYNERROR:
			WRITE("heading is in place of another heading which doesn't exist"); break;
		case UnavailableLOS_SYNERROR:
			WRITE("this language bundle does not provide Preform syntax"); break;
		default:
			WRITE("syntax error"); break;
	}
