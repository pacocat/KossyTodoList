package KossyTodoList::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use DBI;
use Digest::SHA;
use Time::Piece;
use Encode;
use DBIx::Skinny;
use KossyTodoList::Model;

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

sub db {
    my $self = shift;
    if (! defined $self->{_db}) {
    $self->{_db} = KossyTodoList::Model->new(+{
        dsn => 'dbi:mysql:training',
        username => 'yourname',
        password => 'yourpass',
    });
    }
    return $self->{_db};
}

sub _decode {
    my ($self, $str, $code) = @_;
    $code //= 'utf-8';
    return Encode::decode($code, $str);
}

sub _encode {
    my ($self, $str, $code) = @_;
    $code //= 'utf-8';
    return Encode::encode($code, $str);
}

sub add_entry {
    my $self = shift;
    #my ($id, $text, $due, $done) = @_;
    my ($text, $due) = @_;
    $text //= 'No text';
    #$due //= '2013-09-20 19:59:11';
    #$done //= 0;
    $self->db->insert('todos', {
        #id  => $id,
        text   => $text,
        due_at       => $due,
        #done       => $done,
        created_at => localtime->datetime(T => ' '),
        updated_at => localtime->datetime(T => ' '),
    });
    return 'true';
}

get '/' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    my @entries = $self->db->search('todos', {}, {
        order_by => { 'created_at' => 'DESC'}, });
    $c->render('index.tx', { entries => \@entries });
};

get '/about' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('about.tx', { });
};

get '/contact' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    $c->render('contact.tx', { });
};

post '/update'  => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;
    my $update_id = $c->req->param('id');
    my @entry = $self->db->search('todos', {id => $update_id} );
    $c->render('modify.tx', { entry => @entry });
};

post '/create' => sub {
    my ($self, $c) = @_;
    #my $strp = DateTime::Format::Strptime->new(pattern => "%b %d, %Y");
    my $result = $c->req->validator([
        'text' => {
            default => 'hogehoge',
            rule => [
                ['NOT_NULL', 'empty text'],
            ],
        },
        'due' => {
            rule => [
                ['NOT_NULL', 'empty due'],
            ],
        }
    ]);
    if ($result->has_error) {
        return $c->render('index.tx', { error => 1, messages => $result->errors });
    }
    my $add = $self->add_entry(map { $result->valid($_) } qw/text due/);
    return $c->redirect('/');
};

post '/delete' => sub {
    my ($self, $c) = @_;
    #my $test_id = $c->req->param('DELETE');
    my $delte_id = $c->req->param('id');
    #my $delsql = 'DELETE FROM todos WHERE id = ' . $delte_id;
    my $delete_row_count = $self->db->delete_by_sql(
    q{DELETE FROM todos WHERE id = ?},
    [$delte_id]
    );
    return $c->redirect('/');
    #$c->render('index.tx', { testparam => $delsql});
};

post '/commit' => sub {
    my ($self, $c)  = @_;
    my $update_id = $c->req->param('id');
    my $modified_text = $c->req->param('text');
    my $modified_due = $c->req->param('due');
    my $modified_done = $c->req->param('done');
    $self->db->update('todos',{text => $modified_text, due_at => $modified_due, done => $modified_done }, {id => $update_id});
    return $c->redirect('/');
};



1;

