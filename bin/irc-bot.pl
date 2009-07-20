#!/usr/bin/perl -w

use Bot::IRC;
use Getopt::Long;
use Log::Log4perl qw(get_logger :levels);

my %botOptions;
GetOptions(\%botOptions, "server=s",
                         "port=i",
                         "nick=s",
                         "channel=s",
                        );

my $bot_logger = get_logger("Bot");
my $irc = Bot->new(\%botOptions);

$irc->bot_print();
$irc->bot_connect();
$irc->bot_handlers();



