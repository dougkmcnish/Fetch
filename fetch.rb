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

if ARGV.include? '-h' or ARGV.include? '--help' or ARGV.include? '-?'
  puts "#{HELPMSG}"
  exit
end

$server = 'changeme'
$user = 'changeme'
$pass = 'changeme'
$inbox = File.expand_path("~/Maildir") 
$host = Socket.gethostname

begin
  
  pop = Net::POP3.new($server)
  pop.start($user, $pass)

  if pop.mails.empty?
    puts "No Mail"
  else

    print "Downloading #{pop.mails.length} messages: "

    pop.each_mail do |m| 
      i = Time.now.to_f + rand(10000) 
      File.open("#{$inbox}/new/#{i}:2#{$host}", 'w') do |f|
          f.write m.pop
          i = Time.now.to_f + rand(10000) 
          f.close
      end

    end
  
    pop.finish
    puts "Done"

  end
    
rescue Exception => e
  puts "Error: #{e.to_s}"
end