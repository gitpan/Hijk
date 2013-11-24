#line 1
package Module::Install::CPANfile;

use strict;
use 5.008_001;
our $VERSION = '0.04';

use Module::CPANfile;
use base qw(Module::Install::Base);

sub cpanfile {
    my $self = shift;
    $self->include("Module::CPANfile");

    my $specs = Module::CPANfile->load->prereq_specs;

    while (my($phase, $requirements) = each %$specs) {
        while (my($type, $requirement) = each %$requirements) {
            if (my $command = $self->command_for($phase, $type)) {
                while (my($mod, $ver) = each %$requirement) {
                    $self->$command($mod, $self->_fix_version($ver));
                }
            }
        }
    }
}

sub _fix_version {
    my($self, $ver) = @_;

    return $ver unless $ver;

    $ver =~ /(?:^|>=?)\s*([\d\.\_]+)/
      and return $1;

    $ver;
}

sub command_for {
    my($self, $phase, $type) = @_;

    if ($type eq 'conflicts') {
        warn 'conflicts is not supported';
        return;
    }

    if ($phase eq 'develop') {
        if ($INC{"Module/Install/AuthorRequires.pm"}) {
            return 'author_requires';
        } elsif ($Module::Install::AUTHOR) {
            warn "develop phase is ignored unless Module::Install::AuthorRequires is installed.\n";
            return;
        } else {
            return;
        }
    }

    if ($type eq 'recommends' or $type eq 'suggests') {
        return 'recommends';
    }

    if ($phase eq 'runtime') {
        return 'requires';
    }

    return "${phase}_requires";
}

1;
__END__

=encoding utf-8

#line 154
