
* If lookup_var_or_command returns a Node, when the Node is evaluated, how do we
  also update the parent Node so that if the parent Node doesn't check out it
  evaluates to the right thing? If we do late evaluation we can't set
  stash[:tmp] until the Node is evaluated after which it'll be too late...

* When a sub is added to the document then we assign a parent to it...
