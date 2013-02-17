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
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type='text/javascript' src='./js/jquery.js'></script>
    <script type='text/javascript' src='./comment.js'></script>
    <link rel="stylesheet" type='text/css' href='./css/style.css'>
    </head>
    <body>
    <a href='$itemurl'>
    <img src='$itemimage' />
    $itemtitle
    </a>
    <div id='result'></div>
    <div id='form'>
    <form action='' id='commentform' name='commentform'>
    <textarea name='comment'></textarea>
    <button type='submit'>insert</button>
    <p><a href='#' onClick='history.back(); return false;'>戻る</a></p>
    <input id='asin' type='hidden' value='$itemASIN'></input>
    </form>
    </div>
!!EOF
    while ($comment = $sth->fetchrow_array) {
	print "\t<div class='comment'>$comment</div>\n";
}
print <<"!!EOF";
    <div id="new_comment"></div>
    </body>
</html>
!!EOF

