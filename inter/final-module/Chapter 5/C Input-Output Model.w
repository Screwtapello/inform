[CInputOutputModel::] C Input-Output Model.

How C programs print text out, really.

@h Setting up the model.

=
void CInputOutputModel::initialise(code_generation_target *cgt) {
}

void CInputOutputModel::initialise_data(code_generation *gen) {
}

void CInputOutputModel::begin(code_generation *gen) {
}

void CInputOutputModel::end(code_generation *gen) {
}

@

=
int CInputOutputModel::compile_primitive(code_generation *gen, inter_ti bip, inter_tree_node *P) {
	text_stream *OUT = CodeGen::current(gen);
	switch (bip) {
		case INVERSION_BIP:	     break; /* we won't support this in C */
		case SPACES_BIP:		 WRITE("for (int j = "); INV_A1; WRITE("; j >= 0; j--) i7_print_char(32);"); break;
		case FONT_BIP:           WRITE("i7_font("); INV_A1; WRITE(")"); break;
		case STYLEROMAN_BIP:     WRITE("i7_style(i7_roman)"); break;
		case STYLEBOLD_BIP:      WRITE("i7_style(i7_bold)"); break;
		case STYLEUNDERLINE_BIP: WRITE("i7_style(i7_underline)"); break;
		case STYLEREVERSE_BIP:   WRITE("i7_style(i7_reverse)"); break;
		case PRINT_BIP:          WRITE("i7_print_C_string("); INV_A1_PRINTMODE; WRITE(")"); break;
		case PRINTRET_BIP:       WRITE("i7_print_C_string("); INV_A1_PRINTMODE; WRITE("); return 1"); break;
		case PRINTCHAR_BIP:      WRITE("i7_print_char("); INV_A1; WRITE(")"); break;
		case PRINTNAME_BIP:      WRITE("i7_print_name("); INV_A1; WRITE(")"); break;
		case PRINTOBJ_BIP:       WRITE("i7_print_object("); INV_A1; WRITE(")"); break;
		case PRINTPROPERTY_BIP:  WRITE("i7_print_property("); INV_A1; WRITE(")"); break;
		case PRINTNUMBER_BIP:    WRITE("i7_print_decimal("); INV_A1; WRITE(")"); break;
		case PRINTNLNUMBER_BIP:  WRITE("fn_i7_mgl_EnglishNumber(1, "); INV_A1; WRITE(")"); break;
		case PRINTDEF_BIP:       WRITE("i7_print_def_art("); INV_A1; WRITE(")"); break;
		case PRINTCDEF_BIP:      WRITE("i7_print_cdef_art("); INV_A1; WRITE(")"); break;
		case PRINTINDEF_BIP:     WRITE("i7_print_indef_art("); INV_A1; WRITE(")"); break;
		case PRINTCINDEF_BIP:    WRITE("i7_print_cindef_art("); INV_A1; WRITE(")"); break;
		case BOX_BIP:            WRITE("i7_print_box("); INV_A1_BOXMODE; WRITE(")"); break;
		case READ_BIP:           WRITE("i7_read("); INV_A1; WRITE(", "); INV_A2; WRITE(")"); break;

		default: 				 return NOT_APPLICABLE;
	}
	return FALSE;
}

@

= (text to inform7_clib.h)
#define i7_bold 1
#define i7_roman 2
#define i7_underline 3
#define i7_reverse 4

void i7_style(int what) {
}

void i7_font(int what) {
}

typedef struct i7_stream {
	FILE *to_file;
	wchar_t *to_memory;
	size_t memory_used;
	size_t memory_capacity;
	i7val previous_id;
	i7val write_here_on_closure;
	size_t write_limit;
	int active;
	int encode_UTF8;
	int char_size;
} i7_stream;

#define I7_MAX_STREAMS 128

i7_stream i7_memory_streams[I7_MAX_STREAMS];

i7val i7_stdout_id = 0, i7_stderr_id = 1, i7_str_id = 0;

