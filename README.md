fetch.rb
=========

POPs mail off of a POP3 server 
and stores the mail in a Maildir
of your choosing.  The POP3 portion
is almost a straight copy/paste 
from the Net::POP3 docs, with a couple
changes to fake Maildir support.
The rest is a novice coder reinventing
the wheel. ;)


FIXME
-------
Should probably do a 
better job of creating our 
Maildir structure. Until then you\'ll
need to make sure to create 
$inbox/(new|cur|tmp)

You\'ll currently need to manually
configure host/user/pass in-script
as well.  