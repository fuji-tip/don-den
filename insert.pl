#!/usr/bin/perl
use CGI;
use DBI;
use strict;
use warnings;

require './dbcon.pm';

# read the CGI params
my $cgi = CGI->new;
my $asin = $cgi->param("asin");
my $comment = $cgi->param("comment");

# connect to the database
my $dbh = &connect;

# check the username and password in the database
my $statement = qq{INSERT INTO amazon_item (asin, comment) VALUES(?, ?)};
my $sth = $dbh->prepare($statement)
  or die $dbh->errstr;
$sth->execute($asin, $comment)
  or die $sth->errstr;

# create a JSON string according to the database result
my $json = ($sth) ? 
  qq{{"success" : "insert successful!"}} : 
  qq{{"error" : "username or password is wrong"}};

# return JSON string
print $cgi->header(-type => "application/json", -charset => "utf-8");
print $json;
