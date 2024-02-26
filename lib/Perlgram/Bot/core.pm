package Perlgram::Bot::core;

use LWP::UserAgent;
use HTTP::Request;
use JSON;
use strict;
use warnings;
use Data::Dumper;

sub new {
    my ($class, $token) = @_;
    my $ua = LWP::UserAgent->new;
    my $json = JSON->new->allow_nonref;
    my $self = { token => $token , requ => $ua , json => $json };
    bless $self, $class;
    return $self;
}


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

sub _request {
    my ($self, $method, $data) = @_;

    my $filtered_data = _remove_undef_keys_recursive($data);
    print Dumper($filtered_data);
    my $response = $self->{requ}->post("https://api.telegram.org/bot" . $self->{token} . "/" . $method, $filtered_data);
    my $content = $response->decoded_content;

    return $self->{json}->decode($content);
}





sub setWebhook {
    my ($self, $url, $ip_address, $max_connections, $allowed_updates, $drop_pending_updates, $secret_token) = @_;
    $ip_address //= undef;
    $max_connections //= undef;
    $allowed_updates //= undef;
    $drop_pending_updates //= 1;
    $secret_token //= undef;
    my %data = {
        url                   => $url,
        ip_address            => $ip_address,
        max_connections       => $max_connections,
        allowed_updates       => $allowed_updates,
        drop_pending_updates  => $drop_pending_updates,
        secret                => $secret_token,
    };
    return $self->_request('setWebhook', \%data);
}

sub getUpdates {
    my ($self, $offset, $limit, $timeout, $allowed_updates) = @_;
    $offset //= undef;
    $limit //= undef;
    $timeout //= undef;
    $allowed_updates //= undef;
    my %data = (
        offset          => $offset,
        limit           => $limit,
        timeout         => $timeout,
        allowed_updates => $allowed_updates,
    );
    return $self->_request('getUpdates', \%data);
}

sub deleteWebhook {
    my ($self,$drop_pending_updates) = @_;
    my %data = (
        drop_pending_updates => $drop_pending_updates
    );
    return $self->_request('deleteWebhook', \%data);
}

sub getWebhookInfo {
    my ($self) = @_;
    return $self->_request('getWebhookInfo', {});
}

sub getMe {
    my ($self) = @_;
    return $self->_request('getMe',{});
}

sub getFile {
    my ($self,$file_id) = @_;
    return $self->_request('getFile',{file_id => $file_id});
}

sub downloadFile {
    my ($self, $file_id, $local_path) = @_;
    my $file_info = $self->getFile($file_id);
    my $file_url = "https://api.telegram.org/file/bot" . $self->{token} . "/" . $file_info->{'file_path'};
    my $filename = (split '/', $file_info->{'file_path'})[-1];
    $local_path //= '.';
    my $full_local_path = $local_path . '/' . $filename;
    my $response = $self->{requ}->get($file_url);
    if ($response->is_success) {
        open my $fh, '>', $full_local_path or warn "Could not open file '$full_local_path' for writing: $!";
        print $fh $response->decoded_content;
        close $fh;
        return 1;
    } else {
        warn "Error downloading file: " . $response->status_line;
        return 0;
    }
}

sub sendMessage {
    my ($self,$chat_id,$text,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$link_preview_options,$entities,$message_thread_id) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $link_preview_options //= undef;
    $entities //= undef;
    $message_thread_id //= undef;
    my %data = (
        chat_id => $chat_id,
        text => $text,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        link_preview_options => $link_preview_options,
        entities => $entities,
        message_thread_id => $message_thread_id

    );
    return $self->_request('sendMessage', \%data);
}

sub forwardMessage {
    my ($self,$chat_id,$from_chat_id,$message_id,$disable_notification,$protect_content,$message_thread_id) = @_;
    $disable_notification //= undef;
    $protect_content //= undef;
    $message_thread_id //= undef;
    my $meth = 'forwardMessage';
    my $msgst = 'message_id';
    if (ref($message_id) eq 'ARRAY') {
        $meth = 'forwardMessages';
        $msgst = 'message_ids';
    }
    my %data = (
        chat_id => $chat_id,
        from_chat_id => $from_chat_id,
        $msgst => $message_id,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        message_thread_id => $message_thread_id
    );
    return $self->_request($meth, \%data);
}

