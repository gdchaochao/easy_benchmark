
-- query02
with wscs as
 (select sold_date_sk
        ,sales_price
  from  (select ws_sold_date_sk sold_date_sk
              ,ws_ext_sales_price sales_price
        from web_sales
        union all
        select cs_sold_date_sk sold_date_sk
              ,cs_ext_sales_price sales_price
        from catalog_sales) a),
 wswscs as
 (select d_week_seq,
        sum(case when (d_day_name='Sunday') then sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then sales_price else null end) sat_sales
 from wscs
     ,date_dim
 where d_date_sk = sold_date_sk
 group by d_week_seq)
 select d_week_seq1
       ,round(sun_sales1/sun_sales2,2)
       ,round(mon_sales1/mon_sales2,2)
       ,round(tue_sales1/tue_sales2,2)
       ,round(wed_sales1/wed_sales2,2)
       ,round(thu_sales1/thu_sales2,2)
       ,round(fri_sales1/fri_sales2,2)
       ,round(sat_sales1/sat_sales2,2)
 from
 (select wswscs.d_week_seq d_week_seq1
        ,sun_sales sun_sales1
        ,mon_sales mon_sales1
        ,tue_sales tue_sales1
        ,wed_sales wed_sales1
        ,thu_sales thu_sales1
        ,fri_sales fri_sales1
        ,sat_sales sat_sales1
  from wswscs,date_dim
  where date_dim.d_week_seq = wswscs.d_week_seq and
        d_year = 2001) y,
 (select wswscs.d_week_seq d_week_seq2
        ,sun_sales sun_sales2
        ,mon_sales mon_sales2
        ,tue_sales tue_sales2
        ,wed_sales wed_sales2
        ,thu_sales thu_sales2
        ,fri_sales fri_sales2
        ,sat_sales sat_sales2
  from wswscs
      ,date_dim
  where date_dim.d_week_seq = wswscs.d_week_seq and
        d_year = 2001+1) z
 where d_week_seq1=d_week_seq2-53
 order by d_week_seq1;

-- query03
select  dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,sum(ss_ext_sales_price) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 436
   and dt.d_moy=12
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
 limit 100;

-- query04
select  dt.d_year 
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,sum(ss_ext_sales_price) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 436
   and dt.d_moy=12
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
 limit 100;

with year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(((ss_ext_list_price-ss_ext_wholesale_cost-ss_ext_discount_amt)+ss_ext_sales_price)/2) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((cs_ext_list_price-cs_ext_wholesale_cost-cs_ext_discount_amt)+cs_ext_sales_price)/2) ) year_total
       ,'c' sale_type
 from customer
     ,catalog_sales
     ,date_dim
 where c_customer_sk = cs_bill_customer_sk
   and cs_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum((((ws_ext_list_price-ws_ext_wholesale_cost-ws_ext_discount_amt)+ws_ext_sales_price)/2) ) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_email_address
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_c_firstyear
     ,year_total t_c_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
   and t_s_firstyear.customer_id = t_c_secyear.customer_id
   and t_s_firstyear.customer_id = t_c_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_firstyear.customer_id
   and t_s_firstyear.customer_id = t_w_secyear.customer_id
   and t_s_firstyear.sale_type = 's'
   and t_c_firstyear.sale_type = 'c'
   and t_w_firstyear.sale_type = 'w'
   and t_s_secyear.sale_type = 's'
   and t_c_secyear.sale_type = 'c'
   and t_w_secyear.sale_type = 'w'
   and t_s_firstyear.dyear =  2001
   and t_s_secyear.dyear = 2001+1
   and t_c_firstyear.dyear =  2001
   and t_c_secyear.dyear =  2001+1
   and t_w_firstyear.dyear = 2001
   and t_w_secyear.dyear = 2001+1
   and t_s_firstyear.year_total > 0
   and t_c_firstyear.year_total > 0
   and t_w_firstyear.year_total > 0
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
   and case when t_c_firstyear.year_total > 0 then t_c_secyear.year_total / t_c_firstyear.year_total else null end
           > case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_email_address
limit 100;

-- query05
with ssr as
 (select s_store_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ss_store_sk as store_sk,
            ss_sold_date_sk  as date_sk,
            ss_ext_sales_price as sales_price,
            ss_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from store_sales
    union all
    select sr_store_sk as store_sk,
           sr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           sr_return_amt as return_amt,
           sr_net_loss as net_loss
    from store_returns
   ) salesreturns,
     date_dim,
     store
 where date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and date_add('1998-08-04',14)
       and store_sk = s_store_sk
 group by s_store_id)
 ,
 csr as
 (select cp_catalog_page_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  cs_catalog_page_sk as page_sk,
            cs_sold_date_sk  as date_sk,
            cs_ext_sales_price as sales_price,
            cs_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from catalog_sales
    union all
    select cr_catalog_page_sk as page_sk,
           cr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           cr_return_amount as return_amt,
           cr_net_loss as net_loss
    from catalog_returns
   ) salesreturns,
     date_dim,
     catalog_page
 where date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and date_add('1998-08-04',14)
       and page_sk = cp_catalog_page_sk
       group by cp_catalog_page_id)
 ,
 wsr as
 (select web_site_id,
        sum(sales_price) as sales,
        sum(profit) as profit,
        sum(return_amt) as returns,
        sum(net_loss) as profit_loss
 from
  ( select  ws_web_site_sk as wsr_web_site_sk,
            ws_sold_date_sk  as date_sk,
            ws_ext_sales_price as sales_price,
            ws_net_profit as profit,
            cast(0 as decimal(7,2)) as return_amt,
            cast(0 as decimal(7,2)) as net_loss
    from web_sales
    union all
    select ws_web_site_sk as wsr_web_site_sk,
           wr_returned_date_sk as date_sk,
           cast(0 as decimal(7,2)) as sales_price,
           cast(0 as decimal(7,2)) as profit,
           wr_return_amt as return_amt,
           wr_net_loss as net_loss
    from web_returns left outer join web_sales on
         ( wr_item_sk = ws_item_sk
           and wr_order_number = ws_order_number)
   ) salesreturns,
     date_dim,
     web_site
 where date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and date_add('1998-08-04',14)
       and wsr_web_site_sk = web_site_sk
 group by web_site_id)
  select  channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from
 (select 'store channel' as channel
        ,concat('store',s_store_id) as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   ssr
 union all
 select 'catalog channel' as channel
        ,concat('catalog_page',cp_catalog_page_id) as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from  csr
 union all
 select 'web channel' as channel
        ,concat('web_site',web_site_id) as id
        , sales
        , returns
        , (profit - profit_loss) as profit
 from   wsr
  ) x
 group by channel, id with rollup
 order by channel
         ,id
 limit 100;

-- query07

select  i_item_id, 
        avg(ss_quantity) agg1,
        avg(ss_list_price) agg2,
        avg(ss_coupon_amt) agg3,
        avg(ss_sales_price) agg4 
 from store_sales, customer_demographics, date_dim, item, promotion
 where ss_sold_date_sk = d_date_sk and
       ss_item_sk = i_item_sk and
       ss_cdemo_sk = cd_demo_sk and
       ss_promo_sk = p_promo_sk and
       cd_gender = 'F' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Primary' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 1998 
 group by i_item_id
 order by i_item_id
 limit 100;

-- query11

with year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ss_ext_list_price-ss_ext_discount_amt) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year 
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,c_preferred_cust_flag customer_preferred_cust_flag
       ,c_birth_country customer_birth_country
       ,c_login customer_login
       ,c_email_address customer_email_address
       ,d_year dyear
       ,sum(ws_ext_list_price-ws_ext_discount_amt) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,c_preferred_cust_flag 
         ,c_birth_country
         ,c_login
         ,c_email_address
         ,d_year
         )
  select  
                  t_s_secyear.customer_id
                 ,t_s_secyear.customer_first_name
                 ,t_s_secyear.customer_last_name
                 ,t_s_secyear.customer_email_address
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.dyear = 2001
         and t_s_secyear.dyear = 2001+1
         and t_w_firstyear.dyear = 2001
         and t_w_secyear.dyear = 2001+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else 0.0 end
             > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else 0.0 end
 order by t_s_secyear.customer_id
         ,t_s_secyear.customer_first_name
         ,t_s_secyear.customer_last_name
         ,t_s_secyear.customer_email_address
limit 100;

-- query12

select  i_item_id
      ,i_item_desc
      ,i_category
      ,i_class
      ,i_current_price
      ,sum(ws_ext_sales_price) as itemrevenue
      ,sum(ws_ext_sales_price)*100/sum(sum(ws_ext_sales_price)) over
          (partition by i_class) as revenueratio
from
        web_sales
        ,item
        ,date_dim
where
        ws_item_sk = i_item_sk
        and i_category in ('Jewelry', 'Sports', 'Books')
        and ws_sold_date_sk = d_date_sk
        and d_date between cast('2001-01-12' as date)
                                and date_add('2001-01-12',30)
group by
        i_item_id
        ,i_item_desc
        ,i_category
        ,i_class
        ,i_current_price
order by
        i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio
limit 100;

-- query13

select avg(ss_quantity)
       ,avg(ss_ext_sales_price)
       ,avg(ss_ext_wholesale_cost)
       ,sum(ss_ext_wholesale_cost)
 from store_sales
     ,store
     ,customer_demographics
     ,household_demographics
     ,customer_address
     ,date_dim
 where s_store_sk = ss_store_sk
 and  ss_sold_date_sk = d_date_sk and d_year = 2001
 and((ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'D'
  and cd_education_status = '2 yr Degree'
  and ss_sales_price between 100.00 and 150.00
  and hd_dep_count = 3   
     )or
     (ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'S'
  and cd_education_status = 'Secondary'
  and ss_sales_price between 50.00 and 100.00   
  and hd_dep_count = 1
     ) or 
     (ss_hdemo_sk=hd_demo_sk
  and cd_demo_sk = ss_cdemo_sk
  and cd_marital_status = 'W'
  and cd_education_status = 'Advanced Degree'
  and ss_sales_price between 150.00 and 200.00 
  and hd_dep_count = 1  
     ))
 and((ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('CO', 'IL', 'MN')
  and ss_net_profit between 100 and 200  
     ) or
     (ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('OH', 'MT', 'NM')
  and ss_net_profit between 150 and 300  
     ) or
     (ss_addr_sk = ca_address_sk
  and ca_country = 'United States'
  and ca_state in ('TX', 'MO', 'MI')
  and ss_net_profit between 50 and 250  
     ))
;

-- query15

