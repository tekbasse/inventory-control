-- catalog-create.sql
--
-- @authors
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
--
--

    creation_date           timestamptz default current_timestamp not null,
    one_line_description    varchar(400),
    detailed_description    varchar(4000),
    search_keywords         varchar(4000),
    unit varchar(5),

    -- manufactured list price
    listprice numeric,

    -- same as ec_products.price
    sellprice numeric,

    lastcost numeric,

    -- based on ec_products.ship_status
    -- the useage is split to qci_parts.order_turnaround and qci_parts.onhand
    -- q = ships quickly, m = ships moderately quickly, s = ships slowly
    -- o = special, i = inconsistent/unknown/ask
    -- messages are changeable
    -- ec_products.ship_status was char(1) check (ships in ('o','q','m','s','i')),
    order_turnaround            char(1) default 'i',

    -- no_shipping_avail_p     boolean default 'f',
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

    onhand numeric DEFAULT '0',

    notes text,

    -- changing parts.makemodel to series for consistency with qci_series
    series boolean DEFAULT 'f',
    assembly boolean DEFAULT 'f',
    alternate boolean DEFAULT 'f',

    -- rop is Re-Order Point
    rop numeric,

    -- these are used if accounts-ledger is loaded
    inventory_accno_id integer,
    income_accno_id integer,
    expense_accno_id integer,

    bin text,

    obsolete boolean DEFAULT 'f',

    -- apparently bom here is true when item is an assembly
    -- TODO determine if assembly can include a service in SL
    bom boolean DEFAULT 'f',

    -- these are for external referencing
    -- changing from text to varchar(4000) so values can be indexed for search pkg
    image varchar(4000),
    drawing varchar(4000),
    microfiche varchar(4000),

    -- partsgroup_id is a categories reference
    partsgroup_id integer,


    project_id integer,

    avgcost numeric,

    -- from ec_products.dirname, a local dir that holds pictures, sample chapters, etc.
    -- dirname                 varchar(200),
    product_dir varchar(300),

    -- whether this item should show up in searches (e.g., if it's
    -- a volume of a series, you might not want it to)

    present_p               boolean default 't',

    -- whether the item should show up at all in the user pages
    -- ec_products.active_p                boolean default 't',
    -- see obsolete, with reverse meaning

    -- the date the product becomes available for sale (it can be listed
    -- before then, it's just not buyable)
    available_date          timestamptz default current_timestamp not null,

    announcements           varchar(4000),
    announcements_expire    timestamptz,

    -- if there's a web page with more info about the product
    url                     varchar(300),
    template_id             integer references ecca_ec_templates,


    -- a tcl represented list of lists, indicating parameters for
    -- users to choose upon ordering.. generally something that only affects
    -- how the item is configured, ie all configurations represent
    -- same item, price, specifications
    parameters_list              varchar(4000),
    variations_list              varchar(4000),

    -- notify via email this list of emails when item purchased
    email_on_purchase_list  varchar(4000),

    -- the user ID and IP address of the creator of the product
    -- priceupdate date DEFAULT current_date,
    -- becomes last_modified
    last_modified           timestamptz not null,
    last_modifying_user     integer not null references users,
    modified_ip_address     varchar(20) not null    

);


CREATE TABLE qci_partsgroup (
  id integer default nextval('id'),
  partsgroup text
);

create index qci_partsgroup_id_key on qci_partsgroup (id);
create index qci_partsgroup_key on qci_partsgroup (partsgroup);



CREATE TABLE qci_pricegroup (
  id integer default nextval('id'),
  pricegroup text
);

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
  parts_id integer
  chart_id integer
);


create index qci_parts_id_key on qci_parts (id);
create index qci_parts_partnumber_key on qci_parts (lower(partnumber));
create index qci_parts_description_key on qci_parts (lower(description));
create index qci_partstax_parts_id_key on qci_partstax (parts_id);


create index qci_partsvendor_vendor_id_key on qci_partsvendor (vendor_id);
create index qci_partsvendor_parts_id_key on qci_partsvendor (parts_id);

create index qci_pricegroup_pricegroup_key on qci_pricegroup (pricegroup);
create index qci_pricegroup_id_key on qci_pricegroup (id);


-- following from ecommerce

create table qci_product_series_map (
    -- a series (was product_id)
    -- changed to series because an assembly has component parts
    -- but a series is a set of similar products
     series_id               integer not null,

    -- this is the product_id of a product that is one of the
    -- items of the above series
     product_id            integer not null,
     last_modified           timestamptz not null,
     last_modifying_user     integer not null references users,
     modified_ip_address     varchar(20) not null
);


-- SL makemodel references parts_id, we have qci_product_series_map
-- and use qci_series for tracking series data
CREATE TABLE qci_series (
  series_id integer,
  make varchar(300),
  model varchar(300)
);

create index qci_makemodel_parts_id_key on qci_makemodel (parts_id);
create index qci_makemodel_make_key on qci_makemodel (lower(make));
create index qci_makemodel_model_key on qci_makemodel (lower(model));
