[Inter::Node::] Inter Nodes.

To create nodes of inter code, and manage everything about them except their
tree locations.

@h Bytecode definition.

@d inter_t unsigned int
@d signed_inter_t int

@h Chunks.

@d IST_SIZE 100

@d SYMBOL_BASE_VAL 0x40000000

@d PREFRAME_SKIP_AMOUNT 0
@d PREFRAME_VERIFICATION_COUNT 1
@d PREFRAME_ORIGIN 2
@d PREFRAME_COMMENT 3
@d PREFRAME_SIZE 4

@h Frames.

=
inter_t Inter::Node::get_metadata(inter_tree_node *F, int at) {
	if (F == NULL) return 0;
	return F->W.repo_segment->bytecode[F->W.index + at];
}

void Inter::Node::set_metadata(inter_tree_node *F, int at, inter_t V) {
	if (F) F->W.repo_segment->bytecode[F->W.index + at] = V;
}

inter_warehouse *Inter::Node::warehouse(inter_tree_node *F) {
	if (F == NULL) return NULL;
	return F->W.repo_segment->owning_warehouse;
}

inter_symbols_table *Inter::Node::ID_to_symbols_table(inter_tree_node *F, inter_t ID) {
	return Inter::Warehouse::get_symbols_table(Inter::Node::warehouse(F), ID);
}

text_stream *Inter::Node::ID_to_text(inter_tree_node *F, inter_t ID) {
	return Inter::Warehouse::get_text(Inter::Node::warehouse(F), ID);
}

inter_package *Inter::Node::ID_to_package(inter_tree_node *F, inter_t ID) {
	if (ID == 0) return NULL; // yes?
	return Inter::Warehouse::get_package(Inter::Node::warehouse(F), ID);
}

inter_frame_list *Inter::Node::ID_to_frame_list(inter_tree_node *F, inter_t N) {
	return Inter::Warehouse::get_frame_list(Inter::Node::warehouse(F), N);
}

void *Inter::Node::ID_to_ref(inter_tree_node *F, inter_t N) {
	return Inter::Warehouse::get_ref(Inter::Node::warehouse(F), N);
}

inter_symbols_table *Inter::Node::globals(inter_tree_node *F) {
	if (F) return Inter::Tree::global_scope(F->tree);
	return NULL;
}

int Inter::Node::eq(inter_tree_node *F1, inter_tree_node *F2) {
	if ((F1 == NULL) || (F2 == NULL)) {
		if (F1 == F2) return TRUE;
		return FALSE;
	}
	if (F1->W.repo_segment != F2->W.repo_segment) return FALSE;
	if (F1->W.index != F2->W.index) return FALSE;
	return TRUE;
}

@ =
inter_tree_node *Inter::Node::root_frame(inter_warehouse *warehouse, inter_tree *I) {
	inter_tree_node *P = Inter::Warehouse::find_room(warehouse, I, 2, NULL, NULL);
	P->W.data[ID_IFLD] = (inter_t) NOP_IST;
	P->W.data[LEVEL_IFLD] = 0;
	return P;
}

inter_tree_node *Inter::Node::fill_0(inter_bookmark *IBM, int S, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 2, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	return P;
}

inter_tree_node *Inter::Node::fill_1(inter_bookmark *IBM, int S, inter_t V, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 3, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V;
	return P;
}

inter_tree_node *Inter::Node::fill_2(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 4, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	return P;
}

inter_tree_node *Inter::Node::fill_3(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 5, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	return P;
}

inter_tree_node *Inter::Node::fill_4(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_t V4, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 6, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	P->W.data[DATA_IFLD + 3] = V4;
	return P;
}

inter_tree_node *Inter::Node::fill_5(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_t V4, inter_t V5, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 7, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	P->W.data[DATA_IFLD + 3] = V4;
	P->W.data[DATA_IFLD + 4] = V5;
	return P;
}

inter_tree_node *Inter::Node::fill_6(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_t V4, inter_t V5, inter_t V6, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 8, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	P->W.data[DATA_IFLD + 3] = V4;
	P->W.data[DATA_IFLD + 4] = V5;
	P->W.data[DATA_IFLD + 5] = V6;
	return P;
}

inter_tree_node *Inter::Node::fill_7(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_t V4, inter_t V5, inter_t V6, inter_t V7, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 9, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	P->W.data[DATA_IFLD + 3] = V4;
	P->W.data[DATA_IFLD + 4] = V5;
	P->W.data[DATA_IFLD + 5] = V6;
	P->W.data[DATA_IFLD + 6] = V7;
	return P;
}

