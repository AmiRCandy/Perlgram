package Perlgram;
use strict;
use warnings;
use LWP::UserAgent;
use JSON qw(encode_json decode_json);
use Log::Log4perl qw(:easy);
use Perlgram::Error;

our $VERSION = '0.02';
our $AUTHORITY = 'cpan:AMIRCANDY'; # Replace with your CPAN ID

sub new {
    my ($class, %args) = @_;
    unless ($args{token}) {
        Perlgram::Error->new(message => "Token required")->throw;
    }
    my $self = {
        token      => $args{token},
        api_url    => $args{api_url} || 'https://api.telegram.org/bot',
        ua         => LWP::UserAgent->new(timeout => 30),
        logger     => Log::Log4perl->get_logger(__PACKAGE__),
        on_error   => $args{on_error}, # Optional error callback
    };
    bless $self, $class;
    $self->_init_logger unless Log::Log4perl::initialized();
    return $self;
}

sub _init_logger {
    Log::Log4perl->easy_init($Log::Log4perl::DEBUG);
}

sub api_request {
    my ($self, $method, $params, $multipart) = @_;
    my $url = $self->{api_url} . $self->{token} . "/$method";

    my $response;
    eval {
        if ($multipart) {
            $response = $self->{ua}->post($url, Content_Type => 'multipart/form-data', Content => $params);
        } elsif ($params && ref($params) eq 'HASH') {
            $response = $self->{ua}->post($url, Content => encode_json($params));
        } else {
            $response = $self->{ua}->get($url);
        }
    };
    if ($@) {
        $self->{logger}->error("Connection error: $@ (method: $method)");
        my $error = Perlgram::Error->new(
            message => "Connection error: $@",
            code    => 500,
        );
        if ($self->{on_error}) {
            $self->{on_error}->($error);
            return undef;
        }
        $error->throw;
    }

    unless ($response && ref($response) eq 'HTTP::Response') {
        $self->{logger}->error("Invalid response object (method: $method)");
        my $error = Perlgram::Error->new(
            message => "Invalid response from server",
            code    => 500,
        );
        if ($self->{on_error}) {
            $self->{on_error}->($error);
            return undef;
        }
        $error->throw;
    }

    if ($response->is_success) {
        my $data = eval { decode_json($response->decoded_content) };
        if ($@) {
            $self->{logger}->error("JSON decode error: $@ (method: $method)");
            my $error = Perlgram::Error->new(
                message => "JSON decode error: $@",
                code    => 500,
            );
            if ($self->{on_error}) {
                $self->{on_error}->($error);
                return undef;
            }
            $error->throw;
        }
        if ($data->{ok}) {
            return $data->{result};
        } else {
            $self->{logger}->error("API error: $data->{description} (code: $data->{error_code}, method: $method)");
            my $error = Perlgram::Error->new(
                message => "API error: $data->{description} (method: $method)",
                code    => $data->{error_code},
            );
            if ($self->{on_error}) {
                $self->{on_error}->($error);
                return undef;
            }
            $error->throw;
        }
    } else {
        my $error_detail = $response->decoded_content || ($response->status_line || "Unknown error");
        my $er = $response->decoded_content;
        $self->{logger}->error("HTTP error: $error_detail (method: $method) $er");
        my $error = Perlgram::Error->new(
            message => "HTTP error: $error_detail",
            code    => $response->code || 500,
        );
        if ($self->{on_error}) {
            $self->{on_error}->($error);
            return undef;
        }
        $error->throw;
    }
}
# General Methods
sub getMe { shift->api_request('getMe'); }
sub logOut { shift->api_request('logOut'); }
sub close { shift->api_request('close'); }

# Update Methods
sub getUpdates { shift->api_request('getUpdates', @_); }
sub setWebhook { shift->api_request('setWebhook', @_); }
sub deleteWebhook { shift->api_request('deleteWebhook', @_); }
sub getWebhookInfo { shift->api_request('getWebhookInfo'); }