sub copyMessage {
    my ($self,$chat_id,$from_chat_id,$message_id,$caption,$parse_mode,$caption_entities,$reply_parameters,$reply_markup,$disable_notification,$protect_content,$message_thread_id) = @_;
    $disable_notification //= undef;
    $protect_content //= undef;
    $message_thread_id //= undef;
    $caption //= undef;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $reply_parameters //= undef;
    $caption_entities //= undef;
    my $meth = 'copyMessage';
    my $msgst = 'message_id';
    if (ref($message_id) eq 'ARRAY') {
        $meth = 'copyMessages';
        $msgst = 'message_ids';
    }
    my %data = (
        chat_id => $chat_id,
        from_chat_id => $from_chat_id,
        $msgst => $message_id,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        message_thread_id => $message_thread_id ,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        reply_parameters => $reply_parameters,
        caption_entities => $caption_entities
    );
    return $self->_request('copyMessage', \%data);
}

sub sendPhoto {
    my ($self,$chat_id,$photo,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$has_spoiler) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $has_spoiler //= undef;
    $caption //= undef;
    my %data = (
        chat_id => $chat_id,
        photo => $photo,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities,
        has_spoiler => $has_spoiler
    );
    return $self->_request('sendPhoto', \%data);
}

sub sendAudio {
    my ($self,$chat_id,$audio,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$duration,$performer,$title,$thumbnail) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $caption //= undef;
    $duration //= undef;
    $performer //= undef;
    $title //= undef;
    $thumbnail //= undef;
    my %data = (
        chat_id => $chat_id,
        audio => $audio,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities,
        duration => $duration,
        performer => $performer,
        title => $title,
        thumbnail => $thumbnail
    );
    return $self->_request('sendAudio', \%data);
}

sub sendDocument {
    my ($self,$chat_id,$document,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$thumbnail,$disable_content_type_detection) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $caption //= undef;
    $thumbnail //= undef;
    $disable_content_type_detection //= undef;
    my %data = (
        chat_id => $chat_id,
        document => $document,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities ,
        thumbnail => $thumbnail,
        disable_content_type_detection => $disable_content_type_detection
    );
    return $self->_request('sendDocument', \%data);
}

sub sendVideo {
    my ($self,$chat_id,$video,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$supports_streaming,$thumbnail) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $caption //= undef;
    $thumbnail //= undef;
    $supports_streaming //= undef;
    my %data = (
        chat_id => $chat_id,
        video => $video,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities,
        supports_streaming => $supports_streaming,
        thumbnail => $thumbnail
    );
    return $self->_request('sendVideo', \%data);
}

sub sendAnimation {
    my ($self,$chat_id,$animation,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$thumbnail,$has_spoiler,$duration,$width,$height,) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $caption //= undef;
    $thumbnail //= undef;
    $has_spoiler //= undef;
    $duration //= undef;
    $width //= undef;
    $height //= undef;
    my %data = (
        chat_id => $chat_id,
        animation => $animation,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities,
        thumbnail => $thumbnail,
        has_spoiler => $has_spoiler,
        duration => $duration,
        width => $width,
        height => $height
    );
    return $self->_request('sendAnimation',\%data);
}

sub sendVoice {
    my ($self,$chat_id,$voice,$caption,$parse_mode,$reply_markup,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$caption_entities,$duration) = @_;
    $parse_mode //= undef;
    $reply_markup //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $caption_entities //= undef;
    $caption //= undef;
    $duration //= undef;
    my %data = (
        chat_id => $chat_id,
        voice => $voice,
        caption => $caption,
        parse_mode => $parse_mode,
        reply_markup => $reply_markup,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id ,
        caption_entities => $caption_entities ,
        duration => $duration
    );
    return $self->_request('sendVoice', \%data);
}

sub sendVideoNote {
    my ($self,$chat_id,$video_note,$duration,$length,$thumbnail,$disable_notification,$protect_content,$reply_parameters,$message_thread_id) = @_;
    $duration //= undef;
    $length //= undef;
    $thumbnail //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    my %data = (
        chat_id => $chat_id,
        video_note => $video_note,
        duration => $duration,
        length => $length,
        thumbnail => $thumbnail,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id
    );
    return $self->_request('sendVideoNote', \%data);
}

