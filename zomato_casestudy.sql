drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users


----1 what is the total amount each customer spent on zomato?
select s.userid, sum(p.price) as total_amount from sales s
inner join  product p
on p.product_id =s.product_id
group by userid

--2-howmany days has each customer visited zomato?
select userid,count(distinct created_date)  as most_visit from sales
group by userid

--3-what was   the first product purchase by each customer 

select * from
(select *,rank() over(partition by userid order by created_date) as rnk
from sales) A 
where rnk = 1

---4 what is the most purchased item on the menu and howmany time was  it purchased by all customers?
select s.userid, count(product_id) as most_purchased_item
from sales s
where product_id =( 
select top 1 product_id from sales group by product_id
order by count(product_id) desc)
group by userid

select * from product


---5.which item was purchased first by the customer after they became a member?
select * from
(select c.*,rank() over(partition by userid order by created_date desc)  rnk from
(select s.userid,s.created_date,s.product_id, g.gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date <= gold_signup_date) c)d where rnk = 1



select * from sales;
select * from product;
select * from goldusers_signup;
select * from users

----what is the total order and amount spent for each member before they became a member?
---total order by created_date
----total amount
--before member

---why is itwrong 1 st one

select  s.userid,count(created_date ) as order_purchased,sum(p.price)  as total_amount
from sales s
inner join product p
on s.product_id = p.product_id
inner join goldusers_signup g
on s.userid= g.userid
where created_date != gold_signup_date
group by s.userid

select  userid,count(created_date ) as order_purchased,sum(price)  as total_amount from
(select c.*,d.price from
(select s.userid,s.created_date,s.product_id, g.gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date <= gold_signup_date) c inner join product d 
on c.product_id = d.product_id)e
group by userid



---9 if buying each product generates points for eg 5rs=2 zomato point and each product has different
---points for ie  p1 5rs= 1 zomato point , for p2 10 rs = 5 zomato point and p3 5 rs= 1 zomato point
--calculate points collected by each customers and for which product most points have been given till now 



select userid, sum(total_points)*2.5 as points_money_earned from 
(select e.*, total_amount/points  total_points from
(select d.*,case when product_id= 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 
end as points from
(select c.userid,c.product_id,sum(price) total_amount from 
(
select s.*,p.price
from sales s 
inner join product p
on s.product_id= p.product_id) c
group by userid,product_id)d)e)f
group by userid;



-----9---which product most points have been given till now 

select * from
(select *, rank() over (order by points_earned desc) rnk from
(select product_id, sum(total_points) as points_earned from 
(select e.*, total_amount/points  total_points from
(select d.*,case when product_id= 1 then 5 when product_id = 2 then 2 when product_id = 3 then 5 else 0 
end as points from
(select c.userid,c.product_id,sum(price) total_amount from 
(
select s.*,p.price
from sales s 
inner join product p
on s.product_id= p.product_id) c
group by userid,product_id)d)e)f
group by product_id)f)g where rnk = 1;



---10 in the first one year after a customer joins the gold program (including their join date ) irrespective 
--of what the customer has purchased they earn 5 zomato point for every 10rs spent who earned more 1 or 3
---and what was their points earning in their 1 st year ?


select c.*,p.price*0.5 total_points_earned from
(select s.userid,s.created_date,s.product_id, g.gold_signup_date
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and created_date >= gold_signup_date and created_date<=DATEADD(year,1,gold_signup_date))c
inner join product p on c.product_id = p.product_id




----11.rnk all the transaction of the customers

select s.*, rank() over(partition by userid order by created_date ) rnk from sales s


----12.rank all the transaction for each member whhenever they are a zomato gold meber for every non gold member  transaction mark as 

select e.*,case when rnk= 0 then 'na' else rnk end as rnkk from
(select c.*, cast((case when gold_signup_date is null then 0 else rank() 
over(partition by userid order by  created_date desc) end) as varchar) as rnk from
(select s.userid,s.created_date,s.product_id, g.gold_signup_date
from sales s
left join goldusers_signup g
on s.userid = g.userid
and created_date >= gold_signup_date) c )e;