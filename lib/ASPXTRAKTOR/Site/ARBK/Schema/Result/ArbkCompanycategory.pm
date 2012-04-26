use utf8;
package ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanycategory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanycategory

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

=head1 TABLE: C<arbk_companycategory>

=cut

__PACKAGE__->table("arbk_companycategory");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkBusinesscategory>

=cut

__PACKAGE__->belongs_to(
  "category",
  "ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkBusinesscategory",
  { id => "category_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-03 13:34:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JaXDKhLAqQZbDaiT1+7b1A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