# Message Methods
sub sendMessage { shift->api_request('sendMessage', @_); }
sub forwardMessage { shift->api_request('forwardMessage', @_); }
sub copyMessage { shift->api_request('copyMessage', @_); }
sub sendPhoto { shift->api_request('sendPhoto', @_, 1); }
sub sendAudio { shift->api_request('sendAudio', @_, 1); }
sub sendDocument { shift->api_request('sendDocument', @_, 1); }
sub sendVideo { shift->api_request('sendVideo', @_, 1); }
sub sendAnimation { shift->api_request('sendAnimation', @_, 1); }
sub sendVoice { shift->api_request('sendVoice', @_, 1); }
sub sendVideoNote { shift->api_request('sendVideoNote', @_, 1); }
sub sendMediaGroup { shift->api_request('sendMediaGroup', @_); }
sub sendLocation { shift->api_request('sendLocation', @_); }
sub editMessageLiveLocation { shift->api_request('editMessageLiveLocation', @_); }
sub stopMessageLiveLocation { shift->api_request('stopMessageLiveLocation', @_); }
sub sendVenue { shift->api_request('sendVenue', @_); }
sub sendContact { shift->api_request('sendContact', @_); }
sub sendPoll { shift->api_request('sendPoll', @_); }
sub sendDice { shift->api_request('sendDice', @_); }
sub sendChatAction { shift->api_request('sendChatAction', @_); }

# Inline Mode
sub answerInlineQuery { shift->api_request('answerInlineQuery', @_); }
sub answerWebAppQuery { shift->api_request('answerWebAppQuery', @_); }

# Message Editing
sub editMessageText { shift->api_request('editMessageText', @_); }
sub editMessageCaption { shift->api_request('editMessageCaption', @_); }
sub editMessageMedia { shift->api_request('editMessageMedia', @_, 1); }
sub editMessageReplyMarkup { shift->api_request('editMessageReplyMarkup', @_); }
sub stopPoll { shift->api_request('stopPoll', @_); }
sub deleteMessage { shift->api_request('deleteMessage', @_); }

# Chat Management
sub banChatMember { shift->api_request('banChatMember', @_); }
sub unbanChatMember { shift->api_request('unbanChatMember', @_); }
sub restrictChatMember { shift->api_request('restrictChatMember', @_); }
sub promoteChatMember { shift->api_request('promoteChatMember', @_); }
sub setChatAdministratorCustomTitle { shift->api_request('setChatAdministratorCustomTitle', @_); }
sub banChatSenderChat { shift->api_request('banChatSenderChat', @_); }
sub unbanChatSenderChat { shift->api_request('unbanChatSenderChat', @_); }
sub setChatPermissions { shift->api_request('setChatPermissions', @_); }
sub exportChatInviteLink { shift->api_request('exportChatInviteLink', @_); }
sub createChatInviteLink { shift->api_request('createChatInviteLink', @_); }
sub editChatInviteLink { shift->api_request('editChatInviteLink', @_); }
sub revokeChatInviteLink { shift->api_request('revokeChatInviteLink', @_); }
sub approveChatJoinRequest { shift->api_request('approveChatJoinRequest', @_); }
sub declineChatJoinRequest { shift->api_request('declineChatJoinRequest', @_); }
sub setChatPhoto { shift->api_request('setChatPhoto', @_, 1); }
sub deleteChatPhoto { shift->api_request('deleteChatPhoto', @_); }
sub setChatTitle { shift->api_request('setChatTitle', @_); }
sub setChatDescription { shift->api_request('setChatDescription', @_); }
sub pinChatMessage { shift->api_request('pinChatMessage', @_); }
sub unpinChatMessage { shift->api_request('unpinChatMessage', @_); }
sub unpinAllChatMessages { shift->api_request('unpinAllChatMessages', @_); }
sub leaveChat { shift->api_request('leaveChat', @_); }
sub getChat { shift->api_request('getChat', @_); }
sub getChatAdministrators { shift->api_request('getChatAdministrators', @_); }
sub getChatMemberCount { shift->api_request('getChatMemberCount', @_); }
sub getChatMember { shift->api_request('getChatMember', @_); }
sub setChatStickerSet { shift->api_request('setChatStickerSet', @_); }
sub deleteChatStickerSet { shift->api_request('deleteChatStickerSet', @_); }

# Callback Queries
sub answerCallbackQuery { shift->api_request('answerCallbackQuery', @_); }

# Payments
sub sendInvoice { shift->api_request('sendInvoice', @_); }
sub createInvoiceLink { shift->api_request('createInvoiceLink', @_); }
sub answerShippingQuery { shift->api_request('answerShippingQuery', @_); }
sub answerPreCheckoutQuery { shift->api_request('answerPreCheckoutQuery', @_); }

