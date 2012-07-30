-- catalog-create.sql
--
-- @authors
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--
--

-- The ecommerce.ec_products table is meshed into qci_parts here
-- because SL will be doing the most work with it.
-- accounts-receivables qar_ec_products will be a thin version 
-- for the shopping basket

-- TODO convert qci_parts to use CR

CREATE TABLE qci_parts (
    -- was id int DEFAULT nextval ( 'id' ), now
    id              integer constraint qci_ec_products_product_id_fk
                               references acs_objects(object_id)
                               on delete cascade
                               constraint qci_ec_products_product_id_pk
                               primary key,

    -- was parts.partnumber 
    sku                     varchar(100),

    -- was parts.description, 
    product_name            varchar(200),

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

    -- based on ec_products.ship_satus
    -- the useage is split to qci_parts.order_turnaround and qci_parts.onhand
    -- q = ships quickly, m = ships moderately quickly, s = ships slowly
    -- o = special, i = inconsistent/unknown/ask
    -- messages are changeable
    -- ec_products.ship_status was char(1) check (ships in ('o','q','m','s','i')),
    order_turnaround            char(1) default 'i',

    no_shipping_avail_p     boolean default 'f',
    -- leave this blank if shipping is calculated using
    -- one of the more complicated methods available
    shipping                numeric,
    -- fill this in if shipping is calculated by: above price
    -- for first item (with this product_id), and the below
    -- price for additional items (with this product_id)
    shipping_additional     numeric,
    -- fill this in if shipping is calculated using weight
    -- use whatever units you want (lbs/kg), just be consistent
    -- and make your shipping algorithm take the units into
    -- account

    weight numeric,
    onhand numeric DEFAULT 0,

    notes varchar(4000),

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

    -- TODO change partsgroup_id to use categories
    partsgroup_id integer,

    -- TODO project_id to optionally reference existing project-manager or logger id
    project_id integer,

    avgcost numeric,

    -- from ec_products.dirname, holds pictures, sample chapters, etc.
    dirname                 varchar(200),

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

    -- if there's a web site with more info about the product
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
create unique index qci_partsgroup_key on qci_partsgroup (partsgroup);



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
  validfrom date,0
  validto date,
  curr char(3)
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

-- we aren't going to bother to define all the attributes of an ec_product type
-- for now, because we are just using it for site-wide-search anyway
-- we have a corresponding pl/sql package for the ec_product object_type
-- it can be found at ecommerce/sql/ec-product-package-create.
-- and is called at the end of this script
create table qci_ec_products (
     product_id              integer constraint qci_ec_products_product_id_fk
                             references acs_objects(object_id)
                             on delete cascade
                             constraint qci_ec_products_product_id_pk
                             primary key,
    -- above changed by wtem@olywa.net, 2001-03-24
                             -- integer not null primary key,
     sku                     varchar(100),
     product_name            varchar(200),
     creation_date           timestamptz default current_timestamp not null,
     one_line_description    varchar(400),
     detailed_description    varchar(4000),
     search_keywords         varchar(4000),
    -- this is the regular price for the product.  If user
    -- classes are charged a different price, it should be
    -- specified in qci_ec_product_user_class_prices
     price                   numeric, 
    -- for stuff that can't be shipped like services
     no_shipping_avail_p     boolean default 'f',
    -- leave this blank if shipping is calculated using
    -- one of the more complicated methods available
     shipping                numeric,
    -- fill this in if shipping is calculated by: above price
    -- for first item (with this product_id), and the below
    -- price for additional items (with this product_id)
     shipping_additional     numeric,
    -- fill this in if shipping is calculated using weight
    -- use whatever units you want (lbs/kg), just be consistent
    -- and make your shipping algorithm take the units into
    -- account
     weight                  numeric,
    -- holds pictures, sample chapters, etc.
     dirname                 varchar(200),
    -- whether this item should show up in searches (e.g., if it's
    -- a volume of a series, you might not want it to)
     present_p               boolean default 't',
    -- whether the item should show up at all in the user pages
     active_p                boolean default 't',
    -- the date the product becomes available for sale (it can be listed
    -- before then, it's just not buyable)
     available_date          timestamptz default current_timestamp not null,
     announcements           varchar(4000),
     announcements_expire    timestamptz,
    -- if there's a web site with more info about the product
     url                     varchar(300),
     template_id             integer references ecca_ec_templates,
    -- o = out of stock, q = ships quickly, m = ships
    -- moderately quickly, s = ships slowly, i = in stock
    -- with no message about the speed of the shipment (shipping
    -- messages are in parameters .ini file)
     stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
    -- comma-separated lists of available colors, sizes, and styles for the user
    -- to choose upon ordering
     color_list              varchar(4000),
     size_list               varchar(4000),
     style_list              varchar(4000),
    -- email this list on purchase
     email_on_purchase_list  varchar(4000),
    -- the user ID and IP address of the creator of the product
     last_modified           timestamptz not null,
     last_modifying_user     integer not null references users,
     modified_ip_address     varchar(20) not null    
);

create view qci_ec_products_displayable
as
select * from qci_ec_products
where active_p='t';

create view qci_ec_products_searchable
as
select * from qci_ec_products
where active_p='t' and present_p='t';

create table qci_ec_products_audit (
     product_id              integer,
     product_name            varchar(200),
     creation_date           timestamptz,
     one_line_description    varchar(400),
     detailed_description    varchar(4000),
     search_keywords         varchar(4000),
     price                   numeric,
     shipping                numeric,
     shipping_additional     numeric,
     weight                  numeric,
     dirname                 varchar(200),
     present_p               boolean default 't',
     active_p                boolean default 't',
     available_date          timestamptz,
     announcements           varchar(4000),
     announcements_expire    timestamptz,
     url                     varchar(300),
     template_id             integer,
     stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
     last_modified           timestamptz,
     last_modifying_user     integer,
     modified_ip_address     varchar(20),
     delete_p                boolean default 'f'
);

create function qci_ec_products_audit_tr ()
returns opaque as '
begin
     insert into qci_ec_products_audit (
     product_id, product_name, creation_date,
     one_line_description, detailed_description,
     search_keywords, shipping,
     shipping_additional, weight,
     dirname, present_p,
     active_p, available_date,
     announcements, announcements_expire, 
     url, template_id,
     stock_status,
     last_modified,
     last_modifying_user, modified_ip_address
     ) values (
     old.product_id, old.product_name, old.creation_date,
     old.one_line_description, old.detailed_description,
     old.search_keywords, old.shipping,
     old.shipping_additional, old.weight,
     old.dirname, old.present_p,
     old.active_p, old.available_date,
     old.announcements, old.announcements_expire, 
     old.url, old.template_id,
     old.stock_status,
     old.last_modified,
     old.last_modifying_user, old.modified_ip_address
     );
     return new;
end;' language 'plpgsql';

create trigger qci_ec_products_audit_tr
after update or delete on qci_ec_products
for each row execute procedure qci_ec_products_audit_tr ();

-- ec_product_series_map was not fully implemented, so am
-- taking the liberty to change it to fit its name
create table qci_product_series_map (
    -- a series (was product_id)
    -- changed to series because an assembly has component parts
    -- but a series is a set of similar products
     series_id               integer not null references qci_series,

    -- this is the product_id of a product that is one of the
    -- components of the above series
     product_id            integer not null references qci_ec_products,
     primary key (series_id, component_id),
     last_modified           timestamptz not null,
     last_modifying_user     integer not null references users,
     modified_ip_address     varchar(20) not null
);

create index qci_product_series_map_idx2 on qci_product_series_map(component_id);

create table qci_product_series_map_audit (
     series_id               integer,
     product_id            integer,
     last_modified           timestamptz,
     last_modifying_user     integer,
     modified_ip_address     varchar(20),
     delete_p                boolean default 'f'
);


create function qci_product_series_map_audit_tr ()
returns opaque as '
begin
     insert into qci_product_series_map_audit (
     series_id, product_id,
     last_modified,
     last_modifying_user, modified_ip_address
     ) values (
     old.series_id, old.product_id,
     old.last_modified,
     old.last_modifying_user, old.modified_ip_address      
     );
     return new;
end;' language 'plpgsql';

create trigger qci_product_series_map_audit_tr
after update or delete on qci_product_series_map
for each row execute procedure qci_product_series_map_audit_tr ();


-- SL makemodel references parts_id, we have qci_product_series_map
-- and use qci_series for tracking series data
CREATE TABLE qci_series (
  series_id integer,
  make text,
  model text
);

create index qci_makemodel_parts_id_key on qci_makemodel (parts_id);
create index qci_makemodel_make_key on qci_makemodel (lower(make));
create index qci_makemodel_model_key on qci_makemodel (lower(model));
