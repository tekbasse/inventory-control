-- inventory-control-drop.sql
--
-- @author Dekka Corp.
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id
--

drop trigger qci_ec_custom_p_f_values_audit_tr on qci_ec_custom_product_field_values;

drop function qci_ec_custom_p_f_values_audit_tr ();

drop table qci_ec_custom_p_field_values_audit;

drop table qci_ec_custom_product_field_values;

drop trigger qci_ec_custom_prod_fields_audit_tr on qci_ec_custom_product_fields;

drop function qci_ec_custom_prod_fields_audit_tr ();

drop table qci_ec_custom_product_fields_audit;

drop table qci_ec_custom_product_fields;




drop trigger qci_ec_product_links_audit_tr on qci_ec_product_links;

drop function qci_ec_product_links_audit_tr ();

drop table qci_ec_product_links_audit ();

drop index qci_ec_product_links_idx on qci_ec_product_links ();

drop table qci_ec_product_links ();



drop trigger qci_ec_product_u_c_prices_audit_tr on qci_ec_product_user_class_prices;

drop function qci_ec_product_u_c_prices_audit_tr ();

drop table qci_ec_product_u_c_prices_audit ();

drop index qci_ec_product_user_class_idx on qci_ec_product_user_class_prices();

drop table qci_ec_product_user_class_prices ();


drop trigger qci_ec_product_series_map_audit_tr on qci_ec_product_series_map;

drop function qci_ec_product_series_map_audit_tr ();


drop table qci_ec_product_series_map_audit ();

drop index qci_ec_product_series_map_idx2 on qci_ec_product_series_map();

drop table qci_ec_product_series_map ();


drop trigger qci_ec_sale_prices_audit_tr on qci_ec_sale_prices;

drop function qci_ec_sale_prices_audit_tr ();


drop table qci_ec_sale_prices_audit;


drop view qci_ec_sale_prices_current;

drop index qci_ec_sale_prices_by_product_idx on qci_ec_sale_prices();

drop table qci_ec_sale_prices;

drop view qci_ec_sale_price_id_sequence;
drop sequence qci_ec_sale_price_id_seq;

drop index qci_ec_product_purchase_comb_idx4 on qci_ec_product_purchase_comb();
drop index qci_ec_product_purchase_comb_idx3 on qci_ec_product_purchase_comb();
drop index qci_ec_product_purchase_comb_idx2 on qci_ec_product_purchase_comb();
drop index qci_ec_product_purchase_comb_idx1 on qci_ec_product_purchase_comb();
drop index qci_ec_product_purchase_comb_idx0 on qci_ec_product_purchase_comb();

drop table qci_ec_product_purchase_comb ();

drop trigger qci_ec_products_audit_tr on qci_ec_products;

drop function qci_ec_products_audit_tr ();

drop table qci_ec_products_audit ();

drop view qci_ec_products_searchable;

drop view qci_ec_products_displayable;

drop table qci_ec_products();



drop function qci_timespan_days();

drop function qci_least();

DROP TRIGGER qci_check_inventory ON qar_oe;



DROP FUNCTION qci_check_inventory();


DROP TABLE qci_inventory;


DROP TABLE qci_warehouse;


DROP TABLE qci_makemodel;


