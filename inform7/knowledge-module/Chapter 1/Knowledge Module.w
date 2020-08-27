[KnowledgeModule::] Knowledge Module.

Setting up the use of this module.

@ This section simoly sets up the module in ways expected by //foundation//, and
contains no code of interest. The following constant exists only in tools
which use this module:

@d KNOWLEDGE_MODULE TRUE

@ Like all modules, this one must define a |start| and |end| function:

=
COMPILE_WRITER(booking *, Rules::Bookings::log)
COMPILE_WRITER(inference *, World::Inferences::log)
COMPILE_WRITER(inference_subject *, InferenceSubjects::log)
COMPILE_WRITER(property *, Properties::log)
COMPILE_WRITER(rulebook *, Rulebooks::log)
COMPILE_WRITER_I(int, World::Inferences::log_kind)

@

@e ACTIVITY_CREATIONS_DA
@e INFERENCES_DA
@e OBJECT_COMPILATION_DA
@e PROPERTY_CREATIONS_DA
@e PROPERTY_PROVISION_DA
@e PROPERTY_TRANSLATIONS_DA
@e RULE_ATTACHMENTS_DA
@e RULEBOOK_COMPILATION_DA
@e INSTANCE_COUNTING_MREASON
@e COMPILATION_SIZE_MREASON
@e OBJECT_COMPILATION_MREASON

=
void KnowledgeModule::start(void) {
	Properties::SameRelations::start();
	Properties::SettingRelations::start();
	Properties::ComparativeRelations::start();
	Properties::ProvisionRelation::start();
	REGISTER_WRITER('b', Rules::Bookings::log);
	REGISTER_WRITER('I', World::Inferences::log);
	REGISTER_WRITER('j', InferenceSubjects::log);
	REGISTER_WRITER('K', Rulebooks::log);
	REGISTER_WRITER_I('n', World::Inferences::log_kind)
	REGISTER_WRITER('Y', Properties::log);
	Log::declare_aspect(ACTIVITY_CREATIONS_DA, L"activity creations", FALSE, FALSE);
	Log::declare_aspect(INFERENCES_DA, L"inferences", FALSE, TRUE);
	Log::declare_aspect(OBJECT_COMPILATION_DA, L"object compilation", FALSE, FALSE);
	Log::declare_aspect(PROPERTY_CREATIONS_DA, L"property creations", FALSE, FALSE);
	Log::declare_aspect(PROPERTY_PROVISION_DA, L"property provision", FALSE, FALSE);
	Log::declare_aspect(PROPERTY_TRANSLATIONS_DA, L"property translations", FALSE, FALSE);
	Log::declare_aspect(RULE_ATTACHMENTS_DA, L"rule attachments", FALSE, FALSE);
	Log::declare_aspect(RULEBOOK_COMPILATION_DA, L"rulebook compilation", FALSE, FALSE);
	Memory::reason_name(INSTANCE_COUNTING_MREASON, "instance-of-kind counting");
	Memory::reason_name(COMPILATION_SIZE_MREASON, "size estimates for compiled objects");
	Memory::reason_name(OBJECT_COMPILATION_MREASON, "compilation workspace for objects");
}
void KnowledgeModule::end(void) {
}
