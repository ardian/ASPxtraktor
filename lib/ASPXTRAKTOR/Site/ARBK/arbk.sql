BEGIN;
CREATE TABLE "arbk_businesscategory" (
    "id" integer NOT NULL PRIMARY KEY,
    "Name" varchar(200) NOT NULL
)
;
CREATE TABLE "arbk_legalentity" (
    "id" integer NOT NULL PRIMARY KEY,
    "Name" varchar(200) NOT NULL
)
;
CREATE TABLE "arbk_person" (
    "id" integer NOT NULL PRIMARY KEY,
    "PersonalID" varchar(40) NOT NULL,
    "Name" varchar(200) NOT NULL
)
;
drop TABLE "arbk_company_Owners";

CREATE TABLE "arbk_company_Owners" (
    "id" integer NOT NULL PRIMARY KEY,
    "company_id" integer NOT NULL REFERENCES "arbk_company" ("id"),
    "legalentity_id" integer NOT NULL REFERENCES "arbk_legalentity" ("id"),
    UNIQUE ("company_id", "legalentity_id")
)
;
drop TABLE "arbk_company_SecondaryCategories";

CREATE TABLE "arbk_company_SecondaryCategories" (
    "id" integer NOT NULL PRIMARY KEY,
    "company_id" integer NOT NULL REFERENCES "arbk_company" ("id"),
    "businesscategory_id" integer NOT NULL REFERENCES "arbk_businesscategory" ("id"),
    UNIQUE ("company_id", "businesscategory_id")
)
;
drop TABLE "arbk_company_AuthorizedPersons";

CREATE TABLE "arbk_company_AuthorizedPersons" (
    "id" integer NOT NULL PRIMARY KEY,
    "company_id" integer NOT NULL REFERENCES "arbk_company" ("id"),
    "person_id" integer NOT NULL REFERENCES "arbk_person" ("id"),
    UNIQUE ("company_id", "person_id")
)
;
CREATE TABLE "arbk_company" (
    "id" integer NOT NULL PRIMARY KEY,
    "Name" varchar(200) NOT NULL,
    "RegNumber" integer NOT NULL,
    "EmploysNumber" integer NOT NULL,
    "ConstitutionDate" integer NOT NULL,
    "Telephone" varchar(200) NOT NULL,
    "Capital" double NOT NULL,
    "AddressStreet" varchar(200) NOT NULL,
    "AddressStreetNumber" varchar(10) NOT NULL,
    "AddressCity" varchar(40) NOT NULL,
    "AddressPostCode" varchar(10) NOT NULL,
    "PrimaryCategory_id" integer NOT NULL REFERENCES "arbk_businesscategory" ("id")
)
;
CREATE TABLE "arbk_companycategory" (
    "id" integer NOT NULL PRIMARY KEY,
    "Category_id" integer NOT NULL REFERENCES "arbk_businesscategory" ("id")
)
;

create unique index arbk_company_reg on arbk_company (RegNumber);

COMMIT;