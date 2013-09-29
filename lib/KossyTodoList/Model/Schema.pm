package KossyTodoList::Model::Schema;
use strict;
use warnings;
use DBIx::Skinny::Schema;
use DateTime;
use DateTime::Format::MySQL;



install_table todos => schema {
	pk 'id';
	columns qw/id text due_at done created_at updated_at/;
};


install_utf8_columns qw/body/;

1;