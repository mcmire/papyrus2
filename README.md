# Papyrus

## THIS IS A PRE-RELEASE VERSION

This library is a re-write of a prior library I created. (If you are interested,
a much earlier version is available [here](http://github.com/mcmire/papyrus)). I
am still in the process of changing some things, so I wouldn't use this for
anything just yet.

---

## What is Papyrus?

Papyrus is a templating library. If you've been using Ruby for a while
you've probably heard of Liquid or Mustache. If you write PHP regularly, you
might use Smarty, and if you're old enough to remember the popularity of phpBB
forums you might have composed posts in BBCode. All of these are templating
languages. It works like this: you have a text document and that document
contains special code -- expressions wrapped in brackets of some kind. When
you run the text document through the templating library, it sees these
bracketed expressions and *evaluates* them. Different expressions do different
things, but they all produce text, so the renderer just substitutes each
expression for whatever text it produces. So what you finally end up with is a
slightly different text document, but one which is free of special
expressions. So Papyrus works the same way.

Naturally, Papyrus calls these expressions "substitutions", or *subs* for short.
Some subs are *variables*. That means they just hold simple values: someone's
name, a list of your favorite albums, that sort of thing. Other expressions,
however, are *commands*. This means they can do things -- give you the current
time, calculate someone's age based on their birthyear, and so forth. Either
way, the stuff inside a sub is just a series of words, or a series of groups of
words, where the first word is special. You can group words together with
quotes. So, with that in mind a typical Papyrus document might look like this:

    Hello, my name is Billy. I am [age] years old and I was born when [president_in_year 1999] was president. When I am president I am going to [random "cure cancer" "stop the wars in the Middle East" "roll up into a ball and cry"].

If the `[age]` sub (a variable) evaluated to `13`, the `[president_in_year]`
sub (a command) evaluated to "Bill Clinton", and the `[random]` sub (another
command) evaluated (at least on one run) to `stop the wars in the Middle
East`, then this text document would be rendered as:

    Hello, my name is Billy. I am 13 years old and I was born when George W. Bush was president. When I am president I am going to stop the wars in the Middle East.

"Okay, that's neat," you might be saying. "But we already have templating
languages like the ones you just mentioned. What makes Papyrus so special?"
Well, you know those subs I just talked about? Turns out that you can do two
pretty cool things with them:

1. A variable can produce another sub. Say you have a variable `[foo]`, and
   its value is `[bar]`, and `[bar]`'s value is `42`. So, `[foo]` would
   actually render as `42`, and not `[bar]` as you might think.
2. The arguments to a command sub may be subs themselves. So, take our
   `[president]` command from the example before. If we had another command
   `[10 years ago]` that returned a year, we could in theory say
   `[president_in_year [10 years ago]]` and Papyrus would do a double
   substitution: first `[10 years ago]` to get `[president_in_year 2002]`, and
   then that to get `George W. Bush`.

## So how does Papyrus work?

Read the source, man! But seriously. I've tried to document a lot of the code
because I think the whole thing is pretty neat. I used Rocco for the first time.
It feels like you're reading a book, kind of. I think you'll like it.
Check it out: <http://mcmire.github.com/papyrus2/doc/papyrus.html>. (Note: I'm
still working on this, excuse the dust)

## How did Papyrus come about?

Papyrus was built for [Codexed](http://codexed.com), which was both a website
for people who enjoy writing and a community composed of these people.
Underneath it all, though, we were essentially a blog host. It was the same idea
as something like Blogger or WordPress: you could set up an account and write
and publish posts. You could also customize how your journal looked through
templates. All you had to do was give us HTML, tell us where the body of your
post should appear in that HTML along with some extras, and we'd stitch it all
together on the backend. This, of course, means that we had to have an engine
that could process those templates.

So everything you see here is that template engine, extracted straight from
Codexed. Not everything's exactly the same: I've taken some effort to clean
things up and add proper documentation and that sort of thing. But it's pretty
much all there.

## Are you actively working on this? Do you offer support?

So here's the deal. This is an extraction from a previous project, and I don't
work on that project anymore. I am putting this code up here only for show.
At the moment, though, I have no plans to use it in a project. So no, I am
unfortunately not actively working on this.

## I'm writing a blog engine, can I use Papyrus for it?

Absolutely! I mean, even if I'm not working on it doesn't mean it doesn't work.
Just run the tests if you don't believe me.

The real question is, will it meet your needs exactly. That, I'm not sure. I
know that Papyrus isn't as pure conceptually as I'd like -- there were a few
little changes we had to make for Codexed. I imagine there are probably things
you want to do with it, and that's fine. I can answer any questions you have,
just ping me.

## Did you draw on any resources while designing Papyrus?

Yes, originally it started as a fork of Brian Wisti and Greg Millam's
[PageTemplate](https://github.com/brianwisti/PageTemplate) gem, as I wanted
to have logic commands. For Codexed, we determined this was not necessary for
the initial feature set. While I was on summer vacation one year I ended up
rewriting pretty much everything, so that was that. Some of the tokenizer code
also came from a predecessor of Codexed. Besides that, it looks an awful lot
like Lisp and I don't think that's a coincidence.

## The rest

Papyrus is (c) 2008-2012 Elliot Winkler <elliot.winkler@gmail.com>.

You are free to use any code here as you like, whether for commercial or
personal purposes. I do not provide any warranty for damages caused by this
software, etc., etc.

