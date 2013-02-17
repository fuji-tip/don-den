#!/usr/bin/perl

require 'amazon.pm';
use encoding "utf-8";

use CGI;

my $q = new CGI;
my $presentpage;
if (($q->param('page')) == undef) {
    $presentpage = 1;
} else {
    $presentpage = $q->param('page');
}
my $Keywords    = $q->param('Keywords');
my $SearchIndex = $q->param('SearchIndex');
my %selected = ( $SearchIndex => ' selected' );

my $amz_response = &amazon_simple_search($SearchIndex, $Keywords, $presentpage);

my $itemurl = "./item.pl";
my $itemtitle;
my $itemimage;
my $itemASIN;

my $itemnum = $amz_response->{'Items'}->{'TotalResults'};
my $totalpages = $amz_response->{'Items'}->{'TotalPages'};

my $entryperpage = 10;

print <<"!!EOF";
Content-type: text/html

<!DOCTYPE html>
<html>
    <head>
    <meta charset='UTF-8' />
    <link rel="stylesheet" type="text/css" href="./css/style.css" />
    <link rel='stylesheet' type='text/css' href='./css/bootstrap.min.css' />
    <link rel='stylesheet' type='text/css' href='./css/bootstrap-responsive.min.css' />
    <meta name="viewport" content="width=320, initial-scale=1.0, maximum-scale=1.0, user-scalable=no "/>
    </head>
    <body>
      <div class='container-fluid'>
        <form action='amazon-html.pl' method='GET' class=''>
          <select name='SearchIndex'>
            <option value='Books'$selected{'Books'}>本</option>
            <option value='DVD'$selected{'DVD'}>DVD</option>
            <option value='Video'$selected{'Video'}>ビデオ</option>
            <option value='VideoGames'$selected{'VideoGames'}>ゲーム</option>
          </select>
          <input type='text' name='Keywords' value='$Keywords' class='input-type search-query' placeholder='Search word...'>
          <input class='btn' type='submit' value='検索'>
          <p>$itemnum 件ヒットしました。</p>
!!EOF

if ($totalpages > 10) {
    print "<p>検索結果が10ページを超えています。キーワードを増やして検索してください。</p>";
}

for ($i = 0; ($i < $entryperpage) && (($entryperpage * ($presentpage-1) + $i) < $itemnum); $i++) {
    #$itemurl = $amz_response->{'Items'}->{'Item'}[$i]->{'DetailPageURL'};
    $itemtitle = $amz_response->{'Items'}->{'Item'}[$i]->{'ItemAttributes'}->{'Title'};
    $itemimage = $amz_response->{'Items'}->{'Item'}[$i]->{'SmallImage'}->{'URL'};
    $itemASIN = $amz_response->{'Items'}->{'Item'}[$i]->{'ASIN'};
    print "\t<div class='itemimage'>\n\t\t<a href='$itemurl?ASIN=$itemASIN'><img src='$itemimage'>\n\t</div>\n";
    print "\t<div class='itemtitle'>\n\t\t<a href='$itemurl?ASIN=$itemASIN'>$itemtitle</a>\n\t</div>\n";
}

for ($i = 1; ($i <= $totalpages) && ($i <= 10); $i++) {
    if ($i == $presentpage) {
	print "<div class='page'>$i</div>";
    } else {
	print "<div class='page'><a href='./amazon-html.pl?SearchIndex=$SearchIndex&Keywords=$Keywords&page=$i'>$i</a></div>";
    }
}
if ($totalpages > 10) {
    print "<div class='page'>.....</div>";
}

print "</div></form></body></html>";
0;

