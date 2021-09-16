Calling Inform from C.

In 2021, Inform gained the ability to generate C code which could be used as
part of a larger program, for example in a framework such as Unity.

@h Introduction.
Users of the Inform UI apps make programs which are usually textual simulations,
and which are in any case sealed boxes running on virtual machines such as Glulx.
Although very creative things have been done to hook those up to other machinery,
usually via Javascript trickery when running those VMs as part of a website, it
is mostly impractical to use those tricks to have Inform 7 work as part of a
bigger program not written in Inform.

However, it is now, as of 2021, possible to use Inform equally well as a
command-line tool and to use it to generate code which can link into a C
program, and indeed it's therefore quite easy to have a hybrid program --
part Inform, part C/C++ (or indeed anything else which can call C functions).
For example, one could imagine a game developed with Unity which uses a
portion of Inform 7 code to manage, say, just world-modelling or text
generation services.

The following documentation covers how to build hybrid Inform-and-C programs.

@h Example makes.
The Inform source repository includes a small suite of examples of such hybrid
programs, stored at:
= (text as ConsoleText)
inform/inform7/Tests/Test Makes/Eg1-C
inform/inform7/Tests/Test Makes/Eg2-C
...
=
These toy programs are automatically built and tested as part of the Inform 7
test suite, but they can also be copied and then experimented with. We'll call
these projects "makes", and indeed each one contains a makefile. Change directory
to it, type |make|, and an executable should appear.

The makefiles assume that you have access to the |clang| C compiler, but |gcc|
could equally be used, or any C-99 compatible tool. The makefiles open with a
reference to the location of the |inform7| installation on your filing system;
so that opening will need to be edited if you move these projects out of
|inform/inform7/Tests/Test Makes/|.

@h Example 1: Hello World.
This first example is not even a hybrid. It compiles the simplest of Basic Inform
programs:
= (text as Inform 7)
To begin:
	say "Hello world.";
=
...by translating it into a C program, which it then compiles, to produce a native
executable. The following shows this working:
= (text as ConsoleText)
$ cd "inform/inform7/Tests/Test Makes/Eg1-C"
$ ls
Eg1.i7			ideal_output.txt	makefile
$ make -silent
$ ls
Eg1			    Eg1-I.o			    ideal_output.txt
Eg1-I.c			Eg1.i7			    makefile
$ ./Eg1
Hello world.
=
|ideal_output.txt| contains the text which the program should print, if it works
correctly: this is used in testing. The make process accomplished the following:
= (text)
 Eg1.i7     source in Inform 7
   |
   | inform7
  \|/
 Eg1-I.c    source in C
   |
   | clang (acting as C compiler)
  \|/
 Eg1-I.o    C object file
   |
   | clang (acting as linker)
  \|/
  Eg1       native executable
=
As with all of the examples, |make run| runs the program, building it if necessary;
and |make clean| removes the files generated by the build process, returning the
directory to its mint condition. In this case, that means deleting |Eg1-I.c|,
|Eg1-I.o| and |Eg1|. Note the filenaming convention: the |-I| in the name of, say,
|Eg1-I.c| is supposed to signal that the file was derived from an Inform original.

The makefile for Example 1 is simple, and in a full build it runs the following:
= (text as ConsoleText)
$ make
../../../Tangled/inform7 -silence -basic -format=C -o Eg1-I.c Eg1.i7
clang -g -std=c99 -c -I ../../../Internal/Miscellany -o Eg1-I.o Eg1-I.c
clang -g -o Eg1 Eg1-I.o
=
All three tools compile silently if no errors occur, though in the case of //inform7//
that's only because |-silence| was asked for. |-basic| indicates that this is a
Basic Inform program, which is not asked to contain a command parser, for example.
|-format=C| makes the output a C program rather than an Inform 6 one, of course.

The |-I ../../../Internal/Miscellany| switch when using |clang| as C compiler
tells it that this directory should be in the search path for |#include| files.
This is needed so that:
= (text as C)
#include "inform7_clib.h"
=
will work. This header file is supplied in every Inform installation at:
= (text)
inform7/Internal/Miscellany/inform7_clib.h
=