sub sendMediaGroup {
    my ($self,$chat_id,$media,$disable_notification,$protect_content,$reply_parameters,$message_thread_id) = @_;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    my %data = (
        chat_id => $chat_id,
        media => $media,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id
    );
    return $self->_request('sendMediaGroup', \%data);
}

sub sendLocation {
    my ($self,$chat_id,$latitude,$longitude,$horizontal_accuracy,$live_period,$heading,$proximity_alert_radius,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$reply_markup) = @_;
    $horizontal_accuracy //= undef;
    $live_period //= undef;
    $heading //= undef;
    $proximity_alert_radius //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        latitude => $latitude,
        longitude => $longitude,
        horizontal_accuracy => $horizontal_accuracy,
        live_period => $live_period,
        heading => $heading,
        proximity_alert_radius => $proximity_alert_radius,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id,
        reply_markup => $reply_markup
    );
    return $self->_request('sendLocation', \%data);
}

sub sendVenue {
    my ($self,$chat_id,$latitude,$longitude,$title,$address,$foursquare_id,$foursquare_type,$google_place_id,$google_place_type,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$reply_markup) = @_;
    $foursquare_type //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $reply_markup //= undef;
    $google_place_type //= undef;
    $google_place_id //= undef;
    $foursquare_id //= undef;
    $foursquare_type //= undef;
    my %data = (
        chat_id => $chat_id,
        latitude => $latitude,
        longitude => $longitude,
        title => $title,
        address => $address,
        foursquare_id => $foursquare_id,
        foursquare_type => $foursquare_type,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id,
        reply_markup => $reply_markup ,
        google_place_id => $google_place_id,
        google_place_type => $google_place_type
    );
    return $self->_request('sendVenue', \%data);
}

sub sendContact {
    my ($self,$chat_id,$phone_number,$first_name,$last_name,$vcard,$disable_notification,$protect_content,$reply_parameters,$message_thread_id,$reply_markup) = @_;
    $last_name //= undef;
    $disable_notification //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $message_thread_id //= undef;
    $reply_markup //= undef;
    $vcard //= undef;
    my %data = (
        chat_id => $chat_id,
        phone_number => $phone_number,
        first_name => $first_name,
        last_name => $last_name,
        disable_notification => $disable_notification,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        message_thread_id => $message_thread_id,
        reply_markup => $reply_markup ,
        vcard => $vcard
    );
    return $self->_request('sendContact', \%data);   
}

sub sendPoll {

}

sub sendDice {
    my ($self,$chat_id,$emoji,$disable_notification,$message_thread_id,$protect_content,$reply_parameters,$reply_markup) = @_;
    $emoji //= undef;
    $disable_notification //= undef;
    $message_thread_id //= undef;
    $protect_content //= undef;
    $reply_parameters //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        emoji => $emoji,
        disable_notification => $disable_notification,
        message_thread_id => $message_thread_id,
        protect_content => $protect_content,
        reply_parameters => $reply_parameters,
        reply_markup => $reply_markup
    );
    return $self->_request('sendDice', \%data);
}

sub sendChatAction {
    my ($self,$chat_id,$action,$message_thread_id) = @_;
    $message_thread_id //= undef;
    my %data = (
        chat_id => $chat_id,
        action => $action ,
        message_thread_id => $message_thread_id
    );
    return $self->_request('sendChatAction', \%data);
}

sub setMessageReaction {
    my ($self,$chat_id,$message_id,$reaction,$is_big) = @_;
    $is_big //= undef;
    $reaction //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        reaction => $reaction,
        is_big => $is_big
    );
    return $self->_request('setMessageReaction', \%data);
}

sub getUserProfilePhotos {
    my ($self,$user_id,$offset,$limit) = @_;
    $offset //= undef;
    $limit //= undef;
    my %data = (
        user_id => $user_id,
        offset => $offset,
        limit => $limit
    );
    return $self->_request('getUserProfilePhotos', \%data);
}

sub banChatMember {
    my ($self,$chat_id,$user_id,$until_date,$revoke_messages) = @_;
    $until_date //= undef;
    $revoke_messages //= undef;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id ,
        until_date => $until_date,
        revoke_messages => $revoke_messages
    );
    return $self->_request('banChatMember', \%data);
}

