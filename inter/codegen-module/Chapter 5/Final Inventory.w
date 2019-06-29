[CodeGen::Inventory::] Final Inventory.

To print a summary of the contents of a repository.

@ This target is fairly simple: when we get the message to begin generation,
we simply ask the Inter module to output some text, and return true to
tell the generator that nothing more need be done.

=
void CodeGen::Inventory::create_target(void) {
	code_generation_target *inv_cgt = CodeGen::Targets::new(I"inventory");
	METHOD_ADD(inv_cgt, BEGIN_GENERATION_MTID, CodeGen::Inventory::inv);
}

int CodeGen::Inventory::inv(code_generation_target *cgt, code_generation *gen) {
	if (gen->from_step == NULL) internal_error("temporary generations cannot be output");
	CodeGen::Inventory::print(gen->from_step->text_out_file, gen->from, gen->just_this_package);
	return TRUE;
}

void CodeGen::Inventory::print(OUTPUT_STREAM, inter_repository *I, inter_package *from) {
	if (I == NULL) internal_error("no repository");
	if (from == NULL) internal_error("no package");
	int recurse = FALSE;
	
	if (from == Inter::Packages::main(I)) recurse = TRUE;
	else {
		inter_symbol *ptype = Inter::Packages::type(from);
		if (Str::eq(ptype->symbol_name, I"_module")) {
			WRITE("Module '%S'\n", from->package_name->symbol_name);
			text_stream *title = CodeGen::Inventory::read_metadata(from, I"`title");
			if (title) WRITE("From extension '%S by %S' version %S\n", title,
				CodeGen::Inventory::read_metadata(from, I"`author"),
				CodeGen::Inventory::read_metadata(from, I"`version"));
			recurse = TRUE;
		} else if (Str::eq(ptype->symbol_name, I"_submodule")) {
			if (from->child_package) {
				WRITE("%S:\n", from->package_name->symbol_name);
				INDENT;
					for (inter_package *R = from->child_package; R; R = R->next_package)
						CodeGen::unmark(R->package_name);
					for (inter_package *R = from->child_package; R; R = R->next_package) {
						if (CodeGen::marked(R->package_name)) continue;
						inter_symbol *ptype = Inter::Packages::type(R);
						OUTDENT;
						WRITE("  %S ", ptype->symbol_name);
						int N = 1;
						for (inter_package *R2 = R->next_package; R2; R2 = R2->next_package)
							if (Inter::Packages::type(R2) == ptype)
								N++;
						WRITE("x %d: ", N);
						INDENT;
						int pos = Str::len(ptype->symbol_name) + 7;
						int first = TRUE;
						for (inter_package *R2 = R; R2; R2 = R2->next_package) {
							if (Inter::Packages::type(R2) == ptype) {
								text_stream *name = CodeGen::Inventory::read_metadata(R2, I"`name");
								if (name == NULL) name = R2->package_name->symbol_name;
								if ((pos > 0) && (first == FALSE)) WRITE(", ");
								pos += Str::len(name) + 2;
								if (pos > 80) { WRITE("\n"); pos = Str::len(name) + 2; }
								WRITE("%S", name);
								CodeGen::mark(R2->package_name);
								first = FALSE;
							}
						}
						if (pos > 0) WRITE("\n");
					}
					for (inter_package *R = from->child_package; R; R = R->next_package)
						CodeGen::unmark(R->package_name);
				OUTDENT;
			}
		}
	}
	if (recurse) {
		INDENT;
		for (inter_package *M = from->child_package; M; M = M->next_package)
			CodeGen::Inventory::print(OUT, I, M);
		OUTDENT;
	}
}

text_stream *CodeGen::Inventory::read_metadata(inter_package *P, text_stream *key) {
	if (P == NULL) return NULL;
	inter_symbol *found = Inter::SymbolsTables::symbol_from_name(Inter::Packages::scope(P), key);
	if ((found) && (Inter::Symbols::is_defined(found))) {
		inter_frame F = Inter::Symbols::defining_frame(found);
		inter_t val2 = F.data[VAL1_MD_IFLD + 1];
		return Inter::get_text(P->stored_in, val2);
	}
	return NULL;
}
