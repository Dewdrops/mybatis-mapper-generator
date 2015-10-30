requires 'latest';
requires 'strictures';
requires 'DBI';
requires 'DBD::mysql';
requires 'Data::Printer';
requires 'Template';
requires 'Kavorka';
requires 'File::Path';
requires 'File::Spec::Functions';
requires 'POSIX';
requires 'AppConfig';
requires 'Type::Tiny';
requires 'Const::Fast';
requires 'Moo';
requires 'String::CamelCase';
requires 'autobox::Core';

on 'test' => sub {
    requires 'Test::More';
}
