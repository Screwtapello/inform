[SynopticActions::] Actions.

To compile the main/synoptic/actions submodule.

@ Before this runs, action packages are scattered all over the Inter tree.
We must allocate each one a unique ID.

As this is called, //Synoptic Utilities// has already formed a list |action_nodes|
of packages of type |_action|.

@ The access possibilities for the noun and second are as follows:

@d UNRESTRICTED_ACCESS 1 /* question not meaningful, e.g. for a number */
@d DOESNT_REQUIRE_ACCESS 2 /* actor need not be able to touch this object */
@d REQUIRES_ACCESS 3 /* actor must be able to touch this object */
@d REQUIRES_POSSESSION 4 /* actor must be carrying this object */

=
void SynopticActions::compile(inter_tree *I, tree_inventory *inv) {
	if (TreeLists::len(inv->action_nodes) > 0) {
		TreeLists::sort(inv->action_nodes, Synoptic::module_order);
		for (int i=0; i<TreeLists::len(inv->action_nodes); i++) {
			inter_package *pack = Inter::Package::defined_by_frame(inv->action_nodes->list[i].node);
			inter_tree_node *D = Synoptic::get_definition(pack, I"action_id");
			D->W.data[DATA_CONST_IFLD+1] = (inter_ti) i;
			D = Synoptic::get_optional_definition(pack, I"var_id");
			if (D) D->W.data[DATA_CONST_IFLD+1] = (inter_ti) (20000 + i);
		}
	}
	@<Define CCOUNT_ACTION_NAME@>;
	@<Define AD_RECORDS@>;
	if (TreeLists::len(inv->action_nodes) > 0) {
		@<Define ACTIONHAPPENED array@>;
		@<Define ACTIONCODING array@>;
		@<Define ACTIONDATA array@>;
	}
	@<Define DB_ACTION_DETAILS function@>;
}

@<Define CCOUNT_ACTION_NAME@> =
	inter_name *iname = HierarchyLocations::find(I, CCOUNT_ACTION_NAME_HL);
	Produce::numeric_constant(I, iname, K_value, (inter_ti) TreeLists::len(inv->action_nodes));

@<Define AD_RECORDS@> =
	inter_name *iname = HierarchyLocations::find(I, AD_RECORDS_HL);
	Produce::numeric_constant(I, iname, K_value, (inter_ti) TreeLists::len(inv->action_nodes));

@<Define ACTIONHAPPENED array@> =
	inter_name *iname = HierarchyLocations::find(I, ACTIONHAPPENED_HL);
	Synoptic::begin_array(I, iname);
	for (int i=0; i<=(TreeLists::len(inv->action_nodes)/16); i++)
		Synoptic::numeric_entry(0);
	Synoptic::numeric_entry(0);
	Synoptic::end_array(I);

@<Define ACTIONCODING array@> =
	inter_name *iname = HierarchyLocations::find(I, ACTIONCODING_HL);
	Synoptic::begin_array(I, iname);
	for (int i=0; i<TreeLists::len(inv->action_nodes); i++) {
		inter_package *pack = Inter::Package::defined_by_frame(inv->action_nodes->list[i].node);
		inter_symbol *double_sharp_s = Metadata::read_optional_symbol(pack, I"^double_sharp");
		inter_ti no = Metadata::read_optional_numeric(pack, I"^no_coding");
		if ((no) || (double_sharp_s == NULL)) Synoptic::numeric_entry(0);
		else Synoptic::symbol_entry(double_sharp_s);
	}
	Synoptic::numeric_entry(0);
	Synoptic::end_array(I);

