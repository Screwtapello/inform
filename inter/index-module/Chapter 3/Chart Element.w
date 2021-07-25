[ChartElement::] Chart Element.

To write the Chart element (Ch) in the index.

@ This is a table of kinds of value, followed by a set of descriptions of each,
and it is quite dense with information.

=
void ChartElement::render(OUTPUT_STREAM, localisation_dictionary *D) {
	inter_tree *I = InterpretIndex::get_tree();
	tree_inventory *inv = Synoptic::inv(I);
	TreeLists::sort(inv->kind_nodes, Synoptic::module_order);
	TreeLists::sort(inv->instance_nodes, Synoptic::module_order);
	HTML::begin_wide_html_table(OUT);
	int pass = 1;
	@<Add a dotty row to the chart of kinds@>;
	@<Add a titling row to the chart of kinds@>;
	@<Add a dotty row to the chart of kinds@>;
	@<Add the rubric below the chart of kinds@>;
	@<Run through the kinds in priority order@>;
	@<Add a dotty row to the chart of kinds@>;
	HTML::end_html_table(OUT);
	pass = 2;
	@<Run through the kinds in priority order@>;
	@<Explain about covariance and contravariance@>;
}

@ Not all of the built-in kinds are indexed on the Kinds page. The ones
omitted are of no help to end users, and would only clutter up the table
with misleading entries. Remaining kinds are grouped together in
"priority" order, a device to enable the quasinumerical kinds to stick
together, the enumerative ones, and so on. A lower priority number puts you
higher up, but kinds with priority 0 do not appear in the index at all.

@d LOWEST_INDEX_PRIORITY 100

@<Run through the kinds in priority order@> =
	for (int priority = 1; priority <= LOWEST_INDEX_PRIORITY; priority++) {
		inter_package *pack;
		LOOP_OVER_INVENTORY_PACKAGES(pack, i, inv->kind_nodes)
			if ((Metadata::read_optional_numeric(pack, I"^is_base")) &&
				(Metadata::read_optional_numeric(pack, I"^is_subkind_of_object") == 0) &&
				(priority == (int) Metadata::read_optional_numeric(pack, I"^index_priority"))) {
				if ((priority == 8) || (Metadata::read_optional_numeric(pack, I"^is_definite"))) {
					@<Index this kind package@>;
				}
			}
		if ((priority == 1) || (priority == 6) || (priority == 7)) {
			if (pass == 1) {
				@<Add a dotty row to the chart of kinds@>;
				if (priority == 7) {
					@<Add a second titling row to the chart of kinds@>;
					@<Add a dotty row to the chart of kinds@>;
				}
			} else HTML_TAG("hr");
		}
	}

@ An atypical row:

@<Add a titling row to the chart of kinds@> =
	HTML::first_html_column_nowrap(OUT, 0, "#e0e0e0");
	WRITE("<b>");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.BasicKinds");
	WRITE("</b>");
	ChartElement::index_kind_col_head(OUT, I"Index.Elements.Ch.DefaultColumn", "default", D);
	ChartElement::index_kind_col_head(OUT, I"Index.Elements.Ch.RepeatColumn", "repeat", D);
	ChartElement::index_kind_col_head(OUT, I"Index.Elements.Ch.PropsColumn", "props", D);
	ChartElement::index_kind_col_head(OUT, I"Index.Elements.Ch.UnderColumn", "under", D);
	HTML::end_html_row(OUT);

@ And another:

@<Add a second titling row to the chart of kinds@> =
	HTML::first_html_column_nowrap(OUT, 0, "#e0e0e0");
	WRITE("<b>");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.NewKinds");
	WRITE("</b>");
	ChartElement::index_kind_col_head(OUT, I"Index.Elements.Ch.DefaultColumn", "default", D);
	ChartElement::index_kind_col_head(OUT, NULL, NULL, D);
	ChartElement::index_kind_col_head(OUT, NULL, NULL, D);
	ChartElement::index_kind_col_head(OUT, NULL, NULL, D);
	HTML::end_html_row(OUT);

