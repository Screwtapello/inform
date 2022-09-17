[SynopticHierarchy::] Synoptic Hierarchy.

The layout and naming conventions for the contents of the main/synoptic module.

@ This section gives a map of what resources will be made in the synoptic
module. The definitions here enable code generated by //inform7// or //inter//
to call functions or use constants defined in the synoptic module, and also
allow them to be referred to from kits linked in.

Because the synoptic module exists only to provide resources, this section is
in effect a specification for it.

@e SYNOPTIC_HIERARCHY_MADE_ITHBIT

=
void SynopticHierarchy::establish(inter_tree *I) {
	if (InterTree::test_history(I, SYNOPTIC_HIERARCHY_MADE_ITHBIT)) return;
	InterTree::set_history(I, SYNOPTIC_HIERARCHY_MADE_ITHBIT);
	location_requirement req;
	@<Resources for actions@>;
	@<Resources for activities@>;
	@<Resources for chronology@>;
	@<Resources for conjugations@>;
	@<Resources for dialogue@>;
	@<Resources for extensions@>;
	@<Resources for instances@>;
	@<Resources for kinds@>;
	@<Resources for multimedia@>;
	@<Resources for properties@>;
	@<Resources for relations@>;
	@<Resources for rulebooks@>;
	@<Resources for rules@>;
	@<Resources for scenes@>;
	@<Resources for tables@>;
	@<Resources for tests@>;
	@<Resources for use options@>;
}

@ The notation here is a little cryptic, but see //runtime: Hierarchy// for a
fuller explanation.

@d SYN_SUBMD(r)
	req = LocationRequirements::synoptic_submodule(I, LargeScale::register_submodule_identity(r));
@d SYN_CONST(id, n) {
		HierarchyLocations::con(I, id, n, req);
		inter_name *iname = HierarchyLocations::iname(I, id);
		inter_symbol *S = InterNames::to_symbol(iname);
		Wiring::socket(I, InterNames::to_text(iname), S);
	}
@d SYN_FUNCT(id, n, t) {
		HierarchyLocations::fun(I, id, n, Translation::to(t), req);
		inter_name *iname = HierarchyLocations::iname(I, id);
		inter_symbol *S = InterNames::to_symbol(iname);
		Wiring::socket(I, InterNames::get_translation(iname), S);
	}

@h Actions.
The |/main/synoptic/actions| submodule.

@e ACTIONCODING_HL
@e ACTIONDATA_HL
@e ACTIONHAPPENED_HL
@e AD_RECORDS_HL
@e CCOUNT_ACTION_NAME_HL
@e DB_ACTION_DETAILS_HL

@<Resources for actions@> =
	SYN_SUBMD(I"actions")
		SYN_CONST(ACTIONCODING_HL,                I"ActionCoding")
		SYN_CONST(ACTIONDATA_HL,                  I"ActionData")
		SYN_CONST(ACTIONHAPPENED_HL,              I"ActionHappened")
		SYN_CONST(AD_RECORDS_HL,                  I"AD_RECORDS")
		SYN_CONST(CCOUNT_ACTION_NAME_HL,          I"CCOUNT_ACTION_NAME")
		SYN_FUNCT(DB_ACTION_DETAILS_HL,           I"DB_Action_Details_fn", I"DB_Action_Details")

@h Activities.
The |/main/synoptic/activities| submodule.

@e ACTIVITY_AFTER_RULEBOOKS_HL
@e ACTIVITY_ATB_RULEBOOKS_HL
@e ACTIVITY_BEFORE_RULEBOOKS_HL
@e ACTIVITY_FOR_RULEBOOKS_HL
@e ACTIVITY_VAR_CREATORS_HL

