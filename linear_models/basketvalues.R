library(dplyr); library(dbplyr); library(ggplot2);

conn <- dbConnect(odbc::odbc(), "fagroup-prod", bigint = "integer")

transactions <- conn %>%
  tbl(in_schema('publish', 'transactions_online'))

top_brands <-
  transactions %>%
  filter(!nonretail) %>%
  group_by(brand) %>%
  summarise(n=sum(unitssold)) %>%
  arrange(desc(n)) %>%
  filter(row_number() <= 10) %>%
  collect()

orders <- transactions %>%
  filter(orderdate >= '2020-06-01') %>%
  filter(!nonretail, !bin_returned) %>%
  group_by(salesordernumber) %>%
  summarise(basketsize = sum(unitssold),
            basketvalue = sum(grosssales),
            discount = sql("sum(case when bin_discount then 1 else 0 end) > 0"),
            clearance =sql("sum(case when bin_clearance then 1 else 0 end) > 0"),
            division = sql("listagg(distinct(division),'_') within group (order by division)"),
            brand = case_when(any(brand == 'nike') ~ 'nike',
                              any(brand == 'adidas') ~ 'adidas',
                              any(brand == 'kings will dream') ~ 'kings will dream',
                              any(brand == 'vans') ~ 'vans',
                              any(brand == 'the north face') ~ 'the north face',
                              any(brand == 'puma') ~ 'puma',
                              T ~ 'other')) %>%
  collect()

ggplot(orders, aes(x = basketsize, y = basketvalue)) +
  geom_point(alpha = 0.1)

model <- lm(basketvalue ~ basketsize + discount + clearance + brand + division, orders)
summary(model)

basketsize <- c(1,2,3)
discount <- c('1','0','1')
clearance <- c('0','0','0')
division <- c('apparel', 'footwear','footwear')
brand <- c('nike', 'adidas','the north face')

df <- data.frame(basketsize, discount, clearance, brand, division)

predict(model, newdata =df)
