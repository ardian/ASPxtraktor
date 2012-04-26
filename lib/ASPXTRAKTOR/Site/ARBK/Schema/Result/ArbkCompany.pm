use utf8;
package ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompany;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompany

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

=head1 TABLE: C<arbk_company>

=cut

__PACKAGE__->table("arbk_company");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 regnumber

  data_type: 'integer'
  is_nullable: 0

=head2 employsnumber

  data_type: 'integer'
  is_nullable: 0

=head2 constitutiondate

  data_type: 'integer'
  is_nullable: 0

=head2 telephone

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 capital

  data_type: 'longtext'
  is_nullable: 0

=head2 addressstreet

  data_type: 'varchar'
  is_nullable: 0
  size: 200

=head2 addressstreetnumber

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 addresscity

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 addresspostcode

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 primarycategory_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "regnumber",
  { data_type => "integer", is_nullable => 0 },
  "employsnumber",
  { data_type => "integer", is_nullable => 0 },
  "constitutiondate",
  { data_type => "integer", is_nullable => 0 },
  "telephone",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "capital",
  { data_type => "longtext", is_nullable => 0 },
  "addressstreet",
  { data_type => "varchar", is_nullable => 0, size => 200 },
  "addressstreetnumber",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "addresscity",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "addresspostcode",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "primarycategory_id",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<RegNumber>

=over 4

=item * L</regnumber>

=back

=cut

__PACKAGE__->add_unique_constraint("RegNumber", ["regnumber"]);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-04-06 20:41:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ob7+wlol8Bt6OLkB4AcUzA


__PACKAGE__->belongs_to(
    "primarycategory",
    "ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkBusinesscategory",
    { id => "primarycategory_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
    );

__PACKAGE__->has_many(
    "arbk_company_secondary_categories",
    "ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanySecondaryCategory",
    { "foreign.company_id" => "self.id" },
    { cascade_copy => 0, cascade_delete => 0 },
    );

__PACKAGE__->has_many(
    "arbk_company_owners",
    "ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanyOwner",
    { "foreign.company_id" => "self.id" },
    { cascade_copy => 0, cascade_delete => 0 },
    );

__PACKAGE__->has_many(
    "arbk_company_authorized_persons",
    "ASPXTRAKTOR::Site::ARBK::Schema::Result::ArbkCompanyAuthorizedPerson",
    { "foreign.company_id" => "self.id" },
    { cascade_copy => 0, cascade_delete => 0 },
    );



1;