inter_tree_node *Inter::Node::fill_8(inter_bookmark *IBM, int S, inter_t V1, inter_t V2, inter_t V3, inter_t V4, inter_t V5, inter_t V6, inter_t V7, inter_t V8, inter_error_location *eloc, inter_t level) {
	inter_tree *I = Inter::Bookmarks::tree(IBM);
	inter_tree_node *P = Inter::Warehouse::find_room(Inter::Tree::warehouse(I), I, 10, eloc, Inter::Bookmarks::package(IBM));
	P->W.data[ID_IFLD] = (inter_t) S;
	P->W.data[LEVEL_IFLD] = level;
	P->W.data[DATA_IFLD] = V1;
	P->W.data[DATA_IFLD + 1] = V2;
	P->W.data[DATA_IFLD + 2] = V3;
	P->W.data[DATA_IFLD + 3] = V4;
	P->W.data[DATA_IFLD + 4] = V5;
	P->W.data[DATA_IFLD + 5] = V6;
	P->W.data[DATA_IFLD + 6] = V7;
	P->W.data[DATA_IFLD + 7] = V8;
	return P;
}

@ =
int Inter::Node::extend(inter_tree_node *F, inter_t by) {
	if (by == 0) return TRUE;
	if ((F->W.index + F->W.extent + PREFRAME_SIZE < F->W.repo_segment->size) ||
		(F->W.repo_segment->next_room)) return FALSE;
		
	if (F->W.repo_segment->size + (int) by <= F->W.repo_segment->capacity) {	
		Inter::Node::set_metadata(F, PREFRAME_SKIP_AMOUNT,
			Inter::Node::get_metadata(F, PREFRAME_SKIP_AMOUNT) + by);
		F->W.repo_segment->size += by;
		F->W.extent += by;
		return TRUE;
	}

	int next_size = Inter::Warehouse::enlarge_size(F->W.repo_segment->capacity, F->W.extent + PREFRAME_SIZE + (int) by);

	F->W.repo_segment->next_room = Inter::Warehouse::new_room(F->W.repo_segment->owning_warehouse,
		next_size, F->W.repo_segment);

	warehouse_floor_space W = Inter::Warehouse::find_room_in_room(F->W.repo_segment->next_room, F->W.extent + (int) by);

	F->W.repo_segment->size = F->W.index;
	F->W.repo_segment->capacity = F->W.index;

	inter_t a = Inter::Node::get_metadata(F, PREFRAME_VERIFICATION_COUNT);
	inter_t b = Inter::Node::get_metadata(F, PREFRAME_ORIGIN);
	inter_t c = Inter::Node::get_metadata(F, PREFRAME_COMMENT);

	F->W.index = W.index;
	F->W.repo_segment = W.repo_segment;
	for (int i=0; i<W.extent; i++)
		if (i < F->W.extent)
			W.data[i] = F->W.data[i];
		else
			W.data[i] = 0;
	F->W.data = W.data;
	F->W.extent = W.extent;

	Inter::Node::set_metadata(F, PREFRAME_VERIFICATION_COUNT, a);
	Inter::Node::set_metadata(F, PREFRAME_ORIGIN, b);
	Inter::Node::set_metadata(F, PREFRAME_COMMENT, c);
	return TRUE;
}

inter_t Inter::Node::vcount(inter_tree_node *F) {
	inter_t v = Inter::Node::get_metadata(F, PREFRAME_VERIFICATION_COUNT);
	Inter::Node::set_metadata(F, PREFRAME_VERIFICATION_COUNT, v + 1);
	return v;
}

inter_t Inter::Node::to_index(inter_tree_node *F) {
	if ((F->W.repo_segment == NULL) || (F->W.index < 0)) internal_error("no index for null frame");
	return (F->W.repo_segment->index_offset) + (inter_t) (F->W.index);
}

@

=
inter_error_location *Inter::Node::retrieve_origin(inter_tree_node *F) {
	if (F == NULL) return NULL;
	return Inter::Warehouse::retrieve_origin(Inter::Node::warehouse(F), Inter::Node::get_metadata(F, PREFRAME_ORIGIN));
}

inter_error_message *Inter::Node::error(inter_tree_node *F, text_stream *err, text_stream *quote) {
	inter_error_message *iem = CREATE(inter_error_message);
	inter_error_location *eloc = Inter::Node::retrieve_origin(F);
	if (eloc)
		iem->error_at = *eloc;
	else
		iem->error_at = Inter::Errors::file_location(NULL, NULL);
	iem->error_body = err;
	iem->error_quote = quote;
	return iem;
}

inter_t Inter::Node::get_comment(inter_tree_node *F) {
	if (F) return Inter::Node::get_metadata(F, PREFRAME_COMMENT);
	return 0;
}

void Inter::Node::attach_comment(inter_tree_node *F, inter_t ID) {
	if (F) Inter::Node::set_metadata(F, PREFRAME_COMMENT, ID);
}

inter_package *Inter::Node::get_package(inter_tree_node *F) {
	if (F) return F->package;
	return NULL;
}

inter_t Inter::Node::get_package_alt(inter_tree_node *X) {
	inter_tree_node *F = X;
	while (TRUE) {
		F = Inter::Tree::parent(F);
		if (F == NULL) break;
		if (F->W.data[ID_IFLD] == PACKAGE_IST)
			return F->W.data[PID_PACKAGE_IFLD];
	}
	return 0;
}

void Inter::Node::attach_package(inter_tree_node *F, inter_package *pack) {
	if (F) F->package = pack;
}

