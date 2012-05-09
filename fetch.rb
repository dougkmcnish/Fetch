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

$server = 'changeme'
$user = 'changeme'
$pass = 'changeme'
$sqlite3_cache = 'poptest.db'
$boxcar_addr = ''
$inbox = File.expand_path("~/Maildir") 
$host = Socket.gethostname

class Pop3Session

  def initialize(server,user,pass)
    
    @pop = Net::POP3.new($server)
    @pop.start($user, $pass)
    @cache = Pop3Cache.new

  end
  
  def new_mail? 
    return nil if pop.mails.empty? 
    return true 
  end

  def fetch_mail 
    @pop.each_mail do |m| 

      i = Time.now.to_f + rand(10000) 

      File.open("#{$inbox}/new/#{i}:2#{$host}", 'w') do |f|
          f.write m.pop
          i = Time.now.to_f + rand(10000) 
          f.close
      end

    end

  end
  
  def boxcar_notify

    @pop.each_mail do |m|
      unless @cache.seen(m)
        #email boxcar 
      end
    end
  end
  
  
    
    
end

class Pop3Cache
  
  def initialize 
    File.exists?($sqlite3_cache) ? self.open_db : self.create_db
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
    return count 
  end  

  def add(mid)
  end
    

end


begin
  

  if pop.mails.empty?
    puts "No Mail"
  else

    print "Downloading #{pop.mails.length} messages: "

    pop.finish
    puts "Done"

  end
    
rescue Exception => e
  puts "Error: #{e.to_s}"
end
