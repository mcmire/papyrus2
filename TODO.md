# TODO

* Rename NodeList to Tree
* Rename ContextItem to Context
* Finish up block command modifiers (there are unused references to this in
* Remove Document#options, I don't see a need for this
* There's no way to add commands to the lexicon which are implemented via method
  (you must use CustomCommandSet)
* Support specifying beginning and ending tokens so that you can use a template
  as a meta-template -- parsing it once to set the template initially, then
  parsing it again at runtime to evaluate it
* Clean up how insertion_doppelgangers are evaluated -- this logic should not be
  in NodeList but in the Node itself
