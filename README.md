fetch.rb: 
=========

Retreive mail from POP3 server. Supports SSL. 
Will store mail in *$HOME/Maildir/Inbox* or simply 
hand off From: and Subject: headers to a Boxcar 
account. 
Doesn't rely on read status, so it plays nice with
IMAP users who just want to archive mail. Caches 
unique IDs in *~/.pop3cache.db* (requires sqlite3) 


##Before run:##
    
* *gem install sqlite3* 
* *mkdir -p ~/Maildir/Inbox/{cur,new,tmp}* (if you
plan on storing mail.) 
* Configure user settings in *~/.fetchrc.rb* if 
you don't want to set them in your script. 
Config file will override script defaults. 
  
##ToDo:##
  
* Automatically Create Maildir if necessary
Just run *mkdir -p ~/Maildir/Inbox/{new,cur,tmp}* 
in the interim. 

* Real config file support. Lazy loading right
now because I'm lazy. 

* Optional file logging 

* Handle exceptions. See item 2. 
* Maybe daemonize (if I get bored one day)
* Validate SSL certs.