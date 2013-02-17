#!/usr/bin/perl

use encoding "utf-8";

use lib '/home/fuji-tip/local/lib/perl5';
use lib '/Users/fuji/perl5/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2/';

use Digest::SHA qw(hmac_sha256_base64);
use DateTime;
use URI::Escape;
use LWP::Simple;
use XML::Simple;

use constant ACCESS_KEY_ID => 'AKIAJVAXSZPIP25QILNA';
use constant SECRET_ACCESS_KEY => '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';

sub amazon_xml {
    my ($config) = @_;

    my $use_config = join '&', map { $_ . '=' . $config->{$_} } sort keys %{$config};
    my $signature = "GET\nwebservices.amazon.co.jp\n/onca/xml\n$use_config";
    my $hashed_signature = hmac_sha256_base64($signature, SECRET_ACCESS_KEY);
    
    while (length($hashed_signature) % 4) {
	$hashed_signature .= '=';
    }
    my $response = get ('http://webservices.amazon.co.jp/onca/xml?' . $use_config . '&Signature=' . uri_escape($hashed_signature));
    
    my $xml = XML::Simple->new;
    my $xml_data = $xml->XMLin($response);

    return $xml_data;
}

sub amazon_simple_search {
    my ($SearchIndex, $Keywords, $presentpage) =  @_;

    my $dt = DateTime->now;
    my $config = {
	Service  => 'AWSECommerceService',
	AWSAccessKeyId => ACCESS_KEY_ID,
	AssociateTag => "don-den-22",
	SearchIndex  => uri_escape($SearchIndex),
	Operation  => 'ItemSearch',
	ItemPage => $presentpage,
	Keywords => uri_escape($Keywords),
	ResponseGroup => uri_escape('ItemAttributes,Images'),
	Version  => '2009-01-06',
	Timestamp => uri_escape("$dt") . 'Z',
    };

    my $xml_data = &amazon_xml($config);
    
    return $xml_data;
}

sub amazon_asin_select {
    my ($SearchIndex, $itemASIN) = @_;

    my $dt = DateTime->now;
    my $config = {
	Service  => 'AWSECommerceService',
	AWSAccessKeyId => ACCESS_KEY_ID,
	AssociateTag => "don-den-22",
	#SearchIndex  => uri_escape($SearchIndex),
	Operation  => 'ItemLookup',
	ItemId => $itemASIN,
	ResponseGroup => uri_escape('ItemAttributes,Images'),
	Version  => '2009-01-06',
	Timestamp => uri_escape("$dt") . 'Z',
    };

    my $xml_data = &amazon_xml($config);

    return $xml_data;
}
1;
