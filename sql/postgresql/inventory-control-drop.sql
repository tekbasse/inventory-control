-- inventory-control-drop.sql
--
-- @author Benjamin Brink
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
--


drop table qci_announcements;

drop index qci_ec_product_links_map_idx;

drop table qci_ec_product_links_map;

drop index qci_ec_sale_prices_by_product_idx;

drop table qci_ec_sale_prices;


drop index qci_ec_product_purchase_comb_idx4;
drop index qci_ec_product_purchase_comb_idx3;
drop index qci_ec_product_purchase_comb_idx2;
drop index qci_ec_product_purchase_comb_idx1;
drop index qci_ec_product_purchase_comb_idx0;

drop table qci_ec_product_purchase_comb;

drop index qci_partstax_parts_id_idx;

DROP TABLE qci_partstax;


DROP TABLE qci_partscustomer;


drop index qci_pricegroup_id_idx;
drop index qci_pricegroup_pricegroup_idx;


DROP TABLE qci_pricegroup;

drop index qci_partsgroup_idx;
drop index qci_partsgroup_id_idx;

DROP TABLE qci_partsgroup;




DROP TABLE qci_inventory;

DROP TABLE qci_warehouse;

drop index qci_series_model_idx;
drop index qci_series_make_idx;
drop index qci_series_series_id_idx;

DROP TABLE qci_series;

drop table qci_product_series_map;


drop table qci_part_attributes_map;

drop table qci_attribute_choices;

drop table qci_attributes;

drop table qci_shipping_details;

drop index qci_parts_product_name_idx;
drop index qci_parts_sku_idx;
drop index qci_parts_id_idx;

drop table qci_parts;

drop sequence qci_id_seq;