sub unbanChatMember {
    my ($self,$chat_id,$user_id,$only_if_banned) = @_;
    $only_if_banned //= undef;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id ,
        only_if_banned => $only_if_banned
    );
    return $self->_request('unbanChatMember', \%data);
}

sub restrictChatMember {
    my ($self,$chat_id,$user_id,$permissions,$until_date,$use_independent_chat_permissions) = @_;
    $until_date //= undef;
    $use_independent_chat_permissions //= undef;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id ,
        permissions => $permissions,
        until_date => $until_date,
        use_independent_chat_permissions => $use_independent_chat_permissions
    );
    return $self->_request('restrictChatMember', \%data);
}

sub promoteChatMember {
    my ($self,$chat_id,$user_id,$is_anonymous,$can_manage_chat,$can_delete_messages,$can_manage_video_chats,$can_restrict_members,$can_promote_members,$can_change_info,$can_invite_users,$can_post_stories,$can_edit_stories,$can_delete_stories,$can_post_messages,$can_edit_messages,$can_pin_messages,$can_manage_topics) = @_;
    $is_anonymous //= undef;
    $can_manage_chat //= undef;
    $can_delete_messages //= undef;
    $can_manage_video_chats //= undef;
    $can_restrict_members //= undef;
    $can_promote_members //= undef;
    $can_change_info //= undef;
    $can_invite_users //= undef;
    $can_post_stories //= undef;
    $can_edit_stories //= undef;
    $can_delete_stories //= undef;
    $can_post_messages //= undef;
    $can_edit_messages //= undef;
    $can_pin_messages //= undef;
    $can_manage_topics //= undef;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id ,
        is_anonymous => $is_anonymous,
        can_manage_chat => $can_manage_chat,
        can_delete_messages => $can_delete_messages,
        can_manage_video_chats => $can_manage_video_chats,
        can_restrict_members => $can_restrict_members,
        can_promote_members => $can_promote_members,
        can_change_info => $can_change_info,
        can_invite_users => $can_invite_users,
        can_post_stories => $can_post_stories,
        can_edit_stories => $can_edit_stories,
        can_delete_stories => $can_delete_stories,
        can_post_messages => $can_post_messages,
        can_edit_messages => $can_edit_messages,
        can_pin_messages => $can_pin_messages,
        can_manage_topics => $can_manage_topics
    );
    return $self->_request('promoteChatMember', \%data);
}

sub setChatAdministratorCustomTitle {
    my ($self,$chat_id,$user_id,$custom_title) = @_;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id ,
        custom_title => $custom_title
    );
    return $self->_request('setChatAdministratorCustomTitle', \%data);
}

sub banChatSenderChat {
    my ($self,$chat_id,$sender_chat_id) = @_;
    my %data = (
        chat_id => $chat_id,
        sender_chat_id => $sender_chat_id
    );
    return $self->_request('banChatSenderChat', \%data);
}

sub unbanChatSenderChat {
    my ($self,$chat_id,$sender_chat_id) = @_;
    my %data = (
        chat_id => $chat_id,
        sender_chat_id => $sender_chat_id
    );
    return $self->_request('unbanChatSenderChat', \%data);
}

sub setChatPermissions {
    my ($self,$chat_id,$permissions,$use_independent_chat_permissions) = @_;
    $use_independent_chat_permissions //= undef;
    my %data = (
        chat_id => $chat_id,
        permissions => $permissions,
        use_independent_chat_permissions => $use_independent_chat_permissions
    );
    return $self->_request('setChatPermissions', \%data);
}

sub exportChatInviteLink {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('exportChatInviteLink', \%data);
}

sub createChatInviteLink {
    my ($self,$chat_id,$name,$expire_date,$member_limit,$creates_join_request) = @_;
    $expire_date //= undef;
    $member_limit //= undef;
    $creates_join_request //= undef;
    my %data = (
        chat_id => $chat_id,
        name => $name,
        expire_date => $expire_date,
        member_limit => $member_limit,
        creates_join_request => $creates_join_request
    );
    return $self->_request('createChatInviteLink', \%data);
}

