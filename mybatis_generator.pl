#!/usr/bin/env perl

use latest;
use strictures 2;
use utf8;
use DBI;
use Data::Printer;
use Template;
use Kavorka;
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile);
use POSIX qw(strftime);
use AppConfig;

use FindBin;
use lib "$FindBin::Bin/lib";
use YTable;

binmode STDERR, ":utf8";
binmode STDOUT, ":utf8";

my $config = AppConfig->new(
    'output_dir|o=s'  => { DEFAULT => 'outputJava' },
    'config_file|f=s' => { DEFAULT => 'config.ini' },
    'dsn|d=s',
    'package|p=s',
    'user|u=s'        => { DEFAULT => 'root' },
    'author|a=s'      => { DEFAULT => '' },
    'passwd|pw=s'     => { DEFAULT => '' },
);
$config->args();
$config->file($config->config_file) if $config->config_file;

my $outfile_dir = $config->output_dir;
my $mapper_tmpl = 'mapper.tt';
my $entity_tmpl = 'entity.tt';
my $dsn         = $config->dsn;
my $user        = $config->user;
my $passwd      = $config->passwd;
my $author      = $config->author;
my $package     = $config->package;

make_path $outfile_dir unless -e -d $outfile_dir;

my $tt = Template->new({
         ENCODING    => 'utf-8',
         INTERPOLATE => 1,
    });

my $dbh = DBI->connect($dsn, $user, $passwd,
    {
        'RaiseError' => 1,
        'mysql_enable_utf8' => 1,
    });

fun gen_outfile_name($tbl) {
    catfile $outfile_dir, $tbl->java_entity_name . 'Mapper.java';
}

my @tables = $dbh->tables;
for (@tables) {
    s/.*\.`(.*)`/$1/;
    my $sth     = $dbh->column_info(undef, 'yl_webim', $_, undef);
    my $columns = $sth->fetchall_hashref(['TABLE_NAME', 'COLUMN_NAME']);
    # p $columns;
    while (my ($k, $v) = each %$columns) {
        my $tbl          = YTable->new($k, $v);
        my $vars         = $tbl->gen_tt_vars;
        $vars->{author}  = $author;
        $vars->{day}     = strftime "%y/%m/%d", localtime;
        $vars->{package} = $package;
        my $outfile      = gen_outfile_name($tbl);
        $tt->process($mapper_tmpl, $vars, $outfile) or die $tt->error();
    }
}

$dbh->disconnect();
