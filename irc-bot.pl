#!/usr/bin/perl -w

use Bot::IRC;

my $irc = Bot->new();

$irc->bot_print();
$irc->bot_connect();
$irc->bot_handlers();



