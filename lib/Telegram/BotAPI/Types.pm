package Telegram::BotAPI::Types;
use strict;
use warnings;

our $User = {
    id           => undef,
    is_bot       => undef,
    first_name   => undef,
    last_name    => undef,
    username     => undef,
    language_code => undef,
    can_join_groups => undef,
    can_read_all_group_messages => undef,
    supports_inline_queries => undef,
};

our $Chat = {
    id                          => undef,
    type                        => undef,
    title                       => undef,
    username                    => undef,
    first_name                  => undef,
    last_name                   => undef,
    photo                       => undef,
    bio                         => undef,
    description                 => undef,
    invite_link                 => undef,
    pinned_message              => undef,
    permissions                 => undef,
    slow_mode_delay             => undef,
    message_auto_delete_time    => undef,
    sticker_set_name            => undef,
    can_set_sticker_set         => undef,
};

our $Message = {
    message_id                    => undef,
    from                          => undef,
    chat                          => undef,
    date                          => undef,
    text                          => undef,
    entities                      => undef,
    caption                       => undef,
    caption_entities              => undef,
    photo                         => undef,
    document                      => undef,
    audio                         => undef,
    video                         => undef,
    animation                     => undef,
    voice                         => undef,
    video_note                    => undef,
    contact                       => undef,
    location                      => undef,
    venue                         => undef,
    poll                          => undef,
    dice                          => undef,
    new_chat_members              => undef,
    left_chat_member              => undef,
    new_chat_title                => undef,
    new_chat_photo                => undef,
    delete_chat_photo             => undef,
    group_chat_created            => undef,
    supergroup_chat_created       => undef,
    channel_chat_created          => undef,
    message_auto_delete_timer_changed => undef,
    migrate_to_chat_id            => undef,
    migrate_from_chat_id          => undef,
    pinned_message                => undef,
    invoice                       => undef,
    successful_payment            => undef,
    connected_website             => undef,
    reply_markup                  => undef,
};

our $InlineQuery = {
    id       => undef,
    from     => undef,
    query    => undef,
    offset   => undef,
    chat_type => undef,
};

our $CallbackQuery = {
    id              => undef,
    from            => undef,
    message         => undef,
    inline_message_id => undef,
    chat_instance   => undef,
    data            => undef,
    game_short_name => undef,
};

our $ShippingQuery = {
    id               => undef,
    from             => undef,
    invoice_payload  => undef,
    shipping_address => undef,
};

our $PreCheckoutQuery = {
    id                    => undef,
    from                  => undef,
    currency              => undef,
    total_amount          => undef,
    invoice_payload       => undef,
    shipping_option_id    => undef,
    order_info            => undef,
};

our $Poll = {
    id                    => undef,
    question              => undef,
    options               => undef,
    total_voter_count     => undef,
    is_closed             => undef,
    is_anonymous          => undef,
    type                  => undef,
    allows_multiple_answers => undef,
    correct_option_id     => undef,
    explanation           => undef,
    explanation_entities  => undef,
    open_period           => undef,
    close_date            => undef,
};

our $PollAnswer = {
    poll_id    => undef,
    user       => undef,
    option_ids => undef,
};

our $ChatMember = {
    user                  => undef,
    status                => undef,
    custom_title          => undef,
    is_anonymous          => undef,
    until_date            => undef,
    can_be_edited         => undef,
    can_post_messages     => undef,
    can_edit_messages     => undef,
    can_delete_messages   => undef,
    can_restrict_members  => undef,
    can_promote_members   => undef,
    can_change_info       => undef,
    can_invite_users      => undef,
    can_pin_messages      => undef,
    is_member             => undef,
    can_send_messages     => undef,
    can_send_media_messages => undef,
    can_send_polls        => undef,
    can_send_other_messages => undef,
    can_add_web_page_previews => undef,
};

our $ChatJoinRequest = {
    chat       => undef,
    from       => undef,
    date       => undef,
    bio        => undef,
    invite_link => undef,
};

1;
__END__

=head1 NAME

Telegram::BotAPI::Types - Data structures for Telegram API objects

=head1 DESCRIPTION

Defines Perl hash structures for Telegram API objects, including User, Chat, Message, InlineQuery, and more.

=head1 AUTHOR

Your Name, E<lt>your.email@example.comE<gt>

=head1 LICENSE

Artistic License 2.0