package Perlgram::Bot::keyboard;

use JSON::MaybeXS;
use Data::Dumper;

sub _remove_undef_keys_recursive {
    my ($data) = @_;

    if (ref $data eq 'HASH') {
        my %filtered_data;

        for my $key (keys %$data) {
            my $value = _remove_undef_keys_recursive($data->{$key});
            $filtered_data{$key} = $value if defined $value;
        }

        return \%filtered_data;
    }
    elsif (ref $data eq 'ARRAY') {
        my @filtered_data = map { _remove_undef_keys_recursive($_) } @$data;
        return \@filtered_data;
    }
    else {
        return $data;
    }
}
sub ReplyKeyboardMarkup {
    my ($self,$keyboard,$resize_keyboard, $is_persistent, $one_time_keyboard, $input_field_placeholder, $selective) = @_;
    $is_persistent //= undef;
    $resize_keyboard //= undef;
    $one_time_keyboard //= undef;
    $input_field_placeholder //= undef;
    $selective //= undef;
    return encode_json(_remove_undef_keys_recursive({
        keyboard                => $keyboard,
        resize_keyboard         => $resize_keyboard,
        one_time_keyboard       => $one_time_keyboard,
        input_field_placeholder => $input_field_placeholder,
        selective               => $selective
    }));
}

sub InlineKeyboardMarkup {
    my ($inline_keyboard) = @_;
    return {
        inline_keyboard => $inline_keyboard
    };
}

sub InlineKeyboardButton {
    my ($text, $url, $callback_data, $switch_inline_query, $switch_inline_query_current_chat , $pay , $callback_game , $switch_inline_query_chosen_chat , $web_app , $login_url)  = @_;
    $url //= undef;
    $callback_data //=undef;
    $switch_inline_query //= undef;
    $switch_inline_query_current_chat //= undef;
    $pay //= undef;
    $callback_game //= undef;
    $switch_inline_query_chosen_chat //= undef;
    $web_app //= undef;
    $login_url //= undef;

    return {
        text                             => $text,
        url                              => $url,
        callback_data                    => $callback_data,
        switch_inline_query              => $switch_inline_query,
        switch_inline_query_current_chat => $switch_inline_query_current_chat,
        pay => $pay ,
        callback_game => $callback_game ,
        switch_inline_query_chosen_chat => $switch_inline_query_chosen_chat ,
        web_app => $web_app ,
        login_url => $login_url
    };
}

sub ReplyKeyboardRemove {
    my ($selective) = @_;
    $selective //= undef;
    return {
        remove_keyboard => 1 ,
        selective => $selective
    };
}

sub ForceReply {
    my($input_field_placeholder , $selective) = @_;
    $input_field_placeholder //= undef;
    $selective //= undef;
    return {
        force_reply => 1 ,
        input_field_placeholder => $input_field_placeholder ,
        selective => $selective
    };
}

sub KeyboardButton {
    my ($self,$text, $request_users, $request_chat, $request_contact, $request_location, $request_poll, $web_app) = @_;
    $request_users //= undef;
    $request_chat //= undef;
    $request_contact //= undef;
    $request_poll //= undef;
    $request_location //= undef;
    $web_app //= undef;

    return {
        text             => $text,
        request_users    => $request_users,
        request_chat     => $request_chat,
        request_contact  => $request_contact,
        request_location => $request_location,
        request_poll     => $request_poll,
        web_app          => $web_app,
    };
}

sub KeyboardButtonRequestUsers {
    my ($request_id , $user_is_bot , $user_is_premium , $max_quantity) = @_;
    $user_is_bot //= undef;
    $user_is_premium //= undef;
    $max_quantity //= undef;
    return {
        request_id => $request_id ,
        user_is_bot => $user_is_bot ,
        user_is_premium => $user_is_premium ,
        max_quantity => $max_quantity
    };
}

sub KeyboardButtonRequestChat {
    my ($request_id , $chat_is_channel , $chat_is_forum , $chat_has_username , $chat_is_created , $user_administrator_rights , $bot_administrator_rights , $bot_is_member) = @_;
    $chat_has_username //= undef;
    $chat_is_forum //= undef;
    $chat_is_created //= undef;
    $user_administrator_rights //= undef;
    $bot_administrator_rights //= undef;
    $bot_is_member //= undef;
    return {
        request_id => $request_id ,
        chat_is_channel => $chat_is_channel ,
        chat_is_forum => $chat_is_forum ,
        chat_has_username => $chat_has_username ,
        chat_is_created => $chat_is_created ,
        user_administrator_rights => $user_administrator_rights ,
        bot_administrator_rights => $bot_administrator_rights ,
        bot_is_member => $bot_is_member
    };
}

sub KeyboardButtonPollType {
    my ($type) = @_;
    $type //= undef;
    return {
        type => $type
    };
}

1;