@<Resources for activities@> =
	SYN_SUBMD(I"activities")
		SYN_CONST(ACTIVITY_AFTER_RULEBOOKS_HL,    I"Activity_after_rulebooks")
		SYN_CONST(ACTIVITY_ATB_RULEBOOKS_HL,      I"Activity_atb_rulebooks")
		SYN_CONST(ACTIVITY_BEFORE_RULEBOOKS_HL,   I"Activity_before_rulebooks")
		SYN_CONST(ACTIVITY_FOR_RULEBOOKS_HL,      I"Activity_for_rulebooks")
		SYN_CONST(ACTIVITY_VAR_CREATORS_HL,       I"activity_var_creators")

@h Chronology.
The |/main/synoptic/chronology| submodule.

@e TIMEDEVENTSTABLE_HL
@e TIMEDEVENTTIMESTABLE_HL
@e PASTACTIONSI6ROUTINES_HL
@e NO_PAST_TENSE_CONDS_HL
@e NO_PAST_TENSE_ACTIONS_HL
@e TESTSINGLEPASTSTATE_HL

@<Resources for chronology@> =
	SYN_SUBMD(I"chronology")
		SYN_CONST(TIMEDEVENTSTABLE_HL,            I"TimedEventsTable")
		SYN_CONST(TIMEDEVENTTIMESTABLE_HL,        I"TimedEventTimesTable")
		SYN_CONST(PASTACTIONSI6ROUTINES_HL,       I"PastActionsI6Routines")
		SYN_CONST(NO_PAST_TENSE_CONDS_HL,         I"NO_PAST_TENSE_CONDS")
		SYN_CONST(NO_PAST_TENSE_ACTIONS_HL,       I"NO_PAST_TENSE_ACTIONS")
		SYN_FUNCT(TESTSINGLEPASTSTATE_HL,         I"test_fn", I"TestSinglePastState")

@h Conjugations.
The |/main/synoptic/conjugations| submodule.

@e TABLEOFVERBS_HL

@<Resources for conjugations@> =
	SYN_SUBMD(I"conjugations")
		SYN_CONST(TABLEOFVERBS_HL,                I"TableOfVerbs")

@h Dialogue.
The |/main/synoptic/dialogue| submodule.

@e DIALOGUEBEATS_HL
@e DIALOGUELINES_HL

@<Resources for dialogue@> =
	SYN_SUBMD(I"dialogue")
		SYN_CONST(DIALOGUEBEATS_HL,               I"TableOfDialogueBeats")
		SYN_CONST(DIALOGUELINES_HL,               I"TableOfDialogueLines")

@h Extensions.
The |/main/synoptic/extensions| submodule.

@e SHOWEXTENSIONVERSIONS_HL
@e SHOWFULLEXTENSIONVERSIONS_HL
@e SHOWONEEXTENSION_HL

@<Resources for extensions@> =
	SYN_SUBMD(I"extensions")
		SYN_FUNCT(SHOWEXTENSIONVERSIONS_HL,       I"showextensionversions_fn", I"ShowExtensionVersions")
		SYN_FUNCT(SHOWFULLEXTENSIONVERSIONS_HL,   I"showfullextensionversions_fn", I"ShowFullExtensionVersions")
		SYN_FUNCT(SHOWONEEXTENSION_HL,            I"showoneextension_fn", I"ShowOneExtension")

@h Instances.
The |/main/synoptic/instances| submodule.

@e SHOWMEINSTANCEDETAILS_HL

@<Resources for instances@> =
	SYN_SUBMD(I"instances")
		SYN_FUNCT(SHOWMEINSTANCEDETAILS_HL,       I"showmeinstancedetails_fn", I"ShowMeInstanceDetails")

@h Kinds.
The |/main/synoptic/kinds| submodule.

@e DEFAULTVALUEOFKOV_HL
@e DEFAULTVALUEFINDER_HL
@e PRINTKINDVALUEPAIR_HL
@e KOVCOMPARISONFUNCTION_HL
@e KOVDOMAINSIZE_HL
@e KOVISBLOCKVALUE_HL
@e I7_KIND_NAME_HL
@e KOVSUPPORTFUNCTION_HL
@e SHOWMEKINDDETAILS_HL
@e BASE_KIND_HWM_HL
@e RUCKSACK_CLASS_HL
@e KINDHIERARCHY_HL

