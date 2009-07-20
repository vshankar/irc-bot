#!/usr/bin/perl -w

use Bot::IRC;
use Switch;
use Getopt::Long;
use Log::Log4perl qw(get_logger :levels);

my %botOptions;
GetOptions(\%botOptions, "server:s",
                         "port:i",
                         "nick:s",
                         "channel:s",
                         "verbose:i"
                        );

########################## Initialize the logger. ############################
my $logger = get_logger("Bot");

if (defined $botOptions{'verbose'}) {
    switch($botOptions{'verbose'}) {
        case 1      { $logger->level($WARN);  }
        case 2      { $logger->level($INFO);  }
        case 3      { $logger->level($DEBUG); }
        else        { $logger->level($WARN);  }
    }
} else {
    $logger->level($WARN);
}

my $appender = Log::Log4perl::Appender->new(
    "Log::Dispatch::File",
    filename => "/tmp/ircbot.log",
    mode     => "append",
);

$logger->add_appender($appender);

my $layout = 
    Log::Log4perl::Layout::PatternLayout->new(
                "%d %p> %F{1}: %m%n");

$appender->layout($layout);

##############################################################################

######################## create the bot instance. ############################
my $irc = Bot->new(\%botOptions);

$irc->bot_print();
$irc->bot_connect();
$irc->bot_handlers();

##############################################################################