select  ca_zip
       ,sum(cs_sales_price)
 from catalog_sales
     ,customer
     ,customer_address
     ,date_dim
 where cs_bill_customer_sk = c_customer_sk
 	and c_current_addr_sk = ca_address_sk 
 	and ( substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475',
                                   '85392', '85460', '80348', '81792')
 	      or ca_state in ('CA','WA','GA')
 	      or cs_sales_price > 500)
 	and cs_sold_date_sk = d_date_sk
 	and d_qoy = 2 and d_year = 2000
 group by ca_zip
 order by ca_zip
 limit 100;

-- query17

select  i_item_id
       ,i_item_desc
       ,s_state
       ,count(ss_quantity) as store_sales_quantitycount
       ,avg(ss_quantity) as store_sales_quantityave
       ,stddev_samp(ss_quantity) as store_sales_quantitystdev
       ,stddev_samp(ss_quantity)/avg(ss_quantity) as store_sales_quantitycov
       ,count(sr_return_quantity) as store_returns_quantitycount
       ,avg(sr_return_quantity) as store_returns_quantityave
       ,stddev_samp(sr_return_quantity) as store_returns_quantitystdev
       ,stddev_samp(sr_return_quantity)/avg(sr_return_quantity) as store_returns_quantitycov
       ,count(cs_quantity) as catalog_sales_quantitycount ,avg(cs_quantity) as catalog_sales_quantityave
       ,stddev_samp(cs_quantity) as catalog_sales_quantitystdev
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitycov
 from store_sales
     ,store_returns
     ,catalog_sales
     ,date_dim d1
     ,date_dim d2
     ,date_dim d3
     ,store
     ,item
 where d1.d_quarter_name = '1998Q1'
   and d1.d_date_sk = ss_sold_date_sk
   and i_item_sk = ss_item_sk
   and s_store_sk = ss_store_sk
   and ss_customer_sk = sr_customer_sk
   and ss_item_sk = sr_item_sk
   and ss_ticket_number = sr_ticket_number
   and sr_returned_date_sk = d2.d_date_sk
   and d2.d_quarter_name in ('1998Q1','1998Q2','1998Q3')
   and sr_customer_sk = cs_bill_customer_sk
   and sr_item_sk = cs_item_sk
   and cs_sold_date_sk = d3.d_date_sk
   and d3.d_quarter_name in ('1998Q1','1998Q2','1998Q3')
 group by i_item_id
         ,i_item_desc
         ,s_state
 order by i_item_id
         ,i_item_desc
         ,s_state
limit 100;

-- query19

select  i_brand_id brand_id, i_brand brand, i_manufact_id, i_manufact,
 	sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item,customer,customer_address,store
 where d_date_sk = ss_sold_date_sk
   and ss_item_sk = i_item_sk
   and i_manager_id=7
   and d_moy=11
   and d_year=1999
   and ss_customer_sk = c_customer_sk 
   and c_current_addr_sk = ca_address_sk
   and substr(ca_zip,1,5) <> substr(s_zip,1,5) 
   and ss_store_sk = s_store_sk 
 group by i_brand
      ,i_brand_id
      ,i_manufact_id
      ,i_manufact
 order by ext_price desc
         ,i_brand
         ,i_brand_id
         ,i_manufact_id
         ,i_manufact
limit 100 ;

-- query20

select  i_item_id
       ,i_item_desc
       ,i_category
       ,i_class
       ,i_current_price
       ,sum(cs_ext_sales_price) as itemrevenue
       ,sum(cs_ext_sales_price)*100/sum(sum(cs_ext_sales_price)) over
           (partition by i_class) as revenueratio
 from   catalog_sales
     ,item
     ,date_dim
 where cs_item_sk = i_item_sk
   and i_category in ('Jewelry', 'Sports', 'Books')
   and cs_sold_date_sk = d_date_sk
 and d_date between cast('2001-01-12' as date)
                                and date_add('2001-01-12',30)
 group by i_item_id
         ,i_item_desc
         ,i_category
         ,i_class
         ,i_current_price
 order by i_category
         ,i_class
         ,i_item_id
         ,i_item_desc
         ,revenueratio
limit 100;

-- query21

select  *
 from(select w_warehouse_name
            ,i_item_id
            ,sum(case when (cast(d_date as date) < cast ('1998-04-08' as date))
                        then inv_quantity_on_hand
                      else 0 end) as inv_before
            ,sum(case when (cast(d_date as date) >= cast ('1998-04-08' as date))
                      then inv_quantity_on_hand
                      else 0 end) as inv_after
   from inventory
       ,warehouse
       ,item
       ,date_dim
   where i_current_price between 0.99 and 1.49
     and i_item_sk          = inv_item_sk
     and inv_warehouse_sk   = w_warehouse_sk
     and inv_date_sk    = d_date_sk
     and d_date between date_add('1998-04-08',-30)
                    and date_add('1998-04-08',30)
   group by w_warehouse_name, i_item_id) x
 where (case when inv_before > 0
             then inv_after / inv_before
             else null
             end) between 2.0/3.0 and 3.0/2.0
 order by w_warehouse_name
         ,i_item_id
 limit 100;

-- query22

select  i_product_name
             ,i_brand
             ,i_class
             ,i_category
             ,avg(inv_quantity_on_hand) qoh
       from inventory
           ,date_dim
           ,item
       where inv_date_sk=d_date_sk
              and inv_item_sk=i_item_sk
              and d_month_seq between 1212 and 1212 + 11
       group by i_product_name,i_brand,i_class,i_category with rollup
order by qoh, i_product_name, i_brand, i_class, i_category
limit 100;

-- query25

select  
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 ,sum(ss_net_profit) as store_sales_profit
 ,sum(sr_net_loss) as store_returns_loss
 ,sum(cs_net_profit) as catalog_sales_profit
 from
 store_sales
 ,store_returns
 ,catalog_sales
 ,date_dim d1
 ,date_dim d2
 ,date_dim d3
 ,store
 ,item
 where
 d1.d_moy = 4
 and d1.d_year = 2000
 and d1.d_date_sk = ss_sold_date_sk
 and i_item_sk = ss_item_sk
 and s_store_sk = ss_store_sk
 and ss_customer_sk = sr_customer_sk
 and ss_item_sk = sr_item_sk
 and ss_ticket_number = sr_ticket_number
 and sr_returned_date_sk = d2.d_date_sk
 and d2.d_moy               between 4 and  10
 and d2.d_year              = 2000
 and sr_customer_sk = cs_bill_customer_sk
 and sr_item_sk = cs_item_sk
 and cs_sold_date_sk = d3.d_date_sk
 and d3.d_moy               between 4 and  10 
 and d3.d_year              = 2000
 group by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 order by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 limit 100;

-- query26

select  i_item_id, 
        avg(cs_quantity) agg1,
        avg(cs_list_price) agg2,
        avg(cs_coupon_amt) agg3,
        avg(cs_sales_price) agg4 
 from catalog_sales, customer_demographics, date_dim, item, promotion
 where cs_sold_date_sk = d_date_sk and
       cs_item_sk = i_item_sk and
       cs_bill_cdemo_sk = cd_demo_sk and
       cs_promo_sk = p_promo_sk and
       cd_gender = 'F' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Primary' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 1998 
 group by i_item_id
 order by i_item_id
 limit 100;

-- query28

select  *
from (select avg(ss_list_price) B1_LP
            ,count(ss_list_price) B1_CNT
            ,count(distinct ss_list_price) B1_CNTD
      from store_sales
      where ss_quantity between 0 and 5
        and (ss_list_price between 11 and 11+10 
             or ss_coupon_amt between 460 and 460+1000
             or ss_wholesale_cost between 14 and 14+20)) B1,
     (select avg(ss_list_price) B2_LP
            ,count(ss_list_price) B2_CNT
            ,count(distinct ss_list_price) B2_CNTD
      from store_sales
      where ss_quantity between 6 and 10
        and (ss_list_price between 91 and 91+10
          or ss_coupon_amt between 1430 and 1430+1000
          or ss_wholesale_cost between 32 and 32+20)) B2,
     (select avg(ss_list_price) B3_LP
            ,count(ss_list_price) B3_CNT
            ,count(distinct ss_list_price) B3_CNTD
      from store_sales
      where ss_quantity between 11 and 15
        and (ss_list_price between 66 and 66+10
          or ss_coupon_amt between 920 and 920+1000
          or ss_wholesale_cost between 4 and 4+20)) B3,
     (select avg(ss_list_price) B4_LP
            ,count(ss_list_price) B4_CNT
            ,count(distinct ss_list_price) B4_CNTD
      from store_sales
      where ss_quantity between 16 and 20
        and (ss_list_price between 142 and 142+10
          or ss_coupon_amt between 3054 and 3054+1000
          or ss_wholesale_cost between 80 and 80+20)) B4,
     (select avg(ss_list_price) B5_LP
            ,count(ss_list_price) B5_CNT
            ,count(distinct ss_list_price) B5_CNTD
      from store_sales
      where ss_quantity between 21 and 25
        and (ss_list_price between 135 and 135+10
          or ss_coupon_amt between 14180 and 14180+1000
          or ss_wholesale_cost between 38 and 38+20)) B5,
     (select avg(ss_list_price) B6_LP
            ,count(ss_list_price) B6_CNT
            ,count(distinct ss_list_price) B6_CNTD
      from store_sales
      where ss_quantity between 26 and 30
        and (ss_list_price between 28 and 28+10
          or ss_coupon_amt between 2513 and 2513+1000
          or ss_wholesale_cost between 42 and 42+20)) B6
limit 100;

-- query29

select   
     i_item_id
    ,i_item_desc
    ,s_store_id
    ,s_store_name
    ,sum(ss_quantity)        as store_sales_quantity
    ,sum(sr_return_quantity) as store_returns_quantity
    ,sum(cs_quantity)        as catalog_sales_quantity
 from
    store_sales
   ,store_returns
   ,catalog_sales
   ,date_dim             d1
   ,date_dim             d2
   ,date_dim             d3
   ,store
   ,item
 where
     d1.d_moy               = 4 
 and d1.d_year              = 1999
 and d1.d_date_sk           = ss_sold_date_sk
 and i_item_sk              = ss_item_sk
 and s_store_sk             = ss_store_sk
 and ss_customer_sk         = sr_customer_sk
 and ss_item_sk             = sr_item_sk
 and ss_ticket_number       = sr_ticket_number
 and sr_returned_date_sk    = d2.d_date_sk
 and d2.d_moy               between 4 and  4 + 3 
 and d2.d_year              = 1999
 and sr_customer_sk         = cs_bill_customer_sk
 and sr_item_sk             = cs_item_sk
 and cs_sold_date_sk        = d3.d_date_sk     
 and d3.d_year              in (1999,1999+1,1999+2)
 group by
    i_item_id
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 order by
    i_item_id 
   ,i_item_desc
   ,s_store_id
   ,s_store_name
 limit 100;

