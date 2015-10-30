package YTable;

use latest;
use utf8;
use Moo;
use Types::Standard qw(Str InstanceOf ArrayRef);
use Kavorka;
use Data::Printer;
use String::CamelCase qw(camelize);
use autobox::Core;

use YField;

has fields => (
    is => 'ro',
    isa => ArrayRef[ InstanceOf['YField'] ]
);
has schema => (is => 'ro', isa => Str);
has name => (is => 'ro', isa => Str);

around BUILDARGS => fun($ori, $cls, $tbl, $flds) {
    my @flds = ();
    while (my ($k, $f) = each %$flds) {
        my $fld = YField->new({
                name         => $f->{COLUMN_NAME},
                type         => $f->{TYPE_NAME},
                is_nullable  => !!$f->{NULLABLE},
                is_primary   => !!$f->{mysql_is_pri_key},
                is_auto_inc  => !!$f->{mysql_is_auto_increment},
                is_curr_time => scalar(
                    $f->{COLUMN_DEF} && $f->{COLUMN_DEF} =~ qr/CURRENT_TIMESTAMP/
                ),
            });
        # p $fld;
        push @flds, $fld;
    }

    my @args = (
        name   => $tbl,
        fields => \@flds,
    );
    return $cls->$ori(@args);
};

method java_mapper_name() {
    $self->java_entity_name . 'Mapper'
}

method java_entity_name() {
    ucfirst camelize $self->name
}

method pri_key_name() {
    $self->fields->grep(sub { $_->is_primary })->[0]->name
}

method gen_tt_vars() {
    my $names = $self->fields
        ->grep(sub { !$_->is_auto_inc && !$_->is_curr_time })
        ->map(sub { $_->name });

    return {
        table_name       => $self->name,
        class_name       => $self->java_entity_name,
        instance_name    => lcfirst($self->java_entity_name),
        mapper_name      => $self->java_mapper_name,
        mapper_bean_name => lcfirst($self->java_mapper_name),
        pri_key          => $self->pri_key_name,
        fields_csv       => $names->join(", "),
        fields_values    => $names->map(sub { "#{$_}" })->join(", "),
        fields_update    => $names->map(sub { "$_=#{$_}" })->join(", "),
    };
}

1;