@<Resources for kinds@> =
	SYN_SUBMD(I"kinds")
		SYN_CONST(BASE_KIND_HWM_HL,               I"BASE_KIND_HWM")
		SYN_FUNCT(DEFAULTVALUEOFKOV_HL,           I"defaultvalue_fn", I"DefaultValueOfKOV")
		SYN_FUNCT(DEFAULTVALUEFINDER_HL,          I"defaultvaluefinder_fn", I"DefaultValueFinder")
		SYN_FUNCT(PRINTKINDVALUEPAIR_HL,          I"printkindvaluepair_fn", I"PrintKindValuePair")
		SYN_FUNCT(KOVCOMPARISONFUNCTION_HL,       I"comparison_fn", I"KOVComparisonFunction")
		SYN_FUNCT(KOVDOMAINSIZE_HL,               I"domainsize_fn", I"KOVDomainSize")
		SYN_FUNCT(KOVISBLOCKVALUE_HL,             I"blockvalue_fn", I"KOVIsBlockValue")
		SYN_FUNCT(I7_KIND_NAME_HL,                I"printkindname_fn", I"I7_Kind_Name")
		SYN_FUNCT(KOVSUPPORTFUNCTION_HL,          I"support_fn", I"KOVSupportFunction")
		SYN_FUNCT(SHOWMEKINDDETAILS_HL,           I"showmekinddetails_fn", I"ShowMeKindDetails")
		SYN_CONST(RUCKSACK_CLASS_HL,              I"RUCKSACK_CLASS")
		SYN_CONST(KINDHIERARCHY_HL,               I"KindHierarchy")

@h Multimedia.
The |/main/synoptic/multimedia| submodule.

@e RESOURCEIDSOFFIGURES_HL
@e RESOURCEIDSOFSOUNDS_HL
@e NO_EXTERNAL_FILES_HL
@e TABLEOFEXTERNALFILES_HL

@<Resources for multimedia@> =
	SYN_SUBMD(I"multimedia")
		SYN_CONST(RESOURCEIDSOFFIGURES_HL,        I"ResourceIDsOfFigures")
		SYN_CONST(RESOURCEIDSOFSOUNDS_HL,         I"ResourceIDsOfSounds")
		SYN_CONST(NO_EXTERNAL_FILES_HL,           I"NO_EXTERNAL_FILES")
		SYN_CONST(TABLEOFEXTERNALFILES_HL,        I"TableOfExternalFiles")

@h Properties.
The |/main/synoptic/properties| submodule.

@e CCOUNT_PROPERTY_HL

@<Resources for properties@> =
	SYN_SUBMD(I"properties")
		SYN_CONST(CCOUNT_PROPERTY_HL,             I"CCOUNT_PROPERTY")

@h Relations.
The |/main/synoptic/relations| submodule.

@e CREATEDYNAMICRELATIONS_HL
@e CCOUNT_BINARY_PREDICATE_HL
@e ITERATERELATIONS_HL
@e RPROPERTY_HL

@<Resources for relations@> =
	SYN_SUBMD(I"relations")
		SYN_FUNCT(CREATEDYNAMICRELATIONS_HL,      I"creator_fn", I"CreateDynamicRelations")
		SYN_CONST(CCOUNT_BINARY_PREDICATE_HL,     I"CCOUNT_BINARY_PREDICATE")
		SYN_FUNCT(ITERATERELATIONS_HL,            I"iterator_fn", I"IterateRelations")
		SYN_FUNCT(RPROPERTY_HL,                   I"property_fn", I"RProperty")

@h Rulebooks.
The |/main/synoptic/rulebooks| submodule.

@e NUMBER_RULEBOOKS_CREATED_HL
@e RULEBOOK_VAR_CREATORS_HL
@e SLOW_LOOKUP_HL
@e RULEBOOKS_ARRAY_HL
@e RULEBOOKNAMES_HL