@<Define ACTIONDATA array@> =
	inter_name *iname = HierarchyLocations::find(I, ACTIONDATA_HL);
	Produce::annotate_iname_i(iname, TABLEARRAY_IANN, 1);
	Synoptic::begin_array(I, iname);
	for (int i=0; i<TreeLists::len(inv->action_nodes); i++) {
		inter_package *pack = Inter::Package::defined_by_frame(inv->action_nodes->list[i].node);
		inter_symbol *double_sharp_s = Metadata::read_optional_symbol(pack, I"^double_sharp");
		if (double_sharp_s == NULL) {
			Synoptic::numeric_entry(0);
			Synoptic::numeric_entry(0);
			Synoptic::numeric_entry(0);
			Synoptic::numeric_entry(0);
			Synoptic::numeric_entry(0);
		} else {
			Synoptic::symbol_entry(double_sharp_s);
			inter_ti out_of_world = Metadata::read_numeric(pack, I"^out_of_world");
			inter_ti requires_light = Metadata::read_numeric(pack, I"^requires_light");
			inter_ti can_have_noun = Metadata::read_numeric(pack, I"^can_have_noun");
			inter_ti can_have_second = Metadata::read_numeric(pack, I"^can_have_second");
			inter_ti noun_access = Metadata::read_numeric(pack, I"^noun_access");
			inter_ti second_access = Metadata::read_numeric(pack, I"^second_access");
			inter_symbol *noun_kind = Metadata::read_symbol(pack, I"^noun_kind");
			inter_symbol *second_kind = Metadata::read_symbol(pack, I"^second_kind");
			int mn = 0, ms = 0, ml = 0, mnp = 1, msp = 1, hn = 0, hs = 0;
			if (requires_light) ml = 1;
			if (noun_access == REQUIRES_ACCESS) mn = 1;
			if (second_access == REQUIRES_ACCESS) ms = 1;
			if (noun_access == REQUIRES_POSSESSION) { mn = 1; hn = 1; }
			if (second_access == REQUIRES_POSSESSION) { ms = 1; hs = 1; }
			if (can_have_noun == 0) mnp = 0;
			if (can_have_second == 0) msp = 0;
			inter_ti bitmap = (inter_ti) (mn + ms*0x02 + ml*0x04 + mnp*0x08 +
				msp*0x10 + (out_of_world?1:0)*0x20 + hn*0x40 + hs*0x80);
			Synoptic::numeric_entry(bitmap);
			Synoptic::symbol_entry(noun_kind);
			Synoptic::symbol_entry(second_kind);
			inter_symbol *vc_s = Metadata::read_optional_symbol(pack, I"^var_creator");
			if (vc_s) Synoptic::symbol_entry(vc_s);
			else Synoptic::numeric_entry(0);
		}
		Synoptic::numeric_entry((inter_ti) (20000 + i));
	}
	Synoptic::numeric_entry(0);
	Synoptic::end_array(I);

@<Define DB_ACTION_DETAILS function@> =
	inter_name *iname = HierarchyLocations::find(I, DB_ACTION_DETAILS_HL);
	Synoptic::begin_function(I, iname);
	inter_symbol *act_s = Synoptic::local(I, I"act", NULL);
	inter_symbol *n_s = Synoptic::local(I, I"n", NULL);
	inter_symbol *s_s = Synoptic::local(I, I"s", NULL);
	inter_symbol *for_say_s = Synoptic::local(I, I"for_say", NULL);
	Produce::inv_primitive(I, SWITCH_BIP);
	Produce::down(I);
		Produce::val_symbol(I, K_value, act_s);
		Produce::code(I);
		Produce::down(I);

	for (int i=0; i<TreeLists::len(inv->action_nodes); i++) {
		inter_package *pack = Inter::Package::defined_by_frame(inv->action_nodes->list[i].node);
		inter_symbol *double_sharp_s = Metadata::read_optional_symbol(pack, I"^double_sharp");
		if (double_sharp_s) {
			inter_symbol *debug_fn_s = Metadata::read_symbol(pack, I"^debug_fn");
			Produce::inv_primitive(I, CASE_BIP);
			Produce::down(I);
				Produce::val_symbol(I, K_value, double_sharp_s);
				Produce::code(I);
				Produce::down(I);
					Produce::inv_call(I, debug_fn_s);
					Produce::down(I);
						Produce::val_symbol(I, K_value, n_s);
						Produce::val_symbol(I, K_value, s_s);
						Produce::val_symbol(I, K_value, for_say_s);					
					Produce::up(I);
				Produce::up(I);
			Produce::up(I);
		}
	}

		Produce::up(I);
	Produce::up(I);
	Synoptic::end_function(I, iname);