sub editChatInviteLink {
    my ($self,$chat_id,$invite_link,$name,$expire_date,$member_limit,$creates_join_request) = @_;
    $expire_date //= undef;
    $member_limit //= undef;
    $creates_join_request //= undef;
    my %data = (
        chat_id => $chat_id,
        invite_link => $invite_link,
        name => $name,
        expire_date => $expire_date,
        member_limit => $member_limit,
        creates_join_request => $creates_join_request
    );
    return $self->_request('editChatInviteLink', \%data);
}

sub revokeChatInviteLink {
    my ($self,$chat_id,$invite_link) = @_;
    my %data = (
        chat_id => $chat_id,
        invite_link => $invite_link
    );
    return $self->_request('revokeChatInviteLink', \%data);
}

sub approveChatJoinRequest {
    my ($self,$chat_id,$user_id) = @_;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id
    );
    return $self->_request('approveChatJoinRequest', \%data);
}

sub declineChatJoinRequest {
    my ($self,$chat_id,$user_id) = @_;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id
    );
    return $self->_request('declineChatJoinRequest', \%data);
}

sub setChatPhoto {
    my ($self,$chat_id,$photo) = @_;
    my %data = (
        chat_id => $chat_id,
        photo => $photo
    );
    return $self->_request('setChatPhoto', \%data);
}

sub deleteChatPhoto {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('deleteChatPhoto', \%data);
}

sub setChatTitle {
    my ($self,$chat_id,$title) = @_;
    my %data = (
        chat_id => $chat_id,
        title => $title
    );
    return $self->_request('setChatTitle', \%data);
}

sub setChatDescription {
    my ($self,$chat_id,$description) = @_;
    my %data = (
        chat_id => $chat_id,
        description => $description
    );
    return $self->_request('setChatDescription', \%data);
}

sub pinChatMessage {
    my ($self,$chat_id,$message_id,$disable_notification) = @_;
    $disable_notification //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        disable_notification => $disable_notification
    );
    return $self->_request('pinChatMessage', \%data);
}

sub unpinChatMessage {
    my ($self,$chat_id,$message_id) = @_;
    $message_id //= undef;
    my %data = (
        chat_id => $chat_id ,
        message_id => $message_id
    );
    return $self->_request('unpinChatMessage', \%data);
}

sub unpinAllChatMessages {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('unpinAllChatMessages', \%data);
}

sub leaveChat {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('leaveChat', \%data);
}

sub getChat {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('getChat', \%data);
}

sub getChatAdministrators {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('getChatAdministrators', \%data);
}

sub getChatMemberCount {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('getChatMemberCount', \%data);
}

sub getChatMember {
    my ($self,$chat_id,$user_id) = @_;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id
    );
    return $self->_request('getChatMember', \%data);
}

sub setChatStickerSet {
    my ($self,$chat_id,$sticker_set_name) = @_;
    my %data = (
        chat_id => $chat_id,
        sticker_set_name => $sticker_set_name
    );
    return $self->_request('setChatStickerSet', \%data);
}

sub deleteChatStickerSet {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('deleteChatStickerSet', \%data);
}

sub getForumTopicIconStickers {
    my ($self) = @_;
    return $self->_request('getForumTopicIconStickers');
}

sub createForumTopic {
    my ($self,$chat_id,$name,$icon_color,$icon_custom_emoji_id) = @_;
    $icon_color //= undef;
    $icon_custom_emoji_id //= undef;
    my %data = (
        chat_id => $chat_id,
        name => $name,
        icon_color => $icon_color,
        icon_custom_emoji_id => $icon_custom_emoji_id
    );
    return $self->_request('createForumTopic', \%data);
}

sub editForumTopic {
    my ($self,$chat_id,$message_thread_id,$name,$icon_custom_emoji_id) = @_;
    $icon_custom_emoji_id //= undef;
    $name //= undef;
    my %data = (
        chat_id => $chat_id,
        message_thread_id => $message_thread_id,
        name => $name,
        icon_custom_emoji_id => $icon_custom_emoji_id
    );
    return $self->_request('editForumTopic', \%data);
}

sub closeForumTopic {
    my ($self,$chat_id,$message_thread_id) = @_;
    my %data = (
        chat_id => $chat_id,
        message_thread_id => $message_thread_id
    );
    return $self->_request('closeForumTopic', \%data);
}

sub reopenForumTopic {
    my ($self,$chat_id,$message_thread_id) = @_;
    my %data = (
        chat_id => $chat_id,
        message_thread_id => $message_thread_id
    );
    return $self->_request('reopenForumTopic', \%data);
}

