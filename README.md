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

This started out as a quick and dirty 
mail fetcher. I've since added the ability
to send only necessary message headers to 
Boxcar on IOS to get around the otherwise 
excellent Sparrow app's missing push notification
support. This works better than using fetchmail/procmail
because I couldn't coerce fetchmail into leaving 
the read status of messages alone. Oh, and 
fetchmail/procmail is zero fun to set up. Works for me. 
Hope it's helpful to other Sparrow fans. 


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