i7val i7_do_glk_stream_get_current(void) {
	return i7_str_id;
}

void i7_do_glk_stream_set_current(i7val id) {
	if ((id < 0) || (id >= I7_MAX_STREAMS)) { fprintf(stderr, "Stream ID %d out of range\n", id); exit(1); }
	i7_str_id = id;
}

i7_stream i7_new_stream(FILE *F) {
	i7_stream S;
	S.to_file = F;
	S.to_memory = NULL;
	S.memory_used = 0;
	S.memory_capacity = 0;
	S.write_here_on_closure = 0;
	S.write_limit = 0;
	S.previous_id = 0;
	S.active = 0;
	S.encode_UTF8 = 0;
	S.char_size = 4;
	return S;
}

void i7_initialise_streams(void) {
	for (int i=0; i<I7_MAX_STREAMS; i++) i7_memory_streams[i] = i7_new_stream(NULL);
	i7_memory_streams[i7_stdout_id] = i7_new_stream(stdout);
	i7_memory_streams[i7_stdout_id].active = 1;
	i7_memory_streams[i7_stdout_id].encode_UTF8 = 1;
	i7_memory_streams[i7_stderr_id] = i7_new_stream(stderr);
	i7_memory_streams[i7_stderr_id].active = 1;
	i7_memory_streams[i7_stderr_id].encode_UTF8 = 1;
	i7_do_glk_stream_set_current(i7_stdout_id);
}

i7val i7_open_stream(FILE *F) {
	for (int i=0; i<I7_MAX_STREAMS; i++)
		if (i7_memory_streams[i].active == 0) {
			i7_memory_streams[i] = i7_new_stream(F);
			i7_memory_streams[i].active = 1;
			i7_memory_streams[i].previous_id = i7_str_id;
			i7_str_id = i;
			return i;
		}
	fprintf(stderr, "Out of streams\n"); exit(1);
}

i7val i7_do_glk_stream_open_memory(i7val buffer, i7val len, i7val fmode, i7val rock) {
	if (fmode != 1) { fprintf(stderr, "Only file mode 1 supported, not %d\n", fmode); exit(1); }
	i7val id = i7_open_stream(NULL);
	i7_memory_streams[id].write_here_on_closure = buffer;
	i7_memory_streams[id].write_limit = (size_t) len;
	i7_memory_streams[id].char_size = 1;
	return id;
}

i7val i7_do_glk_stream_open_memory_uni(i7val buffer, i7val len, i7val fmode, i7val rock) {
	if (fmode != 1) { fprintf(stderr, "Only file mode 1 supported, not %d\n", fmode); exit(1); }
	i7val id = i7_open_stream(NULL);
	i7_memory_streams[id].write_here_on_closure = buffer;
	i7_memory_streams[id].write_limit = (size_t) len;
	i7_memory_streams[id].char_size = 4;
	return id;
}

i7val i7_do_glk_stream_get_position(i7val id) {
	if ((id < 0) || (id >= I7_MAX_STREAMS)) { fprintf(stderr, "Stream ID %d out of range\n", id); exit(1); }
	i7_stream *S = &(i7_memory_streams[id]);
	return (i7val) S->memory_used;
}

