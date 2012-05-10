#!/usr/bin/env ruby

HELPMSG=<<-EOS

fetch.rb: 
  Retreive mail from POP3 server. Supports SSL. 
  Will store mail in *$HOME/Maildir/Inbox* or simply 
  hand off From: and Subject: headers to a Boxcar 
  account. 
  Doesn't rely on read status, so it plays nice with
  IMAP users who just want to archive mail. Caches 
  unique IDs in *~/.pop3cache.db* (requires sqlite3) 


  **Before run:**
    
    * *gem install sqlite3* 
    * *mkdir -p ~/Maildir/Inbox/{cur,new,tmp}* (if you
      plan on storing mail.) 
    * Configure user settings in *~/.fetchrc.rb* if 
      you don't want to set them in your script. 
      Config file will override script defaults. 
  
  **ToDo:** 
  
    * Automatically Create Maildir if necessary
      Just run *mkdir ~/Maildir/Inbox/{new,cur,tmp}* 
      in the interim. 

    * Real config file support. Lazy loading right
      now because I'm lazy. 

    * Optional file logging 

    * Handle exceptions. See item 2. 
    * Maybe daemonize (if I get bored one day) 

   
EOS



$server = ''
$user = ''
$pass = ''
$use_ssl = true #Set to false if you're not using SSL 

# What would you like to accomplish
$download_mail = false #change to true to write mail to maildir
$boxcar_notify = true  #change to true to send push notification via boxcar

# If you're using this for boxcar notifications. 
$boxcar_addr = ''
$smtp_relay = 'localhost'


#------------------------

require 'socket'
require 'net/pop'
require 'sqlite3' 
require 'net/smtp' 

#Environment stuff 

$inbox = File.expand_path("~/Maildir/Inbox") 
$sqlite3_cache = File.expand_path("~/.pop3cache.db") 
$host = Socket.gethostname

load File.expand_path("~/.fetchrc.rb") if File.exists?(File.expand_path("~/.fetchrc.rb")) 

if ARGV.include? '-h' or ARGV.include? '--help' or ARGV.include? '-?'
  puts "#{HELPMSG}"
  exit
end

# If you want debugging output
if ARGV.include? '-d' 
  $debug = true
end

class Pop3Session

  def initialize(server,user,pass,ssl)
    
    print "Logging in: " if $debug
    @pop = Net::POP3.new(server)
    @pop.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if ssl == true 
    @pop.start(user,pass)
    puts "DONE" if $debug
   
    print "Initializing cache: " if $debug
    @cache = Pop3Cache.new
    puts "DONE" if $debug

  end
  
  def new_mail? 
    if @pop.mails.empty? 
      print "*No Mail*" if $debug 
      return nil
    end
    return true 
  end

  def fetch_mail 
    print "Fetching mail: " if $debug
    if self.new_mail? 
      @pop.each_mail do |m| 
        if @cache.seen?(m.uidl) == 0
          self.maildir_store(m) if $download_mail 
          self.boxcar_notify(m) if $boxcar_notify 
        end
      end
    end
    puts "DONE" if $debug 
  end

  def maildir_store(msg)
    i = Time.now.to_f + rand(10000) 
    File.open("#{$inbox}/new/#{i}:2#{$host}", 'w') do |f|
      f.write msg.pop
      f.close
    end
  end
  
  def boxcar_notify(msg)

    hdr = msg.header.split(/\n/) 

    msgstr = <<EOSMTP
#{hdr.grep(/^From: /)[0]}
To: #{$boxcar_addr}
#{hdr.grep(/^Subject: /)[0]}

EOM
EOSMTP

    puts msgstr if $debug
    Net::SMTP.start($smtp_relay, 25) do |smtp| 
      smtp.send_message msgstr,
      'alerts@nonesense_addr.tld',
      $boxcar_addr
    end

  end    
    
end

class Pop3Cache
  
  def initialize 
    File.exists?($sqlite3_cache) ? self.open_db : self.create
  end
  
  def open_db
    @c = SQLite3::Database.new($sqlite3_cache) 
  end
  
  def create 
    self.open_db
    @c.execute('create table mid_cache ( mid text, seen integer )') 
  end


  def seen?(mid) 
    count = @c.get_first_value('select count(*) from mid_cache where mid = \'' + mid + '\'') 
    self.add(mid) unless count > 0 
    return count 
  end  

  def add(mid)
    @c.execute('insert into mid_cache values ("' + mid + '", "' + 
               Time.now.strftime("%Y-%m-%d %H:%M:%S") + '")')
  end
    

end



#############################
#Here comes our program logic
#############################




#begin
  
  p = Pop3Session.new($server,$user,$pass,$use_ssl) 
  p.fetch_mail 
    
#rescue Exception => e
 # puts "Error: #{e.to_s}"
#end