-- query31

with ss as
 (select ca_county,d_qoy, d_year,sum(ss_ext_sales_price) as store_sales
 from store_sales,date_dim,customer_address
 where ss_sold_date_sk = d_date_sk
  and ss_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year),
 ws as
 (select ca_county,d_qoy, d_year,sum(ws_ext_sales_price) as web_sales
 from web_sales,date_dim,customer_address
 where ws_sold_date_sk = d_date_sk
  and ws_bill_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year)
 select 
        ss1.ca_county
       ,ss1.d_year
       ,ws2.web_sales/ws1.web_sales web_q1_q2_increase
       ,ss2.store_sales/ss1.store_sales store_q1_q2_increase
       ,ws3.web_sales/ws2.web_sales web_q2_q3_increase
       ,ss3.store_sales/ss2.store_sales store_q2_q3_increase
 from
        ss ss1
       ,ss ss2
       ,ss ss3
       ,ws ws1
       ,ws ws2
       ,ws ws3
 where
    ss1.d_qoy = 1
    and ss1.d_year = 2000
    and ss1.ca_county = ss2.ca_county
    and ss2.d_qoy = 2
    and ss2.d_year = 2000
 and ss2.ca_county = ss3.ca_county
    and ss3.d_qoy = 3
    and ss3.d_year = 2000
    and ss1.ca_county = ws1.ca_county
    and ws1.d_qoy = 1
    and ws1.d_year = 2000
    and ws1.ca_county = ws2.ca_county
    and ws2.d_qoy = 2
    and ws2.d_year = 2000
    and ws1.ca_county = ws3.ca_county
    and ws3.d_qoy = 3
    and ws3.d_year =2000
    and case when ws1.web_sales > 0 then ws2.web_sales/ws1.web_sales else null end 
       > case when ss1.store_sales > 0 then ss2.store_sales/ss1.store_sales else null end
    and case when ws2.web_sales > 0 then ws3.web_sales/ws2.web_sales else null end
       > case when ss2.store_sales > 0 then ss3.store_sales/ss2.store_sales else null end
 order by ss1.d_year;

-- query33

