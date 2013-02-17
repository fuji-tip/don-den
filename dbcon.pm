
#!/usr/bin/perl

use lib '/home/fuji-tip/local/lib/perl5';
use lib '/Users/fuji/perl5/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2/';
use encoding 'utf-8';

use Config::Simple;
use DBI;

sub connect {
    my $db = new Config::Simple('./dbconfig.cfg');
    
    my $dbname = $db->param('dbname');
    my $server = $db->param('server');
    my $port = $db->param('port');
    my $user = $db->param('user');
    my $pass = $db->param('pass');
    
    my $dbh = DBI->connect("DBI:mysql:$dbname:$server:$port", "$user@$server", $pass)
	or die $DBI::errstr;
    return $dbh;
}


sub add_record {
    my ($userid, $asin, $commet, $likes) = @_;

    
}

sub extract_record {
    my ($asin, $userid) = @_;
    my $query;

    if ($userid) {
	$query = "select * from amazon_item where asin = '$asin' order by date asc;";
    } else {
	$query = "select * from amazon_item where asin = '$asin' and　userid = '$userid' order by date asc;";
    }

    my $dbh = &connect;

    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    my $result = $sth->fetchrow;

    $sth->finish();
    $dbh->disconnect();
    
    return $result;
}
1;