void i7_do_glk_stream_close(i7val id, i7val result) {
	if ((id < 0) || (id >= I7_MAX_STREAMS)) { fprintf(stderr, "Stream ID %d out of range\n", id); exit(1); }
	if (id == 0) { fprintf(stderr, "Cannot close stdout\n"); exit(1); }
	if (id == 1) { fprintf(stderr, "Cannot close stderr\n"); exit(1); }
	i7_stream *S = &(i7_memory_streams[id]);
	if (S->active == 0) { fprintf(stderr, "Stream %d already closed\n", id); exit(1); }
	if (i7_str_id == id) i7_str_id = S->previous_id;
	if (S->write_here_on_closure != 0) {
		if (S->char_size == 4) {
			for (size_t i = 0; i < S->write_limit; i++)
				if (i < S->memory_used)
					i7_write_word(i7mem, S->write_here_on_closure, i, S->to_memory[i], i7_lvalue_SET);
				else
					i7_write_word(i7mem, S->write_here_on_closure, i, 0, i7_lvalue_SET);
		} else {
			for (size_t i = 0; i < S->write_limit; i++)
				if (i < S->memory_used)
					i7mem[S->write_here_on_closure + i] = S->to_memory[i];
				else
					i7mem[S->write_here_on_closure + i] = 0;
		}
	}
	if (result) {
		i7_write_word(i7mem, result, 0, 0, i7_lvalue_SET);
		i7_write_word(i7mem, result, 1, S->memory_used, i7_lvalue_SET);
	}
	S->active = 0;
	S->memory_used = 0;
}

void i7_print_char(i7val x) {
	i7_stream *S = &(i7_memory_streams[i7_str_id]);
	if (S->to_file) {
		unsigned int c = (unsigned int) x;
		if (S->encode_UTF8) {
			if (c >= 0x800) {
				fputc(0xE0 + (c >> 12), S->to_file);
				fputc(0x80 + ((c >> 6) & 0x3f), S->to_file);
				fputc(0x80 + (c & 0x3f), S->to_file);
			} else if (c >= 0x80) {
				fputc(0xC0 + (c >> 6), S->to_file);
				fputc(0x80 + (c & 0x3f), S->to_file);
			} else fputc((int) c, S->to_file);
		} else {
			fputc((int) c, S->to_file);
		}
	} else {
		if (S->memory_used >= S->memory_capacity) {
			size_t needed = 4*S->memory_capacity;
			if (needed == 0) needed = 1024;
			wchar_t *new_data = (wchar_t *) calloc(needed, sizeof(wchar_t));
			if (new_data == NULL) { fprintf(stderr, "Out of memory\n"); exit(1); }
			for (size_t i=0; i<S->memory_used; i++) new_data[i] = S->to_memory[i];
			free(S->to_memory);
			S->to_memory = new_data;
		}
		S->to_memory[S->memory_used++] = (wchar_t) x;
	}
}

void i7_print_C_string(char *c_string) {
	if (c_string)
		for (int i=0; c_string[i]; i++)
			i7_print_char((i7val) c_string[i]);
}

void i7_print_decimal(i7val x) {
	char room[32];
	sprintf(room, "%d", (int) x);
	i7_print_C_string(room);
}

