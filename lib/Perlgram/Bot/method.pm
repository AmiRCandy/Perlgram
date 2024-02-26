package Perlgram::Bot::method;

sub LoginUrl {
    my ($url , $forward_text , $bot_username , $request_write_access) = @_;
    $forward_text //= undef;
    $bot_username //= undef;
    $request_write_access //= undef;
    return {
        url => $url ,
        forward_text => $forward_text ,
        bot_username => $bot_username ,
        request_write_access => $request_write_access
    };
}

sub SwitchInlineQueryChosenChat {
    my ($query , $allow_user_chats , $allow_bot_chats , $allow_group_chats , $allow_channel_chats) = @_;
    $allow_bot_chats //= undef;
    $allow_user_chats //= undef;
    $allow_group_chats //= undef;
    $allow_channel_chats //=undef;
    return {
        query => $query ,
        allow_user_chats => $allow_user_chats ,
        allow_bot_chats => $allow_bot_chats ,
        allow_group_chats => $allow_group_chats ,
        allow_channel_chats => $allow_channel_chats
    };
}

sub WebAppInfo {
    my ($url) = @_;
    return {
        url => $url
    };
}

sub ChatAdministratorRights {
    my (%args) = @_;
    return {
        is_anonymous          => $args{is_anonymous} // 0,
        can_manage_chat       => $args{can_manage_chat} // 0,
        can_delete_messages   => $args{can_delete_messages} // 0,
        can_manage_video_chats => $args{can_manage_video_chats} // 0,
        can_restrict_members  => $args{can_restrict_members} // 0,
        can_promote_members   => $args{can_promote_members} // 0,
        can_change_info       => $args{can_change_info} // 0,
        can_invite_users      => $args{can_invite_users} // 0,
        can_post_stories      => $args{can_post_stories} // 0,
        can_edit_stories      => $args{can_edit_stories} // 0,
        can_delete_stories    => $args{can_delete_stories} // 0,
        can_post_messages     => $args{can_post_messages} // 0,
        can_edit_messages     => $args{can_edit_messages} // 0,
        can_pin_messages      => $args{can_pin_messages} // 0,
        can_manage_topics     => $args{can_manage_topics} // 0,
    };
}

sub LinkPreviewOptions {
    my ($is_disabled,$url,$prefer_small_media,$prefer_large_media,$show_above_text) = @_;
    $is_disabled //= 1;
    $url //= undef;
    $prefer_small_media //= undef;
    $prefer_large_media //= undef;
    $show_above_text //= undef;
    return {
        is_disabled => $is_disabled ,
        url => $url ,
        prefer_small_media => $prefer_small_media ,
        prefer_large_media => $prefer_large_media ,
        show_above_text => $show_above_text
    };
}

sub ReplyParameters {
    my ($message_id,$chat_id,$allow_sending_without_reply,$quote,$quote_parse_mode,$quote_position) = @_;
    $chat_id //= undef;
    $allow_sending_without_reply //= undef;
    $quote //= undef;
    $quote_parse_mode //= undef;
    $quote_position //= undef;
    return {
        message_id => $message_id ,
        chat_id => $chat_id ,
        allow_sending_without_reply => $allow_sending_without_reply ,
        quote => $quote ,
        quote_parse_mode => $quote_parse_mode ,
        quote_position => $quote_position
    };
}

sub ChatPermissions {
    my (%args) = @_;
    return {
        can_send_messages => $args{can_send_messages} // 1,
        can_send_audios => $args{can_send_audios} // 1,
        can_send_documents => $args{can_send_documents} // 1,
        can_send_photos => $args{can_send_photos} // 1,
        can_send_videos => $args{can_send_videos} // 1,
        can_send_video_notes => $args{can_send_video_notes} // 1,
        can_send_voice_notes => $args{can_send_voice_notes} // 1,
        can_send_polls => $args{can_send_polls} // 1,
        can_send_other_messages => $args{can_send_other_messages} // 1,
        can_add_web_page_previews => $args{can_add_web_page_previews} // 1,
        can_change_info => $args{can_change_info} // 1,
        can_invite_users => $args{can_invite_users} // 1,
        can_pin_messages => $args{can_pin_messages} // 1,
        can_manage_topics => $args{can_manage_topics} // 1
    };
}

sub BotCommand {
    my ($command,$description) = @_;
    return {
        command => $command ,
        description => $description
    };
}

1;