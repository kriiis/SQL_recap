use magist;

select * from product_category_name_translation
where product_category_name_english like 'health%' or product_category_name_english like 'perfumery';
# category_names: beleza_saude and perfumaria

#Select all the products from the health_beauty or perfumery categories that
#have been paid by credit card with a payment amount of more than 1000$,
#from orders that were purchased during 2018 and have a ‘delivered’ status?

create temporary table selected_orders
select op.order_id, o.customer_id from order_payments op
join orders o on op.order_id = o.order_id
where op.payment_type = 'credit_card'
and op.payment_value > 1000
and o.order_status = 'delivered'
and extract(year from o.order_purchase_timestamp) = 2018;

create temporary table ordered_products
select selected_orders.order_id, selected_orders.customer_id,p.product_id, p.product_category_name, p.product_weight_g, oi.seller_id from selected_orders
join order_items oi on selected_orders.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where p.product_category_name = 'beleza_saude' or p.product_category_name = 'perfumaria';

#For the products that you selected, get the following information:

#The average weight of those products
select avg(product_weight_g) from ordered_products;
#5180.4833g - about 5,2 kg

#The cities where there are sellers that sell those products
select distinct city from ordered_products
join sellers s on ordered_products.seller_id = s.seller_id
join geo on s.seller_zip_code_prefix = geo.zip_code_prefix;
# teresopolis, 
#curitiba
#são paulo
#campinas
#bombinhas
#niteroi
#indaial
#sao bernardo do campo
#piracicaba

#The cities where there are customers who bought products
select distinct city from ordered_products
join customers c on ordered_products.customer_id = c.customer_id
join geo on c.customer_zip_code_prefix = geo.zip_code_prefix;
# sao paulo,vicosa,rio de janeiro,campo grande,belem,botucatu,campinas,belo horizonte,cachoeiro de itapemirim,costa marques,
#ji-parana,bonfinopolis de minas,parnamirim,guarapuava,sao joao do piaui,picos,divinopolis,americo brasiliense,fortaleza,santana do jacare
#brasilia,feira de santana,palmas,juiz de fora,coari,lages,uberaba,tapiramuta,tres lagoas,colider,ribeirao preto,guaratingueta,natal,guarani
 
drop temporary table selected_products;
drop temporary table ordered_products;