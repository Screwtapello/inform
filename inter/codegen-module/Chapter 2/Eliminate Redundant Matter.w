[CodeGen::Eliminate::] Eliminate Redundant Matter.

To remove (for example) functions which we can prove will never be called or
referred to as values.

@h Pipeline stage.
Experience shows that around 20 per cent of the code generated by Inform 7
consists of functions which are never in fact needed. Probably diligent
book-keeping at the generation stage could reduce some of that, but other
redundancies arise because of functions assimilated from the template, and
we don't have much control over that. This stage removes everything that
isn't used.

=
void CodeGen::Eliminate::create_pipeline_stage(void) {
	CodeGen::Stage::new(I"eliminate-redundant-code",
		CodeGen::Eliminate::run_pipeline_stage, NO_STAGE_ARG, FALSE);
}

int CodeGen::Eliminate::run_pipeline_stage(pipeline_step *step) {
	inter_tree *I = step->repository;
	Inter::Tree::traverse(I, CodeGen::Eliminate::package_preserver, NULL, NULL, PACKAGE_IST);
	Inter::Tree::traverse(I, CodeGen::Eliminate::package_destroyer, NULL, NULL, PACKAGE_IST);
	return TRUE;
}

@h Preservation.
We operate on a presumption of guilt: any package which we cannot prove is
needed will be deleted. |Main_fn| is clearly needed, since it is where
execution will begin. A handful of other functions, not called yet but
needed in the final compilation stage (and which replace stubs which would
otherwise be provided by the veneer), must also be included. Command
packages contain grammar for command verbs typed at run-time: these affect
an essential data structure (i.e., the parser grammar) implicitly, and so
we can't detect the dependency here. So we require all command packages to
be included.

=
void CodeGen::Eliminate::package_preserver(inter_tree *I, inter_tree_node *P, void *state) {
	inter_package *pack = Inter::Package::defined_by_frame(P);
	inter_symbol *ptype = Inter::Packages::type(pack);
	if (ptype == command_ptype_symbol)
		CodeGen::Eliminate::require(pack, NULL, I"it's a _command package");
	else if (ptype == property_ptype_symbol)
		CodeGen::Eliminate::require(pack, NULL, I"it's a _property package");
	else if (ptype == function_ptype_symbol) {
		if (Str::eq(pack->package_name->symbol_name, I"Main_fn"))
			CodeGen::Eliminate::require(pack, NULL, I"it's Main");
		else if (Str::eq(pack->package_name->symbol_name, I"DefArt_fn"))
			CodeGen::Eliminate::require(pack, NULL, I"it's a veneer replacement");
		else if (Str::eq(pack->package_name->symbol_name, I"CDefArt_fn"))
			CodeGen::Eliminate::require(pack, NULL, I"it's a veneer replacement");
		else if (Str::eq(pack->package_name->symbol_name, I"IndefArt_fn"))
			CodeGen::Eliminate::require(pack, NULL, I"it's a veneer replacement");
		else if (Str::eq(pack->package_name->symbol_name, I"CIndefArt_fn"))
			CodeGen::Eliminate::require(pack, NULL, I"it's a veneer replacement");
	}
}

@ Once you need a package, what else do you need?

=
void CodeGen::Eliminate::require(inter_package *pack, inter_package *witness, text_stream *reason) {
	if ((pack->package_flags) & USED_PACKAGE_FLAG) return;
	pack->package_flags |= USED_PACKAGE_FLAG;
	if (witness) {
		LOGIF(ELIMINATION, "Need $6 because of $6 (because %S)\n", pack, witness, reason);
	} else {
		LOGIF(ELIMINATION, "Need $6 (because %S)\n", pack, reason);
	}
	@<If you need a package, you need its parent@>;
	@<If you need a package, you need its external dependencies@>;
	@<If you need a function or action, you need its internal resources@>;
}

@<If you need a package, you need its parent@> =
	inter_package *parent = Inter::Packages::parent(pack);
	if (parent) CodeGen::Eliminate::require(parent, pack, I"it's the parent");

@<If you need a package, you need its external dependencies@> =
	inter_symbols_table *tab = Inter::Packages::scope(pack);
	for (int i=0; i<tab->size; i++) {
		inter_symbol *symb = tab->symbol_array[i];
		if ((symb) && (symb->equated_to) &&
			(Inter::Symbols::get_flag(symb, ALIAS_ONLY_BIT) == FALSE)) {
			inter_symbol *to = symb;
			while ((to) && (to->equated_to)) to = to->equated_to;
			inter_package *needed = to->owning_table->owning_package;
			CodeGen::Eliminate::require(needed, pack, I"it's an external symbol");
		}
	}

@<If you need a function or action, you need its internal resources@> =
	text_stream *rationale = NULL;
	inter_symbol *ptype = Inter::Packages::type(pack);
	if (ptype == function_ptype_symbol) rationale = I"it's a _function block";
	if (ptype == action_ptype_symbol) rationale = I"it's an _action subpackage";
	if (rationale) {
		inter_tree_node *D = Inter::Symbols::definition(pack->package_name);
		LOOP_THROUGH_INTER_CHILDREN(C, D) {
			if (C->W.data[ID_IFLD] == PACKAGE_IST) {
				inter_package *P = Inter::Package::defined_by_frame(C);
				CodeGen::Eliminate::require(P, pack, rationale);
			}
		}
	}

@h Destruction.
Whatever has not been preserved, is now destroyed.

=
void CodeGen::Eliminate::package_destroyer(inter_tree *I, inter_tree_node *P, void *state) {
	inter_package *pack = Inter::Package::defined_by_frame(P);
	if ((pack) && ((pack->package_flags & USED_PACKAGE_FLAG) == 0)) {
		LOGIF(ELIMINATION, "Striking unused package $3 (type %S)\n",
			pack->package_name, Inter::Packages::type(pack)->symbol_name);
		Inter::Tree::remove_node(P);
	}
}
