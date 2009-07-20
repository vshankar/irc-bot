#!/usr/bin/perl -w

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Bot::IRC',
    VERSION         => '1.0',
    EXE_FILES       => [ 'bin/irc-bot.pl' ],
    PREREQ_PM       => {
                            'Net::IRC'          =>      0,
                            'Log::Log4perl'     =>      0,
                            'Getopt::Long'      =>      0
                    },
    INSTALLSCRIPT   => "/usr/bin",
);

