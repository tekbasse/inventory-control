-- inventory-control-create.sql
--
-- @author Benjamin Brink
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
--

create sequence qci_id_seq start 1;
select nextval('qci_id_seq') as nextval;

create table qci_parts (
    id integer default nextval ('qci_id_seq'),
    -- was parts.number
    sku   varchar(100),
    -- was parts.description
    product_name  varchar(200),
    one_line_description    varchar(400),
    detailed_description    varchar(4000),

    creation_date           timestamptz default current_timestamp,
    -- the date the product becomes available for sale (it can be listed
    -- before then, it's just not buyable)
    available_date          timestamptz,

    -- whether this item should show up in searches (e.g., if it's
    -- a volume of a series, you might not want it to)
    present_p               varchar(1) default '1',
    search_keywords         varchar(4000),

    unit varchar(5),
    -- manufactured list price
    listprice numeric,
    -- same as ec_products.price
    sellprice numeric,
    lastcost numeric,

    -- changing parts.makemodel to series for consistency with qci_series
    series varchar(1) DEFAULT '0',
    assembly varchar(1) DEFAULT '0',
    -- instead of stating 'alternate' would an  alternate map make more sense?
    alternate varchar(1) DEFAULT '0',

    onhand numeric DEFAULT '0',
    -- rop is Re-Order Point
    rop numeric,
    bin varchar(300),
    obsolete varchar(1) DEFAULT '0',
    -- apparently bom here is true when item is an assembly
    -- TODO determine if assembly can include a service in SL
    bom varchar(1) DEFAULT '0',

    avgcost numeric,

    -- these are defaults used for accounts-ledger transactions
    inventory_accno_id integer,
    income_accno_id integer,
    expense_accno_id integer,
    -- these are for external referencing
    image varchar(4000),
    drawing varchar(4000),
    microfiche varchar(4000),
    notes text, 
    -- Categories references
    partsgroup_id integer,
    project_id integer,

    -- from ec_products.dirname, a local dir that holds pictures, sample chapters, etc.
    -- dirname                 varchar(200),
    product_dir varchar(300),
    -- if there's a web page with more info about the product
    url                     varchar(300),
    display_template_id      integer,
    -- generally something that only affects
    -- how the item is configured, ie all configurations represent
    -- same price, sku, other specifications same
    use_attributes_map_p  varchar(1) default '0',
    -- notify via email this list of emails when item purchased
    email_on_purchase_list  varchar(4000),

    -- the user ID and IP address of the creator of the product
    -- priceupdate date DEFAULT current_date, becomes last_modified
    last_modified           timestamptz not null,
    last_modifying_user     integer not null,
    modified_ip_address     varchar(20) not null    
);

create index qci_parts_id_idx on qci_parts (id);
create index qci_parts_sku_idx on qci_parts (sku);
create index qci_parts_product_name_idx on qci_parts (product_name);

create table qci_shipping_details (
   part_id integer,
    -- based on ec_products.ship_status
    -- the useage is split to qci_parts.order_turnaround and qci_parts.onhand
    -- q = ships quickly, m = ships moderately quickly, s = ships slowly
    -- o = special, i = inconsistent/unknown/ask
    -- These codes should be expanded for a range of common cases
    -- messages are changeable
    -- ec_products.ship_status was char(1) check (ships in ('o','q','m','s','i')),
    order_turnaround            char(1) default 'i',

    -- was no_shipping_avail_p     boolean default 'f',
    shippable_p varchar(1) default '1',
    -- leave this blank if shipping is calculated using
    -- one of the more complicated methods available
    weight numeric,
    shipping_wt_one                numeric,
    -- fill this in if shipping is calculated by: above price
    -- for first item (with this product_id), and the below
    -- price for additional items (with this product_id)
    shipping_wt_multiple     numeric,
    -- fill this in if shipping is calculated using weight
    -- use whatever units you want (lbs/kg), just be consistent
    -- and make your shipping algorithm take the units into
    -- account
    shipping_vol_one numeric,
    shipping_volume_additional numeric,
    downloadable_p varchar(1) default '0'
    
);

create table qci_attributes (
  id integer,
  -- choices are pick one etc. to be defined in api
  input_mode varchar(1),
  label varchar(40),
  description varchar(120),
  notes_publishable text,
  notes_internal text
);

create table qci_attribute_choices (
  choice_id integer,
  label varchar(40),
  description varchar(120)
);

create table qci_part_attributes_map (
  attribute_id integer,
  choice_id integer
);



-- following from ecommerce
-- This table contains the products and also the product series.
-- A product series has the same fields as a product (it actually
-- *is* a product, since it's for sale, has its own price, etc.).
-- The only difference is that it has other products associated
-- with it (that are part of it).  So information about the
-- whole series is kept in this table and the product_series_map
-- table keeps track of which products are inside each series.


create table qci_product_series_map (
    -- a series (was product_id)
    -- changed to series because an assembly has component parts
    -- but a series is a set of similar products
     series_id               integer not null,

    -- this is the product_id of a product that is one of the
    -- items of the above series
     product_id            integer not null,
     last_modified           timestamptz not null,
     last_modifying_user     integer not null ,
     modified_ip_address     varchar(20) not null
);


-- SL makemodel references parts_id, we have qci_product_series_map
-- and use qci_series for tracking series data
CREATE TABLE qci_series (
  series_id integer,
  make varchar(300),
  model varchar(300)
);

create index qci_series_series_id_idx on qci_series (series_id);
create index qci_series_make_idx on qci_series (make);
create index qci_series_model_idx on qci_series (model);


CREATE TABLE qci_warehouse (
-- TODO: associate the warehouse with a contacts record
  id integer default nextval('qci_id_seq'),
  label varchar(40),
  description varchar(300)
);


CREATE TABLE qci_inventory (
  warehouse_id integer,
  parts_id integer,
  trans_id integer,
  orderitems_id integer,
  qty numeric,
  -- was shippingdate date,
  shipping_time timestamptz,
  employee_id integer
);

--  EXTRAS -- 

CREATE TABLE qci_partsgroup (
  id integer default nextval('qci_id_seq'),
  partsgroup varchar(300)
);

create index qci_partsgroup_id_idx on qci_partsgroup (id);
create index qci_partsgroup_idx on qci_partsgroup (partsgroup);

CREATE TABLE qci_pricegroup (
  id integer default nextval('qci_id_seq'),
  pricegroup varchar(300)
);


create index qci_pricegroup_pricegroup_idx on qci_pricegroup (pricegroup);
create index qci_pricegroup_id_idx on qci_pricegroup (id);


CREATE TABLE qci_partscustomer (
  parts_id integer,
  customer_id integer,
  pricegroup_id integer,
  pricebreak numeric,
  sellprice numeric,
  validfrom date,
  validto date,
  curr char(6)
);


CREATE TABLE qci_partstax (
  parts_id integer,
  chart_id integer
);

create index qci_partstax_parts_id_idx on qci_partstax (parts_id);



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
        modified_ip_address     varchar(20) not null
);

create index qci_ec_product_links_map_idx on qci_ec_product_links_map (product_a);

-- handy announcements associate with sku, series etc.
create table qci_announcements (
    id varchar(120), 
    publish_p varchar(1),   
    announcement           varchar(4000),
    expiration    timestamptz,
    trashed_p varchar(1)
);

