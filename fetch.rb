#!/usr/bin/env ruby
=begin

fetch.rb: 
  POPs mail off of a POP3 server 
  and stores the mail in a Maildir
  of your choosing.  The POP3 portion
  is almost a straight copy/paste 
  from the Net::POP3 docs.  The rest
  is a novice coder reinventing
  the wheel. ;)
  
  FIXME: Should probably do a 
  better job of creating our 
  Maildir structure. Until then
  Just make sure to create 
  #{INBOX}/(new|cur|tmp)
  
  
=end 

require 'socket'
require 'net/pop'


$server = 'changeme'
$user = 'changeme'
$pass = 'changeme'
$inbox = File.expand_path("~/Maildir") 
$host = Socket.gethostname

begin
  

  puts 'Starting'
  pop = Net::POP3.new($server)
  pop.start($user, $pass)

  if pop.mails.empty?
    puts "No Mail"
  else
    
    pop.each_mail do |m| 
      puts "Here?"
      i = Time.now.to_f + rand(10000) 
      puts "Or Here?"
      File.open("#{$inbox}/new/#{i}:2#{$host}", 'w') do |f|
          f.write m.pop
          i = Time.now.to_f + rand(10000) 
          f.close
      end
#      m.delete
    end
    
  end
    
rescue Exception => e
  puts "Error: #{e.to_s}"
end