#define i7_glk_exit 0x0001
#define i7_glk_set_interrupt_handler 0x0002
#define i7_glk_tick 0x0003
#define i7_glk_gestalt 0x0004
#define i7_glk_gestalt_ext 0x0005
#define i7_glk_window_iterate 0x0020
#define i7_glk_window_get_rock 0x0021
#define i7_glk_window_get_root 0x0022
#define i7_glk_window_open 0x0023
#define i7_glk_window_close 0x0024
#define i7_glk_window_get_size 0x0025
#define i7_glk_window_set_arrangement 0x0026
#define i7_glk_window_get_arrangement 0x0027
#define i7_glk_window_get_type 0x0028
#define i7_glk_window_get_parent 0x0029
#define i7_glk_window_clear 0x002A
#define i7_glk_window_move_cursor 0x002B
#define i7_glk_window_get_stream 0x002C
#define i7_glk_window_set_echo_stream 0x002D
#define i7_glk_window_get_echo_stream 0x002E
#define i7_glk_set_window 0x002F
#define i7_glk_window_get_sibling 0x0030
#define i7_glk_stream_iterate 0x0040
#define i7_glk_stream_get_rock 0x0041
#define i7_glk_stream_open_file 0x0042
#define i7_glk_stream_open_memory 0x0043
#define i7_glk_stream_close 0x0044
#define i7_glk_stream_set_position 0x0045
#define i7_glk_stream_get_position 0x0046
#define i7_glk_stream_set_current 0x0047
#define i7_glk_stream_get_current 0x0048
#define i7_glk_stream_open_resource 0x0049
#define i7_glk_fileref_create_temp 0x0060
#define i7_glk_fileref_create_by_name 0x0061
#define i7_glk_fileref_create_by_prompt 0x0062
#define i7_glk_fileref_destroy 0x0063
#define i7_glk_fileref_iterate 0x0064
#define i7_glk_fileref_get_rock 0x0065
#define i7_glk_fileref_delete_file 0x0066
#define i7_glk_fileref_does_file_exist 0x0067
#define i7_glk_fileref_create_from_fileref 0x0068
#define i7_glk_put_char 0x0080
#define i7_glk_put_char_stream 0x0081
#define i7_glk_put_string 0x0082
#define i7_glk_put_string_stream 0x0083
#define i7_glk_put_buffer 0x0084
#define i7_glk_put_buffer_stream 0x0085
#define i7_glk_set_style 0x0086
#define i7_glk_set_style_stream 0x0087
#define i7_glk_get_char_stream 0x0090
#define i7_glk_get_line_stream 0x0091
#define i7_glk_get_buffer_stream 0x0092
#define i7_glk_char_to_lower 0x00A0
#define i7_glk_char_to_upper 0x00A1
#define i7_glk_stylehint_set 0x00B0
#define i7_glk_stylehint_clear 0x00B1
#define i7_glk_style_distinguish 0x00B2
#define i7_glk_style_measure 0x00B3
#define i7_glk_select 0x00C0
#define i7_glk_select_poll 0x00C1
#define i7_glk_request_line_event 0x00D0
#define i7_glk_cancel_line_event 0x00D1
#define i7_glk_request_char_event 0x00D2
#define i7_glk_cancel_char_event 0x00D3
#define i7_glk_request_mouse_event 0x00D4
#define i7_glk_cancel_mouse_event 0x00D5
#define i7_glk_request_timer_events 0x00D6
#define i7_glk_image_get_info 0x00E0
#define i7_glk_image_draw 0x00E1
#define i7_glk_image_draw_scaled 0x00E2
#define i7_glk_window_flow_break 0x00E8
#define i7_glk_window_erase_rect 0x00E9
#define i7_glk_window_fill_rect 0x00EA
#define i7_glk_window_set_background_color 0x00EB
#define i7_glk_schannel_iterate 0x00F0
#define i7_glk_schannel_get_rock 0x00F1
#define i7_glk_schannel_create 0x00F2
#define i7_glk_schannel_destroy 0x00F3
#define i7_glk_schannel_create_ext 0x00F4
#define i7_glk_schannel_play_multi 0x00F7
#define i7_glk_schannel_play 0x00F8
#define i7_glk_schannel_play_ext 0x00F9
#define i7_glk_schannel_stop 0x00FA
#define i7_glk_schannel_set_volume 0x00FB
#define i7_glk_sound_load_hint 0x00FC
#define i7_glk_schannel_set_volume_ext 0x00FD
#define i7_glk_schannel_pause 0x00FE
#define i7_glk_schannel_unpause 0x00FF
#define i7_glk_set_hyperlink 0x0100
#define i7_glk_set_hyperlink_stream 0x0101
#define i7_glk_request_hyperlink_event 0x0102
#define i7_glk_cancel_hyperlink_event 0x0103
#define i7_glk_buffer_to_lower_case_uni 0x0120
#define i7_glk_buffer_to_upper_case_uni 0x0121
#define i7_glk_buffer_to_title_case_uni 0x0122
#define i7_glk_buffer_canon_decompose_uni 0x0123
#define i7_glk_buffer_canon_normalize_uni 0x0124
#define i7_glk_put_char_uni 0x0128
#define i7_glk_put_string_uni 0x0129
#define i7_glk_put_buffer_uni 0x012A
#define i7_glk_put_char_stream_uni 0x012B
#define i7_glk_put_string_stream_uni 0x012C
#define i7_glk_put_buffer_stream_uni 0x012D
#define i7_glk_get_char_stream_uni 0x0130
#define i7_glk_get_buffer_stream_uni 0x0131
#define i7_glk_get_line_stream_uni 0x0132
#define i7_glk_stream_open_file_uni 0x0138
#define i7_glk_stream_open_memory_uni 0x0139
#define i7_glk_stream_open_resource_uni 0x013A
#define i7_glk_request_char_event_uni 0x0140
#define i7_glk_request_line_event_uni 0x0141
#define i7_glk_set_echo_line_event 0x0150
#define i7_glk_set_terminators_line_event 0x0151
#define i7_glk_current_time 0x0160
#define i7_glk_current_simple_time 0x0161
#define i7_glk_time_to_date_utc 0x0168
#define i7_glk_time_to_date_local 0x0169
#define i7_glk_simple_time_to_date_utc 0x016A
#define i7_glk_simple_time_to_date_local 0x016B
#define i7_glk_date_to_time_utc 0x016C
#define i7_glk_date_to_time_local 0x016D
#define i7_glk_date_to_simple_time_utc 0x016E
#define i7_glk_date_to_simple_time_local 0x016F