@ A dotty row:

@<Add a dotty row to the chart of kinds@> =
	HTML_OPEN_WITH("tr", "bgcolor=\"#888\"");
	HTML_OPEN_WITH("td", "height=\"1\" colspan=\"5\" cellpadding=\"0\"");
	HTML_CLOSE("td");
	HTML_CLOSE("tr");

@ Note the named IDs here, which must match those linked from the titling
row.

@<Add the rubric below the chart of kinds@> =
	HTML_OPEN_WITH("tr", "style=\"display:none\" id=\"default\"");
	HTML_OPEN_WITH("td", "colspan=\"5\"");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.DefaultGloss");
	HTML_TAG("hr");
	HTML_CLOSE("td");
	HTML_CLOSE("tr");
	HTML_OPEN_WITH("tr", "style=\"display:none\" id=\"repeat\"");
	HTML_OPEN_WITH("td", "colspan=\"5\"");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.RepeatGloss");
	HTML_TAG("hr");
	HTML_CLOSE("td");
	HTML_CLOSE("tr");
	HTML_OPEN_WITH("tr", "style=\"display:none\" id=\"props\"");
	HTML_OPEN_WITH("td", "colspan=\"5\"");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.PropsGloss");
	HTML_TAG("hr");
	HTML_CLOSE("td");
	HTML_CLOSE("tr");
	HTML_OPEN_WITH("tr", "style=\"display:none\" id=\"under\"");
	HTML_OPEN_WITH("td", "colspan=\"5\"");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.UnderGloss");
	HTML_TAG("hr");
	HTML_CLOSE("td");
	HTML_CLOSE("tr");

@ So, the actual content, which is presented as a row of the table in pass 1,
or as paragraph of text in pass 2:

@<Index this kind package@> =
	switch (pass) {
		case 1: {
			char *repeat = "cross", *props = "cross", *under = "cross";
			int shaded = FALSE;
			if (Metadata::read_optional_numeric(pack, I"^shaded_in_index")) shaded = TRUE;
			if (Metadata::read_optional_numeric(pack, I"^finite_domain")) repeat = "tick";
			if (Metadata::read_optional_numeric(pack, I"^has_properties")) props = "tick";
			if (Metadata::read_optional_numeric(pack, I"^understandable")) under = "tick";
			if (priority == 8) { repeat = NULL; props = NULL; under = NULL; }
			ChartElement::begin_chart_row(OUT);
			ChartElement::index_kind_name_cell(OUT, shaded, pack);
			ChartElement::end_chart_row(OUT, shaded, pack, repeat, props, under);
			break;
		}
		case 2: {
			@<Write heading for the detailed index entry for this kind@>;
			HTML::open_indented_p(OUT, 1, "tight");
			@<Index kinds of kinds matched by this kind@>;
			@<Index explanatory text supplied for a kind@>;
			@<Index literal patterns which can specify this kind@>;
			@<Index possible values of an enumerated kind@>;
			HTML_CLOSE("p");
			break;
		}
	}
	if (Str::eq(Metadata::read_textual(pack, I"^printed_name"), I"object"))
		ChartElement::index_subkinds(OUT, inv, pack, 2, pass, D);

@<Write heading for the detailed index entry for this kind@> =
	HTML::open_indented_p(OUT, 1, "halftight");
	IndexUtilities::anchor_numbered(OUT, i); /* ...the anchor to which the grey icon in the table led */
	WRITE("<b>"); IndexUtilities::kind_name(OUT, pack, FALSE, TRUE); WRITE("</b>");
	WRITE(" (");
	Localisation::italic_0(OUT, D, I"Index.Elements.Ch.Plural");
	WRITE(" ");
	IndexUtilities::kind_name(OUT, pack, TRUE, FALSE); WRITE(")");
	IndexUtilities::link_to_documentation(OUT, pack);
	HTML_CLOSE("p");
	text_stream *variance =  Metadata::read_optional_textual(pack, I"^variance");
	if (Str::len(variance) > 0) {
		HTML::open_indented_p(OUT, 1, "tight");
		WRITE("<i>%S&nbsp;", variance);
		HTML_OPEN_WITH("a", "href=#contra>");
		HTML_TAG_WITH("img", "border=0 src=inform:/doc_images/shelp.png");
		HTML_CLOSE("a");
		WRITE("</i>");
		HTML_CLOSE("p");
	}

