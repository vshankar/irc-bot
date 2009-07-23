package Bot;

use strict;
use Net::IRC;
use Log::Log4perl qw(get_logger);
use Data::Dumper::Simple;

use constant    SERVER  => 'irc.freenode.net';
use constant    NICK    => 'kaboom';
use constant    PORT    => 6667;
use constant    CHANNEL => 'irctestchannel';

use constant    CHANNELHASH     => "#";

my @quips = (
                [ "An idiot with a computer is a faster, better idiot. -- Rich Julius"  ],
                [ "The difference between insanity and genius is measured by success"   ],
                [ "If at first you don't succeed, you must be a programmer."            ],
                [ "Pang is the past tense of ping"                                      ],
                [ "be() || !be() ? true : false"                                        ]
            );


########### Private Fcuntion(s) ####################

# this functions checks weather the message
# is _really_ for us.
sub __is_message_for_me {
    my ($self, $msg) = @_;

    if ($$msg =~ /^$self->{nick}.*/) {
        return 2;
    } else {
        if ($$msg =~ /$self->{nick}/) {
            return 1;
        }
    }
    return 0;
}

sub __select_random_quip {
    my $rval = int(rand(scalar(@quips)));
    return $quips[$rval];
}

####################################################

sub new {
    my ($this, $option) = @_;
    my $class = ref($this) || $this;
    my $logger = get_logger("Bot");

    my $self = {
        nick    => $option->{nick}      || NICK,
        server  => $option->{server}    || SERVER,
        port    => $option->{port}      || PORT,
        channel => $option->{channel}   || CHANNEL
    };

    if ($self->{port} != PORT) {
        $logger->info($self->{port} . " is not the default port " . 
                        "for an IRC server. Make sure you have not " .
                        "mistyped anything");

    }

    bless($self);
    return $self;
}

sub bot_connect {
    my $self = shift;
    my $logger = get_logger("Bot");

    $self->{irc} = new Net::IRC;

    $self->{connection} = 
                $self->{irc}->newconn(
                        Nick    => $self->{nick},
                        Server  => $self->{server},
                        Port    => $self->{port},
                        );

    $logger->warn("Connected to " . $self->{server});
}

sub bot_send_private_msg {
    my ($self, $conn, $msg) = @_;
    my $logger = get_logger("Bot");

    $logger->info("Sending message to channel: " . $msg);
    $conn->privmsg(CHANNELHASH . $self->{channel},
                                 $msg);
}

sub bot_send_private_msg_2_nick {
    my ($self, $conn, $nick, $msg) = @_;
    my $logger = get_logger("Bot");

    $logger->info("Sending private msg to " . $nick .
                    "msg: " . $msg);

    $conn->privmsg($nick, $msg);
}

sub bot_join_channel {
    my ($self, $conn) = @_;
    my $logger = get_logger("Bot");

    $logger->warn("Joining Channel #" . $self->{channel});
    $conn->join(CHANNELHASH . $self->{channel});
    $logger->warn("Joined " . $self->{channel});
    $self->bot_send_private_msg($conn, "Hello Folks");
}

sub bot_process_message {
    my ($self, $conn, $event) = @_;
    my $logger = get_logger("Bot");

    my $from_nick = $event->{nick};
    my $from_real = $event->{user};
    my $msg = $event->{args}[0];

    my $retval = $self->__is_message_for_me(\$msg);

    if ($retval == 2) {
        my $rquip = __select_random_quip();
        $self->bot_send_private_msg($conn, $from_nick . ": " . $rquip->[0]);
    } else {
        if ($retval == 1) {
            $self->bot_send_private_msg($conn, "Hmm, for me ?");
        }
    }
}

sub bot_cdcc {
    my ($self, $conn, $event) = @_;
    my $logger = get_logger("Bot");

    my @dcc = split(/ /, $event->{args}[0]);

    $logger->info("Recieved DCC " . uc($dcc[1]) . " from " .
                    $event->{nick});

    if (uc($dcc[1]) eq 'CHAT') {
        $conn->new_chat(0, $event->{nick}, $dcc[-2],
                                           $dcc[-1]);
        warn Dumper($event);
    }
}

# need to reply the peer with a
# crafty message. :-)
sub bot_private_msg {
    my ($self, $conn, $event) = @_;

    $self->bot_send_private_msg_2_nick($conn,
                                       $event->{nick},
                                       $event->{args}[0]
                                    );     
}

sub bot_handlers {
    my $self = shift;
    my $logger = get_logger("Bot");

    $logger->info("Got /MOTD from IRC Server " . $self->{server});

    $self->{connection}->add_handler('376',
                            sub {
                                my ($conn, $event) = @_;
                                $self->bot_join_channel($conn, $event);
                            }
                        );

    $self->{connection}->add_handler('public',
                            sub {
                                $self->bot_process_message(@_);
                            }
                        );
    
    $self->{connection}->add_handler('cdcc',
                            sub {
                                $self->bot_cdcc(@_);
                            }
                        );

    $self->{connection}->add_handler('chat',
                            sub {
                                $self->bot_private_msg(@_);
                            }
                        );

    $logger->warn("Listening for messages from IRC server " .
                                $self->{server});

    $self->{irc}->start;
}

sub bot_print {
    my $self = shift;
    my $logger = get_logger("Bot");
    my $logString;


    $logString  =  "Conencting to => ";
    $logString .= "\n\tServer: " . $self->{server} . "\n\tPort: ".
                            $self->{port} . "\n\tNick: " .
                            $self->{nick} . "\n\tChannel: #" .
                            $self->{channel} . "\n";
    $logger->info($logString);
}


1;



