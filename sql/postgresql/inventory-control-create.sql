-- inventory-control-create.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--

-- following from SL

CREATE TABLE qci_warehouse (
-- TODO: associate the warehouse with a contacts record
  id int default nextval('id'),
  description text
);


CREATE TABLE qci_inventory (
  warehouse_id int,
  parts_id int,
  trans_id int,
  orderitems_id int,
  qty float4,
  shippingdate date,
-- following for auditing
  employee_id int
);


--  following from ecommerce package
-- TODO move products db into CR

-- This table contains the products and also the product series.
-- A product series has the same fields as a product (it actually
-- *is* a product, since it's for sale, has its own price, etc.).
-- The only difference is that it has other products associated
-- with it (that are part of it).  So information about the
-- whole series is kept in this table and the product_series_map
-- table below keeps track of which products are inside each
-- series. 

-- wtem@olywa.net, 2001-03-24
-- begin  
--        acs_object_type__create_type ( 
--              supertype     => 'acs_object', 
--              object_type   => 'ec_product', 
--              pretty_name   => 'Product', 
--              pretty_plural => 'Products', 
--              table_name    => 'EC_PRODUCTS', 
--              id_column     => 'PRODUCT_ID',
-- 	     package_name  => 'ECOMMERCE'
--        ); 
-- end;
-- /
-- show errors;

create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__create_type (
    ''ec_product'',
    ''Product'',
    ''Products'',
    ''acs_object'',
    ''ec_products'',
    ''product_id'',
    ''ecommerce'',
    ''f'',
    null,
    null
   );

  return 0;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();





-- people who bought product_id also bought products 0 through
-- 4, where product_0 is the most frequently purchased, 1 is next,
-- etc.
create table qci_ec_product_purchase_comb (
        product_id      integer not null primary key references qci_ec_products,
        product_0       integer references qci_ec_products,
        product_1       integer references qci_ec_products,
        product_2       integer references qci_ec_products,
        product_3       integer references qci_ec_products,
        product_4       integer references qci_ec_products
);

create index qci_ec_product_purchase_comb_idx0 on qci_ec_product_purchase_comb(product_0);
create index qci_ec_product_purchase_comb_idx1 on qci_ec_product_purchase_comb(product_1);
create index qci_ec_product_purchase_comb_idx2 on qci_ec_product_purchase_comb(product_2);
create index qci_ec_product_purchase_comb_idx3 on qci_ec_product_purchase_comb(product_3);
create index qci_ec_product_purchase_comb_idx4 on qci_ec_product_purchase_comb(product_4);

create sequence qci_ec_sale_price_id_seq start 1;
create view qci_ec_sale_price_id_sequence as select nextval('qci_ec_sale_price_id_seq') as nextval;

create table qci_ec_sale_prices (
        sale_price_id           integer not null primary key,
        product_id              integer not null references qci_ec_products,
        sale_price              numeric,
        sale_begins             timestamptz not null,
        sale_ends               timestamptz not null,
        -- like Introductory Price or Sale Price or Special Offer
        sale_name               varchar(30),
        -- if non-null, the user has to know this code to get the sale price
        offer_code              varchar(20),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index qci_ec_sale_prices_by_product_idx on qci_ec_sale_prices(product_id);

create view qci_ec_sale_prices_current
as
select * from qci_ec_sale_prices
where now() >= sale_begins
and now() <= sale_ends;


create table qci_ec_sale_prices_audit (
        sale_price_id           integer,
        product_id              integer,
        sale_price              numeric,
        sale_begins             timestamptz,
        sale_ends               timestamptz,
        sale_name               varchar(30),
        offer_code              varchar(20),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


create function qci_ec_sale_prices_audit_tr ()
returns opaque as '
begin
        insert into qci_ec_sale_prices_audit (
        sale_price_id, product_id, sale_price,
        sale_begins, sale_ends, sale_name, offer_code,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.sale_price_id, old.product_id, old.sale_price,
        old.sale_begins, old.sale_ends, old.sale_name, old.offer_code,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger qci_ec_sale_prices_audit_tr
after update or delete on qci_ec_sale_prices
for each row execute procedure qci_ec_sale_prices_audit_tr ();


-- this specifies that product_a links to product_b on the display page for product_a
create table qci_ec_product_links (
        product_a               integer not null references qci_ec_products,
        product_b               integer not null references qci_ec_products,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_a, product_b)
);

create index qci_ec_product_links_idx on qci_ec_product_links (product_b);

create table qci_ec_product_links_audit (
        product_a               integer,
        product_b               integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function qci_ec_product_links_audit_tr ()
returns opaque as '
begin
        insert into qci_ec_product_links_audit (
        product_a, product_b,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_a, old.product_b,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger qci_ec_product_links_audit_tr
after update or delete on qci_ec_product_links
for each row execute procedure qci_ec_product_links_audit_tr ();



-- I could in theory make some hairy system that lets them specify
-- what kind of form element each field will have, does 
-- error checking, etc., but I don't think it's necessary since it's 
-- just the site administrator using it.  So here's a very simple
-- table to store the custom product fields:
create table qci_ec_custom_product_fields (
        field_identifier        varchar(100) not null primary key,
        field_name              varchar(100),
        default_value           varchar(100),
        -- column type for oracle (i.e. text, varchar(50), integer, ...)
        column_type             varchar(100),
        creation_date           timestamptz,
        active_p                boolean default 't',
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table qci_ec_custom_product_fields_audit (
        field_identifier        varchar(100),
        field_name              varchar(100),
        default_value           varchar(100),
        column_type             varchar(100),
        creation_date           timestamptz,
        active_p                boolean default 't',
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function qci_ec_custom_prod_fields_audit_tr ()
returns opaque as '
begin
        insert into qci_ec_custom_product_fields_audit (
        field_identifier, field_name,
        default_value, column_type,
        creation_date, active_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.field_identifier, old.field_name,
        old.default_value, old.column_type,
        old.creation_date, old.active_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger qci_ec_custom_prod_fields_audit_tr
after update or delete on qci_ec_custom_product_fields
for each row execute procedure qci_ec_custom_prod_fields_audit_tr ();

-- more columns are added to this table (by Tcl scripts) when the 
-- administrator adds custom product fields
-- the columns in this table have the name of the field_identifiers
-- in qci_ec_custom_product_fields
-- this table stores the values
create table qci_ec_custom_product_field_values (
        product_id              integer not null primary key references qci_ec_products,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table qci_ec_custom_p_field_values_audit (
        product_id              integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function qci_ec_custom_p_f_values_audit_tr ()
returns opaque as '
begin
        insert into qci_ec_custom_p_field_values_audit (
        product_id,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger qci_ec_custom_p_f_values_audit_tr
after update or delete on qci_ec_custom_product_field_values
for each row execute procedure qci_ec_custom_p_f_values_audit_tr();

   
   