@<Index literal patterns which can specify this kind@> =
	text_stream *notation = Metadata::read_optional_textual(pack, I"^notation");
	if (Str::len(notation) > 0) {
		WRITE("%S", notation);
		HTML_TAG("br");
	}

@<Index kinds of kinds matched by this kind@> =
	int f = FALSE;
	WRITE("<i>Matches:</i> ");
	inter_package *conf_pack;
	LOOP_THROUGH_SUBPACKAGES(conf_pack, pack, I"_conformance") {
		inter_symbol *xref = Metadata::read_optional_symbol(conf_pack, I"^conformed_to");
		inter_package *other = Inter::Packages::container(xref->definition);
		if (f) WRITE(", ");
		IndexUtilities::kind_name(OUT, other, FALSE, TRUE);
		f = TRUE;
	}
	HTML_TAG("br");

@<Index possible values of an enumerated kind@> =
	if (Str::ne(Metadata::read_textual(pack, I"^printed_name"), I"object"))
		if (Metadata::read_optional_numeric(pack, I"^instance_count") > 0)
			ChartElement::index_instances(OUT, inv, pack, 1);

@<Index explanatory text supplied for a kind@> =
	ChartElement::index_inferences(OUT, pack, FALSE);

@<Explain about covariance and contravariance@> =
	HTML_OPEN("p");
	HTML_TAG_WITH("a", "name=contra");
	HTML_OPEN_WITH("span", "class=\"smaller\"");
	Localisation::write_0(OUT, D, I"Index.Elements.Ch.CovarianceGloss");
	HTML_CLOSE("span");
	HTML_CLOSE("p");

@h Kind table construction.
First, here's the table cell for the heading at the top of a column: the
link is to the part of the rubric explaining what goes into the column.

=
void ChartElement::index_kind_col_head(OUTPUT_STREAM, text_stream *key, char *anchor,
	localisation_dictionary *D) {
	HTML::next_html_column_nowrap(OUT, 0);
	WRITE("<i>");
	if (Str::len(key) > 0) Localisation::write_0(OUT, D, key);
	WRITE("</i>&nbsp;");
	if (anchor) {
		HTML_OPEN_WITH("a", "href=\"#\" onClick=\"showBasic('%s');\"", anchor);
		HTML_TAG_WITH("img", "border=0 src=inform:/doc_images/shelp.png");
		HTML_CLOSE("a");
	}
}

@ Once we're past the heading row, each row is made in two parts: first this
is called --

=
int striper = FALSE;
void ChartElement::begin_chart_row(OUTPUT_STREAM) {
	char *col = NULL;
	if (striper) col = "#f0f0ff";
	striper = striper?FALSE:TRUE;
	HTML::first_html_column_nowrap(OUT, 0, col);
}

@ It's convenient to return the shadedness: a row is shaded if it's for a kind
which can have enumerated values but doesn't at the moment -- for instance, the
sound effects row is shaded if there are none.

=
int ChartElement::index_kind_name_cell(OUTPUT_STREAM, int shaded, inter_package *pack) {
	if (shaded) HTML::begin_colour(OUT, I"808080");
	IndexUtilities::kind_name(OUT, pack, FALSE, TRUE);
	if (Metadata::read_optional_numeric(pack, I"^is_quasinumerical")) {
		WRITE("&nbsp;");
		HTML_OPEN_WITH("a", "href=\"Kinds.html?segment2\"");
		HTML_TAG_WITH("img", "border=0 src=inform:/doc_images/calc1.png");
		HTML_CLOSE("a");
	}
	IndexUtilities::link_to_documentation(OUT, pack);
	int i = (int) Metadata::read_optional_numeric(pack, I"^instance_count");
	if (i >= 1) WRITE(" [%d]", i);
	IndexUtilities::below_link_numbered(OUT, pack->allocation_id);
	if (shaded) HTML::end_colour(OUT);
	return shaded;
}

