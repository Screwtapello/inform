Using Inter.

Using Inter at the command line.

@h What Inter does.
The command-line executable Inter packages up the back end of the Inform 7
compiler into a stand-alone tool, and enables that back end to be used more
flexibly. For example, it can read or write either textual or binary inter
code, and can convert between them. It can also perform any of the numerous
code-generation stages on the code it reads, in any sequence. In short, it
aims to be a Swiss Army knife for inter code.

Because of that, it's possible to test code-generation stages individually:
we can read in some inter code from a text file, perform a single stage on
it, and write it out as text again. This gives us a very helpful window into
what Inform is doing; it also provides a test-bed for future optimisation,
or for future applications of inter code.

@h Command-line usage.
If you have compiled the standard distribution of the command-line tools
for Inform then the Inter executable will be at |inter/Tangled/inter|.

Inter has three basic modes. In the first, the command line specifies only
a single file:

	|$ inter/Tangled/inter INTERFILE|

Inter simply verifies this file for correctness: that is, to see if the inter
code supplied conforms to the inter specification. It returns the exit code 0
if all is well, and issues error messages and returns 1 if not.

Such files can be in either textual or binary form, and Inter automatically
detects which by looking at their contents. (Conventionally, such files
have the filename extension |.intert| or |.interb| respectively, but that's
not how Inter decides.)

@ In the second mode, Inter converts from textual to binary form or vice
versa. The option |-binary X| writes a binary form of the inter to file |X|,
and |-textual X| writes a text form. So, for example,

	|$ inter/Tangled/inter my.intert -binary my.interb|

converts |my.intert| (a textual inter file) to its binary equivalent
|my.interb|, and conversely:

	|$ inter/Tangled/inter my.interb -textual my.intert|

@ In the third and most flexible mode, Inter runs the supplied code through
a pipeline of processing stages. The pipeline, which must contain at least
one stage, can be quite elaborate (see later), but for example:

	|read <- myfile.inter, resolve-conditional-compilation, generate inform6 -> myfile.i6|

is a valid three-stage pipeline. The command to do this is then:

	|$ inter/Tangled/inter -pipeline-text 'PIPELINE'|

where |PIPELINE| is a textual description like the one above. In practice,
it may not be convenient to spell the pipeline out on the command line, so
one can also put it into a text file:

	|$ inter/Tangled/inter -pipeline-file mypl.interpipeline|

Pipelines can contain variables, and their values can be set at the command
line with e.g.:

	|-variable '*out=myfile.i6'|

It is also possible to set the default directory for reading and writing files:

	|-domain D|

@h Assimilation.
Inform makes use of what are called "kits" of pre-compiled Inter code:
for example, |CommandParserKit| contains code for the traditional interactive
fiction command parser. For speed, Inter loads these as binary Inter, but
that means they have to be compiled from time to time. This is called
"assimilation".

The source code for these could in priniple be textual Inter, but that's too
verbose to write comfortably. In practice we use Inform 6 code as a notation,
and therefore assimilation is really a cross-compilation from I6 to Inter.

Kits are like so-called "fat binaries", in that they contain binary Inter
for each different architecture with which they are compatible. Inter can
assimilate for only one architecture at a time, so a command must specify
which is wanted. For example:

	|$ inter/Tangled/inter -architecture 16 -assimilate K|
	|$ inter/Tangled/inter -architecture 32d -assimilate K|

Incrementally assimilating kits as needed could be done with something like
the Unix tool |make|, but in fact Inbuild has this ability: the command

	|$ inbuild/Tangled/inbuild -build K|

looks at the kit, works out which architectures need re-assimilation, and
then issues commands like the above to instruct |inter| to do so. Indeed,
multiple kits can be managed with a single command:

	|$ inbuild/Tangled/inbuild -build -contents-of inform7/Internal/Inter|
