[PL::Bibliographic::IFID::] Interactive Fiction ID.

Computes and makes available the IFID (Interactive Fiction ID) number
for an Inform-generated work of IF, in compliance with the Treaty of Babel.

@h Definitions.

@ The Interactive Fiction ID number for an Inform 7-compiled work is the
same as the UUID unique ID generated by the Inform 7 application.

UUIDs are not generated here, but by the user interface application: we expect
to read them in the form of the |uuid.txt| file placed in the project bundle
by that application. After some agonising, I decided that the Treaty did not
actually oblige me to crash out if this file did not exist: but in such
cases the UUID is empty.

@d MAX_UUID_LENGTH 128 /* the UUID is truncated to this if necessary */

=
text_stream *uuid_text = NULL;
int uuid_read = -1;

text_stream *PL::Bibliographic::IFID::read_uuid(void) {
	if (uuid_read >= 0) return uuid_text;
	uuid_text = Str::new();
	uuid_read = 0;
	FILE *xf = Filenames::fopen(filename_of_uuid, "r");
	if (xf == NULL) return uuid_text; /* the UUID is the empty string if the file is missing */
	int c;
	while (((c = fgetc(xf)) != EOF) /* the UUID file is plain text, not Unicode */
		&& (uuid_read++ < MAX_UUID_LENGTH-1))
		PUT_TO(uuid_text, Characters::toupper(c));
	fclose(xf);
	return uuid_text;
}

@ The IFID is written into the compiled story file, too, both in order
that it can be printed by the VERSION command and to brand the file so
that it can still be identified even if it loses touch with its iFiction
record. We store the IFID in plain text, with a "magic string" identifier
around it, in byte-accessible memory.

=
void PL::Bibliographic::IFID::define_UUID(void) {
	text_stream *uuid = PL::Bibliographic::IFID::read_uuid();
	inter_name *UUID_array_iname = Hierarchy::find(UUID_ARRAY_NRL);
	packaging_state save = Packaging::enter_home_of(UUID_array_iname);
	Emit::named_string_constant(UUID_array_iname, uuid);
	Packaging::exit(save);
}

inter_name *PL::Bibliographic::IFID::UUID(void) {
	return Hierarchy::find(UUID_ARRAY_NRL);
}