void glulx_glk(i7val glk_api_selector, i7val argc, i7varargs args, i7val *z) {
	int rv = 0;
	switch (glk_api_selector) {
		case i7_glk_gestalt:
			rv = 1; break;
		case i7_glk_window_iterate:
			rv = 0; break;
		case i7_glk_window_open:
			rv = 1; break;
		case i7_glk_set_window:
			rv = 0; break;
		case i7_glk_stream_iterate:
			rv = 0; break;
		case i7_glk_fileref_iterate:
			rv = 0; break;
		case i7_glk_stylehint_set:
			rv = 0; break;
		case i7_glk_schannel_iterate:
			rv = 0; break;
		case i7_glk_schannel_create:
			rv = 0; break;
		case i7_glk_stream_get_position:
			rv = i7_do_glk_stream_get_position(args.args[0]); break;
		case i7_glk_stream_close:
			i7_do_glk_stream_close(args.args[0], args.args[1]); break;
		case i7_glk_stream_set_current:
			i7_do_glk_stream_set_current(args.args[0]); break;
		case i7_glk_stream_get_current:
			rv = i7_do_glk_stream_get_current(); break;
		case i7_glk_stream_open_memory:
			rv = i7_do_glk_stream_open_memory(args.args[0], args.args[1], args.args[2], args.args[3]); break;
		case i7_glk_stream_open_memory_uni:
			rv = i7_do_glk_stream_open_memory_uni(args.args[0], args.args[1], args.args[2], args.args[3]); break;
		default:
			printf("Unimplemented: glulx_glk %d.\n", glk_api_selector);
			rv = 0; 	exit(1);
break;
	}
	if (z) *z = rv;
}

void i7_print_def_art(i7val x) {
	fn_i7_mgl_DefArt(x);
}

void i7_print_cdef_art(i7val x) {
	fn_i7_mgl_CDefArt(x);
}

void i7_print_indef_art(i7val x) {
	fn_i7_mgl_IndefArt(x);
}

void i7_print_cindef_art(i7val x) {
	fn_i7_mgl_CIndefArt(x);
}

void i7_print_name(i7val x) {
	fn_i7_mgl_PrintShortName(x);
}

void i7_print_object(i7val x) {
	printf("Unimplemented: i7_print_object.\n");
	exit(1);
}

void i7_print_property(i7val x) {
	printf("Unimplemented: i7_print_property.\n");
	exit(1);
}

void i7_print_box(i7val x) {
	printf("Unimplemented: i7_print_box.\n");
	exit(1);
}

void i7_read(i7val x) {
	printf("Unimplemented: i7_read.\n");
	exit(1);
}
=