@ Finally we close the name cell, add the remaining cells, and close out the
whole row.

=
void ChartElement::end_chart_row(OUTPUT_STREAM, int shaded, inter_package *pack,
	char *tick1, char *tick2, char *tick3) {
	if (tick1) HTML::next_html_column(OUT, 0);
	else HTML::next_html_column_spanning(OUT, 0, 4);
	if (shaded) HTML::begin_colour(OUT, I"808080");
	WRITE("%S", Metadata::read_optional_textual(pack, I"^index_default"));
	if (shaded) HTML::end_colour(OUT);
	if (tick1) {
		HTML::next_html_column_centred(OUT, 0);
		if (tick1)
			HTML_TAG_WITH("img",
				"border=0 alt=\"%s\" src=inform:/doc_images/%s%s.png",
				tick1, shaded?"grey":"", tick1);
		HTML::next_html_column_centred(OUT, 0);
		if (tick2)
			HTML_TAG_WITH("img",
				"border=0 alt=\"%s\" src=inform:/doc_images/%s%s.png",
				tick2, shaded?"grey":"", tick2);
		HTML::next_html_column_centred(OUT, 0);
		if (tick3)
			HTML_TAG_WITH("img",
				"border=0 alt=\"%s\" src=inform:/doc_images/%s%s.png",
				tick3, shaded?"grey":"", tick3);
	}
	HTML::end_html_row(OUT);
}

@h Recursing through subkinds.
The following limitation exists just to catch errors.

@d MAX_OBJECT_INDEX_DEPTH 10000

=
void ChartElement::index_subkinds(OUTPUT_STREAM, tree_inventory *inv, inter_package *pack,
	int depth, int pass, localisation_dictionary *D) {
	inter_package *subkind_pack;
	LOOP_OVER_INVENTORY_PACKAGES(subkind_pack, i, inv->kind_nodes)
		if ((Metadata::read_optional_numeric(subkind_pack, I"^is_base")) &&
			(Metadata::read_optional_numeric(subkind_pack, I"^is_subkind_of_object"))) {
			inter_symbol *super_weak = Metadata::read_optional_symbol(subkind_pack, I"^superkind");
			if ((super_weak) && (Inter::Packages::container(super_weak->definition) == pack))
				ChartElement::index_object_kind(OUT, inv, subkind_pack, depth, pass, D);
		}
}

void ChartElement::index_object_kind(OUTPUT_STREAM, tree_inventory *inv,
	inter_package *pack, int depth, int pass, localisation_dictionary *D) {
	if (depth == MAX_OBJECT_INDEX_DEPTH) internal_error("MAX_OBJECT_INDEX_DEPTH exceeded");
	inter_symbol *class_s = Metadata::read_optional_symbol(pack, I"^object_class");
	if (class_s == NULL) internal_error("no class for object kind");
	text_stream *anchor = class_s->symbol_name;

	int shaded = FALSE;
	@<Begin the object citation line@>;
	@<Index the name part of the object citation@>;
	@<Index the link icons part of the object citation@>;
	@<End the object citation line@>;
	if (pass == 2) @<Add a subsidiary paragraph of details about this object@>;
	ChartElement::index_subkinds(OUT, inv, pack, depth+1, pass, D);
}

@<Begin the object citation line@> =
	if (pass == 1) ChartElement::begin_chart_row(OUT);
	if (pass == 2) {
		HTML::open_indented_p(OUT, depth, "halftight");
		IndexUtilities::anchor(OUT, anchor);
	}

