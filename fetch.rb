#!/usr/bin/env ruby

HELPMSG=<<-EOS

fetch.rb: 
  POPs mail off of a POP3 server 
  and stores the mail in a Maildir
  of your choosing.  The POP3 portion
  is almost a straight copy/paste 
  from the Net::POP3 docs, with a couple
  changes to fake Maildir support.
  The rest is a novice coder reinventing
  the wheel. ;)
  
  FIXME: Should probably do a 
  better job of creating our 
  Maildir structure. Until then you\'ll
  need to make sure to create 
  $inbox/(new|cur|tmp)
  
  You\'ll currently need to manually
  configure host/user/pass in-script
  as well. 
  
EOS

require 'socket'
require 'net/pop'
require 'sqlite3' 

if ARGV.include? '-h' or ARGV.include? '--help' or ARGV.include? '-?'
  puts "#{HELPMSG}"
  exit
end

if ARGV.include? '-d' 
  $debug = true
end

$server = 'changeme'
$user = 'changeme'
$pass = 'changeme'
$sqlite3_cache = 'poptest.db'
$boxcar_addr = ''
$download_mail = false #change to true to write mail to maildir
$boxcar_notify = false #change to true to send push notification via boxcar
$inbox = File.expand_path("~/Maildir") 
$host = Socket.gethostname

class Pop3Session

  def initialize(server,user,pass)
    
    print "Logging in: " if $debug
    @pop = Net::POP3.new(server)
    @pop.start(user,pass)
    puts "DONE" if $debug
   
    print "Initializing cache: " if $debug
    @cache = Pop3Cache.new
    puts "DONE" if $debug

  end
  
  def new_mail? 
    if pop.mails.empty? 
      puts "No mail" if $debug 
      return nil
    end
    return true 
  end

  def fetch_mail 
    print "Fetching mail: " if $debug
    if self.new_mail? 
      @pop.each_mail do |m| 
        unless @cache.seen(m.uidl)
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
    
    msg.each_line do |line| 
      puts hdr.grep(/^From: /)
      puts hdr.grep(/^Subject: /) 
    end
  end    
    
end

class Pop3Cache
  
  def initialize 
    File.exists?($sqlite3_cache) ? self.open_db : self.create
  end
  
  def open_db
    @c = SQLite3::Database.new($cache) 
  end
  
  def create(cache) 
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




begin
  
  p = Pop3Session.new($server,$user,$pass) 

  
    
    
    
rescue Exception => e
  puts "Error: #{e.to_s}"
end
