use utf8;
package ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanyAuthorizedPerson;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanyAuthorizedPerson

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<arbk_company_AuthorizedPersons>

=cut

__PACKAGE__->table("arbk_company_AuthorizedPersons");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 company_id

  data_type: 'integer'
  is_nullable: 0

=head2 person_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "company_id",
  { data_type => "integer", is_nullable => 0 },
  "person_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-06 20:41:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ab9sYMt98VmLUNoECUO7SA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
