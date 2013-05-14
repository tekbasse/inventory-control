-- inventory-control-create.sql
--
-- @author Benjamin Brink
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
--

-- following from SL

CREATE TABLE qci_warehouse (
-- TODO: associate the warehouse with a contacts record
  id integer default nextval('id'),
  description text
);


CREATE TABLE qci_inventory (
  warehouse_id integer,
  parts_id integer,
  trans_id integer,
  orderitems_id integer,
  qty numeric,
  -- was shippingdate date,
  shipping_time,
  employee_id integer
);


--  following from ecommerce package

-- This table contains the products and also the product series.
-- A product series has the same fields as a product (it actually
-- *is* a product, since it's for sale, has its own price, etc.).
-- The only difference is that it has other products associated
-- with it (that are part of it).  So information about the
-- whole series is kept in this table and the product_series_map
-- table keeps track of which products are inside each series.

CREATE TABLE qci_series (
       id integer,
       label varchar(30)
       title varchar(120),
       description text
);

CREATE TABLE qci_product_series_map (
    series_id integer,
    product_id integer
);



-- people who bought product_id also bought products 0 through
-- 4, where product_0 is the most frequently purchased, 1 is next,
-- etc.
create table qci_ec_product_purchase_comb (
        product_id      integer not null,
        product_0       integer ,
        product_1       integer ,
        product_2       integer ,
        product_3       integer ,
        product_4       integer 
);

create index qci_ec_product_purchase_comb_idx0 on qci_ec_product_purchase_comb(product_0);
create index qci_ec_product_purchase_comb_idx1 on qci_ec_product_purchase_comb(product_1);
create index qci_ec_product_purchase_comb_idx2 on qci_ec_product_purchase_comb(product_2);
create index qci_ec_product_purchase_comb_idx3 on qci_ec_product_purchase_comb(product_3);
create index qci_ec_product_purchase_comb_idx4 on qci_ec_product_purchase_comb(product_4);

create sequence qci_ec_sale_price_id_seq start 1;
select nextval('qci_ec_sale_price_id_seq') as nextval;

create table qci_ec_sale_prices (
        sale_price_id           integer not null,
        product_id              integer not null,
        sale_price              numeric,
        sale_begins             timestamptz not null,
        sale_ends               timestamptz not null,
        -- like Introductory Price or Sale Price or Special Offer
        sale_name               varchar(30),
        -- if non-null, the user has to know this code to get the sale price
        offer_code              varchar(20),
	trashed_p               varchar(1),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null,
        modified_ip_address     varchar(20) not null
);

create index qci_ec_sale_prices_by_product_idx on qci_ec_sale_prices(product_id);



-- this specifies that product_a links to product_b on the display page for product_a
create table qci_ec_product_links_map (
        product_a               integer not null,
        product_b               integer not null,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null,
        modified_ip_address     varchar(20) not null,
);

create index qci_ec_product_links_idx on qci_ec_product_links (product_a);


