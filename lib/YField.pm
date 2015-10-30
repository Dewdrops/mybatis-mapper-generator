package YField;

use Moo;
use Types::Standard qw(Str Bool);
use Kavorka;
use Const::Fast;
use latest;
use utf8;

const my %type_map => (
    INT       => 'Integer',
    SMALLINT  => 'Short',
    TINYINT   => 'Short',
    VARCHAR   => 'String',
    CHAR      => 'String',
    TEXT      => 'String',
    LONGTEXT  => 'String',
    TIMESTAMP => 'Timestamp',
    DATETIME  => 'Timestamp',
);

has 'name'         => (is => 'rw', isa => Str);
has 'type'         => (is => 'rw', isa => Str);
has 'is_nullable'  => (is => 'rw', isa => Bool);
has 'is_primary'   => (is => 'rw', isa => Bool);
has 'is_auto_inc'  => (is => 'rw', isa => Bool);
has 'is_curr_time' => (is => 'rw', isa => Bool);

method gen_property() {
}

method gen_getter() {
}

method gen_setter() {
}

1;
