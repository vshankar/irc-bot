package Bot;

use strict;
use Net::IRC;
use Data::Dumper::Simple;

use constant    SERVER  => 'irc.freenode.net';
use constant    NICK    => 'kaboom';
use constant    PORT    => 8001;
use constant    CHANNEL => '#irctestchannel';

sub new {
    my $this = shift; 
    my $class = ref($this) || $this;

    my $self = {
        nick    => $_[0] || NICK,
        server  => $_[1] || SERVER,
        port    => $_[2] || PORT,
        channel => $_[3] || CHANNEL
    };

    bless($self);
    return $self;
}

sub bot_connect {
    my $self = shift;

    $self->{irc} = new Net::IRC;

    $self->{connection} = 
                $self->{irc}->newconn(
                        Nick    => $self->{nick},
                        Server  => $self->{server},
                        Port    => $self->{port},
                        );
}

sub bot_send_private_msg {
    my ($self, $conn) = @_;

    $conn->privmsg($self->{channel},
                        "Hello Boys");
}

sub bot_join_channel{
    my ($self, $conn) = @_;

    $conn->join($self->{channel});
    $self->bot_send_private_msg($conn);
}

sub bot_handlers {
    my $self = shift;

    $self->{connection}->add_handler('376',
                            sub {
                                my ($conn, $event) = @_;
                                $self->bot_join_channel($conn);
                            }
                        );

    $self->{irc}->start;
}

sub bot_print {
    my $self = shift;
    print "Conencting to => ";
    print "\n\tServer: " . $self->{server} . "\n\tPort: ".
                            $self->{port} . "\n\tNick: " .
                            $self->{nick} . "\n";
}


1;