with ss as (
 select
          i_manufact_id,sum(ss_ext_sales_price) total_sales
 from
        store_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_manufact_id in (select
  item_sub.i_manufact_id
from
 item as item_sub
where item_sub.i_category in ('Books'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 3
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -5
 group by i_manufact_id),
 cs as (
 select
          i_manufact_id,sum(cs_ext_sales_price) total_sales
 from
        catalog_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_manufact_id               in (select
  item_sub2.i_manufact_id
from
 item as item_sub2
where item_sub2.i_category in ('Books'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 3
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -5
 group by i_manufact_id),
 ws as (
 select
          i_manufact_id,sum(ws_ext_sales_price) total_sales
 from
        web_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_manufact_id               in (select
  item_sub3.i_manufact_id
from
 item as item_sub3
where item_sub3.i_category in ('Books'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 3
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -5
 group by i_manufact_id)
  select  i_manufact_id ,sum(total_sales) total_sales
 from  (select * from ss
        union all
        select * from cs
        union all
        select * from ws) tmp1
 group by i_manufact_id
 order by total_sales
limit 100;

-- query34

select c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (date_dim.d_dom between 1 and 3 or date_dim.d_dom between 25 and 28)
    and (household_demographics.hd_buy_potential = '>10000' or
         household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and (case when household_demographics.hd_vehicle_count > 0 
        then household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count 
        else null 
        end)  > 1.2
    and date_dim.d_year in (1998,1998+1,1998+2)
    and store.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County',
                           'Williamson County','Williamson County','Williamson County','Williamson County')
    group by ss_ticket_number,ss_customer_sk) dn,customer
    where ss_customer_sk = c_customer_sk
      and cnt between 15 and 20
    order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc, ss_ticket_number;

-- query37

select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, catalog_sales
 where i_current_price between 22 and 22 + 30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between '2001-06-02' and '2001-08-02'
 and i_manufact_id in (678,964,918,849)
 and inv_quantity_on_hand between 100 and 500
 and cs_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;

-- query39

with inv as
(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
       ,stdev,mean, case mean when 0 then null else stdev/mean end cov
 from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory
          ,item
          ,warehouse
          ,date_dim
      where inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and inv_date_sk = d_date_sk
        and d_year =1998
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
 where case mean when 0 then 0 else stdev/mean end > 1)
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from inv inv1,inv inv2
where inv1.i_item_sk = inv2.i_item_sk
  and inv1.w_warehouse_sk =  inv2.w_warehouse_sk
  and inv1.d_moy=4
  and inv2.d_moy=4+1
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;

-- query40

select  
   w_state
  ,i_item_id
  ,sum(case when (cast(d_date as date) < cast ('1998-04-08' as date)) 
                then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_before
  ,sum(case when (cast(d_date as date) >= cast ('1998-04-08' as date)) 
                then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_after
 from
   catalog_sales left outer join catalog_returns on
       (catalog_sales.cs_order_number = catalog_returns.cr_order_number 
        and catalog_sales.cs_item_sk = catalog_returns.cr_item_sk)
  ,warehouse 
  ,item
  ,date_dim
 where
     i_current_price between 0.99 and 1.49
 and item.i_item_sk          = catalog_sales.cs_item_sk
 and catalog_sales.cs_warehouse_sk    = warehouse.w_warehouse_sk 
 and catalog_sales.cs_sold_date_sk    = date_dim.d_date_sk
 and date_dim.d_date between '1998-03-09' and '1998-05-08'
 group by
    w_state,i_item_id
 order by w_state,i_item_id
limit 100;

-- query42

select  dt.d_year
        ,item.i_category_id
        ,item.i_category
        ,sum(ss_ext_sales_price) as s
 from   date_dim dt
        ,store_sales
        ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
        and store_sales.ss_item_sk = item.i_item_sk
        and item.i_manager_id = 1  
        and dt.d_moy=12
        and dt.d_year=1998
 group by       dt.d_year
                ,item.i_category_id
                ,item.i_category
 order by       s desc,dt.d_year
                ,item.i_category_id
                ,item.i_category
limit 100 ;

-- query43

select  s_store_name, s_store_id,
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from date_dim, store_sales, store
 where d_date_sk = ss_sold_date_sk and
       s_store_sk = ss_store_sk and
       s_gmt_offset = -5 and
       d_year = 1998 
 group by s_store_name, s_store_id
 order by s_store_name, s_store_id,sun_sales,mon_sales,tue_sales,wed_sales,thu_sales,fri_sales,sat_sales
 limit 100;

-- query46

select  c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,amt,profit 
 from
   (select ss_ticket_number
          ,ss_customer_sk
          ,ca_city bought_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics,customer_address 
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and store_sales.ss_addr_sk = customer_address.ca_address_sk
    and (household_demographics.hd_dep_count = 4 or
         household_demographics.hd_vehicle_count= 3)
    and date_dim.d_dow in (6,0)
    and date_dim.d_year in (1999,1999+1,1999+2) 
    and store.s_city in ('Fairview','Midway','Oak Grove','Midway','Fairview') 
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,ca_city) dn,customer,customer_address current_addr
    where ss_customer_sk = c_customer_sk
      and customer.c_current_addr_sk = current_addr.ca_address_sk
      and current_addr.ca_city <> bought_city
  order by c_last_name
          ,c_first_name
          ,ca_city
          ,bought_city
          ,ss_ticket_number
  limit 100;

-- query47

with v1 as(
 select i_category, i_brand,
        s_store_name, s_company_name,
        d_year, d_moy,
        sum(ss_sales_price) sum_sales,
        avg(sum(ss_sales_price)) over
          (partition by i_category, i_brand,
                     s_store_name, s_company_name, d_year)
          avg_monthly_sales,
        rank() over
          (partition by i_category, i_brand,
                     s_store_name, s_company_name
           order by d_year, d_moy) rn
 from item, store_sales, date_dim, store
 where ss_item_sk = i_item_sk and
       ss_sold_date_sk = d_date_sk and
       ss_store_sk = s_store_sk and
       (
         d_year = 2000 or
         ( d_year = 2000-1 and d_moy =12) or
         ( d_year = 2000+1 and d_moy =1)
       )
 group by i_category, i_brand,
          s_store_name, s_company_name,
          d_year, d_moy),
 v2 as(
 select v1.i_category
        ,v1.d_year, v1.d_moy
        ,v1.avg_monthly_sales
        ,v1.sum_sales, v1_lag.sum_sales psum, v1_lead.sum_sales nsum
 from v1, v1 v1_lag, v1 v1_lead
 where v1.i_category = v1_lag.i_category and
       v1.i_category = v1_lead.i_category and
       v1.i_brand = v1_lag.i_brand and
       v1.i_brand = v1_lead.i_brand and
       v1.s_store_name = v1_lag.s_store_name and
       v1.s_store_name = v1_lead.s_store_name and
       v1.s_company_name = v1_lag.s_company_name and
       v1.s_company_name = v1_lead.s_company_name and
       v1.rn = v1_lag.rn + 1 and
       v1.rn = v1_lead.rn - 1)
  select  *
 from v2
 where  d_year = 2000 and    
        avg_monthly_sales > 0 and
        case when avg_monthly_sales > 0 then abs(sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
 order by sum_sales - avg_monthly_sales, 3
 limit 100;

-- query48

select sum (ss_quantity)
 from store_sales, store, customer_demographics, customer_address, date_dim
 where s_store_sk = ss_store_sk
 and  ss_sold_date_sk = d_date_sk and d_year = 1998
 and  
 (
  (
   cd_demo_sk = ss_cdemo_sk
   and 
   cd_marital_status = 'M'
   and 
   cd_education_status = '4 yr Degree'
   and 
   ss_sales_price between 100.00 and 150.00  
   )
 or
  (
  cd_demo_sk = ss_cdemo_sk
   and 
   cd_marital_status = 'D'
   and 
   cd_education_status = 'Primary'
   and 
   ss_sales_price between 50.00 and 100.00   
  )
 or 
 (
  cd_demo_sk = ss_cdemo_sk
  and 
   cd_marital_status = 'U'
   and 
   cd_education_status = 'Advanced Degree'
   and 
   ss_sales_price between 150.00 and 200.00  
 )
 )
 and
 (
  (
  ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('KY', 'GA', 'NM')
  and ss_net_profit between 0 and 2000  
  )
 or
  (ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('MT', 'OR', 'IN')
  and ss_net_profit between 150 and 3000 
  )
 or
  (ss_addr_sk = ca_address_sk
  and
  ca_country = 'United States'
  and
  ca_state in ('WI', 'MO', 'WV')
  and ss_net_profit between 50 and 25000 
  )
 )
;

-- query49

select  
 'web' as channel
 ,web.item
 ,web.return_ratio
 ,web.return_rank
 ,web.currency_rank
 from (
        select 
         item
        ,return_ratio
        ,currency_ratio
        ,rank() over (order by return_ratio) as return_rank
        ,rank() over (order by currency_ratio) as currency_rank
        from
        (       select ws.ws_item_sk as item
                ,(cast(sum(coalesce(wr.wr_return_quantity,0)) as decimal(15,4))/
                cast(sum(coalesce(ws.ws_quantity,0)) as decimal(15,4) )) as return_ratio
                ,(cast(sum(coalesce(wr.wr_return_amt,0)) as decimal(15,4))/
                cast(sum(coalesce(ws.ws_net_paid,0)) as decimal(15,4) )) as currency_ratio
                from 
                 web_sales ws left outer join web_returns wr 
                        on (ws.ws_order_number = wr.wr_order_number and 
                        ws.ws_item_sk = wr.wr_item_sk)
                 ,date_dim
                where 
                        wr.wr_return_amt > 10000 
                        and ws.ws_net_profit > 1
                         and ws.ws_net_paid > 0
                         and ws.ws_quantity > 0
                         and ws.ws_sold_date_sk = date_dim.d_date_sk
                         and d_year = 2000
                         and d_moy = 12
                group by ws.ws_item_sk
        ) in_web
 ) web
 where 
 (
 web.return_rank <= 10
 or
 web.currency_rank <= 10
 )
 union all
 select 
 'catalog' as channel
 ,catalog.item
 ,catalog.return_ratio
 ,catalog.return_rank
 ,catalog.currency_rank
 from (
        select 
         item
        ,return_ratio
        ,currency_ratio
        ,rank() over (order by return_ratio) as return_rank
        ,rank() over (order by currency_ratio) as currency_rank
        from
        (       select 
                cs.cs_item_sk as item
                ,(cast(sum(coalesce(cr.cr_return_quantity,0)) as decimal(15,4))/
                cast(sum(coalesce(cs.cs_quantity,0)) as decimal(15,4) )) as return_ratio
                ,(cast(sum(coalesce(cr.cr_return_amount,0)) as decimal(15,4))/
                cast(sum(coalesce(cs.cs_net_paid,0)) as decimal(15,4) )) as currency_ratio
                from 
                catalog_sales cs left outer join catalog_returns cr
                        on (cs.cs_order_number = cr.cr_order_number and 
                        cs.cs_item_sk = cr.cr_item_sk)
                ,date_dim
                where 
                        cr.cr_return_amount > 10000 
                        and cs.cs_net_profit > 1
                         and cs.cs_net_paid > 0
                         and cs.cs_quantity > 0
                         and cs_sold_date_sk = d_date_sk
                         and d_year = 2000
                         and d_moy = 12
                 group by cs.cs_item_sk
        ) in_cat
 ) catalog
 where 
 (
 catalog.return_rank <= 10
 or
 catalog.currency_rank <=10
 )
 union all
 select 
 'store' as channel
 ,store.item
 ,store.return_ratio
 ,store.return_rank
 ,store.currency_rank
 from (
        select 
         item
        ,return_ratio
        ,currency_ratio
        ,rank() over (order by return_ratio) as return_rank
        ,rank() over (order by currency_ratio) as currency_rank
        from
        (       select sts.ss_item_sk as item
                ,(cast(sum(coalesce(sr.sr_return_quantity,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_quantity,0)) as decimal(15,4) )) as return_ratio
                ,(cast(sum(coalesce(sr.sr_return_amt,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_net_paid,0)) as decimal(15,4) )) as currency_ratio
                from 
                store_sales sts left outer join store_returns sr
                        on (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)
                ,date_dim
                where 
                        sr.sr_return_amt > 10000 
                        and sts.ss_net_profit > 1
                         and sts.ss_net_paid > 0 
                         and sts.ss_quantity > 0
                         and ss_sold_date_sk = d_date_sk
                         and d_year = 2000
                         and d_moy = 12
                group by sts.ss_item_sk
        ) in_store
 ) store
 where  (
 store.return_rank <= 10
 or 
 store.currency_rank <= 10
 )
 order by 1,4,5
 limit 100;

-- query50

select  
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as 30days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as 3160days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as 6190days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as 91120days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as 120days 
from
   store_sales
  ,store_returns
  ,store
  ,date_dim d1
  ,date_dim d2
where
    d2.d_year = 2000
and d2.d_moy  = 9
and store_sales.ss_ticket_number = store_returns.sr_ticket_number
and store_sales.ss_item_sk = store_returns.sr_item_sk
and store_sales.ss_sold_date_sk   = d1.d_date_sk
and sr_returned_date_sk   = d2.d_date_sk
and store_sales.ss_customer_sk = store_returns.sr_customer_sk
and store_sales.ss_store_sk = store.s_store_sk
group by
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
order by s_store_name
        ,s_company_id
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
limit 100;

-- query51

WITH web_v1 as (
select
  ws_item_sk item_sk, d_date, sum(ws_sales_price),
  sum(sum(ws_sales_price))
      over (partition by ws_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from web_sales
    ,date_dim
where ws_sold_date_sk=d_date_sk
  and d_month_seq between 1193 and 1193+11
  and ws_item_sk is not NULL
group by ws_item_sk, d_date),
store_v1 as (
select
  ss_item_sk item_sk, d_date, sum(ss_sales_price),
  sum(sum(ss_sales_price))
      over (partition by ss_item_sk order by d_date rows between unbounded preceding and current row) cume_sales
from store_sales
    ,date_dim
where ss_sold_date_sk=d_date_sk
  and d_month_seq between 1193 and 1193+11
  and ss_item_sk is not NULL
group by ss_item_sk, d_date)
 select  *
from (select item_sk
     ,d_date
     ,web_sales
     ,store_sales
     ,max(web_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) web_cumulative
     ,max(store_sales)
         over (partition by item_sk order by d_date rows between unbounded preceding and current row) store_cumulative
     from (select case when web.item_sk is not null then web.item_sk else store.item_sk end item_sk
                 ,case when web.d_date is not null then web.d_date else store.d_date end d_date
                 ,web.cume_sales web_sales
                 ,store.cume_sales store_sales
           from web_v1 web full outer join store_v1 store on (web.item_sk = store.item_sk
                                                          and web.d_date = store.d_date)
          )x )y
where web_cumulative > store_cumulative
order by item_sk
        ,d_date
limit 100;

-- query52

select  dt.d_year
        ,item.i_brand_id brand_id
        ,item.i_brand brand
        ,sum(ss_ext_sales_price) ext_price
 from date_dim dt
     ,store_sales
     ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
    and store_sales.ss_item_sk = item.i_item_sk
    and item.i_manager_id = 1
    and dt.d_moy=12
    and dt.d_year=1998
 group by dt.d_year
        ,item.i_brand
        ,item.i_brand_id
 order by dt.d_year
        ,ext_price desc
        ,brand_id
limit 100 ;

-- query53

select  * from 
(select i_manufact_id,
sum(ss_sales_price) sum_sales,
avg(sum(ss_sales_price)) over (partition by i_manufact_id) avg_quarterly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
ss_sold_date_sk = d_date_sk and
ss_store_sk = s_store_sk and
d_month_seq in (1212,1212+1,1212+2,1212+3,1212+4,1212+5,1212+6,1212+7,1212+8,1212+9,1212+10,1212+11) and
((i_category in ('Books','Children','Electronics') and
i_class in ('personal','portable','reference','self-help') and
i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
                'exportiunivamalg #9','scholaramalgamalg #9'))
or(i_category in ('Women','Music','Men') and
i_class in ('accessories','classical','fragrances','pants') and
i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
                'importoamalg #1')))
group by i_manufact_id, d_qoy ) tmp1
where case when avg_quarterly_sales > 0 
        then abs (sum_sales - avg_quarterly_sales)/ avg_quarterly_sales 
        else null end > 0.1
order by avg_quarterly_sales,
         sum_sales,
         i_manufact_id
limit 100;

-- query55

select  i_brand_id brand_id, i_brand brand,
        sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item
 where d_date_sk = ss_sold_date_sk
        and ss_item_sk = i_item_sk
        and i_manager_id=36
        and d_moy=12
        and d_year=2001
 group by i_brand, i_brand_id
 order by ext_price desc, i_brand_id
limit 100 ;

-- query56

with ss as (
 select i_item_id,sum(ss_ext_sales_price) total_sales
 from
        store_sales,
        date_dim,
         customer_address,
         item
 where item.i_item_id in (select
     i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select i_item_id,sum(cs_ext_sales_price) total_sales
 from
        catalog_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select i_item_id,sum(ws_ext_sales_price) total_sales
 from
        web_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select  i_item_id ,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by total_sales
 limit 100;

-- query57

with v1 as(
 select i_category, i_brand,
        cc_name,
        d_year, d_moy,
        sum(cs_sales_price) sum_sales,
        avg(sum(cs_sales_price)) over
          (partition by i_category, i_brand,
                     cc_name, d_year)
          avg_monthly_sales,
        rank() over
          (partition by i_category, i_brand,
                     cc_name
           order by d_year, d_moy) rn
 from item, catalog_sales, date_dim, call_center
 where cs_item_sk = i_item_sk and
       cs_sold_date_sk = d_date_sk and
       cc_call_center_sk= cs_call_center_sk and
       (
         d_year = 2000 or
         ( d_year = 2000-1 and d_moy =12) or
         ( d_year = 2000+1 and d_moy =1)
       )
 group by i_category, i_brand,
          cc_name , d_year, d_moy),
 v2 as(
 select v1.i_category, v1.i_brand
        ,v1.d_year, v1.d_moy
        ,v1.avg_monthly_sales
        ,v1.sum_sales, v1_lag.sum_sales psum, v1_lead.sum_sales nsum
 from v1, v1 v1_lag, v1 v1_lead
 where v1.i_category = v1_lag.i_category and
       v1.i_category = v1_lead.i_category and
       v1.i_brand = v1_lag.i_brand and
       v1.i_brand = v1_lead.i_brand and
       v1. cc_name = v1_lag. cc_name and
       v1. cc_name = v1_lead. cc_name and
       v1.rn = v1_lag.rn + 1 and
       v1.rn = v1_lead.rn - 1)
  select  *
 from v2
 where  d_year = 2000 and
        avg_monthly_sales > 0 and
        case when avg_monthly_sales > 0 then abs(sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
 order by sum_sales - avg_monthly_sales, 3
 limit 100;

-- query59

with wss as 
 (select d_week_seq,
        ss_store_sk,
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from store_sales,date_dim
 where d_date_sk = ss_sold_date_sk
 group by d_week_seq,ss_store_sk
 )
  select  s_store_name1,s_store_id1,d_week_seq1
       ,sun_sales1/sun_sales2,mon_sales1/mon_sales2
       ,tue_sales1/tue_sales2,wed_sales1/wed_sales2,thu_sales1/thu_sales2
       ,fri_sales1/fri_sales2,sat_sales1/sat_sales2
 from
 (select s_store_name s_store_name1,wss.d_week_seq d_week_seq1
        ,s_store_id s_store_id1,sun_sales sun_sales1
        ,mon_sales mon_sales1,tue_sales tue_sales1
        ,wed_sales wed_sales1,thu_sales thu_sales1
        ,fri_sales fri_sales1,sat_sales sat_sales1
  from wss,store,date_dim d
  where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between 1185 and 1185 + 11) y,
 (select s_store_name s_store_name2,wss.d_week_seq d_week_seq2
        ,s_store_id s_store_id2,sun_sales sun_sales2
        ,mon_sales mon_sales2,tue_sales tue_sales2
        ,wed_sales wed_sales2,thu_sales thu_sales2
        ,fri_sales fri_sales2,sat_sales sat_sales2
  from wss,store,date_dim d
  where d.d_week_seq = wss.d_week_seq and
        ss_store_sk = s_store_sk and 
        d_month_seq between 1185+ 12 and 1185 + 23) x
 where s_store_id1=s_store_id2
   and d_week_seq1=d_week_seq2-52
 order by s_store_name1,s_store_id1,d_week_seq1
limit 100;

-- query60

with ss as (
 select
          i_item_id,sum(ss_ext_sales_price) total_sales
 from
        store_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select
          i_item_id,sum(cs_ext_sales_price) total_sales
 from
        catalog_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select
          i_item_id,sum(ws_ext_sales_price) total_sales
 from
        web_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select   
  i_item_id
,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by i_item_id
      ,total_sales
 limit 100;

-- query61

select  promotions,total,cast(promotions as decimal(15,4))/cast(total as decimal(15,4))*100
from
  (select sum(ss_ext_sales_price) promotions
   from  store_sales
        ,store
        ,promotion
        ,date_dim
        ,customer
        ,customer_address 
        ,item
   where ss_sold_date_sk = d_date_sk
   and   ss_store_sk = s_store_sk
   and   ss_promo_sk = p_promo_sk
   and   ss_customer_sk= c_customer_sk
   and   ca_address_sk = c_current_addr_sk
   and   ss_item_sk = i_item_sk 
   and   ca_gmt_offset = -7
   and   i_category = 'Books'
   and   (p_channel_dmail = 'Y' or p_channel_email = 'Y' or p_channel_tv = 'Y')
   and   s_gmt_offset = -7
   and   d_year = 1999
   and   d_moy  = 11) promotional_sales,
  (select sum(ss_ext_sales_price) total
   from  store_sales
        ,store
        ,date_dim
        ,customer
        ,customer_address
        ,item
   where ss_sold_date_sk = d_date_sk
   and   ss_store_sk = s_store_sk
   and   ss_customer_sk= c_customer_sk
   and   ca_address_sk = c_current_addr_sk
   and   ss_item_sk = i_item_sk
   and   ca_gmt_offset = -7
   and   i_category = 'Books'
   and   s_gmt_offset = -7
   and   d_year = 1999
   and   d_moy  = 11) all_sales
order by promotions, total
limit 100;

-- query62

select  
   substr(w_warehouse_name,1,20) as s
  ,sm_type
  ,web_name
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk <= 30 ) then 1 else 0 end)  as 30days 
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 30) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 60) then 1 else 0 end )  as 3160days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 60) and 
                 (ws_ship_date_sk - ws_sold_date_sk <= 90) then 1 else 0 end)  as 6190days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk > 90) and
                 (ws_ship_date_sk - ws_sold_date_sk <= 120) then 1 else 0 end)  as 91120days
  ,sum(case when (ws_ship_date_sk - ws_sold_date_sk  > 120) then 1 else 0 end)  as 120days
from
   web_sales
  ,warehouse
  ,ship_mode
  ,web_site
  ,date_dim
where
    d_month_seq between 1212 and 1212 + 11
and ws_ship_date_sk   = d_date_sk
and ws_warehouse_sk   = w_warehouse_sk
and ws_ship_mode_sk   = sm_ship_mode_sk
and ws_web_site_sk    = web_site_sk
group by
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,web_name
order by s
        ,sm_type
       ,web_name
limit 100;

-- query63

select  * 
from (select i_manager_id
             ,sum(ss_sales_price) sum_sales
             ,avg(sum(ss_sales_price)) over (partition by i_manager_id) avg_monthly_sales
      from item
          ,store_sales
          ,date_dim
          ,store
      where ss_item_sk = i_item_sk
        and ss_sold_date_sk = d_date_sk
        and ss_store_sk = s_store_sk
        and d_month_seq in (1212,1212+1,1212+2,1212+3,1212+4,1212+5,1212+6,1212+7,1212+8,1212+9,1212+10,1212+11)
        and ((    i_category in ('Books','Children','Electronics')
              and i_class in ('personal','portable','reference','self-help')
              and i_brand in ('scholaramalgamalg #14','scholaramalgamalg #7',
                                  'exportiunivamalg #9','scholaramalgamalg #9'))
           or(    i_category in ('Women','Music','Men')
              and i_class in ('accessories','classical','fragrances','pants')
              and i_brand in ('amalgimporto #1','edu packscholar #1','exportiimporto #1',
                                 'importoamalg #1')))
group by i_manager_id, d_moy) tmp1
where case when avg_monthly_sales > 0 then abs (sum_sales - avg_monthly_sales) / avg_monthly_sales else null end > 0.1
order by i_manager_id
        ,avg_monthly_sales
        ,sum_sales
limit 100;

-- query65

select 
        s_store_name,
        i_item_desc,
        sc.revenue,
        i_current_price,
        i_wholesale_cost,
        i_brand
 from store, item,
     (select ss_store_sk, avg(revenue) as ave
        from
            (select  ss_store_sk, ss_item_sk, 
                     sum(ss_sales_price) as revenue
                from store_sales, date_dim
                where ss_sold_date_sk = d_date_sk and d_month_seq between 1212 and 1212+11
                group by ss_store_sk, ss_item_sk) sa
        group by ss_store_sk) sb,
     (select  ss_store_sk, ss_item_sk, sum(ss_sales_price) as revenue
        from store_sales, date_dim
        where ss_sold_date_sk = d_date_sk and d_month_seq between 1212 and 1212+11
        group by ss_store_sk, ss_item_sk) sc
 where sb.ss_store_sk = sc.ss_store_sk and 
       sc.revenue <= 0.1 * sb.ave and
       s_store_sk = sc.ss_store_sk and
       i_item_sk = sc.ss_item_sk
 order by s_store_name, i_item_desc
limit 100;

-- query66

select   
         w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,ship_carriers
        ,year
        ,sum(jan_sales) as jan_sales
        ,sum(feb_sales) as feb_sales
        ,sum(mar_sales) as mar_sales
        ,sum(apr_sales) as apr_sales
        ,sum(may_sales) as may_sales
        ,sum(jun_sales) as jun_sales
        ,sum(jul_sales) as jul_sales
        ,sum(aug_sales) as aug_sales
        ,sum(sep_sales) as sep_sales
        ,sum(oct_sales) as oct_sales
        ,sum(nov_sales) as nov_sales
        ,sum(dec_sales) as dec_sales
        ,sum(jan_sales/w_warehouse_sq_ft) as jan_sales_per_sq_foot
        ,sum(feb_sales/w_warehouse_sq_ft) as feb_sales_per_sq_foot
        ,sum(mar_sales/w_warehouse_sq_ft) as mar_sales_per_sq_foot
        ,sum(apr_sales/w_warehouse_sq_ft) as apr_sales_per_sq_foot
        ,sum(may_sales/w_warehouse_sq_ft) as may_sales_per_sq_foot
        ,sum(jun_sales/w_warehouse_sq_ft) as jun_sales_per_sq_foot
        ,sum(jul_sales/w_warehouse_sq_ft) as jul_sales_per_sq_foot
        ,sum(aug_sales/w_warehouse_sq_ft) as aug_sales_per_sq_foot
        ,sum(sep_sales/w_warehouse_sq_ft) as sep_sales_per_sq_foot
        ,sum(oct_sales/w_warehouse_sq_ft) as oct_sales_per_sq_foot
        ,sum(nov_sales/w_warehouse_sq_ft) as nov_sales_per_sq_foot
        ,sum(dec_sales/w_warehouse_sq_ft) as dec_sales_per_sq_foot
        ,sum(jan_net) as jan_net
        ,sum(feb_net) as feb_net
        ,sum(mar_net) as mar_net
        ,sum(apr_net) as apr_net
        ,sum(may_net) as may_net
        ,sum(jun_net) as jun_net
        ,sum(jul_net) as jul_net
        ,sum(aug_net) as aug_net
        ,sum(sep_net) as sep_net
        ,sum(oct_net) as oct_net
        ,sum(nov_net) as nov_net
        ,sum(dec_net) as dec_net
 from (
    select 
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,concat('DIAMOND', ',', 'AIRBORNE') as ship_carriers
        ,d_year as year
        ,sum(case when d_moy = 1 
                then ws_sales_price* ws_quantity else 0 end) as jan_sales
        ,sum(case when d_moy = 2 
                then ws_sales_price* ws_quantity else 0 end) as feb_sales
        ,sum(case when d_moy = 3 
                then ws_sales_price* ws_quantity else 0 end) as mar_sales
        ,sum(case when d_moy = 4 
                then ws_sales_price* ws_quantity else 0 end) as apr_sales
        ,sum(case when d_moy = 5 
                then ws_sales_price* ws_quantity else 0 end) as may_sales
        ,sum(case when d_moy = 6 
                then ws_sales_price* ws_quantity else 0 end) as jun_sales
        ,sum(case when d_moy = 7 
                then ws_sales_price* ws_quantity else 0 end) as jul_sales
        ,sum(case when d_moy = 8 
                then ws_sales_price* ws_quantity else 0 end) as aug_sales
        ,sum(case when d_moy = 9 
                then ws_sales_price* ws_quantity else 0 end) as sep_sales
        ,sum(case when d_moy = 10 
                then ws_sales_price* ws_quantity else 0 end) as oct_sales
        ,sum(case when d_moy = 11
                then ws_sales_price* ws_quantity else 0 end) as nov_sales
        ,sum(case when d_moy = 12
                then ws_sales_price* ws_quantity else 0 end) as dec_sales
        ,sum(case when d_moy = 1 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as jan_net
        ,sum(case when d_moy = 2
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as feb_net
        ,sum(case when d_moy = 3 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as mar_net
        ,sum(case when d_moy = 4 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as apr_net
        ,sum(case when d_moy = 5 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as may_net
        ,sum(case when d_moy = 6 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as jun_net
        ,sum(case when d_moy = 7 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as jul_net
        ,sum(case when d_moy = 8 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as aug_net
        ,sum(case when d_moy = 9 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as sep_net
        ,sum(case when d_moy = 10 
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as oct_net
        ,sum(case when d_moy = 11
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as nov_net
        ,sum(case when d_moy = 12
                then ws_net_paid_inc_tax * ws_quantity else 0 end) as dec_net
     from
          web_sales
         ,warehouse
         ,date_dim
         ,time_dim
          ,ship_mode
     where
            web_sales.ws_warehouse_sk =  warehouse.w_warehouse_sk
        and web_sales.ws_sold_date_sk = date_dim.d_date_sk
        and web_sales.ws_sold_time_sk = time_dim.t_time_sk
        and web_sales.ws_ship_mode_sk = ship_mode.sm_ship_mode_sk
        and d_year = 2002
        and t_time between 49530 and 49530+28800 
        and sm_carrier in ('DIAMOND','AIRBORNE')
     group by 
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
       ,d_year
 union all
    select 
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,concat('DIAMOND', ',', 'AIRBORNE') as ship_carriers
       ,d_year as year
        ,sum(case when d_moy = 1 
                then cs_ext_sales_price* cs_quantity else 0 end) as jan_sales
        ,sum(case when d_moy = 2 
                then cs_ext_sales_price* cs_quantity else 0 end) as feb_sales
        ,sum(case when d_moy = 3 
                then cs_ext_sales_price* cs_quantity else 0 end) as mar_sales
        ,sum(case when d_moy = 4 
                then cs_ext_sales_price* cs_quantity else 0 end) as apr_sales
        ,sum(case when d_moy = 5 
                then cs_ext_sales_price* cs_quantity else 0 end) as may_sales
        ,sum(case when d_moy = 6 
                then cs_ext_sales_price* cs_quantity else 0 end) as jun_sales
        ,sum(case when d_moy = 7 
                then cs_ext_sales_price* cs_quantity else 0 end) as jul_sales
        ,sum(case when d_moy = 8 
                then cs_ext_sales_price* cs_quantity else 0 end) as aug_sales
        ,sum(case when d_moy = 9 
                then cs_ext_sales_price* cs_quantity else 0 end) as sep_sales
        ,sum(case when d_moy = 10 
                then cs_ext_sales_price* cs_quantity else 0 end) as oct_sales
        ,sum(case when d_moy = 11
                then cs_ext_sales_price* cs_quantity else 0 end) as nov_sales
        ,sum(case when d_moy = 12
                then cs_ext_sales_price* cs_quantity else 0 end) as dec_sales
        ,sum(case when d_moy = 1 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jan_net
        ,sum(case when d_moy = 2 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as feb_net
        ,sum(case when d_moy = 3 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as mar_net
        ,sum(case when d_moy = 4 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as apr_net
        ,sum(case when d_moy = 5 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as may_net
        ,sum(case when d_moy = 6 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jun_net
        ,sum(case when d_moy = 7 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jul_net
        ,sum(case when d_moy = 8 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as aug_net
        ,sum(case when d_moy = 9 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as sep_net
        ,sum(case when d_moy = 10 
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as oct_net
        ,sum(case when d_moy = 11
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as nov_net
        ,sum(case when d_moy = 12
                then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as dec_net
     from
          catalog_sales
         ,warehouse
         ,date_dim
         ,time_dim
         ,ship_mode
     where
            catalog_sales.cs_warehouse_sk =  warehouse.w_warehouse_sk
        and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
        and catalog_sales.cs_sold_time_sk = time_dim.t_time_sk
        and catalog_sales.cs_ship_mode_sk = ship_mode.sm_ship_mode_sk
        and d_year = 2002
        and t_time between 49530 AND 49530+28800 
        and sm_carrier in ('DIAMOND','AIRBORNE')
     group by 
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
       ,d_year
 ) x
 group by 
        w_warehouse_name
        ,w_warehouse_sq_ft
        ,w_city
        ,w_county
        ,w_state
        ,w_country
        ,ship_carriers
       ,year
 order by w_warehouse_name
 limit 100;

-- query67

select  *
from (select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category order by sumsales desc) rk
      from (select i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,d_qoy
                  ,d_moy
                  ,s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from store_sales
                ,date_dim
                ,store
                ,item
       where  store_sales.ss_sold_date_sk=date_dim.d_date_sk
          and store_sales.ss_item_sk=item.i_item_sk
          and store_sales.ss_store_sk = store.s_store_sk
          and d_month_seq between 1193 and 1193+11
       group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy,s_store_id with rollup)dw1) dw2
where rk <= 100
order by i_category
        ,i_class
        ,i_brand
        ,i_product_name
        ,d_year
        ,d_qoy
        ,d_moy
        ,s_store_id
        ,sumsales
        ,rk
limit 100;

-- query68

select  c_last_name
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,extended_price
       ,extended_tax
       ,list_price
 from (select ss_ticket_number
             ,ss_customer_sk
             ,ca_city bought_city
             ,sum(ss_ext_sales_price) extended_price 
             ,sum(ss_ext_list_price) list_price
             ,sum(ss_ext_tax) extended_tax 
       from store_sales
           ,date_dim
           ,store
           ,household_demographics
           ,customer_address 
       where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_store_sk = store.s_store_sk  
        and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        and store_sales.ss_addr_sk = customer_address.ca_address_sk
        and date_dim.d_dom between 1 and 2 
        and (household_demographics.hd_dep_count = 4 or
             household_demographics.hd_vehicle_count= 3)
        and date_dim.d_year in (1999,1999+1,1999+2)
        and store.s_city in ('Fairview','Midway')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      ,customer
      ,customer_address current_addr
 where ss_customer_sk = c_customer_sk
   and customer.c_current_addr_sk = current_addr.ca_address_sk
   and current_addr.ca_city <> bought_city
 order by c_last_name
         ,ss_ticket_number
 limit 100;

-- query71

select i_brand_id brand_id, i_brand brand,t_hour,t_minute,
        sum(ext_price) ext_price
 from item, (select ws_ext_sales_price as ext_price, 
                        ws_sold_date_sk as sold_date_sk,
                        ws_item_sk as sold_item_sk,
                        ws_sold_time_sk as time_sk  
                 from web_sales,date_dim
                 where d_date_sk = ws_sold_date_sk
                   and d_moy=12
                   and d_year=2000
                 union all
                 select cs_ext_sales_price as ext_price,
                        cs_sold_date_sk as sold_date_sk,
                        cs_item_sk as sold_item_sk,
                        cs_sold_time_sk as time_sk
                 from catalog_sales,date_dim
                 where d_date_sk = cs_sold_date_sk
                   and d_moy=12
                   and d_year=2000
                 union all
                 select ss_ext_sales_price as ext_price,
                        ss_sold_date_sk as sold_date_sk,
                        ss_item_sk as sold_item_sk,
                        ss_sold_time_sk as time_sk
                 from store_sales,date_dim
                 where d_date_sk = ss_sold_date_sk
                   and d_moy=12
                   and d_year=2000
                 ) tmp,time_dim
 where
   sold_item_sk = i_item_sk
   and i_manager_id=1
   and time_sk = t_time_sk
   and (t_meal_time = 'breakfast' or t_meal_time = 'dinner')
 group by i_brand, i_brand_id,t_hour,t_minute
 order by ext_price desc, i_brand_id
 ;

-- query72

select  i_item_desc
      ,w_warehouse_name
      ,d1.d_week_seq
      ,sum(case when p_promo_sk is null then 1 else 0 end) no_promo
      ,sum(case when p_promo_sk is not null then 1 else 0 end) promo
      ,count(*) total_cnt
from catalog_sales
join inventory on (cs_item_sk = inv_item_sk)
join warehouse on (w_warehouse_sk=inv_warehouse_sk)
join item on (i_item_sk = cs_item_sk)
join customer_demographics on (cs_bill_cdemo_sk = cd_demo_sk)
join household_demographics on (cs_bill_hdemo_sk = hd_demo_sk)
join date_dim d1 on (cs_sold_date_sk = d1.d_date_sk)
join date_dim d2 on (inv_date_sk = d2.d_date_sk)
join date_dim d3 on (cs_ship_date_sk = d3.d_date_sk)
left outer join promotion on (cs_promo_sk=p_promo_sk)
left outer join catalog_returns on (cr_item_sk = cs_item_sk and cr_order_number = cs_order_number)
where d1.d_week_seq = d2.d_week_seq
  and inv_quantity_on_hand < cs_quantity 
  and d3.d_date > d1.d_date + 5
  and hd_buy_potential = '1001-5000'
  and d1.d_year = 2001
  and cd_marital_status = 'M'
group by i_item_desc,w_warehouse_name,d1.d_week_seq
order by total_cnt desc, i_item_desc, w_warehouse_name, d_week_seq
limit 100;

-- query73

select c_last_name
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag 
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and date_dim.d_dom between 1 and 2 
    and (household_demographics.hd_buy_potential = '>10000' or
         household_demographics.hd_buy_potential = 'Unknown')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then 
             household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (1998,1998+1,1998+2)
    and store.s_county in ('Williamson County','Williamson County','Williamson County','Williamson County')
    group by ss_ticket_number,ss_customer_sk) dj,customer
    where ss_customer_sk = c_customer_sk
      and cnt between 1 and 5
    order by cnt desc, c_last_name asc;

-- query74

with year_total as (
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ss_net_paid) year_total
       ,'s' sale_type
 from customer
     ,store_sales
     ,date_dim
 where c_customer_sk = ss_customer_sk
   and ss_sold_date_sk = d_date_sk
   and d_year in (2001,2001+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
 union all
 select c_customer_id customer_id
       ,c_first_name customer_first_name
       ,c_last_name customer_last_name
       ,d_year as year
       ,max(ws_net_paid) year_total
       ,'w' sale_type
 from customer
     ,web_sales
     ,date_dim
 where c_customer_sk = ws_bill_customer_sk
   and ws_sold_date_sk = d_date_sk
   and d_year in (2001,2001+1)
 group by c_customer_id
         ,c_first_name
         ,c_last_name
         ,d_year
         )
  select 
        t_s_secyear.customer_id, t_s_secyear.customer_first_name, t_s_secyear.customer_last_name
 from year_total t_s_firstyear
     ,year_total t_s_secyear
     ,year_total t_w_firstyear
     ,year_total t_w_secyear
 where t_s_secyear.customer_id = t_s_firstyear.customer_id
         and t_s_firstyear.customer_id = t_w_secyear.customer_id
         and t_s_firstyear.customer_id = t_w_firstyear.customer_id
         and t_s_firstyear.sale_type = 's'
         and t_w_firstyear.sale_type = 'w'
         and t_s_secyear.sale_type = 's'
         and t_w_secyear.sale_type = 'w'
         and t_s_firstyear.year = 2001
         and t_s_secyear.year = 2001+1
         and t_w_firstyear.year = 2001
         and t_w_secyear.year = 2001+1
         and t_s_firstyear.year_total > 0
         and t_w_firstyear.year_total > 0
         and case when t_w_firstyear.year_total > 0 then t_w_secyear.year_total / t_w_firstyear.year_total else null end
           > case when t_s_firstyear.year_total > 0 then t_s_secyear.year_total / t_s_firstyear.year_total else null end
 order by 2,1,3
limit 100;

-- query75

WITH all_sales AS (
 SELECT d_year
       ,i_brand_id
       ,i_class_id
       ,i_category_id
       ,i_manufact_id
       ,SUM(sales_cnt) AS sales_cnt
       ,SUM(sales_amt) AS sales_amt
 FROM (SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,cs_quantity - COALESCE(cr_return_quantity,0) AS sales_cnt
             ,cs_ext_sales_price - COALESCE(cr_return_amount,0.0) AS sales_amt
       FROM catalog_sales JOIN item ON i_item_sk=cs_item_sk
                          JOIN date_dim ON d_date_sk=cs_sold_date_sk
                          LEFT JOIN catalog_returns ON (cs_order_number=cr_order_number 
                                                    AND cs_item_sk=cr_item_sk)
       WHERE i_category='Sports'
       UNION
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ss_quantity - COALESCE(sr_return_quantity,0) AS sales_cnt
             ,ss_ext_sales_price - COALESCE(sr_return_amt,0.0) AS sales_amt
       FROM store_sales JOIN item ON i_item_sk=ss_item_sk
                        JOIN date_dim ON d_date_sk=ss_sold_date_sk
                        LEFT JOIN store_returns ON (ss_ticket_number=sr_ticket_number 
                                                AND ss_item_sk=sr_item_sk)
       WHERE i_category='Sports'
       UNION
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ws_quantity - COALESCE(wr_return_quantity,0) AS sales_cnt
             ,ws_ext_sales_price - COALESCE(wr_return_amt,0.0) AS sales_amt
       FROM web_sales JOIN item ON i_item_sk=ws_item_sk
                      JOIN date_dim ON d_date_sk=ws_sold_date_sk
                      LEFT JOIN web_returns ON (ws_order_number=wr_order_number 
                                            AND ws_item_sk=wr_item_sk)
       WHERE i_category='Sports') sales_detail
 GROUP BY d_year, i_brand_id, i_class_id, i_category_id, i_manufact_id)
 SELECT  prev_yr.d_year AS prev_year
                          ,curr_yr.d_year AS year
                          ,curr_yr.i_brand_id
                          ,curr_yr.i_class_id
                          ,curr_yr.i_category_id
                          ,curr_yr.i_manufact_id
                          ,prev_yr.sales_cnt AS prev_yr_cnt
                          ,curr_yr.sales_cnt AS curr_yr_cnt
                          ,curr_yr.sales_cnt-prev_yr.sales_cnt AS sales_cnt_diff
                          ,curr_yr.sales_amt-prev_yr.sales_amt AS sales_amt_diff
 FROM all_sales curr_yr, all_sales prev_yr
 WHERE curr_yr.i_brand_id=prev_yr.i_brand_id
   AND curr_yr.i_class_id=prev_yr.i_class_id
   AND curr_yr.i_category_id=prev_yr.i_category_id
   AND curr_yr.i_manufact_id=prev_yr.i_manufact_id
   AND curr_yr.d_year=2002
   AND prev_yr.d_year=2002-1
   AND CAST(curr_yr.sales_cnt AS DECIMAL(17,2))/CAST(prev_yr.sales_cnt AS DECIMAL(17,2))<0.9
 ORDER BY sales_cnt_diff
 limit 100;

-- query76

select  channel, col_name, d_year, d_qoy, i_category, COUNT(*) sales_cnt, SUM(ext_sales_price) sales_amt FROM (
        SELECT 'store' as channel, 'ss_addr_sk' col_name, d_year, d_qoy, i_category, ss_ext_sales_price ext_sales_price
         FROM store_sales, item, date_dim
         WHERE ss_addr_sk IS NULL
           AND ss_sold_date_sk=d_date_sk
           AND ss_item_sk=i_item_sk
        UNION ALL
        SELECT 'web' as channel, 'ws_web_page_sk' col_name, d_year, d_qoy, i_category, ws_ext_sales_price ext_sales_price
         FROM web_sales, item, date_dim
         WHERE ws_web_page_sk IS NULL
           AND ws_sold_date_sk=d_date_sk
           AND ws_item_sk=i_item_sk
        UNION ALL
        SELECT 'catalog' as channel, 'cs_warehouse_sk' col_name, d_year, d_qoy, i_category, cs_ext_sales_price ext_sales_price
         FROM catalog_sales, item, date_dim
         WHERE cs_warehouse_sk IS NULL
           AND cs_sold_date_sk=d_date_sk
           AND cs_item_sk=i_item_sk) foo
GROUP BY channel, col_name, d_year, d_qoy, i_category
ORDER BY channel, col_name, d_year, d_qoy, i_category
limit 100;

-- query78

with ws as
  (select d_year AS ws_sold_year, ws_item_sk,
    ws_bill_customer_sk ws_customer_sk,
    sum(ws_quantity) ws_qty,
    sum(ws_wholesale_cost) ws_wc,
    sum(ws_sales_price) ws_sp
   from web_sales
   left join web_returns on wr_order_number=ws_order_number and ws_item_sk=wr_item_sk
   join date_dim on ws_sold_date_sk = d_date_sk
   where wr_order_number is null
   group by d_year, ws_item_sk, ws_bill_customer_sk
   ),
cs as
  (select d_year AS cs_sold_year, cs_item_sk,
    cs_bill_customer_sk cs_customer_sk,
    sum(cs_quantity) cs_qty,
    sum(cs_wholesale_cost) cs_wc,
    sum(cs_sales_price) cs_sp
   from catalog_sales
   left join catalog_returns on cr_order_number=cs_order_number and cs_item_sk=cr_item_sk
   join date_dim on cs_sold_date_sk = d_date_sk
   where cr_order_number is null
   group by d_year, cs_item_sk, cs_bill_customer_sk
   ),
ss as
  (select d_year AS ss_sold_year, ss_item_sk,
    ss_customer_sk,
    sum(ss_quantity) ss_qty,
    sum(ss_wholesale_cost) ss_wc,
    sum(ss_sales_price) ss_sp
   from store_sales
   left join store_returns on sr_ticket_number=ss_ticket_number and ss_item_sk=sr_item_sk
   join date_dim on ss_sold_date_sk = d_date_sk
   where sr_ticket_number is null
   group by d_year, ss_item_sk, ss_customer_sk
   )
 select 
ss_sold_year, ss_item_sk, ss_customer_sk,
round(ss_qty/(coalesce(ws_qty,0)+coalesce(cs_qty,0)),2) ratio,
round(ss_qty/(coalesce(ws_qty+cs_qty,1)),2) rs,
ss_qty store_qty, ss_wc store_wholesale_cost, ss_sp store_sales_price,
coalesce(ws_qty,0)+coalesce(cs_qty,0) other_chan_qty,
coalesce(ws_wc,0)+coalesce(cs_wc,0) other_chan_wholesale_cost,
coalesce(ws_sp,0)+coalesce(cs_sp,0) other_chan_sales_price
from ss
left join ws on (ws_sold_year=ss_sold_year and ws_item_sk=ss_item_sk and ws_customer_sk=ss_customer_sk)
left join cs on (cs_sold_year=ss_sold_year and cs_item_sk=ss_item_sk and cs_customer_sk=ss_customer_sk)
where (coalesce(ws_qty,0)>0 or coalesce(cs_qty, 0)>0) and ss_sold_year=2000
order by 
  ss_sold_year, ss_item_sk, ss_customer_sk,
  store_qty desc, store_wholesale_cost desc, store_sales_price desc,
  other_chan_qty,
  other_chan_wholesale_cost,
  other_chan_sales_price,
  rs
limit 100;

-- query79

select 
  c_last_name,c_first_name,substr(s_city,1,30) sub,ss_ticket_number,amt,profit
  from
   (select ss_ticket_number
          ,ss_customer_sk
          ,store.s_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (household_demographics.hd_dep_count = 8 or household_demographics.hd_vehicle_count > 0)
    and date_dim.d_dow = 1
    and date_dim.d_year in (1998,1998+1,1998+2) 
    and store.s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,store.s_city) ms,customer
    where ms.ss_customer_sk = customer.c_customer_sk
 order by c_last_name,c_first_name,sub, profit
limit 100;

-- query80

with ssr as
 (select  s_store_id as store_id,
          sum(ss_ext_sales_price) as sales,
          sum(coalesce(sr_return_amt, 0)) as returns,
          sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
  from store_sales left outer join store_returns on
         (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
     date_dim,
     store,
     item,
     promotion
 where ss_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date) 
                  and (cast('1998-09-04' as date))
       and ss_store_sk = s_store_sk
       and ss_item_sk = i_item_sk
       and i_current_price > 50
       and ss_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
 group by s_store_id)
 ,
 csr as
 (select  cp_catalog_page_id as catalog_page_id,
          sum(cs_ext_sales_price) as sales,
          sum(coalesce(cr_return_amount, 0)) as returns,
          sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
  from catalog_sales left outer join catalog_returns on
         (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
     date_dim,
     catalog_page,
     item,
     promotion
 where cs_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-09-04' as date))
        and cs_catalog_page_sk = cp_catalog_page_sk
       and cs_item_sk = i_item_sk
       and i_current_price > 50
       and cs_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by cp_catalog_page_id)
 ,
 wsr as
 (select  web_site_id,
          sum(ws_ext_sales_price) as sales,
          sum(coalesce(wr_return_amt, 0)) as returns,
          sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
  from web_sales left outer join web_returns on
         (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
     date_dim,
     web_site,
     item,
     promotion
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-09-04' as date))
        and ws_web_site_sk = web_site_sk
       and ws_item_sk = i_item_sk
       and i_current_price > 50
       and ws_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by web_site_id)
  select  channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , concat('store', store_id) as id
        , sales
        , returns
        , profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , concat('catalog_page', catalog_page_id) as id
        , sales
        , returns
        , profit
 from  csr
 union all
 select 'web channel' as channel
        , concat('web_site', web_site_id) as id
        , sales
        , returns
        , profit
 from   wsr
 ) x
 group by channel, id with rollup
 order by channel
         ,id
 limit 100;

-- query82

select  i_item_id
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 30 and 30+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between cast('2002-05-30' as date) and date_add('2002-05-30',60)
 and i_manufact_id in (437,129,727,663)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;

-- query84

select  c_customer_id as customer_id
       , concat(coalesce(c_last_name,'') , ', ', coalesce(c_first_name,'')) as customername
 from customer
     ,customer_address
     ,customer_demographics
     ,household_demographics
     ,income_band
     ,store_returns
 where ca_city          =  'Hopewell'
   and c_current_addr_sk = ca_address_sk
   and ib_lower_bound   >=  32287
   and ib_upper_bound   <=  32287 + 50000
   and ib_income_band_sk = hd_income_band_sk
   and cd_demo_sk = c_current_cdemo_sk
   and hd_demo_sk = c_current_hdemo_sk
   and sr_cdemo_sk = cd_demo_sk
 order by customer_id
 limit 100;

-- query85

select  substr(r_reason_desc,1,20) as r
       ,avg(ws_quantity) as ws
       ,avg(wr_refunded_cash) as wr
       ,avg(wr_fee) as wrf
 from web_sales, web_returns, web_page, customer_demographics cd1,
      customer_demographics cd2, customer_address, date_dim, reason
 where ws_web_page_sk = wp_web_page_sk
   and ws_item_sk = wr_item_sk
   and ws_order_number = wr_order_number
   and ws_sold_date_sk = d_date_sk and d_year = 1998
   and cd1.cd_demo_sk = wr_refunded_cdemo_sk
   and cd2.cd_demo_sk = wr_returning_cdemo_sk
   and ca_address_sk = wr_refunded_addr_sk
   and r_reason_sk = wr_reason_sk
   and
   (
    (
     cd1.cd_marital_status = 'M'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = '4 yr Degree'
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 100.00 and 150.00
    )
   or
    (
     cd1.cd_marital_status = 'D'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Primary'
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 50.00 and 100.00
    )
   or
    (
     cd1.cd_marital_status = 'U'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Advanced Degree'
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 150.00 and 200.00
    )
   )
   and
   (
    (
     ca_country = 'United States'
     and
     ca_state in ('KY', 'GA', 'NM')
     and ws_net_profit between 100 and 200
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('MT', 'OR', 'IN')
     and ws_net_profit between 150 and 300
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('WI', 'MO', 'WV')
     and ws_net_profit between 50 and 250
    )
   )
group by r_reason_desc
order by r
        ,ws
        ,wr
        ,wrf
limit 100;

-- query88

select  *
from
 (select count(*) h8_30_to_9
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk   
     and ss_hdemo_sk = household_demographics.hd_demo_sk 
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2)) 
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 9 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10 
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk 
     and time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales, household_demographics , time_dim, store
 where ss_sold_time_sk = time_dim.t_time_sk
     and ss_hdemo_sk = household_demographics.hd_demo_sk
     and ss_store_sk = s_store_sk
     and time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s8
;

-- query89

select  *
from(
select i_category, i_class, i_brand,
       s_store_name, s_company_name,
       d_moy,
       sum(ss_sales_price) sum_sales,
       avg(sum(ss_sales_price)) over
         (partition by i_category, i_brand, s_store_name, s_company_name)
         avg_monthly_sales
from item, store_sales, date_dim, store
where ss_item_sk = i_item_sk and
      ss_sold_date_sk = d_date_sk and
      ss_store_sk = s_store_sk and
      d_year in (2000) and
        ((i_category in ('Home','Books','Electronics') and
          i_class in ('wallpaper','parenting','musical')
         )
      or (i_category in ('Shoes','Jewelry','Men') and
          i_class in ('womens','birdal','pants') 
        ))
group by i_category, i_class, i_brand,
         s_store_name, s_company_name, d_moy) tmp1
where case when (avg_monthly_sales <> 0) then (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales) else null end > 0.1
order by sum_sales - avg_monthly_sales, s_store_name
limit 100;

-- query90

select  cast(amc as decimal(15,4))/cast(pmc as decimal(15,4)) am_pm_ratio
 from ( select count(*) amc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 6 and 6+1
         and household_demographics.hd_dep_count = 8
         and web_page.wp_char_count between 5000 and 5200) at,
      ( select count(*) pmc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 14 and 14+1
         and household_demographics.hd_dep_count = 8
         and web_page.wp_char_count between 5000 and 5200) pt
 order by am_pm_ratio
 limit 100;

-- query91

select
        cc_call_center_id Call_Center,
        cc_name Call_Center_Name,
        cc_manager Manager,
        sum(cr_net_loss) Returns_Loss
from
        call_center,
        catalog_returns,
        date_dim,
        customer,
        customer_address,
        customer_demographics,
        household_demographics
where
        cr_call_center_sk       = cc_call_center_sk
and     cr_returned_date_sk     = d_date_sk
and     cr_returning_customer_sk= c_customer_sk
and     cd_demo_sk              = c_current_cdemo_sk
and     hd_demo_sk              = c_current_hdemo_sk
and     ca_address_sk           = c_current_addr_sk
and     d_year                  = 1999
and     d_moy                   = 11
and     ( (cd_marital_status       = 'M' and cd_education_status     = 'Unknown')
        or(cd_marital_status       = 'W' and cd_education_status     = 'Advanced Degree'))
and     hd_buy_potential like '0-500%'
and     ca_gmt_offset           = -7
group by cc_call_center_id,cc_name,cc_manager,cd_marital_status,cd_education_status
order by Returns_Loss desc;

-- query93

select  ss_customer_sk
            ,sum(act_sales) sumsales
      from (select ss_item_sk
                  ,ss_ticket_number
                  ,ss_customer_sk
                  ,case when sr_return_quantity is not null then (ss_quantity-sr_return_quantity)*ss_sales_price
                                                            else (ss_quantity*ss_sales_price) end act_sales
            from store_sales left outer join store_returns on (sr_item_sk = ss_item_sk
                                                               and sr_ticket_number = ss_ticket_number)
                ,reason
            where sr_reason_sk = r_reason_sk
              and r_reason_desc = 'Did not like the warranty') t
      group by ss_customer_sk
      order by sumsales, ss_customer_sk
limit 100;

-- query96

select  count(*) as c
from store_sales
    ,household_demographics
    ,time_dim, store
where ss_sold_time_sk = time_dim.t_time_sk
    and ss_hdemo_sk = household_demographics.hd_demo_sk
    and ss_store_sk = s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and household_demographics.hd_dep_count = 5
    and store.s_store_name = 'ese'
order by c
limit 100;

-- query97

with ssci as (
select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales,date_dim
where ss_sold_date_sk = d_date_sk
  and d_month_seq between 1212 and 1212 + 11
group by ss_customer_sk
        ,ss_item_sk),
csci as(
 select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales,date_dim
where cs_sold_date_sk = d_date_sk
  and d_month_seq between 1212 and 1212 + 11
group by cs_bill_customer_sk
        ,cs_item_sk)
 select  sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only
      ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from ssci full outer join csci on (ssci.customer_sk=csci.customer_sk
                               and ssci.item_sk = csci.item_sk)
limit 100;

-- query98

select i_item_id
      ,i_item_desc
      ,i_category
      ,i_class
      ,i_current_price
      ,sum(ss_ext_sales_price) as itemrevenue
      ,sum(ss_ext_sales_price)*100/sum(sum(ss_ext_sales_price)) over
          (partition by i_class) as revenueratio
from
        store_sales
        ,item
        ,date_dim
where
        ss_item_sk = i_item_sk
        and i_category in ('Jewelry', 'Sports', 'Books')
        and ss_sold_date_sk = d_date_sk
        and d_date between cast('2001-01-12' as date) and date_add('2001-01-12',30)
group by
        i_item_id
        ,i_item_desc
        ,i_category
        ,i_class
        ,i_current_price
order by
        i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio;

-- query99

select
   substr(w_warehouse_name,1,20) as w
  ,sm_type
  ,cc_name
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk <= 30 ) then 1 else 0 end)  as 30_days
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 30) and
                 (cs_ship_date_sk - cs_sold_date_sk <= 60) then 1 else 0 end )  as 31_60_days
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 60) and
                 (cs_ship_date_sk - cs_sold_date_sk <= 90) then 1 else 0 end)  as 61_90_days
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk > 90) and
                 (cs_ship_date_sk - cs_sold_date_sk <= 120) then 1 else 0 end)  as 91_120_days
  ,sum(case when (cs_ship_date_sk - cs_sold_date_sk  > 120) then 1 else 0 end)  as 120_days
from
   catalog_sales
  ,warehouse
  ,ship_mode
  ,call_center
  ,date_dim
where
    d_month_seq between 1212 and 1212 + 11
and cs_ship_date_sk   = d_date_sk
and cs_warehouse_sk   = w_warehouse_sk
and cs_ship_mode_sk   = sm_ship_mode_sk
and cs_call_center_sk = cc_call_center_sk
group by
   substr(w_warehouse_name,1,20)
  ,sm_type
  ,cc_name
order by w
        ,sm_type
        ,cc_name
limit 100;