@h Example 2: Hello Hello.
This time we begin with both a C program and an Inform program, both of which
want to say hello: we want to compile these into a single executable. Now the
makefile has an extra step:
= (text)
	Eg2.c		 Eg2.i7     source in C and Inform 7 respectively
	  |			    |
	  |			    | inform7
	  |			   \|/
	  |			 Eg2-I.c    source in C
	  |			    |
	  |	clang	    | clang (acting as C compiler)
	 \|/		   \|/
	Eg2.o		 Eg2-I.o    C object files
	  |			    |
	  +------+------+
		     |
		     | clang (acting as linker)
		    \|/
		    Eg2       		native executable
=
That will be the basic plan for all the remaining examples too, so we'll stop
with these diagrams. Here |Eg2.c| is the C part of our source code, and is not
to be confused with |Eg2-I.c|, which is the conversion to C of the Inform part
of our source. Each produces an object file, and the link unites these into a
single executable.

The Inform source reads:
= (text as Inform 7)
To begin:
	say "Hello from the Inform source."
=
The C source could be very easy too:
= (text as C)
#include "inform7_clib.h"

int main(int argc, char **argv) {
	printf("Hello from the C source code.\n");
	i7process_t proc = i7_new_process();
	i7_run_process(&proc);
	return 0;
}
=
When run, this produces:
= (text as ConsoleText)
Hello from the C source code.
Hello from the Inform source.
=
Note that the C program is the one in command here: in particular, it contains
|main|. That means of course that |Eg2-I.c| must not include a |main| function,
or the linking stage will throw an error; whereas |Eg1-I.c|, in the previous example,
did have to include |main|. So clearly something must be different about the
command to generate C from Inform this time.

This issue is resolved by tweaking the |-format| requested. Whereas the makefile
for example 1 asked |inform7| for |-format=C|, the makefile for example 2 asks it
for |-format=C/no-main|. The |no-main| tells the part of Inform which generates C
code not to make a |main| of its own, and so all is well. |-format=C/main| is
the default arrangement, to which |-format=C| is equivalent.

@ The type |i7process_t| is used for an "Inform process".[1] A single C program can
contain any number of these, and indeed could call them independently from
multiple threads at the same time: but they are all instances of the same Inform
program running, each with its own independent state and data. So, for example,
two different Inform processes will have two different values for the same Inform
variable name. In effect, they are isolated, independent virtual machines, each
running a copy of the same program.

It is essential to create a process as shown, with a call to |i7_new_process|.
Once created, though, the same process can be run multiple times. If we had
written,
= (text as C)
	i7process_t proc = i7_new_process();
	i7_run_process(&proc);
	i7_run_process(&proc);
=
then the result would have been:
= (text as ConsoleText)
Hello from the C source code.
Hello from the Inform source.
Hello from the Inform source.
=

[1] Strictly speaking, typedef names ending |_t| are reserved for use by the
POSIX standard, so this is a sin, but really, I don't see POSIX ever needing names
prefixed |i7|, and besides, everybody does it.

@ A note about thread safety. Suppose the C program runs multiple threads. Then:

(a) It is perfectly thread-safe for two or more threads to each be running
Inform processes simultaneously, but
(b) They must be different |i7process_t| objects, and
(c) They do not share any data: each process has its own data. If there is an
Inform variable called "favourite colour", for example, two different |i7process_t|
processes running at the same time will have two different values of this.

Note that all |i7process_t| instances are running the same Inform program. You
cannot, at present, link multiple different Inform programs into the same C
program.

@ Formally speaking, |i7_run_process| returns the entire Inform program to its
end, and then returns an exit code: 0 if that program exited cleanly, and 1
if it halted with a fatal error, for example through dividing by zero, or
failing a memory allocation. In that event, an error message will be printed
to |stderr|.

So, for the sake of tidiness, the full |Eg2.c| reads:
= (text as C)
#include "inform7_clib.h"

int main(int argc, char **argv) {
	printf("Hello from the C source code.\n");
	i7process_t proc = i7_new_process();
	int exit_code = i7_run_process(&proc);
	if (exit_code == 1) {
		printf("*** Fatal error: halted ***\n");
		fflush(stdout); fflush(stderr);
	}
	return exit_code;
}
=
Example 2 is in fact so simple that it is impossible for the exit code to be
other than 0, but checking the exit code is good practice.