@<End the object citation line@> =
	if (pass == 1) ChartElement::end_chart_row(OUT, shaded, pack, "tick", "tick", "tick");
	if (pass == 2) HTML_CLOSE("p");

@<Index the name part of the object citation@> =
	if (pass == 1) {
		int c = (int) Metadata::read_optional_numeric(pack, I"^instance_count");
		if ((c == 0) && (pass == 1)) shaded = TRUE;
		if (shaded) HTML::begin_colour(OUT, I"808080");
		@<Quote the name of the object being indexed@>;
		if (shaded) HTML::end_colour(OUT);
		if ((pass == 1) && (c > 0)) WRITE(" [%d]", c);
	} else {
		@<Quote the name of the object being indexed@>;
	}

@<Quote the name of the object being indexed@> =
	if (pass == 2) WRITE("<b>");
	IndexUtilities::kind_name(OUT, pack, FALSE, FALSE);
	if (pass == 2) WRITE("</b>");
	if (pass == 2) {
		WRITE(" (");
		Localisation::italic_0(OUT, D, I"Index.Elements.Ch.Plural");
		WRITE(" ");
		IndexUtilities::kind_name(OUT, pack, TRUE, FALSE);
		WRITE(")");
	}

@<Index the link icons part of the object citation@> =
	IndexUtilities::link_package(OUT, pack);
	IndexUtilities::link_to_documentation(OUT, pack);
	if (pass == 1) IndexUtilities::below_link(OUT, anchor);

@<Add a subsidiary paragraph of details about this object@> =
	HTML::open_indented_p(OUT, depth, "tight");
	ChartElement::index_inferences(OUT, pack, TRUE);
	HTML_CLOSE("p");
	ChartElement::index_instances(OUT, inv, pack, depth);

@ =
void ChartElement::index_instances(OUTPUT_STREAM, tree_inventory *inv, inter_package *pack,
	int depth) {
	HTML::open_indented_p(OUT, depth, "tight");
	int c = (int) Metadata::read_optional_numeric(pack, I"^instance_count");
	if (c >= 10) {
		int xtra = IndexRules::extra_ID();
		IndexUtilities::extra_link(OUT, xtra);
		HTML::begin_colour(OUT, I"808080");
		WRITE("%d ", c);
		IndexUtilities::kind_name(OUT, pack, TRUE, FALSE);
		HTML::end_colour(OUT);
		HTML_CLOSE("p");
		IndexUtilities::extra_div_open(OUT, xtra, depth+1, "e0e0e0");
		@<Itemise the instances@>;
		IndexUtilities::extra_div_close(OUT, "e0e0e0");
	} else {
		@<Itemise the instances@>;
		HTML_CLOSE("p");
	}
}

@<Itemise the instances@> =
	int c = 0;
	inter_package *I_pack;
	LOOP_OVER_INVENTORY_PACKAGES(I_pack, i, inv->instance_nodes) {
		inter_symbol *strong_kind_ID = Metadata::read_optional_symbol(I_pack, I"^kind_xref");
		if ((strong_kind_ID) && (Inter::Packages::container(strong_kind_ID->definition) == pack)) {
			if (c > 0) WRITE(", "); c++;
			HTML::begin_colour(OUT, I"808080");
			WRITE("%S", Metadata::read_optional_textual(I_pack, I"^name"));
			HTML::end_colour(OUT);
			IndexUtilities::link_package(OUT, I_pack);
		}
	}

@ Here |pack| can be either an instance or a kind package.

=
void ChartElement::index_inferences(OUTPUT_STREAM, inter_package *pack, int brief) {
	text_stream *explanation = Metadata::read_optional_textual(pack, I"^specification");
	if (Str::len(explanation) > 0) {
		WRITE("%S", explanation);
		HTML_TAG("br");
	}
	text_stream *material = NULL;
	if (brief) material = Metadata::read_optional_textual(pack, I"^brief_inferences");
	else material = Metadata::read_optional_textual(pack, I"^inferences");
	WRITE("%S", material);
}
