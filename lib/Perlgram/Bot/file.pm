package Perlgram::Bot::file;


sub inputFile {
    my ($fileaddr) = @_;
    open(my $fh, "<:binary", $fileaddr) or warn "Error opening document: $!";
    my $bin = $fh;
    close($fh);
    return $bin;
}

1;