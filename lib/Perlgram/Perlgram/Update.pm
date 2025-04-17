package Perlgram::Update;
use strict;
use warnings;
use Carp qw(croak);
use JSON qw(encode_json);
use Perlgram::Types;

sub new {
    my ($class, %args) = @_;
    my $self = {
        bot      => $args{bot} || croak("Bot instance required"),
        update   => $args{update} || croak("Update data required"),
        handlers => $args{handlers} || {}, # User-defined handlers
    };
    bless $self, $class;
    return $self;
}

sub register_handler {
    my ($self, $type, $callback) = @_;
    croak "Handler type required" unless $type;
    croak "Callback must be a CODE reference" unless ref($callback) eq 'CODE';
    $self->{handlers}{$type} = $callback;
}

sub process {
    my ($self) = @_;
    my $update = $self->{update};

    # Map update types to handler keys
    my %update_types = (
        message               => 'message',
        edited_message        => 'edited_message',
        channel_post          => 'channel_post',
        edited_channel_post   => 'edited_channel_post',
        inline_query          => 'inline_query',
        chosen_inline_result  => 'chosen_inline_result',
        callback_query        => 'callback_query',
        shipping_query        => 'shipping_query',
        pre_checkout_query    => 'pre_checkout_query',
        poll                  => 'poll',
        poll_answer           => 'poll_answer',
        my_chat_member        => 'my_chat_member',
        chat_member           => 'chat_member',
        chat_join_request     => 'chat_join_request',
    );

    # Process the first matching update type
    for my $type (keys %update_types) {
        if (my $data = $update->{$type}) {
            my $handler = $self->{handlers}{$update_types{$type}} || $self->can("_handle_$type") || sub { };
            $handler->($self, $data);
            last;
        }
    }
}

# Default handlers (optional, can be overridden by users)
sub _handle_message {
    my ($self, $message) = @_;
    # Default: Do nothing, let users define behavior
}

sub _handle_edited_message {
    my ($self, $message) = @_;
}

sub _handle_channel_post {
    my ($self, $post) = @_;
}

sub _handle_edited_channel_post {
    my ($self, $post) = @_;
}

sub _handle_inline_query {
    my ($self, $inline_query) = @_;
    my $query_id = $inline_query->{id};
    my $query = $inline_query->{query} || '';

    # Default: Return simple inline results
    my $results = [
        {
            type => 'article',
            id => '1',
            title => 'Result 1',
            input_message_content => { message_text => "You searched: $query" },
        },
    ];

    $self->{bot}->answerInlineQuery(
        inline_query_id => $query_id,
        results => encode_json($results),
    );
}

sub _handle_chosen_inline_result {
    my ($self, $result) = @_;
}

sub _handle_callback_query {
    my ($self, $callback_query) = @_;
    my $query_id = $callback_query->{id};
    $self->{bot}->answerCallbackQuery(callback_query_id => $query_id);
}

sub _handle_shipping_query {
    my ($self, $shipping_query) = @_;
    my $query_id = $shipping_query->{id};
    $self->{bot}->answerShippingQuery(
        shipping_query_id => $query_id,
        ok => JSON::true,
        shipping_options => [
            { id => '1', title => 'Standard', prices => [{ label => 'Cost', amount => 500 }] },
        ],
    );
}

sub _handle_pre_checkout_query {
    my ($self, $pre_checkout_query) = @_;
    my $query_id = $pre_checkout_query->{id};
    $self->{bot}->answerPreCheckoutQuery(
        pre_checkout_query_id => $query_id,
        ok => JSON::true,
    );
}

sub _handle_poll {
    my ($self, $poll) = @_;
}

sub _handle_poll_answer {
    my ($self, $poll_answer) = @_;
}

sub _handle_my_chat_member {
    my ($self, $my_chat_member) = @_;
}

sub _handle_chat_member {
    my ($self, $chat_member) = @_;
}

sub _handle_chat_join_request {
    my ($self, $chat_join_request) = @_;
    my $chat_id = $chat_join_request->{chat}{id};
    my $user_id = $chat_join_request->{from}{id};
    $self->{bot}->approveChatJoinRequest(
        chat_id => $chat_id,
        user_id => $user_id,
    );
}

1;
__END__

=head1 NAME

Perlgram::Update - Process Telegram updates with custom handlers

=head1 SYNOPSIS

    use Perlgram;
    use Perlgram::Update;

    my $bot = Perlgram->new(token => 'YOUR_BOT_TOKEN');
    my $update_handler = Perlgram::Update->new(
        bot => $bot,
        update => $update_data,
        handlers => {
            message => sub {
                my ($self, $message) = @_;
                my $chat_id = $message->{chat}{id};
                my $text = $message->{text} || '';
                $self->{bot}->sendMessage(
                    chat_id => $chat_id,
                    text => "Received: $text",
                );
            },
            callback_query => sub {
                my ($self, $callback_query) = @_;
                my $query_id = $callback_query->{id};
                $self->{bot}->answerCallbackQuery(
                    callback_query_id => $query_id,
                    text => 'Button clicked!',
                );
            },
        },
    );
    $update_handler->process();

    # Alternatively, register handlers later
    $update_handler->register_handler('inline_query', sub {
        my ($self, $inline_query) = @_;
        my $query_id = $inline_query->{id};
        $self->{bot}->answerInlineQuery(
            inline_query_id => $query_id,
            results => encode_json([{ type => 'article', id => '1', title => 'Custom', input_message_content => { message_text => 'Custom result' } }]),
        );
    });

=head1 DESCRIPTION

C<Perlgram::Update> processes Telegram update types, such as messages, inline queries, callback queries, and more. Users can define custom handlers for each update type via the constructor or C<register_handler>. Default handlers are provided for some update types but can be overridden.

=head1 METHODS

=over

=item new(bot => $bot, update => $update_data, [handlers => \%handlers])

Creates a new update processor. The C<handlers> hash maps update types to callback functions.

=item register_handler($type, $callback)

Registers a callback function for a specific update type. The callback receives the update object and the update data.

=item process()

Processes the update by calling the appropriate handler based on the update type.

=back

=head1 UPDATE TYPES

Supported update types include:

- message
- edited_message
- channel_post
- edited_channel_post
- inline_query
- chosen_inline_result
- callback_query
- shipping_query
- pre_checkout_query
- poll
- poll_answer
- my_chat_member
- chat_member
- chat_join_request

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 LICENSE

Artistic License 2.0