@h Example 3: HTML Receiver.
This third example demonstrates a "receiver" function. The text printed by
Inform 7 can be captured, processed, and in general handled however the C
program would like. This is done by assigning a receiver to the process,
after it is created, but before it is run:
= (text as C)
	i7process_t proc = i7_new_process();
	i7_set_process_receiver(&proc, my_receiver, 1);
=
Here |my_receiver| is a function. The default receiver looks like this:
= (text as C)
void i7_default_receiver(int id, wchar_t c, char *style) {
	if (id == I7_BODY_TEXT_ID) fputc(c, stdout);
}
=
This receives the text printed by the Inform process, one character at a time.

(*) The |id| is a "window ID", a detail which doesn't matter to a Basic Inform
project -- it will always in fact be |I7_BODY_TEXT_ID|. For a full Inform project
such as an IF work, it might be any of three possibilities:
(-*) |I7_BODY_TEXT_ID|, the main transcript of text in the story;
(-*) |I7_STATUS_TEXT_ID|, the "status line" header at the top of a traditional
Terminal-window-style presentation of this text;
(-*) |I7_BOX_TEXT_ID|, a quotation printed in a box which overlies the main text.

(*) The |style| is a stylistic markup. It will always be a valid C string, of
length at most 256, but is often the empty C string and of length 0, meaning
"this is plain text with no styling applied".
(-*) The three main styles are |italic|, |bold|, |reverse| and |fixedpitch|.
(-*) Plain styling and these three can all be combined with a "fixed-pitch type"
request, thus: |fixedpitch|, |italic,fixedpitch|, |bold,fixedpitch|, |reverse,fixedpitch|.

As can be seen, the default receiver ignores all text not sent to the main window,
and ignores all styling even on that.

The significance of the 1 in the call |i7_set_process_receiver(&proc, my_receiver, 1)|
is that it asked for text to be sent to the receiver encoded as UTF-8. This in fact
is the default receiver's arrangement, too. Call |i7_set_process_receiver(&proc, my_receiver, 0)|
to have the characters arrive raw as a series of unencoded Unicode code-points.

In Example 3, the Inform source is:
= (text as Inform 7)
To begin:
	say "Hello & [italic type]welcome[roman type] from <Inform code>!"
=
The example receiver function converts this to HTML:
= (text)
<html><body>
Hello &amp; <span class="italic">welcome</span> from &lt;Inform code&gt;!
</html></body>
=
The word "welcome" here was printed with the style |"italic"|; all else was
plain.

This example just prints the result, of course, but a receiver function could
equally opt to bottle up the text for use later on.

@h Example 4: CSS Receiver.
Example 4 builds on Example 3 but allows arbitrary named CSS styles to applied,
i.e., it is not limited to bold and italic markup.

The C program from Example 3 is unchanged, but the Inform program does something
more interesting. We're going to need to do something unusual here, and define
two new phrases using inline definitions as raw Inter code, written in Inform 6
notation:
= (text as Inform 7)
To style text with (T - text):
	(- style {T}; -).
=
The result of this will be something which Inform 6 would not compile, because
in I6 the only legal uses of |style| are |style bold| and so on: there is no
legal way for |style| to be followed by an arbitrary value, as it is here. But
Inform 6 will not be compiling this: Inform will convert |style V;| directly to
the Inter statement |!style V|, which will then be translated to C as the function
call |i7_style(proc, V)| -- and that function, in our library of C code supporting
Inform, can handle any textual value of |V|.

With that bit of fancy footwork out of the way, we can make a pair of text
substitutions |[style NAME]| and |[end style]|, with the possible range of
styles enumerated by name, like so:
= (text as Inform 7)
A text style is a kind of value.
The text styles are decorative, calligraphic and enlarged.

To say style as (T - text style):
	style text with "[T]".

To say end style:
	(- style roman; -).
=

Finally, then, we can have:
= (text as Inform 7)
To begin:
	say "[style as enlarged]Hello[end style] & [style as calligraphic]welcome[end style] from <Inform code>!"
=
And the result is:
= (text as Inform 7)
<html><body>
<span class="enlarged">Hello</span> &amp; <span class="calligraphic">welcome</span> from &lt;Inform code&gt;!
</html></body>
=