sub deleteForumTopic {
    my ($self,$chat_id,$message_thread_id) = @_;
    my %data = (
        chat_id => $chat_id,
        message_thread_id => $message_thread_id
    );
    return $self->_request('deleteForumTopic', \%data);
}

sub unpinAllForumTopicMessages {
    my ($self,$chat_id,$message_thread_id) = @_;
    my %data = (
        chat_id => $chat_id,
        message_thread_id => $message_thread_id
    );
    return $self->_request('unpinAllForumTopicMessages', \%data);
}

sub editGeneralForumTopic {
    my ($self,$chat_id,$name) = @_;
    my %data = (
        chat_id => $chat_id,
        name => $name
    );
    return $self->_request('editGeneralForumTopic', \%data);
}

sub closeGeneralForumTopic {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('closeGeneralForumTopic', \%data);
}

sub reopenGeneralForumTopic {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('reopenGeneralForumTopic', \%data);
}

sub hideGeneralForumTopic {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('hideGeneralForumTopic', \%data);
}

sub unhideGeneralForumTopic {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('unhideGeneralForumTopic', \%data);
}

sub unpinAllGeneralForumTopicMessages {
    my ($self,$chat_id) = @_;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('unpinAllGeneralForumTopicMessages', \%data);
}

sub answerCallbackQuery {
    my ($self,$callback_query_id,$text,$show_alert,$url,$cache_time) = @_;
    $cache_time //= 0;
    $text //= undef;
    $show_alert //= undef;
    $url //= undef;
    my %data = (
        callback_query_id => $callback_query_id,
        text => $text,
        show_alert => $show_alert,
        url => $url,
        cache_time => $cache_time
    );
    return $self->_request('answerCallbackQuery', \%data);
}

sub getUserChatBoosts {
    my ($self, $chat_id, $user_id) = @_;
    my %data = (
        chat_id => $chat_id,
        user_id => $user_id
    );
    return $self->_request('getUserChatBoosts', \%data);
}

sub setMyCommands {
    my ($self, $commands,$scope,$language_code) = @_;
    $scope //= undef;
    $language_code //= undef;
    my %data = (
        commands => $commands
    );
    return $self->_request('setMyCommands', \%data);
}

sub deleteMyCommands {
    my ($self, $scope,$language_code) = @_;
    $scope //= undef;
    $language_code //= undef;
    my %data = (
        scope => $scope,
        language_code => $language_code
    );
    return $self->_request('deleteMyCommands', \%data);
}

sub getMyCommands {
    my ($self, $scope,$language_code) = @_;
    $scope //= undef;
    $language_code //= undef;
    my %data = (
        scope => $scope,
        language_code => $language_code
    );
    return $self->_request('getMyCommands', \%data);
}

sub setMyName {
    my ($self, $name,$language_code) = @_;
    $language_code //= undef;
    $name //= undef;
    my %data = (
        name => $name ,
        language_code => $language_code
    );
    return $self->_request('setMyName', \%data);
}

sub getMyName {
    my ($self, $language_code) = @_;
    $language_code //= undef;
    my %data = (
        language_code => $language_code
    );
    return $self->_request('getMyName', \%data);
}

sub setMyDescription {
    my ($self, $description,$language_code) = @_;
    $language_code //= undef;
    $description //= undef;
    my %data = (
        description => $description ,
        language_code => $language_code
    );
    return $self->_request('setMyDescription', \%data);
}

sub getMyDescription {
    my ($self, $language_code) = @_;
    $language_code //= undef;
    my %data = (
        language_code => $language_code
    );
    return $self->_request('getMyDescription', \%data);
}

sub setMyShortDescription {
    my ($self, $short_description,$language_code) = @_;
    $language_code //= undef;
    $short_description //= undef;
    my %data = (
        short_description => $short_description ,
        language_code => $language_code
    );
    return $self->_request('setMyShortDescription', \%data);
}

sub getMyShortDescription {
    my ($self, $language_code) = @_;
    $language_code //= undef;
    my %data = (
        language_code => $language_code
    );
    return $self->_request('getMyShortDescription', \%data);
}

