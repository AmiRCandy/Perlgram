package Telegram::BotAPI::Update;
use strict;
use warnings;
use Carp qw(croak);
use JSON qw(encode_json);
use Telegram::BotAPI::Types;

sub new {
    my ($class, %args) = @_;
    my $self = {
        bot    => $args{bot} || croak("Bot instance required"),
        update => $args{update} || croak("Update data required"),
    };
    bless $self, $class;
    return $self;
}

sub process {
    my ($self) = @_;
    my $update = $self->{update};

    if (my $message = $update->{message}) {
        $self->_handle_message($message);
    } elsif (my $edited_message = $update->{edited_message}) {
        $self->_handle_edited_message($edited_message);
    } elsif (my $channel_post = $update->{channel_post}) {
        $self->_handle_channel_post($channel_post);
    } elsif (my $edited_channel_post = $update->{edited_channel_post}) {
        $self->_handle_edited_channel_post($edited_channel_post);
    } elsif (my $inline_query = $update->{inline_query}) {
        $self->_handle_inline_query($inline_query);
    } elsif (my $chosen_inline_result = $update->{chosen_inline_result}) {
        $self->_handle_chosen_inline_result($chosen_inline_result);
    } elsif (my $callback_query = $update->{callback_query}) {
        $self->_handle_callback_query($callback_query);
    } elsif (my $shipping_query = $update->{shipping_query}) {
        $self->_handle_shipping_query($shipping_query);
    } elsif (my $pre_checkout_query = $update->{pre_checkout_query}) {
        $self->_handle_pre_checkout_query($pre_checkout_query);
    } elsif (my $poll = $update->{poll}) {
        $self->_handle_poll($poll);
    } elsif (my $poll_answer = $update->{poll_answer}) {
        $self->_handle_poll_answer($poll_answer);
    } elsif (my $my_chat_member = $update->{my_chat_member}) {
        $self->_handle_my_chat_member($my_chat_member);
    } elsif (my $chat_member = $update->{chat_member}) {
        $self->_handle_chat_member($chat_member);
    } elsif (my $chat_join_request = $update->{chat_join_request}) {
        $self->_handle_chat_join_request($chat_join_request);
    }
}

sub _handle_message {
    my ($self, $message) = @_;
    my $chat_id = $message->{chat}{id};
    my $text = $message->{text} || '';

    if ($text =~ /^\/start/) {
        $self->{bot}->sendMessage(
            chat_id => $chat_id,
            text    => 'Welcome! Try /help for commands.',
            reply_markup => {
                inline_keyboard => [[
                    { text => 'Help', callback_data => 'help' },
                    { text => 'About', callback_data => 'about' },
                ]],
            },
        );
    } elsif ($text =~ /^\/help/) {
        $self->{bot}->sendMessage(
            chat_id => $chat_id,
            text    => 'Available commands: /start, /help, /photo',
        );
    } elsif ($text =~ /^\/photo/) {
        $self->{bot}->sendPhoto(
            chat_id => $chat_id,
            photo   => 'https://example.com/sample.jpg',
            caption => 'Sample photo',
        );
    } elsif ($text) {
        $self->{bot}->sendMessage(
            chat_id => $chat_id,
            text    => "You said: $text",
        );
    }
}

sub _handle_edited_message {
    my ($self, $message) = @_;
    my $chat_id = $message->{chat}{id};
    $self->{bot}->sendMessage(
        chat_id => $chat_id,
        text    => 'You edited a message!',
    );
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

    my $results = [
        {
            type => 'article',
            id => '1',
            title => 'Result 1',
            input_message_content => { message_text => "You searched: $query" },
        },
        {
            type => 'article',
            id => '2',
            title => 'Result 2',
            input_message_content => { message_text => "Another result for: $query" },
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
    my $data = $callback_query->{data} || '';
    my $chat_id = $callback_query->{message}{chat}{id};

    if ($data eq 'help') {
        $self->{bot}->editMessageText(
            chat_id => $chat_id,
            message_id => $callback_query->{message}{message_id},
            text => 'Help menu: Try /start or /photo',
        );
    } elsif ($data eq 'about') {
        $self->{bot}->editMessageText(
            chat_id => $chat_id,
            message_id => $callback_query->{message}{message_id},
            text => 'This is a Perl Telegram bot!',
        );
    }

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
    my $chat_id = $my_chat_member->{chat}{id};
    $self->{bot}->sendMessage(
        chat_id => $chat_id,
        text    => 'My status in this chat changed!',
    );
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

Telegram::BotAPI::Update - Process all Telegram update types

=head1 SYNOPSIS

    use Telegram::BotAPI::Update;
    my $update_handler = Telegram::BotAPI::Update->new(
        bot    => $bot,
        update => $update_data
    );
    $update_handler->process();

=head1 DESCRIPTION

Handles all Telegram update types, including messages, inline queries, callback queries, polls, and more. Provides example responses for common scenarios.

=head1 AUTHOR

Your Name, E<lt>your.email@example.comE<gt>

=head1 LICENSE

Artistic License 2.0