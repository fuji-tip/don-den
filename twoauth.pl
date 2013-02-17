#!/usr/bin/perl

use lib '/home/fuji-tip/local/lib/perl5';

use strict;
use warnings;
use utf8;
 
use CGI;
use OAuth::Lite::Consumer;
use LWP::UserAgent;
use JSON;
use Config::Simple;
use CGI::Carp qw(fatalsToBrowser);
 

my $q = new Config::Simple('./twconf.cfg');
my $ConsumerKey = $q->param('consumer_key');
my $ConsumerSecret = $q->param('consumer_secret');
my $callback_url = 'http://fuji-tip.sakura.ne.jp/amazon-html.pl';
 
my $consumer = OAuth::Lite::Consumer->new(
    consumer_key    => $ConsumerKey,
    consumer_secret => $ConsumerSecret,
    site => "http://twitter.com/",
    request_token_path => "https://api.twitter.com/oauth/request_token",
    access_token_path => "https://api.twitter.com/oauth/access_token",
    authorize_path => "https://api.twitter.com/oauth/authorize",
    callback_url => $callback_url,
);
 
my $query = CGI->new;
 
if ($query->param('oauth_token') && $query->param('oauth_verifier')) {
    my $access_token = $consumer->get_access_token(
        token => $query->param('oauth_token'),
        verifier => $query->param('oauth_verifier'),
    );
 
    my $req = $consumer->gen_oauth_request(
        method => 'GET',
        url => 'http://api.twitter.com/1/account/verify_credentials.json',
        token => $access_token,
    );
 
    my $ua = new LWP::UserAgent();
    my $res = $ua->request($req);
 
    die $res->status_line if ! $res->is_success;
 
    my $account = decode_json($res->content);
 
    print "Content-type: text/html;charset=UTF-8\n\n";
    print "<img src='$account->{profile_image_url}' />";
    print "<p>ID : $account->{id}</p>";
    print "<p>name : $account->{name}</p>";
    print "<p>screen_name : $account->{screen_name}</p>";
    print "<p>description : $account->{description}</p>";
    exit;
}
else {
    my $request_token = $consumer->get_request_token();
 
    my $uri = $consumer->url_to_authorize(
        token => $request_token,
    );
 
    print $query->redirect($uri);
}
exit;