@<Resources for rulebooks@> =
	SYN_SUBMD(I"rulebooks")
		SYN_CONST(NUMBER_RULEBOOKS_CREATED_HL,    I"NUMBER_RULEBOOKS_CREATED")
		SYN_CONST(RULEBOOK_VAR_CREATORS_HL,       I"rulebook_var_creators")
		SYN_FUNCT(SLOW_LOOKUP_HL,                 I"slow_lookup_fn", I"MStack_GetRBVarCreator")
		SYN_CONST(RULEBOOKS_ARRAY_HL,             I"rulebooks_array")
		SYN_CONST(RULEBOOKNAMES_HL,               I"RulebookNames")

@h Rules.
The |/main/synoptic/rules| and |/main/synoptic/responses| submodule.

@e RULEPRINTINGRULE_HL

@e RESPONSETEXTS_HL
@e NO_RESPONSES_HL
@e RESPONSEDIVISIONS_HL
@e PRINT_RESPONSE_HL

@<Resources for rules@> =
	SYN_SUBMD(I"rules")
		SYN_FUNCT(RULEPRINTINGRULE_HL,            I"print_fn", I"RulePrintingRule")

	SYN_SUBMD(I"responses")
		SYN_CONST(RESPONSEDIVISIONS_HL,           I"ResponseDivisions")
		SYN_CONST(RESPONSETEXTS_HL,               I"ResponseTexts")
		SYN_CONST(NO_RESPONSES_HL,                I"NO_RESPONSES")
		SYN_FUNCT(PRINT_RESPONSE_HL,              I"print_fn", I"PrintResponse")

@h Scenes.
The |/main/synoptic/scenes| submodule.

@e SHOWSCENESTATUS_HL
@e DETECTSCENECHANGE_HL

@<Resources for scenes@> =
	SYN_SUBMD(I"scenes")
		SYN_FUNCT(SHOWSCENESTATUS_HL,             I"show_scene_status_fn", I"ShowSceneStatus")
		SYN_FUNCT(DETECTSCENECHANGE_HL,           I"detect_scene_change_fn", I"DetectSceneChange")

@h Tables.
The |/main/synoptic/tables| submodule.

@e PRINT_TABLE_HL
@e TABLEOFTABLES_HL
@e TB_BLANKS_HL
@e RANKING_TABLE_HL

@e TC_KOV_HL

@<Resources for tables@> =
	SYN_SUBMD(I"tables")
		SYN_FUNCT(PRINT_TABLE_HL,                 I"print_fn", I"PrintTableName")
		SYN_CONST(TABLEOFTABLES_HL,               I"TableOfTables")
		SYN_CONST(TB_BLANKS_HL,                   I"TB_Blanks")
		SYN_CONST(RANKING_TABLE_HL,               I"RANKING_TABLE")

	SYN_SUBMD(I"table_columns")
		SYN_FUNCT(TC_KOV_HL,                      I"weak_kind_ID_of_column_entry_fn", I"TC_KOV")

@h Tests.
The |/main/synoptic/tests| submodule.

@e TESTSCRIPTSUB_HL

@<Resources for tests@> =
	SYN_SUBMD(I"tests")
		SYN_FUNCT(TESTSCRIPTSUB_HL,               I"TestScriptSub_fn", I"TestScriptSub")

@h Use options.
The |/main/synoptic/use_options| submodule.

@e NO_USE_OPTIONS_HL
@e TESTUSEOPTION_HL
@e PRINT_USE_OPTION_HL

@<Resources for use options@> =
	SYN_SUBMD(I"use_options")
		SYN_CONST(NO_USE_OPTIONS_HL,              I"NO_USE_OPTIONS")
		SYN_FUNCT(TESTUSEOPTION_HL,               I"test_fn", I"TestUseOption")
		SYN_FUNCT(PRINT_USE_OPTION_HL,            I"print_fn", I"PrintUseOption")
