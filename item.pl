#!/usr/bin/perl

use lib '/home/fuji-tip/local/lib/perl5';
use lib '/Users/fuji/perl5/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2/';

require 'amazon.pm';
require 'dbcon.pm';

use CGI::Carp qw(fatalsToBrowser);
use encoding "utf-8";

use DBI;
use CGI;

my $q = new CGI;
my $itemASIN = $q->param('ASIN');
my $comment;

my $amz_response = &amazon_asin_select('Books',$itemASIN);

my $itemtitle = $amz_response->{'Items'}->{'Item'}->{'ItemAttributes'}->{'Title'};my $itemimage = $amz_response->{'Items'}->{'Item'}->{'MediumImage'}->{'URL'};
my $itemurl = $amz_response->{'Items'}->{'Item'}->{'DetailPageURL'};
my $dbh = &connect;

my $statement = "SELECT comment FROM amazon_item WHERE asin = '$itemASIN';";
my $sth = $dbh->prepare($statement)
    or die $dbh->errstr;
$sth->execute()
    or die $sth->errstr;

print <<"!!EOF";
Content-type: text/html

<!DOCTYPE html>
<html>
    <head>
    <meta charset='UTF-8'>
    <link rel="stylesheet" type='text/css' href='./css/style.css' />
    <link rel='stylesheet' type='text/css' href='./css/bootstrap.min.css' />
    <link rel='stylesheet' type='text/css' href='./css/bootstrap-responsive.min.css' />
    <meta name="viewport" content="width=320, initial-scale=1.0, maximum-scale=1.0, user-scalable=no "/>
    </head>
    <body>
    <div class='container-fluid'>
      <div class='header'></div>
      <div class='row-fluid' id='item_detail'>
        <div class='span2'>
          <a href='$itemurl'><img src='$itemimage' /></a>
        </div>
        <div class='span4'>$itemtitle</div>
      </div>
      <div class='row-fluid'>
        <div class='result alert span6' id='result'></div>
      </div>
      <div class='row-fluid'>
        <form action='' id='commentform' name='commentform'>
          <div class='span8'>
            <div class='span7'>
              <textarea name='comment' rows='4'></textarea>
            </div>
            <div class='span1'>
              <button type='submit' class='btn'>insert</button>
            </div>
          </div>
          <input id='asin' type='hidden' value='$itemASIN'></input>
        </form>
      </div>
      <div class='row-fluid'>
        <div class='span8'>
          <a href='#' class='btn' onClick='history.back(); return false;'>戻る</a>
        </div>
      </div>
      <div class='row-fluid'>
        <div class='span8' id='past_comment'>
!!EOF
    while ($comment = $sth->fetchrow_array) {
	print "\t<div class='comment'>$comment</div>\n";
}
print <<"!!EOF";
          <div id="new_comment"></div>
        </div>
      </div>
    </div>
    <div class='footer'></div>
    <script type='text/javascript' src='./js/jquery.js'></script>
    <script type='text/javascript' src='./comment.js'></script>
    </body>
</html>
!!EOF