# Stickers
sub sendSticker { shift->api_request('sendSticker', @_, 1); }
sub getStickerSet { shift->api_request('getStickerSet', @_); }
sub uploadStickerFile { shift->api_request('uploadStickerFile', @_, 1); }
sub createNewStickerSet { shift->api_request('createNewStickerSet', @_, 1); }
sub addStickerToSet { shift->api_request('addStickerToSet', @_, 1); }
sub setStickerPositionInSet { shift->api_request('setStickerPositionInSet', @_); }
sub deleteStickerFromSet { shift->api_request('deleteStickerFromSet', @_); }
sub setStickerSetThumb { shift->api_request('setStickerSetThumb', @_, 1); }

# Games
sub sendGame { shift->api_request('sendGame', @_); }
sub setGameScore { shift->api_request('setGameScore', @_); }
sub getGameHighScores { shift->api_request('getGameHighScores', @_); }

# Bot Commands
sub setMyCommands { shift->api_request('setMyCommands', @_); }
sub deleteMyCommands { shift->api_request('deleteMyCommands', @_); }
sub getMyCommands { shift->api_request('getMyCommands', @_); }
sub setChatMenuButton { shift->api_request('setChatMenuButton', @_); }
sub getChatMenuButton { shift->api_request('getChatMenuButton', @_); }
sub setMyDefaultAdministratorRights { shift->api_request('setMyDefaultAdministratorRights', @_); }
sub getMyDefaultAdministratorRights { shift->api_request('getMyDefaultAdministratorRights', @_); }

1;
__END__


=head1 NAME

Perlgram - Comprehensive Perl interface to the Telegram Bot API

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

    use Perlgram;
    my $bot = Perlgram->new(token => 'YOUR_BOT_TOKEN');
    my $user = $bot->getMe();
    print "Bot username: $user->{username}\n";

    # Send a message with a reply keyboard
    $bot->sendMessage(
        chat_id => 123456789,
        text    => 'Choose an option',
        reply_markup => {
            keyboard => [[{ text => 'Option 1' }], [{ text => 'Option 2' }]],
            one_time_keyboard => JSON::true,
        },
    );

=head1 DESCRIPTION

C<Perlgram> is a Perl module for interacting with the Telegram Bot API. It supports all major API methods, including messaging, inline queries, payments, stickers, and games. The module can operate in webhook (real-time updates via HTTPS) or CLI (polling via C<getUpdates>) modes, making it suitable for both production and development environments.

This module is designed to be CPAN-compliant and can be installed via C<cpan> or C<cpanm>. It includes scripts for running bots and examples for quick setup.

=head1 METHODS

See the Telegram Bot API documentation (L<https://core.telegram.org/bots/api>) for parameter details.

=over

=item new(token => $token, [api_url => $url])

Creates a new bot instance. Requires a bot token from @BotFather.

=item getMe, logOut, close

General bot methods.

=item getUpdates, setWebhook, deleteWebhook, getWebhookInfo

Update-related methods.

=item sendMessage, sendPhoto, sendAudio, sendDocument, sendVideo, sendAnimation, sendVoice, sendVideoNote, sendMediaGroup, sendLocation, sendVenue, sendContact, sendPoll, sendDice, sendChatAction

Messaging methods.

=item answerInlineQuery, answerWebAppQuery

Inline mode methods.

=item editMessageText, editMessageCaption, editMessageMedia, editMessageReplyMarkup, stopPoll, deleteMessage

Message editing methods.

=item banChatMember, unbanChatMember, restrictChatMember, promoteChatMember, setChatPermissions, exportChatInviteLink, getChat, getChatAdministrators

Chat management methods.

=item answerCallbackQuery

Callback query handling.

=item sendInvoice, answerShippingQuery, answerPreCheckoutQuery

Payment methods.

=item sendSticker, getStickerSet, createNewStickerSet

Sticker methods.

=item sendGame, setGameScore, getGameHighScores

Game methods.

=item setMyCommands, getMyCommands

Bot command methods.

=back

=head1 DEPENDENCIES

=over

=item * LWP::UserAgent

=item * JSON

=item * Mojolicious (for webhook mode)

=item * Log::Log4perl

=back

=head1 INSTALLATION

To install via CPAN:

    cpan Perlgram

Or, clone from GitHub and build manually:

    git clone https://github.com/AmiRCandy/Perlgram.git
    cd Perlgram
    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHOR

AmiRCandy, E<lt>amirhosen.1385.cmo@gmail.comE<gt>

=head1 BUGS

Please report bugs to the GitHub issue tracker: L<https://github.com/AmiRCandy/Perlgram/issues>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 SEE ALSO

L<https://core.telegram.org/bots/api>, L<Perlgram::Webhook>, L<Perlgram::CLI>