sub setChatMenuButton {
    my ($self, $chat_id,$menu_button) = @_;
    $menu_button //= undef;
    $chat_id //= undef;
    my %data = (
        chat_id => $chat_id,
        menu_button => $menu_button
    );
    return $self->_request('setChatMenuButton', \%data);
}

sub getChatMenuButton {
    my ($self, $chat_id) = @_;
    $chat_id //= undef;
    my %data = (
        chat_id => $chat_id
    );
    return $self->_request('getChatMenuButton', \%data);
}

sub setMyDefaultAdministratorRights {
    my ($self, $rights,$for_channels) = @_;
    $for_channels //= undef;
    $rights //= undef;
    my %data = (
        rights => $rights ,
        for_channels => $for_channels
    );
    return $self->_request('setMyDefaultAdministratorRights', \%data);
}

sub getMyDefaultAdministratorRights {
    my ($self, $for_channels) = @_;
    $for_channels //= undef;
    my %data = (
        for_channels => $for_channels
    );
    return $self->_request('getMyDefaultAdministratorRights', \%data);
}

sub editMessageText {
    my ($self, $chat_id, $message_id, $inline_message_id, $text, $parse_mode, $entities, $link_preview_options, $reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $parse_mode //= undef;
    $entities //= undef;
    $link_preview_options //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        text => $text,
        parse_mode => $parse_mode,
        entities => $entities,
        link_preview_options => $link_preview_options,
        reply_markup => $reply_markup
    );
    return $self->_request('editMessageText', \%data);
}

sub editMessageCaption {
    my ($self, $chat_id, $message_id, $inline_message_id, $caption, $parse_mode, $caption_entities, $reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $parse_mode //= undef;
    $caption_entities //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        caption => $caption,
        parse_mode => $parse_mode,
        caption_entities => $caption_entities,
        reply_markup => $reply_markup
    );
    return $self->_request('editMessageCaption', \%data);
}

sub editMessageMedia {
    my ($self, $chat_id, $message_id, $inline_message_id, $media,$reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        media => $media ,
        reply_markup => $reply_markup
    );
    return $self->_request('editMessageMedia', \%data);
}

sub editMessageLiveLocation {
    my ($self, $chat_id, $message_id, $inline_message_id, $latitude, $longitude, $heading, $proximity_alert_radius, $reply_markup,$horizontal_accuracy) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $reply_markup //= undef;
    $horizontal_accuracy //= undef;
    $heading //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        latitude => $latitude,
        longitude => $longitude,
        heading => $heading,
        proximity_alert_radius => $proximity_alert_radius,
        reply_markup => $reply_markup ,
        horizontal_accuracy => $horizontal_accuracy
    );
    return $self->_request('editMessageLiveLocation', \%data);
}

sub stopMessageLiveLocation {
    my ($self, $chat_id, $message_id, $inline_message_id, $reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        reply_markup => $reply_markup
    );
    return $self->_request('stopMessageLiveLocation', \%data);
}

sub editMessageReplyMarkup {
    my ($self, $chat_id, $message_id, $inline_message_id, $reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $inline_message_id //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        inline_message_id => $inline_message_id,
        reply_markup => $reply_markup
    );
    return $self->_request('editMessageReplyMarkup', \%data);
}

sub stopPoll {
    my ($self, $chat_id, $message_id, $reply_markup) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    $reply_markup //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id,
        reply_markup => $reply_markup
    );
    return $self->_request('stopPoll', \%data);
}

sub deleteMessage {
    my ($self, $chat_id, $message_id) = @_;
    $chat_id //= undef;
    $message_id //= undef;
    my %data = (
        chat_id => $chat_id,
        message_id => $message_id
    );
    return $self->_request('deleteMessage', \%data);
}

sub deleteMessages {
    my ($self, $chat_id, $message_ids) = @_;
    $chat_id //= undef;
    $message_ids //= undef;
    my %data = (
        chat_id => $chat_id,
        message_ids => $message_ids
    );
    return $self->_request('deleteMessages', \%data);
}

sub handleUpdates {
    my ($self, $handler) = @_;
    my $last_update_id = 0;
    my $up = $self->getUpdates();
    foreach my $update (@{$up->{'result'}}) {
        my $update_id = $update->{update_id};
        $handler->($update);
        $last_update_id = $update_id if $update_id > $last_update_id;
    }
    sleep 1;
}

1;